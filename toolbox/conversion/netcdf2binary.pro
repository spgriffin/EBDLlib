;this routine is still unfinished
pro netcdf2binary,workspace_in,workspace_out,prefix_in,prefix_out,start_year,end_year,dataset_field
  COMPILE_OPT IDL2
  ENVI, /restore_base_save_files
  ; Initialize ENVI and send all errors
  ENVI_BATCH_INIT, log_file='batch.txt',/NO_STATUS_WINDOW
  ;initiate the parameters
  binary_extension='.flt'
  hdf_extension='.hdf'
  hdr_extension='.hdr'
  ;Loop from year
  hdr_header='D:\data\parameter\project\tem\world.hdr'
  FOR iyear=start_year,end_year,1 DO BEGIN
    ;path operation
    year_str=STRING(iyear,format='(i04)')
    year_in=workspace_in+!backslash+year_str+!backslash
    year_out=workspace_out+!backslash+year_str+!backslash
    ;Start folder loop
    ;Create output folder
    IF (FILE_TEST(year_out) NE 1) THEN BEGIN
      FILE_MKDIR,year_out
    ENDIF
    filename_regex =prefix_in+ year_str+'*'+hdf_extension
    match_files = FILE_SEARCH(year_in, filename_regex, /fully_qualify_path, count = file_count)
    IF(file_count GT 0) THEN BEGIN
      FOR f=0,file_count-1 ,1 DO BEGIN
        filename=FILE_BASENAME(match_files[f],hdf_extension)
        filename_out =year_out+!backslash+prefix_out + STRMID(filename,12,7) + binary_extension
        data=hdf_reader2(match_files[f],dataset_field)
        nan_index=WHERE(FINITE(data) NE 1,nan_count )
        IF(nan_count GE 1) THEN BEGIN
          data[nan_index]=-9999.0
        ENDIF
        new_data=MAKE_ARRAY(720,360,value=-9999.0,/float)
        new_data[*,20:299]=data
        OPENW,lun,filename_out,/get_lun
        WRITEU,lun,new_data
        FREE_LUN, lun        
        hdr_out=year_out+FILE_BASENAME(filename_out ,binary_extension) + hdr_extension
        IF(FILE_TEST(hdr_out) NE 1) THEN BEGIN
          FILE_COPY,hdr_header,hdr_out
        ENDIF                
      ENDFOR
    ENDIF    
  ENDFOR ;end year loop
end