;+
;
;NAME:
;iug_load_wpr_rish
;
;PURPOSE:
;  Queries the Kyoto_RISH servers for the observation data (uwnd, vwnd, wwnd, pwr1-5, wdt1-5)
;  in the CSV format taken by the Luneberg lens wind profiler radar (LL-WPR) and loads data into
;  tplot format.
;
;SYNTAX:
; iug_load_wpr_rish, datatype = datatype, site=site, parameter=parameter, $
;                        downloadonly=downloadonly, trange=trange, verbose=verbose
;
;KEYWOARDS:
;  datatype = Observation data type. For example, iug_load_wpr_rish, datatype = 'troposphere'.
;            The default is 'troposphere'. 
;   site = LTR observation site.  
;          For example, iug_load_wpr_rish, site = 'sgk'.
;          The default is 'all', i.e., load all available observation points.
;  parameter = parameter name of WPR obervation data.  
;          For example, iug_load_wpr_rish, parameter = 'uwnd'.
;          The default is 'all', i.e., load all available parameters.
;  trange = (Optional) Time range of interest  (2 element array), if
;          this is not set, the default is to prompt the user. Note
;          that if the input time range is not a full day, a full
;          day's data is loaded.
;  /downloadonly, if set, then only download the data, do not load it
;                 into variables.
;
;CODE:
; A. Shinbori, 06/10/2011.
;
;MODIFICATIONS:
; A. Shinbori, 26/12/2011.
; A. Shinbori. 31/01/2012.
; A. Shinbori, 10/02/2012.
; A. Shinbori, 04/03/2013.
; A. Shinbori, 08/04/2013.
;  
;ACKNOWLEDGEMENT:
; $LastChangedBy:  $
; $LastChangedDate:  $
; $LastChangedRevision:  $
; $URL $
;-

pro iug_load_wpr_rish, datatype = datatype, site=site, parameter=parameter, $
                           downloadonly=downloadonly, trange=trange, verbose=verbose

;**************
;keyword check:
;**************
if (not keyword_set(verbose)) then verbose=2

;**************
;datatype check:
;**************
if (not keyword_set(datatype)) then datatype= 'troposphere'

;***********
;site codes:
;***********
;--- all sites (default)
site_code_all = strsplit('bik mnd pon sgk',' ', /extract)

;--- check site codes
if(not keyword_set(site)) then site='all'
site_code = thm_check_valid_name(site, site_code_all, /ignore_case, /include_all)

if n_elements(site_code) eq 1 then begin
   if site_code eq '' then begin
      print, 'This station code is not valid. Please input the allowed keywords, all, bik, mnd, pon, and sgk.'
      return
   endif
endif
print, site_code
 
;***********
;parameters:
;***********
;--- all parameters (default)
parameter_all = strsplit('uwnd vwnd wwnd pwr1 pwr2 pwr3 pwr4 pwr5 wdt1 wdt2 wdt3 wdt4 wdt5',' ', /extract)

;--- check parameters
if(not keyword_set(parameter)) then parameter='all'
parameters = thm_check_valid_name(parameter, parameter_all, /ignore_case, /include_all)

print, parameters

;***************
;data directory:
;***************
site_data_dir = strsplit('bik/wpr/ mnd/wpr/ pon/wpr/ sgk/wpr/',' ', /extract)

;*****************
;defition of unit:
;*****************
;--- all parameters (default)
unit_all = strsplit('m/s dB',' ', /extract)


;******************************************************************
;Loop on downloading files
;******************************************************************
;Get timespan, define FILE_NAMES, and load data:
;===============================================
;
;==================================================================
;Download files, read data, and create tplot vars at each component
;==================================================================
;******************************************************************
;Loop on downloading files
;******************************************************************
;Get timespan, define FILE_NAMES, and load data:
;===============================================
;

;Definition of parameter
jj=0
kk=0
kkk=intarr(n_elements(site_data_dir))
start_time=time_double('2006-3-30')

;In the case that the parameters are except for all.'
if n_elements(site_code) le n_elements(site_data_dir) then begin
   h_max=n_elements(site_code)
   for i=0,n_elements(site_code)-1 do begin
      if site_code[i] eq 'bik' then begin
         kkk[i]=0 
      endif
      if site_code[i] eq 'mnd' then begin
         kkk[i]=1 
      endif
      if site_code[i] eq 'pon' then begin
         kkk[i]=2 
      endif
      if site_code[i] eq 'sgk' then begin
         kkk[i]=3 
      endif
   endfor
endif

