

;本函数用于将hdf文件转换为ArcGIS binary文件
;%针对modis大气产品，由于大气产品为swath结构，数据行列的cellsize不相等
;%因此操作过程中会根据影像数据的最大，最小边界生成一个规则格网的数据
;%生成规则格网的方法为nearest
;
;% 几点说明：
;% Cloud_Optical_Thickness 分辨率与经纬度不一致，经纬度为5KM，云厚度为1KM需要重采样
;% Corrected_Optical_Depth_Land 光学厚度 为三维数组，需要重采样
;% 所以规定 MOD04 的iMOD==4，MOD05的iMOD=5 ， MOD07 为 7
;%  MOD06中Cloud_Top_Pressure_Day 为61，Cloud_Optical_Thickness 为 62
;%   其中  4 和 62 需要特殊处理


PRO hdf2binary_modis_atmosphere,in_path,out_path,startyear,endyear,search_specification,$
    iMOD,field,cellsize,prefix
    
  fltfileSuffix='.flt'
  hdrfileSuffix='.hdr'
  hdffileSuffix='.hdf'
  path_backslash='\'
  
  time_folders=['mod','myd']
  FOR year=startyear,endyear,1 DO BEGIN
    ;path operation
    year_str=STRTRIM(STRING(year),2)
    year_in=in_path+path_backslash+year_str
    year_out=out_path+path_backslash+year_str
    ;Start folder loop
    FOR findex=0,SIZE(time_folders,/N_ELEMENTS)-1,1 DO BEGIN
      folder_in=year_in+path_backslash+time_folders[findex]
      folder_out=year_out+path_backslash+time_folders[findex]
      ;Create output folder
      IF (FILE_TEST(folder_out) NE 1) THEN BEGIN
        FILE_MKDIR,folder_out
      ENDIF
      FOR day=1,365,1 DO BEGIN
        day_str=STRING(day,FORMAT='(I03)')
        hdrfileSearch='*'+search_specification+year_str+day_str+'*'+hdffileSuffix
        hdf_files=FILE_SEARCH(folder_in,hdrfileSearch,/FULLY_QUALIFY_PATH,COUNT=hdf_count)
        IF(hdf_count GE 1 ) THEN BEGIN
          FOR i=0,hdf_count-1,1 DO BEGIN
            i_str=STRTRIM(STRING(i),2)
            filename= FILE_BASENAME(hdf_files[i],hdffileSuffix)
            lon_data = hdfreader(hdf_files[i], 'Longitude')
            lat_data = hdfreader(hdf_files[i], 'Latitude')
            val = hdfreader(hdf_files[i], field)
            ;Confirm the dataset validation
            nanindex=WHERE(FINITE(val) EQ 0 ,nancount);
            IF(nancount LT N_ELEMENTS(val) )  THEN BEGIN
              ;Retrive the dimension infomation of the dataset
              dim=SIZE(val)
              ;Reform the matrix into a vector
              vector=REFORM(val,1,dim[4])
              ;retrive the mean of the data.
              mean=mean(vector,/NAN)
              CASE iMOD OF
                4: BEGIN  ;Aerosol Type
                  CASE dim[0] OF
                    2:BEGIN
                  ;
                  ;                  temp=FLTARR(dim[1]*2,dim[2]*2)
                  ;                  FOR c=0,dim[1]*2-1,1 DO BEGIN
                  ;                    FOR r=0,dim[2]*2-1,1 DO BEGIN
                  ;                      temp[c,r]=val[FLOOR(c/2.0+0.5),FLOOR(r/2.0+0.5)]
                  ;                    ENDFOR
                  ;                  ENDFOR
                  ;                  val=temp
                  END
                  3:BEGIN
                END
              ENDCASE
            END
            5:BEGIN
            IF(nancount GE 1)THEN BEGIN
              val[nanindex]=mean
            ENDIF
          END
          62: BEGIN
          ;PRINT, 'one'
          END
          ELSE: BEGIN
          ;PRINT, 'Please enter a value iMOD'
          END
        ENDCASE
        ;Then resample the longitude and latitude dataset
        ;reference to modis_pro
        origin_col=(SIZE(lon_data,/DIMENSIONS))[0]
        origin_row=(SIZE(lon_data,/DIMENSIONS))[1]
        
        ;The former process for lon and lat,
        ;since it has not taken the abnormal data into consideration, then it was replaced by later code.
        ;      lon_min=MIN(lon_data)
        ;      lon_max=MAX(lon_data)
        ;      lat_min=MIN(lat_data)
        ;      lat_max=MAX(lat_data)
        ;      col=FLOOR(ABS((lon_max-lon_min))/cellsize)
        ;      row=FLOOR(ABS((lat_max-lat_min))/cellsize)
        ;      left=lon_data[0,*]
        ;      right=lon_data[origin_col-1,*]
        ;      top=lat_data[*,0]
        ;      bot=lat_data[*,origin_row-1]
        ;      left=lon_data
        ;      right=lon_data
        ;      top=lat_data
        ;      bot=lat_data
        ; IF (mor_or_after EQ 0) THEN BEGIN
        ;        lon_left=MIN(lon_data(WHERE(FINITE(lon_data) NE 0 AND lon_data GE (mean_lon-threshold_lon) )))
        ;        lon_right=MAX(lon_data(WHERE(FINITE(lon_data) NE 0 AND lon_data LE (mean_lon+threshold_lon))))
        ;        lat_top=MAX(lat_data(WHERE(FINITE(lat_data) NE 0 AND lat_data LE (mean_lat+threshold_lat))))
        ;        lat_bot=MIN(lat_data(WHERE(FINITE(lat_data) NE 0 AND lat_data GE (mean_lat-threshold_lat))))
        ;        IF(lon_right LT 0)THEN BEGIN
        ;          lon_left= (-1) * (180 - lon_left)
        ;          lon_right=  (180 + lon_right)
        ;        ENDIF
        ;      ENDIF ELSE BEGIN
        ;        lon_left=MAX(left(WHERE(FINITE(left) NE 0 AND left LE (mean_lon+threshold_lon))))
        ;        lon_right=MIN(right(WHERE(FINITE(right) NE 0 AND right GE (mean_lon-threshold_lon))))
        ;        lat_top=MIN(top(WHERE(FINITE(top) NE 0 AND top GE (mean_lat-threshold_lat))))
        ;        lat_bot=MAX(bot(WHERE(FINITE(bot) NE 0 AND bot LE (mean_lat+threshold_lat))))
        ;        IF(lon_left LT 0 )THEN BEGIN
        ;          lon_left= (-1) *(180+ lon_left)
        ;        ENDIF
        ;      ENDELSE
        
        left=lon_data[0:(origin_col*0.25-1),*]
        right=lon_data[(origin_col*0.75+1):(origin_col-1),*]
        top=lat_data[*,0:(origin_row*0.25-1)]
        bot=lat_data[*,(origin_row*0.75-1):(origin_row-1)]
        flag=0
        IF (findex EQ 0) THEN BEGIN
          lon_left=MIN(left,/Nan)
          lon_right1=MAX(right,/Nan)
          lon_right2=MIN(right,/Nan)
          lat_top=MAX(top,/Nan)
          lat_bot=MIN(bot,/Nan)
          IF(ABS(lon_right1-lon_right2) GE 300 )THEN BEGIN
            lon_left= (-1) * (180 - lon_left)
            lon_right=  180 + MAX(right(WHERE(right LT 0)))
          ENDIF ELSE BEGIN
            lon_right=lon_right1
            if(lon_left ge lon_right) then begin
              flag=1
              lon_left1=MAX(left,/Nan)
              lon_left2=MIN(left,/Nan)
              lon_right=MIN(right,/Nan)
              lat_top=MIN(top,/Nan)
              lat_bot=MAX(bot,/Nan)
              IF(ABS(lon_left1 - lon_left2) GE 300 )THEN BEGIN
                lon_left= (-1) * (180+ MAX(left(WHERE(left LT 0))))
                lon_right=180 - lon_right
              ENDIF ELSE BEGIN
                lon_left=lon_left1
              ENDELSE
            endif
          ENDELSE
        ENDIF ELSE BEGIN
          lon_left1=MAX(left,/Nan)
          lon_left2=MIN(left,/Nan)
          lon_right=MIN(right,/Nan)
          lat_top=MIN(top,/Nan)
          lat_bot=MAX(bot,/Nan)
          IF(ABS(lon_left1 - lon_left2) GE 300 )THEN BEGIN
            lon_left= (-1) * (180+ MAX(left(WHERE(left LT 0))))
            lon_right=180 - lon_right
          ENDIF ELSE BEGIN
            lon_left=lon_left1
            if(lon_left le lon_right)then begin
              flag=1
              lon_left=MIN(left,/Nan)
              lon_right1=MAX(right,/Nan)
              lon_right2=MIN(right,/Nan)
              lat_top=MAX(top,/Nan)
              lat_bot=MIN(bot,/Nan)
              IF(ABS(lon_right1-lon_right2) GE 300 )THEN BEGIN
                lon_left= (-1) * (180 - lon_left)
                lon_right=  180 + MAX(right(WHERE(right LT 0)))
              ENDIF ELSE BEGIN
                lon_right=lon_right1
              ENDELSE
            endif
          ENDELSE
        ENDELSE
        
        ;If all dataset are invalid, then quit
        IF(FINITE(lon_left) EQ 0 OR FINITE(lon_right) EQ 0 $
          OR FINITE(lat_top) EQ 0 OR FINITE(lat_bot) EQ 0 )THEN BEGIN
          CONTINUE
        ENDIF
        ;Calculate the new col and row
        col=FLOOR(ABS((lon_left-lon_right))/cellsize)
        row=FLOOR(ABS((lat_top-lat_bot))/cellsize)
        ;Resample the lat and lon
        expand,lon_data,col,row,resample_col,fillval=-180,MAXVAL=180
        expand,lat_data,col,row,resample_row,fillval=-180,MAXVAL=180
        
        ;        if(col gt 10)then begin
        ;          flag=0
        ;          expand,lon_data,col,row,resample_col,fillval=-180,MAXVAL=180
        ;          expand,lat_data,col,row,resample_row,fillval=-180,MAXVAL=180
        ;        endif else begin
        ;          flag=1
        ;          IF (findex EQ 0) THEN BEGIN
        ;            lon_left1=MAX(left,/Nan)
        ;            lon_left2=MIN(left,/Nan)
        ;            lon_right=MIN(right,/Nan)
        ;            lat_top=MIN(top,/Nan)
        ;            lat_bot=MAX(bot,/Nan)
        ;            IF(ABS(lon_left1 - lon_left2) GE 300 )THEN BEGIN
        ;              lon_left= (-1) * (180+ MAX(left(WHERE(left LT 0))))
        ;              lon_right=180 - lon_right
        ;            ENDIF ELSE BEGIN
        ;              lon_left=lon_left1
        ;            ENDELSE
        ;          ENDIF ELSE BEGIN
        ;            lon_left=MIN(left,/Nan)
        ;            lon_right1=MAX(right,/Nan)
        ;            lon_right2=MIN(right,/Nan)
        ;            lat_top=MAX(top,/Nan)
        ;            lat_bot=MIN(bot,/Nan)
        ;            IF(ABS(lon_right1-lon_right2) GE 300 )THEN BEGIN
        ;              lon_left= (-1) * (180 - lon_left)
        ;              lon_right=  180 + MAX(right(WHERE(right LT 0)))
        ;            ENDIF ELSE BEGIN
        ;              lon_right=lon_right1
        ;            ENDELSE
        ;          ENDELSE
        ;          col=FLOOR(ABS((lon_left-lon_right))/cellsize)
        ;          row=FLOOR(ABS((lat_top-lat_bot))/cellsize)
        ;          expand,lon_data,col,row,resample_col,fillval=-180,MAXVAL=180
        ;          expand,lat_data,col,row,resample_row,fillval=-180,MAXVAL=180
        ;        endelse
        
        
        
        ;resample the dataset accoding to the new col and row count
        resample_data=FLOAT(congrid(val,col,row))
        ;Reset the NAN data into -9999
        nanindex=WHERE(FINITE(resample_data) EQ 0,count)
        IF(count GE 1)THEN BEGIN
          resample_data[nanindex]=-9999.0
        ENDIF
        IF(findex ne flag )THEN BEGIN
          resample_col=ROTATE(resample_col,2)
          resample_row=ROTATE(resample_row,2)
          resample_data=ROTATE(resample_data,2)
        ENDIF
        
        
        ;sava the dataset into float
        out_flt_file=folder_out+path_backslash+prefix+year_str+day_str+i_str+fltfileSuffix
        OPENW,lun,out_flt_file,/get_lun
        WRITEU,lun,resample_data
        FREE_LUN, lun
        ;save the head infomation into hdr
        out_hdr_file=folder_out+path_backslash+prefix+year_str+day_str+i_str+hdrfileSuffix
        OPENW,lun,out_hdr_file,/get_lun
        PRINTF,lun,'ncols ',col
        PRINTF,lun,'nrows ',row
        PRINTF,lun,'xllcorner ',resample_col[0,row-1]
        PRINTF,lun,'yllcorner ', resample_row[0,row-1]
        PRINTF,lun,'cellsize ',cellsize
        PRINTF,lun,'NODATA_value ',-9999
        PRINTF,lun,'byteorder','    LSBFIRST'
        FREE_LUN, lun
        
      ENDIF
    ENDFOR
  ENDIF
ENDFOR
ENDFOR
ENDFOR
END