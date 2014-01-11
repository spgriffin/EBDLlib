PRO rename_files3
  workspace_in='F:\spatial\MODIS\PFT\mosaic'
  workspace_out='F:\spatial\MODIS\PFT\mosaic'
  prefix_in='pft'
  prefix_out='PFT'
  binary_extension='.flt'
  hdr_extension='.hdr'
  tiff_extension='.tif'
  start_year = 2001
  end_year = 2010
  FOR iyear = start_year, end_year, 1 DO BEGIN
    year_str = STRING(iyear, format = '(i04)')
    year_in = workspace_in+!backslash+year_str+!backslash
    year_out=workspace_out+!backslash+year_str+!backslash
    FILE_MKDIR,year_out
    filename_in=year_in+!backslash+prefix_in+year_str+'mosaic'+tiff_extension
    filename_out =year_out+!backslash+  prefix_out+year_str+'000'+ tiff_extension
    hdr_in=filename_in+hdr_extension
    hdr_out =filename_out+ hdr_extension
    IF(FILE_TEST(filename_in) EQ 1 )THEN BEGIN
      FILE_MOVE, filename_in, filename_out
      FILE_MOVE, hdr_in, hdr_out
    ENDIF
  ENDFOR
END
