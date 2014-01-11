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
PRO binary2tiff_global_wgs, workspace_in, workspace_out, prefix_in, suffix_in, prefix_out,suffix_out, start_year, end_year
  COMPILE_OPT IDL2
  binary_extension = '.flt'
  tiff_extension = '.tif'
  hdr_extension = '.hdr'
  dims=[720,360]
  cellsize=0.5
  FOR year = start_year, end_year, 1 DO BEGIN
    year_str = STRING(year, format = '(i04)')
    year_in = workspace_in+!backslash+year_str+!backslash
    year_out = workspace_out+!backslash+year_str+!backslash
    IF (FILE_TEST(year_out) NE 1) THEN BEGIN
      FILE_MKDIR, year_out
    ENDIF
    FOR day = 0, 382, 1 DO BEGIN
      day_str = STRING(day, format = '(i03)')
      filename_in  = year_in +!backslash+prefix_in  + year_str+day_str+suffix_in  + binary_extension
      filename_out = year_out+!backslash+prefix_out + year_str+day_str+suffix_out + tiff_extension
      IF(FILE_TEST(filename_in) EQ 1 )THEN BEGIN
        OPENR,lun, filename_in,/get_lun
        binary_data=read_binary(lun,data_type=4,DATA_DIMS=dims)
        FREE_LUN,lun
        ;        nan_index=WHERE(binary_data EQ -9999, nan_count)
        ;        binary_data[nan_index]=0.0
        ;        FREE_LUN, lun
        g_tags = $
          {$
          ModelPixelScaleTag: [cellsize, cellsize, 0], $
          ModelTiepointTag: [0, 0, 0, -180.0, 90.0, 0], $
          GTModelTypeGeoKey: 2, $
          GTRasterTypeGeoKey: 1, $
          GeographicTypeGeoKey: 4326$
          }
        WRITE_TIFF, filename_out, binary_data,/float, geotiff=g_tags
      ENDIF
    ENDFOR
  ENDFOR                          ;end year loop
END
