;+
; :description:
;    Resample the data set.
;
; :params:
;    workspace_in
;    workspace_out
;    prefix_in
;    prefix_out
;    factor
;    start_year
;    end_year
;
;
;
; :author: Chang Liao
;-
PRO resample, workspace_in, workspace_out, prefix_in,prefix_out, factor, start_year, end_year
  COMPILE_OPT IDL2
  ENVI, /restore_base_save_files
  ENVI_BATCH_INIT, log_file = 'batch.txt', /NO_STATUS_WINDOW
  tiff_extension = '.tif' 
  FOR iyear = start_year, end_year, 1 DO BEGIN
    year_str = STRING(iyear, format = '(i04)')
    year_in = workspace_in+!backslash+year_str
    year_out = workspace_out+!backslash+year_str
    IF(FILE_TEST(year_out) NE 1)THEN BEGIN
      FILE_MKDIR, year_out
    ENDIF
    FOR day=0,382,1 DO BEGIN
      day_str=STRING(day,format='(i03)')
      filename_in = year_in  + !backslash + prefix_in +  year_str + day_str + tiff_extension
      IF (FILE_TEST(filename_in) EQ 1 )  THEN BEGIN
        ENVI_OPEN_FILE,filename_in , r_fid = r_fid
        out_name =  year_out + !backslash + prefix_out + year_str + day_str + tiff_extension
        ENVI_FILE_QUERY, r_fid, dims = dims, nb = nb
        ENVI_DOIT, 'resize_doit', $
          fid = r_fid, pos = 0, dims = dims, $
          interp = 0, rfact = [factor, factor], $
          out_name = out_name
        ENVI_FILE_MNG, id = r_fid, /remove
      ENDIF
    ENDFOR
  ENDFOR
  PRINT, 'Finished'
  ENVI_BATCH_EXIT
END
