PRO rename_files
  workspace_in='D:\data\spatial\modis\gpp\binary'
  prefix_in='gpp'
  prefix_out='gpp'
  binary_extension='.flt'
  hdr_extension='.hdr'
  start_year=2001
  end_year=2010
  FOR iyear=start_year,end_year,1 DO BEGIN
    year_str=STRING(iyear,format='(i04)')
    year_in=workspace_in+!backslash+year_str+!backslash
    FOR imonth=1,12,1 DO BEGIN
      mon_str=STRING(imonth,format='(i02)')
      FOR iday=1,31,1 DO BEGIN
        day_str=STRING(iday,format='(i02)')
        day_of_year=STRING(day_of_year( imonth, iday, iyear),format='(i03)')
        filename=year_in+!backslash+prefix_in+year_str+mon_str+day_str+binary_extension
        filename_out =year_in+!backslash+  prefix_in+year_str+day_of_year+ binary_extension
        hdr_in=year_in+!backslash+prefix_in+year_str+mon_str+day_str+hdr_extension
        hdr_out =year_in+!backslash+prefix_in+year_str+day_of_year+ hdr_extension
        IF(FILE_TEST(filename) EQ 1 )THEN BEGIN
          FILE_MOVE,filename,filename_out
          FILE_MOVE,hdr_in,hdr_out
        ENDIF
      ENDFOR
    ENDFOR
  ENDFOR
END