FUNCTION hdf_reader,FILE_NAME,SDS_NAME
  COMPILE_OPT idl2
  ;check the input parameters
  ; Open the file and initialize the SD interface
  CATCH, Error_status
  IF Error_status NE 0 THEN BEGIN
    CATCH, /cancel
    PRINT, 'Error occuring '+FILE_NAME
    RETURN ,!Values.f_nan
  ENDIF
  sd_id = HDF_SD_START(FILE_NAME, /read )
  ;Validate the file existing
  IF(sd_id NE -1) THEN BEGIN
    ; Find the index of the sds to read using its name
    sds_index = HDF_SD_NAMETOINDEX(sd_id,SDS_NAME)
    IF(sds_index NE -1) THEN BEGIN
      ; Select it
      sds_id = HDF_SD_SELECT( sd_id, sds_index )
      ; Find a dataset attribute:
      dindex = HDF_SD_ATTRFIND(sds_id, 'scale_factor')
      IF(dindex NE -1) THEN BEGIN
        ; Retrieve scale_factor attribute info:
        HDF_SD_ATTRINFO,sds_id, dindex, NAME=n, TYPE=t, COUNT=c, DATA=scale_factor
      ENDIF ELSE BEGIN
        RETURN ,!Values.f_nan
      ENDELSE
      dindex = HDF_SD_ATTRFIND(sds_id, '_FillValue')
      IF(dindex NE -1) THEN BEGIN
        ; Retrieve _FillValue attribute info:
        HDF_SD_ATTRINFO,sds_id, dindex, NAME=n, TYPE=t, COUNT=c, DATA=_FillValue
      ENDIF ELSE BEGIN
        RETURN ,!Values.f_nan
      ENDELSE
      dindex = HDF_SD_ATTRFIND(sds_id, 'valid_range')
      IF(dindex NE -1) THEN BEGIN
        ; Retrieve valid_range attribute info:
        HDF_SD_ATTRINFO,sds_id, dindex, NAME=n, TYPE=t, COUNT=c, DATA=valid_range
      ENDIF ELSE BEGIN
        RETURN ,!Values.f_nan
      ENDELSE
      ;retrieve the data
      HDF_SD_GETDATA, sds_id, data
      HDF_SD_ENDACCESS, sds_id
      ;close the hdf file
      HDF_SD_END, sd_id
      ;Convert data type into float
      data=float(data)
      ;Query the invalid data and assign them with NAN
      nan_index=WHERE((data LT valid_range[0]) OR (data GT valid_range[1]) OR (data EQ  _FillValue[0]),nan_count)
      IF(nan_count GE 1)  THEN BEGIN
        data[nan_index]=!Values.f_nan
      ENDIF
      ;Multipiy scale_factor
      data= data * scale_factor[0]
      RETURN,data
    ENDIF ELSE BEGIN
      RETURN ,!Values.f_nan
    ENDELSE
  ENDIF ELSE BEGIN
    RETURN ,!Values.f_nan
  ENDELSE
END