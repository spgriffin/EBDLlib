;+
; :description:
;    Delete the path if some file is missing.
;
; :params:
;    path
;    expected_file
;
;
;
; :author: Chang Liao
;-
PRO delete_path,path,expected_file
  CD, CURRENT=current_path
  IF(FILE_TEST(path)) THEN BEGIN
    CD, path
    IF(~FILE_TEST(expected_file)) THEN BEGIN
      CD,current_path
      FILE_DELETE,path, /RECURSIVE
    ENDIF
  ENDIF
  CD, CURRENT=current_path
END