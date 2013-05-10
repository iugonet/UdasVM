;+
;NAME:
;  sd_ui_load_data_load_pro
;
;PURPOSE:
;  Modularized gui sd data loader
;
;HISTORY:
;Y.-M. Tanaka,22/04/2013
;-
;--------------------------------------------------------------------------------
pro sd_ui_load_data_load_pro,$
                         instrument,$
                         datatype,$
                         site_or_param,$
                         parameters,$
                         timeRange,$
                         loadedData,$
                         statusBar,$
                         historyWin
                         

  compile_opt hidden,idl2

  loaded = 0
  notryload = 0

  new_vars = ''
  Answer = ''
  par_names2=''

  tn_before = [tnames('*',create_time=cn_before)]
  
  ;=================================
  ;===== Load the SD data =====
  ;=================================
  if site_or_param[0] eq '*(all)' then begin
      notryload=1
  endif else begin
      erg_load_sdfit, trange=timeRange, sites=site_or_param

      ;Delete the tplot variables not allowed on the GUI:
      store_data, 'sd_*_position_tbl_*',/delete
      store_data, 'sd_*_positioncnt_tbl_*',/delete
      store_data, 'sd_*_veast_bothscat_*',/delete
      store_data, 'sd_*_vnorth_bothscat_*',/delete
      store_data, 'sd_*_vlos_bothscat_*',/delete
    
      if parameters[0] eq '*' then begin
          par_names=tnames('sd_*')
      endif else begin
          par_names=tnames('sd_*_' + parameters +'_?')
      endelse
  endelse

  ;----- Clean up tplot -----;  
  thm_ui_cleanup_tplot,tn_before,create_time_before=cn_before,del_vars=to_delete,new_vars=new_vars

  if new_vars[0] ne '' then begin
      ;----- only add the requested new parameters -----;
      new_vars = ssl_set_intersection([par_names],[new_vars])

      if size(new_vars[0], /type) eq 7 then begin
          loaded = 1
    
          ;----- loop over loaded data -----;
          for i = 0,n_elements(new_vars)-1 do begin
              site_name=strsplit(new_vars[i],'_',/extract)
              site_name2 = site_name[1]

              ;----- Show data policy -----;
              Answer = gui_acknowledgement(instrument=instrument, datatype=datatype, $
                  site_or_param=site_name2, par_names=new_vars[i])

              if Answer eq 'OK' then begin
                  ;----- Add the time clip of tplot variable between start and end times -----;   
                  trange = timeRange
                  time_clip, new_vars[i],trange[0],trange[1],/replace 

                  result = loadedData->add(new_vars[i],mission='SuperDARN',observatory=instrument, instrument=site_name2)
        
                  if ~result then begin
                      statusBar->update,'Error loading: ' + new_vars[i]
                      historyWin->update,'SuperDARN: Error loading: ' + new_vars[i]
                      return
                  endif
              endif else begin
                  break
              endelse
          endfor
      endif
  endif 
  
  if n_elements(to_delete) gt 0 && is_string(to_delete) then begin
    store_data,to_delete,/delete
  endif
                                     
  if (loaded eq 1) and (Answer eq 'OK') then begin     
     statusBar->update,'SuperDARN Data Loaded Successfully'
     historyWin->update,'SuperDARN Data Loaded Successfully'
  endif else if (loaded eq 1) and (Answer eq 'Cancel') then begin     
     statusBar->update,'You must accept the rules of the load for SuperDARN radar data before you load and plot the data.'
     historyWin->update,'You must accept the rules of the load for SuperDARN radar data before you load and plot the data.'
  endif else if (notryload eq 1) and (instrument eq 'SuperDARN_radar') then begin
     statusBar->update,'SuperDARN radar does not support *(all) as a site or parameter(s)-1. Please select others.'
     historyWin->update,'SuperDARN radar does not support *(all) as a site or parameter(s)-1. Please select others.'      
  endif else begin
     statusBar->update,'No Data Loaded.  Data may not be available during this time interval.'
     historyWin->update,'No Data Loaded.  Data may not be available during this time interval.' 
  endelse

end
