;+
;
;NAME:
;iug_load_ear_iono_fr_nc
;
;PURPOSE:
;  Queries the Kyoto_RISH servers for the FAI observation data in the NetCDF format 
;  taken by the equatorial atmosphere radar (EAR) and loads data into
;  tplot format.
;
;SYNTAX:
; iug_load_ear_iono_fr_nc, datatype = datatype, parameter1=parameter1, $
;                          downloadonly=downloadonly, trange=trange, verbose=verbose
;
;KEYWOARDS:
;  datatype = Observation data type. For example, iug_load_ear_iono_fr_nc, datatype = 'fai'.
;            The default is 'fai'. 
;  parameter1 = first parameter name of EAR FAI obervation data.  
;          For example, iug_load_ear_iono_fr_nc, parameter1 = 'fb1p16a'.
;          The default is 'all', i.e., load all available parameters.
;  trange = (Optional) Time range of interest  (2 element array), if
;          this is not set, the default is to prompt the user. Note
;          that if the input time range is not a full day, a full
;          day's data is loaded.
;  /downloadonly, if set, then only download the data, do not load it
;                 into variables.
;                 
;DATA AVAILABILITY:
;  Please check the following homepage of the time schedule of field-aligned irregularity (FAI) observation 
;  before you analyze the FAI data using this software. 
;  http://www.rish.kyoto-u.ac.jp/ear/data-fai/index.html#data
;
;CODE:
; A. Shinbori, 19/09/2010.
;
;MODIFICATIONS:
; A. Shinbori, 24/03/2011.
; A. Shinbori, 09/07/2011.
; A. Shinbori, 01/12/2011.
; A. Shinbori, 31/01/2012.
; A. Shinbori, 17/12/2012.
; 
;ACKNOWLEDGEMENT:
; $LastChangedBy:  $
; $LastChangedDate:  $
; $LastChangedRevision:  $
; $URL $
;-


pro iug_load_ear_iono_fr_nc, datatype = datatype, $
  parameter1=parameter1, $
  downloadonly=downloadonly, $
  trange=trange, $
  verbose=verbose

;**************
;keyword check:
;**************
if (not keyword_set(verbose)) then verbose=2
 
;**********************************
;Load 'ionosphere' data by default:
;**********************************
if (not keyword_set(datatype)) then datatype='fai'

;************
;parameters1:
;************
;--- all parameters1 (default)
parameter1_all = strsplit('fb1p16a fb1p16b fb1p16c fb1p16d fb1p16e fb1p16f fb1p16g fb1p16h fb1p16i '+$
                          'fb1p16j1 fb1p16j2 fb1p16j3 fb1p16j4 fb1p16j5 fb1p16j6 fb1p16j7 fb1p16j8 fb1p16j9 '+$
                          'fb1p16j10 fb1p16j11 fb1p16k1 fb1p16k2 fb1p16k3 fb1p16k4 fb1p16k5 fb8p16k1 fb8p16k2 '+$
                          'fb8p16k3 fb8p16k4 fb1p16m2 fb1p16m3 fb1p16m4 fb8p16m1 fb8p16m2 ',$
                          ' ', /extract)

;--- check site codes
if(not keyword_set(parameter1)) then parameter1='all'
parameters = thm_check_valid_name(parameter1, parameter1_all, /ignore_case, /include_all)

print, parameters

;*****************
;defition of unit:
;*****************
;--- all parameters2 (default)
unit_all = strsplit('m/s dB',' ', /extract)

