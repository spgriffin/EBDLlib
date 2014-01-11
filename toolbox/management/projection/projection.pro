;+
; :description:
;    Convert the projection of tiff file from modis sinusoidal to WGS 84. It could also to modified to other projection.
;
; :params:
;    workspace_in
;    workspace_out
;    prefix_in
;    prefix_out
;    file_extension
;    o_pixel_size
;    fill_value
;    start_year
;    end_year
;
;
;
; :author: Chang Liao
;-
PRO projection, workspace_in, workspace_out, prefix_in, prefix_out, file_extension, o_pixel_size, fill_value, start_year, end_year
  COMPILE_OPT IDL2
  ENVI, /restore_base_save_files
  ENVI_BATCH_INIT, log_file = 'batch.txt', /NO_STATUS_WINDOW
  ;the target project could be in parameter
  o_proj = ENVI_PROJ_CREATE(/geographic)
  FOR iyear = start_year, end_year, 1 DO BEGIN
    year_str = STRING(iyear, format = '(i04)')
    year_in = workspace_in + !backslash + year_str+!backslash
    year_out = workspace_out + !backslash + year_str+!backslash
    IF(FILE_TEST(year_out) NE 1)THEN BEGIN
      FILE_MKDIR, year_out
    ENDIF
    FOR day = 0, 382, 1 DO BEGIN
      day_str = STRING(day, format = '(i03)')
      filename_in = year_in+!backslash+prefix_in+year_str+day_str+file_extension
      IF(FILE_TEST(filename_in) EQ 1) THEN BEGIN
        ENVI_OPEN_FILE, filename_in, r_fid = r_fid
        ENVI_FILE_QUERY, r_fid, dims = dims, nb = nb
        pos  = LINDGEN(nb)
        filename_out = year_out+!backslash+prefix_in+year_str+day_str+file_extension
        ENVI_CONVERT_FILE_MAP_PROJECTION, fid = r_fid, $
          pos = pos, dims = dims, o_proj = o_proj, $
          o_pixel_size = o_pixel_size, grid = [10, 10], $
          out_name = filename_out, warp_method = 3, $
          resampling = 0, background = fill_value
        ENVI_FILE_MNG, id = r_fid, /remove
      ENDIF
    ENDFOR    ;end day loop
  ENDFOR   ;end year loop
  ENVI_BATCH_EXIT
END


