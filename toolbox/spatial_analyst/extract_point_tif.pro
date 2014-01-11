;+
; :description:
;   extract point data from remote sensing dataset
;
;
;
;
;
; :author: chang liao
;-
PRO extract_point_tif,   workspace_in, workspace_out,  start_year, end_year, point_code, longitude, latitude, fill_value
COMPILE_OPT idl2
                                ; initialize envi and send all errors and warnings to the file batch.txt
ENVI, /restore_base_save_files
ENVI_BATCH_INIT, log_file = 'batch.txt', /no_status_window
iproj = ENVI_PROJ_CREATE(/geographic)
                                ; parameters
backslash = '/'
delimiter = ' '
underline = '_'
flt_extension = '.flt'
file_extension = '.tif'
prefix_out = 'gpp'
                                ;controls
year_count = end_year-start_year+1
                                ;files

grid_size = 0
                                ;loop
FOR i = 0, N_elements(point_code)-1, 1 DO BEGIN
    lon = longitude[i]
    lat = latitude[i]
    point_id = point_code[i]
                                ;open file to write
    out_file = workspace_out+backslash+prefix_out+underline+point_id+flt_extension
    OPENW, lun, out_file, /get_lun
    year_data = MAKE_ARRAY(46, year_count, /float)
    flag = 0
    FOR iyear = start_year, end_year, 1 DO BEGIN
        year_str = STRING(iyear, format = '(i04)')
        year_in = workspace_in + backslash + year_str
                                ;setup flag
        temp_year = MAKE_ARRAY(46, /float, value = !values.f_nan)
                                ; FOR iday = 0, 45, 1 DO BEGIN
                                ;  file_index = STRING(iday * 8 +1, format = '(i03)')
        filename_regex = year_str+'*'+file_extension
        match_files = FILE_SEARCH(year_in, filename_regex, /fully_qualify_path, count = file_count)
        IF(file_count EQ 46) THEN BEGIN
            for f = 0, file_count-1, 1 do begin
                ENVI_OPEN_FILE, match_files[f], r_fid = fid
                ENVI_FILE_QUERY, fid, dims = dims, nb = nb, $
                  fname = fname, data_type = data_type
                temp_data0 = ENVI_GET_DATA(fid = fid, dims = dims, pos = 0)
                                ;          IF (flag EQ 0) THEN BEGIN
                oproj = ENVI_GET_PROJECTION(fid = fid, pixel_size = pixel_size, units = unit)
                ENVI_CONVERT_PROJECTION_COORDINATES, lon, lat, iproj, oxmap, oymap, oproj
                ENVI_CONVERT_FILE_COORDINATES, fid, x, y, oxmap, oymap
                xl = FLOOR(x) - grid_size
                xr = CEIL(x)  + grid_size
                yt = FLOOR(y) - grid_size
                yb = CEIL(y)  + grid_size
                dims = [-1l, xl,  xr, yt, yb]
                                ;            flag = 1
                                ;         ENDIF
                temp_data = ENVI_GET_DATA(fid = fid, dims = dims, pos = 0)
                nan_index = WHERE(temp_data GT fill_value, nan_count)
                IF(nan_count GE 1) THEN BEGIN
                    temp_data[nan_index] = !values.f_nan
                ENDIF
                mean_gpp = mean(TEMPORARY(temp_data), /nan)
                temp_year[f] = mean_gpp
                ENVI_FILE_MNG, id = fid, /remove
                
            endfor
        ENDIF                   ;ENDFOR                  ;end day loop
        nan_index = WHERE(gap_fill(temp_year) LT 0, nan_count)
        IF(nan_count GT 0)THEN BEGIN
            temp_year[nan_index] = 0.0
        ENDIF
        year_data[*, iyear-start_year] = temp_year * 1000.0
    ENDFOR                      ;end year loop
    WRITEU, lun, year_data
    FREE_LUN, lun
ENDFOR
END
