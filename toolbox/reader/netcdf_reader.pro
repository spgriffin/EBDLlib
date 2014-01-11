;+
; :description:
;    ; This procedure will read netCDF data and place it in an IDL variable
;
; :params:
;    filename: a string variable that includes the filepath
;    variable_name: a string that must match exactly that produced by routine
;    data: data to be read
;    dims: a vector of the dimensions
;;
; :author: liao46
;-
FUNCTION netcdf_reader, filename,variable_name
  IF (FILE_TEST(filename) NE 1) THEN BEGIN
    PRINT,'Invalid filename'
    RETURN,-1
  ENDIF
  fileID = NCDF_OPEN(filename)
  scale_factor=1.0D
  add_offset=0.0D
  IF(fileID NE -1) THEN BEGIN
    varID = NCDF_VARID(fileID,variable_name)
    IF(varID NE -1) THEN BEGIN
      ; get the data and dimensions
      varstruct = NCDF_VARINQ(fileID,varID)
      ; loop through attributes
      flag=INTARR(5)
      ;since different nc file have different attributes,
      ;then we have to read them dynamically accordingly
      FOR attndx = 0, varstruct.natts-1 DO BEGIN
        ; get attribute name, then use it to get the value
        attname = NCDF_ATTNAME(fileID,varID,attndx)
        NCDF_ATTGET,fileID,varID,attname,value
        CASE attname OF
          'scale_factor':  BEGIN
            scale_factor=DOUBLE(value)
            flag[0]=1
          END
          'add_offset':BEGIN
          add_offset=DOUBLE(value)
          flag[1]=1
        END
        '_FillValue':BEGIN
        _FillValue=DOUBLE(value)
        flag[2]=1
      END
      'missing_value':BEGIN
      missing_value=DOUBLE(value)
      flag[3]=1
    END
    'valid_range':BEGIN
    valid_range =DOUBLE(value)
    flag[4]=1
  END
  ELSE: BEGIN
    undefine,attname
  END
ENDCASE
; attribute loop
ENDFOR
;based upon the flags of each attributes, we set the data as NAN respectively
NCDF_VARGET, fileID, varID, data
data=DOUBLE(data)
IF(flag[2] EQ 1) THEN BEGIN
  ;nanindex=WHERE( data  EQ  FLOAT(_FillValue) or data  EQ -32760,nancount)
  nanindex=WHERE( data  EQ  _FillValue,nancount)
  IF(nancount GE 1)  THEN BEGIN
    data[nanindex]=!VALUES.d_nan
  ENDIF
ENDIF
IF(flag[3] EQ 1) THEN BEGIN
  nanindex=WHERE( data EQ missing_value,nancount)
  IF(nancount GE 1)  THEN BEGIN
    data[nanindex]=!VALUES.d_nan
  ENDIF
ENDIF
data= TEMPORARY(data) * scale_factor+ add_offset
;IF(flag[4] EQ 1) THEN BEGIN
;  min=DOUBLE(valid_range[0])
;  max=DOUBLE(valid_range[1])
;  nanindex=WHERE( data LT MIN OR data GT MAX ,nancount)
;  IF(nancount GE 1)  THEN BEGIN
;    data[nanindex]=!VALUES.D_nan
;  ENDIF
;ENDIF
RETURN,data
ENDIF ELSE BEGIN
  RETURN ,!Values.d_nan
ENDELSE
ENDIF ELSE BEGIN
  RETURN ,!Values.d_nan
ENDELSE
END
