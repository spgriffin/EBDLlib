PRO netcdf2binary_pdsi,workspace_in,workspace_out
  COMPILE_OPT idl2
  ENVI, /restore_base_save_files
  ENVI_BATCH_INIT, log_file = 'batch.txt', /NO_STATUS_WINDOW
  file_format='nc'
  binary_extension='.flt'
  text_extension='.txt'
  nc_extension='.nc'
  bmp_extension='.bmp'
  hdr_extension='.hdr'
  dataset_field='sc_PDSI_pm'
  eco_type='PDSI'
  filename_in=workspace_in+!backslash+'pdsisc.monthly.maps.1850-2010.fawc=1.r2.5x2.5.ipe=2.nc'
  netcdf_reader,filename_in,dataset_field,all_data,dims
  data=FLOAT(all_data[*,*,12*151:12*151+120-1])
  undefine,all_data
  start_year=2001
  end_year=2010
  lon=MAKE_ARRAY(720,/index)*0.5-180.0
  lat=90.0-MAKE_ARRAY(360,/index)*0.5
  x=TRANSPOSE((lon+178.750)/2.5)
  y=TRANSPOSE((76.25-lat)/2.5)
  nan_index0=where(y le 0)
  FOR year=start_year, end_year,1 DO BEGIN
    year_str = STRING(year, format = '(i04)')
    year_in = workspace_in+!backslash+year_str+!backslash
    year_out = workspace_out+!backslash+year_str+!backslash
    IF (FILE_TEST(year_out) NE 1) THEN BEGIN
      FILE_MKDIR, year_out
    ENDIF
    FOR day = 371, 382, 1 DO BEGIN
      day_str = STRING(day, format = '(i03)')
      temp1=rotate(data[*,*,((year-start_year)*12+day-371)],7)
      temp_data= INTERPOLATE(temp1, x, y,/GRID)
      nan_index= WHERE(FINITE(temp_data)  NE 1, nan_count)
      IF(nan_count GT 0)THEN BEGIN
        temp_data[nan_index]=-9999.00
      ENDIF
      temp_data[*,nan_index0]=-9999.00
      filename_out=year_out  + !backslash + eco_type + year_str + day_str+ binary_extension
      OPENW, lun, filename_out, /get_lun
      WRITEU, lun, temp_data
      FREE_LUN, lun
      hdr_out =  year_out+!backslash  + eco_type + year_str+day_str+ hdr_extension
      OPENW,lun,hdr_out,/get_lun
      PRINTF,lun,'ncols ',720
      PRINTF,lun,'nrows ',360
      PRINTF,lun,'xllcorner ',-180.0
      PRINTF,lun,'yllcorner ', -90.0
      PRINTF,lun,'cellsize ',0.5
      PRINTF,lun,'NODATA_value ',-9999
      PRINTF,lun,'byteorder','    LSBFIRST'
      FREE_LUN, lun      
    ENDFOR    
  ENDFOR  
END