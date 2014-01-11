; program to estimate mosaic parameters

PRO georef_mosaic_setup, fids=fids, dims=dims, out_ps=out_ps, $
    xsize=xsize, ysize=ysize, x0=x0, y0=y0, map_info=map_info
  COMPILE_OPT strictarr, hidden
  
  
  
  
  IF N_ELEMENTS(fids) LT 2 THEN BEGIN
    xsize = -1
    ysize = -1
    x0 = -1
    y0 = -1
    RETURN
  ENDIF
  
  ; if no DIMS passed in
  ;
  nfiles = N_ELEMENTS(fids)
  
  dims = FLTARR(5, nfiles)
  FOR i=0, nfiles-1 DO BEGIN
    ENVI_FILE_QUERY, fids[i], ns=ns, nl=nl
    dims[*,i] = [-1L, 0, ns-1, 0, nl-1]
  ENDFOR
  
  ; - compute the size of the output mosaic (xsize and ysize)
  ; - store the map coords of the UL corner of each image since you'll need it later
  ;
  UL_corners_X = DBLARR(nfiles)
  UL_corners_Y = DBLARR(nfiles)
  east = -1e34
  west = 1e34
  north = -1e34
  south = 1e34
  FOR i=0,nfiles-1 DO BEGIN
    pts = [ [dims[1,i], dims[3,i]],   $   ; UL
      [dims[2,i], dims[3,i]],   $ ; UR
      [dims[1,i], dims[4,i]],   $ ; LL
      [dims[2,i], dims[4,i]] ]    ; LR
    ENVI_CONVERT_FILE_COORDINATES, fids[i], pts[0,*], pts[1,*], xmap, ymap, /to_map
    UL_corners_X[i] = xmap[0]
    UL_corners_Y[i] = ymap[0]
    east  = east > MAX(xmap)
    west = west < MIN(xmap)
    north = north > MAX(ymap)
    south = south < MIN(ymap)
  ENDFOR
  xsize = east - west
  ysize = north - south
  xsize_pix = ROUND( xsize/out_ps[0] )
  ysize_pix = ROUND( ysize/out_ps[1] )
  
  ; to make things easy, create a temp image that's got a header
  ; that's the same as the output mosaic image
  ;
  proj = ENVI_GET_PROJECTION(fid=fids[0])
  map_info = ENVI_MAP_INFO_CREATE(proj=proj, mc=[0,0,west,north], ps=out_ps)
  temp = BYTARR(10,10)
  ENVI_ENTER_DATA, temp, map_info=map_info, /no_realize, r_fid=tmp_fid
  
  ; find the x and y offsets for the images
  ;
  x0 = LONARR(nfiles)
  y0 = LONARR(nfiles)
  FOR i=0,nfiles-1 DO BEGIN
    ENVI_CONVERT_FILE_COORDINATES, tmp_fid, xpix, ypix, UL_corners_X[i], UL_corners_Y[i]
    x0[i] = xpix
    y0[i] = ypix
  ENDFOR
  
  ;print, 'fids = ', fids
  ;print, 'dims = ', dims
  ;print, 'out_ps = ', out_ps
  ;print, 'xsize = ', xsize
  ;print, 'ysize = ', ysize
  ;print, 'x0 = ', x0
  ;print, 'y0 = ', y0
  ;print, 'map_info = ', map_info
  
  ; delete the tmp file
  ;
  ENVI_FILE_MNG, id=tmp_fid, /remove, /no_warning
  
END
