PRO rename_files2
  workspace_in = '/scratch/lustreA/l/liao46/data/spatial/TEM/NEP/binary05d'
  prefix_in = 'nep'
  prefix_out = 'NEP'
  binary_extension = '.flt'
  hdr_extension = '.hdr'
  start_year = 2000
  end_year = 2010
  FOR iyear = start_year, end_year, 1 DO BEGIN
    year_str = STRING(iyear, format = '(i04)')
    year_in = workspace_in+!backslash+year_str+!backslash
    FOR day = 0, 382, 1 DO BEGIN
      day_str = STRING(day, format = '(i03)')
      filename_in = year_in+!backslash+prefix_in+year_str+day_str+binary_extension
      filename_out = year_in+!backslash+  prefix_out+year_str+day_str+ binary_extension
      hdr_in = year_in+!backslash+prefix_in+year_str+day_str+hdr_extension
      hdr_out = year_in+!backslash+prefix_out+year_str+day_str+ hdr_extension
      IF(FILE_TEST(filename_in) EQ 1 )THEN BEGIN
        FILE_MOVE, filename_in, filename_out
        FILE_MOVE, hdr_in, hdr_out
      ENDIF
    ENDFOR
  ENDFOR
END
