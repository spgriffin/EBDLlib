;+
; :description:
;   extract point data from remote sensing dataset
;
;
;
;
;
; :author: chang liao
;-
PRO extract_point_binary,   workspace_in, workspace_out,  start_year, end_year, point_code, longitude, latitude, prefix_in,prefix_out, fill_value, data_type, col_count, row_count,cellsize
  COMPILE_OPT idl2
  
  ; parameters
  
  delimiter = ' '
  binary_extension = '.flt'
  text_extension='.txt'
  
  ;controls
  year_count = end_year-start_year+1
  ;files
  DATA_DIMS=[col_count, row_count]
  grid_size = 0
  ;loop
  
  CASE data_type OF
    1: BEGIN
      timeseries_data=MAKE_ARRAY(1,year_count,/float,value=!values.F_NAN)
      start_index=0
      end_index=0
      interval=1
      data_count=1
    END
    2: BEGIN
      timeseries_data=MAKE_ARRAY(4,year_count,/float,value=!values.F_NAN)
      start_index=367
      end_index=370
      interval=1
      data_count=4
    END
    3: BEGIN
      timeseries_data=MAKE_ARRAY(12,year_count,/float,value=!values.F_NAN)
      start_index=371
      end_index=382
      interval=1
      data_count=12
    END
    4: BEGIN
      timeseries_data=MAKE_ARRAY(46,year_count,/float,value=!values.F_NAN)
      start_index=1
      end_index=365
      interval=8
      data_count=46
    END
    5: BEGIN
      timeseries_data=MAKE_ARRAY(365,year_count,/float,value=!values.F_NAN)
      start_index=1
      end_index=365
      interval=1
      data_count=365
    END
    ELSE: PRINT, 'Not one through four'
  ENDCASE
  FOR i = 0, N_ELEMENTS(point_code)-1, 1 DO BEGIN
    lon = longitude[i]
    lat = latitude[i]
    point_id = STRING( point_code[i],format = '(i05)')
    timeseries_data=MAKE_ARRAY(data_count,year_count,/float,value=!values.F_NAN)
    FOR year = start_year, end_year, 1 DO BEGIN
      year_str = STRING(year, format = '(i04)')
      year_in = workspace_in + !backslash + year_str
      year_data=MAKE_ARRAY(data_count,/float,value=!values.F_NAN)
      FOR ind = start_index, end_index,interval DO BEGIN
        ind_str=  STRING(ind,format='(i03)')
        file_in = year_in+!backslash+ prefix_in +year_str+ind_str +binary_extension
        OPENR,  lun,  file_in,  /get_lun
        matrix=read_binary(lun, data_type = 4,  DATA_DIMS=DATA_DIMS)
        FREE_LUN,lun
        nan_index=WHERE(matrix EQ -9999, nan_count)
        IF(nan_count GT 0)THEN BEGIN
          matrix[nan_index]=!values.F_NAN
        ENDIF
        nan_index = WHERE(matrix GE fill_value, nan_count)
        IF(nan_count GE 1) THEN BEGIN
          matrix[nan_index] = !values.F_NAN
        ENDIF
        xl= FLOOR((lon+180.0)/cellsize)
        xr= CEIL((lon+180.0)/cellsize)
        yt= FLOOR((90.0-lat)/cellsize)
        yb= CEIL((90.0-lat)/cellsize)
        data_region=matrix[xl:xr,yt:yb]
        sample_mean=mean(data_region,/nan)
        IF(FINITE(sample_mean) EQ 1)THEN BEGIN
          year_data[(ind-start_index)/interval] = sample_mean
        ENDIF ELSE BEGIN
          FOR win=1,15,1 DO BEGIN
            data_region=matrix[(xl-win):(xr+win),(yt-win):(yb+win)]
            sample_mean=mean(data_region,/nan)
            IF(FINITE(sample_mean) EQ 1)THEN BEGIN
              year_data[(ind-start_index)/interval] = sample_mean
              BREAK
            ENDIF
          ENDFOR
        ENDELSE
      ENDFOR
      timeseries_data[*,year-start_year] =  gap_fill_quadratic(year_data)
    ENDFOR
    file_out = workspace_out+!backslash+prefix_out+point_id+binary_extension
    OPENW, lun, file_out, /get_lun                  ;end year loop
    WRITEU, lun, timeseries_data
    FREE_LUN, lun
    file_out = workspace_out + !backslash + prefix_out + point_id+ text_extension
    OPENW,lun, file_out,width=1000,/get_lun
    PRINTF,lun, timeseries_data
    FREE_LUN,lun
    
  ENDFOR
END
