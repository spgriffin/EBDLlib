;+
; NAME:
; leap_year
;
;
; PURPOSE:
; compute if an array of years are leap years
;
;
; INPUTS:
; year: array of any size/shape of years 
;         (of course leap years are only valid
;          over a range of AD dates past ~4AD)
;
;
; KEYWORD PARAMETERS:
; NUMDAYS: if set returns the number of days in the year instead of
;            a login 1/0 
;
;
; OUTPUTS:
; array of logic 1/0 where 1 is leap year and zero is not 
;
;
; EXAMPLE:
; IDL> print, leap_year(findgen(2,5)+1900)
;    0   0
;    0   0
;    1   0
;    0   0
;    1   0
;
; IDL> print, leap_year(findgen(10)+1900)
;    0   0   0   0   1   0   0   0   1   0
;
;
;
; MODIFICATION HISTORY:
;
;       Thur Feb 8 16:37:16 2007, Brian Larsen
;   written and tested
;
;-
FUNCTION leap_year, year, NUMDAYS=numdays

  mask400 = year mod 400 EQ 0   ; this is a leap year
  mask100 = year mod 100 EQ 0   ; these are not leap years
  mask4 = year mod 4 EQ 0       ; this is a leap year
  
  if n_elements(numdays) eq 0 then $
     numdays = 0 else $
        numdays = 365
  
  
  RETURN, numdays + ((mask400 or mask4) and (~mask100 or mask400))
  

END