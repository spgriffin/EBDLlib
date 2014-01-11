;+
; :description:
;    fill the gaps in low quality data set using SPLINE method
;
; :params:
;    data
;
;
;
; :author: Chang Liao
;-
FUNCTION gap_fill_spline,data
  data_copy=data
  ; figure out where there are NaNs and where the useful data are
  gooddata = WHERE(FINITE(data), ngooddata, comp=baddata, ncomp=nbaddata)
  ; interpolate at the locations of the bad data using the good data
  IF (nbaddata GT 0 ) THEN  BEGIN
    IF(ngooddata GE 4)THEN BEGIN
      data_copy[baddata] = interpol(data[gooddata], gooddata, baddata,/SPLINE,/nan)
    ENDIF ELSE BEGIN
      IF(ngooddata GT 2)THEN BEGIN
        data_copy[baddata] = interpol(data[gooddata], gooddata, baddata)
      ENDIF ELSE BEGIN
        data_copy[baddata]=mean(data,/nan)
      ENDELSE
    ENDELSE
  ENDIF
  RETURN,data_copy
END