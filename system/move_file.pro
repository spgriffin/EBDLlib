PRO move_file, workspace_in, workspace_out, match_string, start_year, end_year



  backslash='/'
 ; match_string='resample'
  ;start_year=2001
  ;end_year=2010
  FOR iyear = start_year, end_year, 1 DO BEGIN
    year_str = STRING(iyear, format = '(i04)')
    year_in = workspace_in+backslash+year_str
    year_out = workspace_out+backslash+year_str
    IF(FILE_TEST(year_out) NE 1)THEN BEGIN
      FILE_MKDIR, year_out
    ENDIF
    
    filename_regex ='*'+ match_string+'*'
    match_files = FILE_SEARCH(year_in, filename_regex, /FULLY_QUALIFY_PATH, COUNT = file_count)
    
    FOR f = 0, file_count-1, 1 DO BEGIN
      FILE_MOVE,match_files[f],year_out
    ENDFOR
    
  ENDFOR
  PRINT, 'Finished'
END
