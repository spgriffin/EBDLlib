PRO show_matrix,data
cgLoadCT, 0
   cgSurf, data, /Shaded, Shades=BytScl(data)
   cgLoadCT, 25, /Brewer, /Reverse
   cgSurf, data, Shades=BytScl(data), /NoErase, Title='Surface Title'
END