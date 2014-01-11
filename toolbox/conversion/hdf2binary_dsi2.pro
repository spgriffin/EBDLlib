;+
; :Description:
;    Convert to Drought Serverity Index into Binary format using built-in HDF routine.
;
; :Params:
;    workspace_in
;    workspace_out
;    prefix_in
;    prefix_out
;    start_year
;    end_year
;    dataset_field
;
;
;
; :Author: liao46
;-
PRO hdf2binary_dsi2,workspace_in,workspace_out,prefix_in,prefix_out,start_year,end_year,dataset_field
  COMPILE_OPT IDL2  
  binary_extension='.flt'
  hdf_extension='.hdf'
  hdr_extension='.hdr'
  ;Loop from year
  FOR iyear=start_year,end_year,1 DO BEGIN
    year_str=STRING(iyear,format='(i04)')
    year_in=workspace_in+!backslash+year_str+!backslash
    year_out=workspace_out+!backslash+year_str+!backslash
    IF (FILE_TEST(year_out) NE 1) THEN BEGIN
      FILE_MKDIR,year_out
    ENDIF
    for day=0,382,1 do begin
      day_str=string(day, format='(i03)')
      filename_in=year_in + !backslash + prefix_in+year_str+day_str + hdf_extension
      if(file_test(filename_in) eq 1) then begin
        data=hdf_reader2(filename_in,dataset_field)
        nan_index=WHERE(FINITE(data) NE 1,nan_count)
        IF(nan_count GE 1) THEN BEGIN
          data[nan_index]=-9999.0
        ENDIF
        global_data=MAKE_ARRAY(720,360,value=-9999.0,/float)
        ;this is the special case for DSI data!!!!
        global_data[*,20:299]=data
        filename_out=year_out + !backslash + prefix_out+year_str+day_str + binary_extension
        OPENW,lun,filename_out,/get_lun
        WRITEU,lun,global_data
        FREE_LUN, lun
        hdr_out=year_out + !backslash + prefix_out+year_str+day_str + hdr_extension
        OPENW,lun,hdr_out,/get_lun
        PRINTF,lun,'ncols ',720
        PRINTF,lun,'nrows ',360
        PRINTF,lun,'xllcorner ',-180.0
        PRINTF,lun,'yllcorner ', -90.0
        PRINTF,lun,'cellsize ',0.5
        PRINTF,lun,'NODATA_value ',-9999
        PRINTF,lun,'byteorder','    LSBFIRST'
        FREE_LUN, lun
      endif
    endfor    ;end day loop
  ENDFOR  ; end year loop
  
END
