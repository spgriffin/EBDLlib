;+
; :description:
;    Read the string array from the text file
;
; :params:
;    filename
;    col_count
;    row_count
;    delimiter
;
;
;
; :author: Chang Liao
;-
FUNCTION text_reader_string, filename,col_count,row_count,delimiter
  COMPILE_OPT idl2
  ON_ERROR, 2
  IF(N_PARAMS() LT 3) THEN BEGIN
    MESSAGE,'must supply enough parameters for the function!'
    RETURN,0
  ENDIF
  data=STRARR(col_count,row_count)
  OPENR, lun, filename, /get_lun
  line = ''
  FOR row=0,row_count-1,1 DO BEGIN
    READF, lun, line
    data[0,row]  = strsplit(line,delimiter,/extract)
  ENDFOR
  FREE_LUN, lun
  RETURN,data
END