for ii=0,h_max-1 do begin
   kk=kkk[ii]
   for iii=0,n_elements(parameters)-1 do begin
      if ~size(fns,/type) then begin
        ;Definition of blr site names:
         if site_code[ii] eq 'bik' then begin
            site_code2='biak'
         endif
         if site_code[ii] eq 'mnd' then begin
            site_code2='manado'
         endif
         if site_code[ii] eq 'pon' then begin
            site_code2='pontianak'
         endif
         if site_code[ii] eq 'sgk' then begin
            site_code2='shigaraki'
         endif
         
        ;****************************
        ;Get files for ith component:
        ;****************************
         file_names = file_dailynames( $
         file_format='YYYYMM/YYYYMMDD/'+$
                     'YYYYMMDD',trange=trange,times=times,/unique)+'.'+parameters[iii]+'.csv'
                     
         ;Set up the start time of the LQ-7 data period:
         in_time =  file_dailynames(file_format='YYYYMMDD',trange=trange,times=times,/unique)
         data_time = time_double(strmid(in_time,0,4)+'-'+strmid(in_time,4,2)+'-'+strmid(in_time,6,2))    
         if data_time[0] lt start_time then break    
           
        ;
        ;Define FILE_RETRIEVE structure:
        ;===============================
         source = file_retrieve(/struct)
         source.verbose=verbose
         source.local_data_dir = root_data_dir() + 'iugonet/rish/misc/'+site_data_dir[kk]+'csv/'
         source.remote_data_dir = 'http://www.rish.kyoto-u.ac.jp/radar-group/blr/'+site_code2+'/data/data/ver02.0212/'
    
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
  
        ;Read the files:
        ;===============      
        ;Definition of parameters and array:
         s=''
         u=''
         time = dblarr(1)

        ;Initialize data and time buffer:
         wpr_data = 0
         wpr_time = 0
         
        ;==============
        ;Loop on files: 
        ;==============
         for h=jj,n_elements(local_paths)-1 do begin
            file= local_paths[h]
            if file_test(/regular,file) then  dprint,'Loading WPR-'+site_code2+' file: ',file $
            else begin
               dprint,'WPR-'+site_code2+' file ',file,' not found. Skipping'
               continue
            endelse
            openr,lun,file,/get_lun    
           ;
           ;Read information of altitude:
           ;=============================
            readf, lun, s
            height = strsplit(s,',',/extract)
            
           ;Definition of time zone at each station:
            if site_code2 eq 'pontianak' then time_zone = 7.0
            if site_code2 eq 'manado' then time_zone = 8.0
            if (site_code2 eq 'biak') or (site_code2 eq 'shigaraki') then time_zone = 9.0   
           
           ;Definition of altitude and data arraies:
            altitude = fltarr(n_elements(height)-1)
            data = strarr(n_elements(height)-1)
            data2 = fltarr(1,n_elements(height)-1)
             
           ;Enter the altitude information:
            for j=0,n_elements(height)-2 do begin
               altitude[j] = float(height[j+1])
            endfor

           ;Enter the missing value:
            for j=0, n_elements(altitude)-1 do begin
               b = float(altitude[j])
               wbad = where(b eq 0,nbad)
               if nbad gt 0 then b[wbad] = !values.f_nan
               data[j] = !values.f_nan
               data2[j] = !values.f_nan
               altitude[j]=b
            endfor

           ;
           ;Loop on readdata:
           ;=================
            k=0
            while(not eof(lun)) do begin
               readf,lun,s
               ok=1
               if strmid(s,0,1) eq '[' then ok=0
               if ok && keyword_set(s) then begin
                  dprint,s ,dlevel=5
                  data = strsplit(s,',',/extract)
         
                 ;Calcurate time:
                 ;==============
                  u=data(0)
                  year = strmid(u,0,4)
                  month = strmid(u,5,2)
                  day = strmid(u,8,2)
                  hour = strmid(u,11,2)
                  minute = strmid(u,14,2)  
                  
                 ;Convert time from LT to UT
                  time = time_double(string(year)+'-'+string(month)+'-'+string(day)+'/'+string(hour)+':'+string(minute)+':'+string(0)) $
                        -time_double(string(1970)+'-'+string(1)+'-'+string(1)+'/'+string(time_zone)+':'+string(0)+':'+string(0))
                 ;
                 ;Enter the missing value:
                  for j=0,n_elements(height)-2 do begin
                     a = float(data[j+1])
                     wbad = where(a eq 999, nbad)
                     if nbad gt 0 then a[wbad] = !values.f_nan
                     data2[k,j]=a
                  endfor
                 
                 ;=============================
                 ;Append data of time and data:
                 ;=============================
                  append_array, wpr_time, time
                  append_array, wpr_data, data2    
               endif
            endwhile 
            free_lun,lun  
         endfor
   
        ;==============================
        ;Store data in TPLOT variables:
        ;==============================
        ;Acknowlegment string (use for creating tplot vars)
         if (site_code[ii] eq 'sgk') then begin
            acknowledgstring = 'If you acquire the Luneberg lens wind profiler radar (LL-WPR) data, ' $
                             + 'we ask that you acknowledge us in your use of the data. This may be done by' $
                             + 'including text such as the LL-WPR data provided by Research Institute' $
                             + 'for Sustainable Humanosphere of Kyoto University. We would also' $
                             + 'appreciate receiving a copy of the relevant publications. The distribution of '$
                             + 'LL-WPR data has been partly supported by the IUGONET (Inter-university Upper '$
                             + 'atmosphere Global Observation NETwork) project (http://www.iugonet.org/) funded '$
                             + 'by the Ministry of Education, Culture, Sports, Science and Technology (MEXT), Japan.'
         endif else begin           
            acknowledgstring = 'If you acquire '+site_code[ii]+'-WPR data, we ask that you acknowledge us in your use of the data. ' $
                             + 'This may be done by including text such as '+site_code[ii]+'-WPR data were obtained by the JEPP-HARIMAU ' $
                             + 'and SATREPS-MCCOE projects promoted by JAMSTEC and BPPT under collaboration with RISH of Kyoto ' $
                             + 'University and LAPAN. We would also appreciate receiving a copy of the relevant publications. ' $
                             + 'The distribution of WPR data has been partly supported by the IUGONET (Inter-university Upper '$
                             + 'atmosphere Global Observation NETwork) project (http://www.iugonet.org/) funded '$
                             + 'by the Ministry of Education, Culture, Sports, Science and Technology (MEXT), Japan.'        
         endelse

         if size(wpr_data,/type) eq 4 then begin 
            o=0 
            if parameters[iii] eq 'pwr1' then o=1  
            if parameters[iii] eq 'pwr2' then o=1
            if parameters[iii] eq 'pwr3' then o=1
            if parameters[iii] eq 'pwr4' then o=1
            if parameters[iii] eq 'pwr5' then o=1
 
            dlimit=create_struct('data_att',create_struct('acknowledgment',acknowledgstring,'PI_NAME', 'H. Hashiguchi'))
            store_data,'iug_wpr_'+site_code[ii]+'_'+parameters[iii],data={x:wpr_time, y:wpr_data, v:altitude},dlimit=dlimit
            new_vars=tnames('iug_wpr_'+site_code[ii]+'_'+parameters[iii])
            if new_vars[0] ne '' then begin                
               options,'iug_wpr_'+site_code[ii]+'_'+parameters[iii],ytitle='WPR-'+site_code[ii]+'!CHeight!C[km]',$
                       ztitle=parameters[iii]+'!C['+unit_all[o]+']'
               options,'iug_wpr_'+site_code[ii]+'_'+parameters[iii], labels='WPR-'+site_code[ii]+' [km]'
              ;add options
               options, 'iug_wpr_'+site_code[ii]+'_'+parameters[iii], 'spec', 1    
            endif
         endif

        ;Clear time and data buffer:
         wpr_data = 0
         wpr_time = 0

         new_vars=tnames('iug_wpr_'+site_code[ii]+'_'+parameters[iii])
         if new_vars[0] ne '' then begin             
           ;add tdegap
            tdegap, 'iug_wpr_'+site_code[ii]+'_'+parameters[iii],/overwrite
         endif
      endif
      jj=n_elements(local_paths)
   endfor
   jj=n_elements(local_paths)
endfor

new_vars=tnames('iug_wpr_*')
if new_vars[0] ne '' then begin     
   print,'*****************************
   print,'Data loading is successful!!'
   print,'*****************************
endif

;******************************
;print of acknowledgement:
;******************************

print, '****************************************************************
print, 'Acknowledgement'
print, '****************************************************************
print, 'we ask that you acknowledge us in your use of the data. This may' 
print, 'be done by including text such as WPR(LQ-7) data provided by Research' 
print, 'Institute for Sustainable Humanosphere of Kyoto University. The Biak, '
print, 'Manado and Pontianak-WPR data were obtained by the JEPP-HARIMAU '
print, 'and SATREPS-MCCOE projects promoted by JAMSTEC and BPPT under collaboration '
print, 'with RISH of Kyoto University and LAPAN.We would also appreciate receiving '
print, 'a copy of the relevant publications. The distribution of WPR(LQ-7) data has '
print, 'been partly supported by the IUGONET (Inter-university Upper atmosphere Global '
print, 'Observation NETwork) project (http://www.iugonet.org/) funded by the Ministry '
print, 'of Education, Culture, Sports, Science and Technology (MEXT), Japan.'

end

