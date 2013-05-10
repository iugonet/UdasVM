;+
;
;NAME:
;  iug_plot2d_ionogram
;
;PURPOSE:
;  Generate several ionogram plots from the ionogram data taken by the ionosonde. 
;
;SYNTAX:
;  iug_plot2d_ionogram, datatype = datatype, valuename=valuename
;
;KEYWOARDS:
;  datatype = Observation data type. For example, plot_iug_ionogram, datatype = 'ionosphere'.
;            The default is 'ionosphere'. 
;  valuename = tplot variable names of ionosonde observation data.  
;         For example, iug_plot2d_ionogram,valuename = 'iug_ionosonde_sgk_ionogram'.
;         The default is 'iug_ionosonde_sgk_ionogram'.
;
;CODE:
;  A. Shinbori, 11/01/2013.
;  
;MODIFICATIONS:
;
;  
;ACKNOWLEDGEMENT:
; $LastChangedBy:  $
; $LastChangedDate:  $
; $LastChangedRevision:  $
; $URL $
;-

pro iug_plot2d_ionogram,datatype=datatype, valuename=valuename

;***************
;Datatype check:
;***************
if not keyword_set(datatype) then datatype='ionosphere'

;*****************
;Value name check:
;*****************
if not keyword_set(valuename) then valuename='iug_ionosonde_sgk_ionogram'

;window,0,xs=512,ys=512
;loadct,39

;Get the ionogram data from tplot variable:
get_data,valuename,data=d

;Number of total frames:
Nt=n_elements(d.y[*,0,0])
print,'The number of total frames: ',Nt
print,n_elements(d.y[0,*,0]),n_elements(d.y[0,0,*])

;Definition of temporary array:
tmp=fltarr(n_elements(d.y[0,*,0]),n_elements(d.y[0,0,*]))

X=round(fix(Nt)/4)
if Nt le 3 then begin 
   Y=Nt
endif else begin
   Y=4
endelse
print, X, Y

;Set up the window size of ionogram plot:
window ,0, xsize=1280,ysize=800

;plot ionograms:
for t=0,Nt-1 do begin
   tmp[*,*]=d.y[t,*,*]
   time = d.x[t]
   if t eq 0 then begin
      plotxyz,d.v1,d.v2,tmp,/noisotropic,/interpolate,xtitle='Frequency [MHz]',ytitle='Height [km]',ztitle ='Echo power [dBV]',$
              multi= strtrim(string(X),2)+','+strtrim(string(Y),2),window=0,charsize =0.75, title = time_string(time),xmargin=[0.2,0.2],ymargin=[0.18,0.18]
   endif else begin
      plotxyz,d.v1,d.v2,tmp,/noisotropic,/interpolate,/add,xtitle='Frequency [MHz]',ytitle='Height [km]',ztitle ='Echo power [dBV]',$
              window=0,charsize =0.75, title = time_string(time),xmargin=[0.2,0.2],ymargin=[0.18,0.18]
   endelse
endfor
end