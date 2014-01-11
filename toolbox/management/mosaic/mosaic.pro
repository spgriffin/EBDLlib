PRO mosaic, workspace_in, workspace_out_mosaic, workspace_out_resample, prefix_in,prefix_out,file_extension,pixel_size,band_pos,fill_value,data_type , start_year, end_year
  ENVI, /restore_base_save_files
  ENVI_BATCH_INIT, log_file = 'batch.txt', /NO_STATUS_WINDOW
  tiff_extension='.tif'
  ;the spatial resolution for MODIS land surface product
  ;start the year loop
  FOR iyear = start_year, end_year, 1 DO BEGIN
    year_str = STRING(iyear, format = '(i04)')
    year_in = workspace_in+!backslash+year_str
    year_out1 = workspace_out_mosaic +!backslash+year_str
    year_out2 = workspace_out_resample + !backslash + year_str
    IF(FILE_TEST(year_out1) NE 1)THEN BEGIN
      FILE_MKDIR, year_out1
    ENDIF
    IF(FILE_TEST(year_out2) NE 1)THEN BEGIN
      FILE_MKDIR,  year_out2
    ENDIF
    for day = 0, 382, 1 do begin
      day_str = string(day, foramt = '(i03)')
      ;have to adjust to make sense for the folder to get, usually the folder could be 2001.01.01 like MODIS GPP
      ;but one option is to convert the data or rearrange the data directory  before mosaic.
      folder_in=year_in + !backslash +day_str
      filename_regex = prefix_in+year_str+'*'+file_extension
      match_files = FILE_SEARCH(folder_in, filename_regex, /FULLY_QUALIFY_PATH, COUNT = file_count)
      fid_in = LON64ARR(file_count)
      pos = LON64ARR(1, file_count)
      use_see_through = INTARR(file_count)
      see_through_val = FLTARR(file_count)
      FOR f = 0, file_count-1, 1 DO BEGIN
        ENVI_OPEN_FILE, match_files[f], r_fid = fid
        IF (fid EQ -1) THEN BEGIN
          CONTINUE
        ENDIF ELSE BEGIN
          fid_in[f] = fid
          pos[*, f] = band_pos
          use_see_through[f] = 1
          see_through_val[f] = fill_value
        ENDELSE
      ENDFOR                  ;mosaicing loop
      filename_out1 = year_out1+!backslash+prefix_out+year_str+day_str+tiff_extension
      georef_mosaic_setup, fids = fid_in, out_ps = pixel_size, dims = dims, xsize = xsize, ysize = ysize, $
        x0 = x0, y0 = y0, map_info = map_info
      ;Start mosaic the images
      ENVI_DOIT, 'mosaic_doit', DIMS = dims, FID = fid_in, $
        OUT_DT = data_type, OUT_NAME = filename_out1, PIXEL_SIZE = pixel_size, $
        POS = pos, background = fill_value, $
        XSIZE = xsize, YSIZE = ysize, X0 = x0, Y0 = y0, $
        SEE_THROUGH_VAL = see_through_val, $
        USE_SEE_THROUGH = use_see_through, $
        R_FID = r_fid, $
        MAP_INFO = map_info, /GEOREF     
      ENVI_FILE_MNG, id = fid_in, /remove
      ENVI_FILE_MNG, id = r_fid, /remove
    endfor
  ENDFOR
  PRINT, 'Finished'
  ENVI_BATCH_EXIT
END
