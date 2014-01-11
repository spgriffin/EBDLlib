PRO hdf2img, workspace_in, workspace_out, prefix_in, prefix_out, grid_name, sd_names, start_year, end_year
COMPILE_OPT IDL2
ENVI, /restore_base_save_files
RESTORE,  '/home/liao46/idl/library/sav/modis_conversion_toolkit.sav'
                                ; Initialize ENVI and send all errors
ENVI_BATCH_INIT, log_file = 'batch.txt', /NO_STATUS_WINDOW
                                ;initiate the parameters
image_extension = '.img'
hdf_extension = '.hdf'
hdr_extension = '.hdr'
out_method = 0
                                ;Loop from year
FOR iyear = start_year, end_year, 1 DO BEGIN
                                ;path operation
    year_str = STRING(iyear, format = '(i04)')
    year_in = workspace_in+!backslash+year_str+!backslash
    year_out = workspace_out+!backslash+year_str+!backslash
                                ;Start folder loop
                                ;Create output folder
    IF (FILE_TEST(year_out) NE 1) THEN BEGIN
        FILE_MKDIR, year_out
    ENDIF

    for day = 0, 382, 1 do begin
        day_str = string(day, format = '(i03)') 
        day_in = year_in+!backslash+day_str
        day_out = year_out + !backslash + day_str
        IF (FILE_TEST(day_out) NE 1) THEN BEGIN
            FILE_MKDIR, day_out
        ENDIF
        filename_regex = prefix_in+ year_str+'*'+hdf_extension
        match_files = FILE_SEARCH( day_in, filename_regex, /fully_qualify_path, count = file_count)
        IF(file_count Ge 1) THEN BEGIN
            FOR f = 0, file_count-1, 1 DO BEGIN
                filename_out = prefix_out+year_str+day_str+image_extension
                convert_modis_data, in_file = match_files[f], $
                  out_path = day_out, out_root = filename_out, $
                  gd_name = grid_name, sd_names = sd_names, out_method = out_method, /grid,  /higher_product
            ENDFOR              ;end file loop
        ENDIF
    endfor                      ;end day loop
ENDFOR                          ;end year loop
ENVI_BATCH_EXIT
END