;******************************************************************
;Loop on downloading files
;******************************************************************
;Get timespan, define FILE_NAMES, and load data:
;===============================================
;
;===================================================================
;Download files, read data, and create tplot vars at each component:
;===================================================================
jj=0
for ii=0,n_elements(parameters)-1 do begin
   if ~size(fns,/type) then begin

     ;Get files for ith component:
     ;***************************
      file_names = file_dailynames( $
      file_format='YYYY/'+$
                  'YYYYMMDD',trange=trange,times=times,/unique)+'.fai'+parameters[ii]+'.nc'
     ;
     ;Define FILE_RETRIEVE structure:
     ;===============================
      source = file_retrieve(/struct)
      source.verbose=verbose
      source.local_data_dir = root_data_dir() + 'iugonet/rish/misc/ktb/ear/fai/f_region/nc/'
      source.remote_data_dir = 'http://www.rish.kyoto-u.ac.jp/ear/data-fai/data/nc/'
    
     ;Get files and local paths, and concatenate local paths:
     ;=======================================================
      local_paths=file_retrieve(file_names,_extra=source)
      local_paths_all = ~(~size(local_paths_all,/type)) ? $
                        [local_paths_all, local_paths] : local_paths
      if ~(~size(local_paths_all,/type)) then local_paths=local_paths_all
   endif else file_names=fns

  ;--- Load data into tplot variables
   if (not keyword_set(downloadonly)) then downloadonly=0

   if (downloadonly eq 0) then begin

     ;===================================================
     ;read data, and create tplot vars at each parameter:
     ;===================================================
     ;Read the files:
     ;===============
   
     ;Definition of time and parameters:
      ear_time=0
      pwr1 = 0
      wdt1 = 0
      dpl1 = 0
      pn1 = 0
  
     ;==============
     ;Loop on files: 
     ;============== 
      for j=jj,n_elements(local_paths)-1 do begin
         file= local_paths[j]
         if file_test(/regular,file) then  dprint,'Loading the FAI observation data taken by the EAR: ',file $
         else begin
            dprint,'The FAI observation data taken by the EAR ',file,' not found. Skipping'
            continue
         endelse
    
         cdfid = ncdf_open(file,/NOWRITE)  ; Open the file
         glob = ncdf_inquire( cdfid )    ; Find out general info

        ;Show user the size of each dimension
         print,'Dimensions', glob.ndims
         for i=0,glob.ndims-1 do begin
            ncdf_diminq, cdfid, i, name,size
            if i eq glob.recdim then  $
               print,'    ', name, size, '(Unlimited dim)' $
            else      $
               print,'    ', name, size  
         endfor

        ;Now tell user about the variables
         print
         print, 'Variables'
         for m=0,glob.nvars-1 do begin
            
           ;Get information about the variable
            info = ncdf_varinq(cdfid, m)
            FmtStr = '(A," (",A," ) Dimension Ids = [ ", 10(I0," "),$)'
            print, FORMAT=FmtStr, info.name,info.datatype, info.dim[*]
            print, ']'

           ;Get attributes associated with the variable
            for l=0,info.natts-1 do begin
               attname = ncdf_attname(cdfid,m,l)
               ncdf_attget,cdfid,m,attname,attvalue
               print,' Attribute ', attname, '=', string(attvalue)
               if (info.name eq 'time') and (attname eq 'units') then time_data=string(attvalue)
            endfor
         endfor

        ;Calculation the start time infomation from the attribute data:
         time_info=strsplit(time_data,' ',/extract)
         syymmdd=time_info[2]
         shhmmss=time_info[3]
         time_diff=strsplit(time_info[4],':',/extract)
         time_diff2=fix(time_diff[0])*3600+fix(time_diff[1])*60 
     
        ;Get the variable
         ncdf_varget, cdfid, 'lat', lat
         ncdf_varget, cdfid, 'lon', lon
         ncdf_varget, cdfid, 'sealvl', sealvl
         ncdf_varget, cdfid, 'bmwdh', bmwdh
         ncdf_varget, cdfid, 'freq', freq
         ncdf_varget, cdfid, 'ipp', ipp
         ncdf_varget, cdfid, 'ndata', ndata
         ncdf_varget, cdfid, 'nfft', nfft
         ncdf_varget, cdfid, 'ncoh', ncoh
         ncdf_varget, cdfid, 'nicoh', nicoh
         ncdf_varget, cdfid, 'beam', beam
         ncdf_varget, cdfid, 'range', range
         ncdf_varget, cdfid, 'az', az
         ncdf_varget, cdfid, 'ze', ze
         ncdf_varget, cdfid, 'date', date
         ncdf_varget, cdfid, 'time', time
         ncdf_varget, cdfid, 'height', height
         ncdf_varget, cdfid, 'pwr', pwr
         ncdf_varget, cdfid, 'width', width
         ncdf_varget, cdfid, 'dpl', dpl
         ncdf_varget, cdfid, 'pnoise', pnoise
 
        ;Calculation of unix time:
         year = fix(strmid(strtrim(string(date),1),0,4))
         month = fix(strmid(strtrim(string(date),1),4,2))
         day = fix(strmid(strtrim(string(date),1),6,2))
                         
        ;Definition of arrary names
         height2 = fltarr(n_elements(range))
         unix_time = dblarr(n_elements(time))
         pwr1_ear=fltarr(n_elements(time),n_elements(range),n_elements(beam))
         wdt1_ear=fltarr(n_elements(time),n_elements(range),n_elements(beam))
         dpl1_ear=fltarr(n_elements(time),n_elements(range),n_elements(beam))
         pnoise1_ear=fltarr(n_elements(time),n_elements(beam)) 
    
         for i=0, n_elements(time)-1 do begin
           ;Change seconds since the midnight of every day (Local Time) into unix time (1970-01-01 00:00:00)      
            unix_time[i] = double(time[i]) +time_double(string(syymmdd)+'/'+string(shhmmss))-double(time_diff2)            
            for k=0, n_elements(range)-1 do begin
               for l=0, n_elements(beam)-1 do begin           
                  a = pwr[k,i,l]            
                  wbad = where(a eq 10000000000,nbad)
                  if nbad gt 0 then a[wbad] = !values.f_nan
                  pwr[k,i,l] =a
                  b = width[k,i,l]            
                  wbad = where(b eq 10000000000,nbad)
                  if nbad gt 0 then b[wbad] = !values.f_nan
                  width[k,i,l]  =b
                  c = dpl[k,i,l]            
                  wbad = where(c eq 10000000000,nbad)
                  if nbad gt 0 then c[wbad] = !values.f_nan
                  dpl[k,i,l] =c                   
                  pwr1_ear[i,k,l]=pwr[k,i,l]  
                  wdt1_ear[i,k,l]=width[k,i,l]  
                  dpl1_ear[i,k,l]=dpl[k,i,l]
               endfor        
            endfor
            for l=0, n_elements(beam)-1 do begin            
               d = pnoise[i,l]            
               wbad = where(d eq 10000000000,nbad)
               if nbad gt 0 then d[wbad] = !values.f_nan
               pnoise[i,l] =d
               pnoise1_ear[i,l]=pnoise[i,l]            
            endfor
         endfor
         ncdf_close,cdfid  ; done
       
        ;=============================
        ;Append data of time and data:
        ;=============================
         append_array, ear_time, unix_time
         append_array, pwr1, pwr1_ear
         append_array, wdt1, wdt1_ear
         append_array, dpl1, dpl1_ear
         append_array, pn1, pnoise1_ear          
      endfor

     ;==============================
     ;Store data in TPLOT variables:
     ;==============================
     ;Acknowlegment string (use for creating tplot vars)
      acknowledgstring = 'The Equatorial Atmosphere Radar belongs to Research Institute for ' $
                       + 'Sustainable Humanosphere (RISH), Kyoto University and is operated by ' $
                       + 'RISH and National Institute of Aeronautics and Space (LAPAN) Indonesia. ' $
                       + 'Distribution of the data has been partly supported by the IUGONET ' $
                       + '(Inter-university Upper atmosphere Global Observation NETwork) project ' $
                       + '(http://www.iugonet.org/) funded by the Ministry of Education, Culture, ' $
                       + 'Sports, Science and Technology (MEXT), Japan.'
      if n_elements(ear_time) gt 1 then begin
         bname2=strarr(n_elements(beam))
         bname=strarr(n_elements(beam))
         pwr2_ear=fltarr(n_elements(ear_time),n_elements(range))
         wdt2_ear=fltarr(n_elements(ear_time),n_elements(range))
         dpl2_ear=fltarr(n_elements(ear_time),n_elements(range))
         pnoise2_ear=fltarr(n_elements(ear_time))       
         if unix_time[0] ne 0 then begin
            dlimit=create_struct('data_att',create_struct('acknowledgment',acknowledgstring,'PI_NAME', 'M. Yamamoto'))         
           ;Store data of wind velocity
            for l=0, n_elements(beam)-1 do begin
               bname2[l]=string(beam[l]+1)
               bname[l]=strsplit(bname2[l],' ', /extract)
               for k=0, n_elements(range)-1 do begin
                  height2[k]=height[k,l]
               endfor
               for i=0, n_elements(ear_time)-1 do begin
                  for k=0, n_elements(range)-1 do begin
                     pwr2_ear[i,k]=pwr1[i,k,l]
                  endfor
               endfor
              ;print, pwr2_ear
               store_data,'iug_ear_fai'+parameters[ii]+'_pwr'+bname[l],data={x:ear_time, y:pwr2_ear, v:height2},dlimit=dlimit
               new_vars=tnames('iug_ear_fai'+parameters[ii]+'_pwr'+bname[l])
               if new_vars[0] ne '' then begin                 
                  options,'iug_ear_fai'+parameters[ii]+'_pwr'+bname[l],ytitle='EAR-iono!CHeight!C[km]',ztitle='pwr'+bname[l]+'!C[dB]'
                  options,'iug_ear_fai'+parameters[ii]+'_pwr'+bname[l],'spec',1
                  tdegap, 'iug_ear_fai'+parameters[ii]+'_pwr'+bname[l], /overwrite
               endif               
               for i=0, n_elements(ear_time)-1 do begin
                  for k=0, n_elements(range)-1 do begin
                     wdt2_ear[i,k]=wdt1[i,k,l]
                  endfor
               endfor
               store_data,'iug_ear_fai'+parameters[ii]+'_wdt'+bname[l],data={x:ear_time, y:wdt2_ear, v:height2},dlimit=dlimit
               new_vars=tnames('iug_ear_fai'+parameters[ii]+'_wdt'+bname[l])
               if new_vars[0] ne '' then begin 
                  options,'iug_ear_fai'+parameters[ii]+'_wdt'+bname[l],ytitle='EAR-iono!CHeight!C[km]',ztitle='wdt'+bname[l]+'!C[m/s]'
                  options,'iug_ear_fai'+parameters[ii]+'_wdt'+bname[l],'spec',1
                  tdegap, 'iug_ear_fai'+parameters[ii]+'_wdt'+bname[l], /overwrite
               endif               
               for i=0, n_elements(ear_time)-1 do begin
                  for k=0, n_elements(range)-1 do begin
                     dpl2_ear[i,k]=dpl1[i,k,l]
                  endfor
               endfor
               store_data,'iug_ear_fai'+parameters[ii]+'_dpl'+bname[l],data={x:ear_time, y:dpl2_ear, v:height2},dlimit=dlimit
               new_vars=tnames('iug_ear_fai'+parameters[ii]+'_dpl'+bname[l])
               if new_vars[0] ne '' then begin 
                  options,'iug_ear_fai'+parameters[ii]+'_dpl'+bname[l],ytitle='EAR-iono!CHeight!C[km]',ztitle='dpl'+bname[l]+'!C[m/s]'
                  options,'iug_ear_fai'+parameters[ii]+'_dpl'+bname[l],'spec',1
                  tdegap, 'iug_ear_fai'+parameters[ii]+'_dpl'+bname[l], /overwrite
               endif             
               for i=0, n_elements(time)-1 do begin
                  pnoise2_ear[i]=pn1[i,l]
               end
               store_data,'iug_ear_fai'+parameters[ii]+'_pn'+bname[l],data={x:ear_time, y:pnoise2_ear},dlimit=dlimit
               new_vars=tnames('iug_ear_fai'+parameters[ii]+'_pn'+bname[l])
               if new_vars[0] ne '' then begin 
                  options,'iug_ear_fai'+parameters[ii]+'_pn'+bname[l],ytitle='pn'+bname[l]+'!C[dB]' 
                  tdegap, 'iug_ear_fai'+parameters[ii]+'_pn'+bname[l], /overwrite    
               endif      
            endfor
         endif
         new_vars=tnames('iug_ear_fai*')
         if new_vars[0] ne '' then begin    
            print,'*****************************
            print,'Data loading is successful!!'
            print,'*****************************
         endif
      endif
   endif
  ;Clear time and data buffer:
   ear_time=0
   pwr1 = 0
   wdt1 = 0
   dpl1 = 0
   pn1 = 0
   
   jj=n_elements(local_paths)
endfor

;*************************
;print of acknowledgement:
;*************************
print, '****************************************************************
print, 'Acknowledgement'
print, '****************************************************************
print, 'The Equatorial Atmosphere Radar belongs to Research Institute for '
print, 'Sustainable Humanosphere (RISH), Kyoto University and is operated by '
print, 'RISH and National Institute of Aeronautics and Space (LAPAN) Indonesia. '
print, 'Distribution of the data has been partly supported by the IUGONET '
print, '(Inter-university Upper atmosphere Global Observation NETwork) project '
print, '(http://www.iugonet.org/) funded by the Ministry of Education, Culture, '
print, 'Sports, Science and Technology (MEXT), Japan.'

end
