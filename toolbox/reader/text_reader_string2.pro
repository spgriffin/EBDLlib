;+
; :description:
;    Read string array from text file
;
; :params:
;    filename---The input text file 
;
; :keywords:
;    row_count ---line count of text file
;    delimiter--- the delimiter for text string
;
; :author: Chang Liao
;-
FUNCTION text_reader_string2, filename,row_count=row_count,delimiter=delimiter
  COMPILE_OPT idl2
  IF(KEYWORD_SET(row_count)) THEN BEGIN
    row_count=row_count
  ENDIF ELSE BEGIN
    row_count=FILE_LINES(filename)
  ENDELSE
  line=''
  OPENR, lun, filename, /get_lun
  READF, lun, line
  IF (KEYWORD_SET(delimiter))THEN BEGIN
    temp=strsplit(STRTRIM(line),delimiter,/extract)
    col_count=N_ELEMENTS(temp)
    data=STRARR(col_count,row_count)
    POINT_LUN, lun, 0
    FOR row=0,row_count-1,1 DO BEGIN
      READF, lun, line
      data[0,row]  = strsplit(STRTRIM(line),delimiter,/extract)
    ENDFOR
  ENDIF ELSE BEGIN
    temp=strsplit(STRTRIM(line),/extract)
    col_count=N_ELEMENTS(temp)
    data=STRARR(col_count,row_count)
    POINT_LUN, lun, 0
    FOR row=0,row_count-1,1 DO BEGIN
      READF, lun, line
      data[0,row]  = strsplit(STRTRIM(line),/EXTRACT)
    ENDFOR
  ENDELSE
  FREE_LUN,lun
  RETURN,data
END