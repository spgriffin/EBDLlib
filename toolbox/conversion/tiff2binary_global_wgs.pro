;+
; :description:
;    Map Pseudo global data set to real global data set from tiff format to binary format.
;
; :params:
;    workspace_in
;    workspace_out
;    prefix_in
;    suffix_in
;    prefix_out
;    suffix_out
;    threshold
;    fill_value
;    start_year
;    end_year
;
;
;
; :author: Chang Liao
;-
PRO tiff2binary_global_wgs, workspace_in, workspace_out, prefix_in, suffix_in, prefix_out,suffix_out, threshold, fill_value, scale_factor, start_year, end_year
  COMPILE_OPT IDL2
  ENVI, /restore_base_save_files
  ENVI_BATCH_INIT, log_file = 'batch.txt', /NO_STATUS_WINDOW
  binary_extension = '.flt'
  tiff_extension = '.tif'
  hdr_extension = '.hdr'
  FOR year = start_year, end_year, 1 DO BEGIN
    year_str = STRING(year, format = '(i04)')
    year_in = workspace_in+!backslash+year_str+!backslash
    year_out = workspace_out+!backslash+year_str+!backslash
    IF (FILE_TEST(year_out) NE 1) THEN BEGIN
      FILE_MKDIR, year_out
    ENDIF
    FOR day = 0, 382, 1 DO BEGIN
      day_str = STRING(day, format = '(i03)')
      filename_in  = year_in +!backslash+prefix_in  + year_str+day_str+suffix_in  + tiff_extension
      filename_out = year_out+!backslash+prefix_out + year_str+day_str+suffix_out + binary_extension
      IF(FILE_TEST(filename_in) EQ 1 )THEN BEGIN
        ENVI_OPEN_FILE, filename_in, r_fid = fid
        ENVI_FILE_QUERY, fid, dims = dims, nb = nb
        data = ENVI_GET_DATA(fid = fid, dims = dims, pos = 0)
        xf = [0, 0]
        yf = [0, (SIZE(data, /dimensions))[1]-1]
        ENVI_CONVERT_FILE_COORDINATES, FID, XF, YF, XMap, YMap, /TO_MAP
        ENVI_FILE_MNG, id = fid, /remove
        nan_index = WHERE(data GE threshold OR data EQ fill_value, nan_count )
        data = data * scale_factor
        IF(nan_count GE 1) THEN BEGIN
          data[nan_index] = -9999.0
        ENDIF
        new_data = MAKE_ARRAY(720, 360, value = -9999.0, /float)
        row_index =FIX( (90.0-ymap)/0.5 )
        new_data[*, row_index[0]:row_index[1]] = data 
        OPENW, lun, filename_out, /get_lun
        WRITEU, lun, new_data
        FREE_LUN, lun
        hdr_out = year_out+!backslash+prefix_out + year_str+day_str+suffix_out + hdr_extension
        OPENW,lun,hdr_out,/get_lun
        PRINTF,lun,'ncols ',720
        PRINTF,lun,'nrows ',360
        PRINTF,lun,'xllcorner ',-180.0
        PRINTF,lun,'yllcorner ', -90.0
        PRINTF,lun,'cellsize ',0.5
        PRINTF,lun,'NODATA_value ',-9999
        PRINTF,lun,'byteorder','    LSBFIRST'
        FREE_LUN, lun
      ENDIF
    ENDFOR
  ENDFOR                          ;end year loop
END
