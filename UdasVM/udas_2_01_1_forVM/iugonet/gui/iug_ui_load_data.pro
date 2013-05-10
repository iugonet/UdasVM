;+ 
;NAME:
;  iug_ui_load_data
;
;PURPOSE:
;  Generates the tab that loads iugonet data for the gui.
;
;HISTORY:
;$LastChangedBy: Y.Tanaka $
;$LastChangedDate: 2010-04-20 $
;
;Modifications:
;A. Shinbori, 02/05/2011
;A. Shinbori, 11/05/2012
;A. Shinbori, 12/06/2012
;A. Shinbori, 24/10/2012
;A. Shinbori, 14/12/2012
;
;--------------------------------------------------------------------------------
pro iug_ui_load_data_event,event

  compile_opt hidden,idl2

  err_xxx = 0
  Catch, err_xxx
  IF (err_xxx NE 0) THEN BEGIN
    Catch, /Cancel
    Help, /Last_Message, Output = err_msg
    if is_struct(state) then begin
      ;send error message
      FOR j = 0, N_Elements(err_msg)-1 DO state.historywin->update,err_msg[j]
      
      if widget_valid(state.baseID) && obj_valid(state.historyWin) then begin 
        thm_gui_error,state.baseid,state.historyWin
      endif
      
      ;update central tree, if possible
      if obj_valid(state.loadTree) then begin
        *state.treeCopyPtr = state.loadTree->getCopy()
      endif  
      
      ;restore state
      Widget_Control, event.TOP, Set_UValue=state, /No_Copy
      
    endif
    Print, 'Error--See history'
    ok=error_message('An unknown error occured and the window must be restarted. See console for details.',$
       /noname, /center, title='Error in Load Data')

    widget_control, event.top,/destroy
  
    RETURN
  ENDIF

  widget_control, event.handler, Get_UValue=state, /no_copy
  
  ;Options
  widget_control, event.id, get_uvalue = uval
  ;not all widgets are assigned uvalues
  if is_string(uval) then begin
    case uval of
      
      'INSTRUMENT': begin
        typelist = widget_info(event.handler,find_by_uname='typelist')
        widget_control,typelist,set_value=*state.typeArray[event.index],set_list_select=0
        paramList = widget_info(event.handler,find_by_uname='paramlist')
        widget_control,paramList,set_value=*(*state.paramArray[event.index])[0]
       ;========================================================================
       ;added the two lines of widget_control to parameters-2
        paramList2 = widget_info(event.handler,find_by_uname='paramlist2')
        widget_control,paramList2,set_value=*(*state.param2Array[event.index])[0]
       ;========================================================================  
      end
      'TYPELIST': begin
        instrument = widget_info(event.handler,find_by_uname='instrument')
        text = widget_info(instrument,/combobox_gettext)
        idx = (where(text eq state.instrumentArray))[0]
        parameter = widget_info(event.handler,find_by_uname='paramlist')
        widget_control,parameter,set_value=*(*state.paramArray[idx])[event.index]
       ;===========================================================================
       ;added the two lines of widget_control in order to have a relation between 
       ;instrument and parameters-2.
        parameter2 = widget_info(event.handler,find_by_uname='paramlist2')
        widget_control,parameter2,set_value=*(*state.param2Array[idx])[event.index]
       ;===========================================================================   
      end
      ;==================================================================
      ;added the two lines controlling the widget of site or parameters-1
    ;  'PARAMLIST': begin    
    ;  end
      ;==================================================================
      'CLEARPARAM': begin
        paramlist = widget_info(event.handler,find_by_uname='paramlist')
        widget_control,paramlist,set_list_select=-1
      end
      ;==================================================================
      ;added the following lines controlling the widget of CLEARPARAM2
       'CLEARPARAM2': begin
        paramlist2 = widget_info(event.handler,find_by_uname='paramlist2')
        widget_control,paramlist2,set_list_select=-1
      end
      ;==================================================================
      'CLEARDATA': begin
        ok = dialog_message("This will delete all currently loaded data.  Are you sure you wish to continue?",/question,/default_no,/center)
        
        if strlowcase(ok) eq 'yes' then begin
          datanames = state.loadedData->getAll(/parent)
          if is_string(datanames) then begin
            for i = 0,n_elements(dataNames)-1 do begin
              result = state.loadedData->remove(datanames[i])
              if ~result then begin
                state.statusBar->update,'Unexpected error while removing data.'
                state.historyWin->update,'Unexpected error while removing data.'
              endif
            endfor
          endif
          state.loadTree->update
          state.callSequence->clearCalls  
        endif
        
      end   
      'DEL': begin
        dataNames = state.loadTree->getValue()
        
        if ptr_valid(datanames[0]) then begin
          for i = 0,n_elements(dataNames)-1 do begin
            result = state.loadedData->remove((*datanames[i]).groupname)
            if ~result then begin
              state.statusBar->update,'Unexpected error while removing data.'
              state.historyWin->update,'Unexpected error while removing data.'
            endif
          endfor
        endif
        state.loadTree->update
   
      end
      'ADD': begin
     
        instrument = widget_info(event.handler,find_by_uname='instrument')
        instrumentText = widget_info(instrument,/combobox_gettext)
        instrumentSelect = (where(instrumentText eq state.instrumentArray))[0] 
        
        type = widget_info(event.handler,find_by_uname='typelist')
        typeSelect = widget_info(type,/list_select)
     
        if typeSelect[0] eq -1 then begin
          state.statusBar->update,'You must select one type'
          state.historyWin->update,'IUGONET add attempted without selecting type'
          break
        endif
        
        typeText = (*state.typeArray[instrumentSelect])[typeSelect]
        
        parameter = widget_info(event.handler,find_by_uname='paramlist')
        paramSelect = widget_info(parameter,/list_select)

        if paramSelect[0] eq -1 then begin
          state.statusBar->update,'You must select at least one parameter'
          state.historyWin->update,'IUGONET add attempted without selecting parameter'
          break
        endif
        
;        ;handle '*' type, if present, introduce all
        if in_set(0,paramSelect) then begin
          paramText = (*(*state.paramArray[instrumentSelect])[typeSelect])
        endif else begin
          paramText = (*(*state.paramArray[instrumentSelect])[typeSelect])[paramSelect]
        endelse

;========================================================================================;
;       Added the following lines of handling the parameter-2
;       
        parameter2 = widget_info(event.handler,find_by_uname='paramlist2')
        param2Select = widget_info(parameter2,/list_select)
        
        if param2Select[0] eq -1 then begin
          state.statusBar->update,'You must select at least one parameter2'
          state.historyWin->update,'IUGONET add attempted without selecting parameter2'
          break
        endif
        
        ;handle '*' type, if present, introduce all
        if in_set(0,param2Select) then begin
          param2Text = (*(*state.param2Array[instrumentSelect])[typeSelect])
        endif else begin
          param2Text = (*(*state.param2Array[instrumentSelect])[typeSelect])[param2Select]
        endelse
;=======================================================================================;
        timeRangeObj = state.timeRangeObj      
        timeRangeObj->getProperty,startTime=startTimeObj,endTime=endTimeObj
      
        startTimeObj->getProperty,tdouble=startTimeDouble,tstring=startTimeString
        endTimeObj->getProperty,tdouble=endTimeDouble,tstring=endTimeString
        
        if startTimeDouble ge endTimeDouble then begin
          state.statusBar->update,'Cannot add data unless end time is greater than start time.'
          state.historyWin->update,'IUGONET add attempted with start time greater than end time.'
          break
        endif
              
        ;======================================
        ;=== Call iug_ui_load_data_load_pro ===
        ;======================================
        iug_ui_load_data_load_pro, $
                                  instrumentText,$
                                  typeText,$
                                  paramText,$
                                  param2Text,$ ;added this parameter
                                  [startTimeString,endTimeString],$
                                  state.loadedData,$
                                  state.statusBar,$
                                  state.historyWin
                                  
      
      
        state.loadTree->update
        
        ;====================================
        ;=== callSequence->addloadiugonet ===
        ;====================================
        state.callSequence->addloadiugonet,$
                               instrumentText,$
                               typeText,$
                               paramText,$
                               param2Text,$ ;added this parameter
                               [startTimeString,endTimeString]
      
      end
      else:
    endcase
  endif
  
  Widget_Control, event.handler, Set_UValue=state, /No_Copy
  return
  
  
end


;****************************
;***** iug_ui_load_data *****
;****************************
pro iug_ui_load_data,tabid,loadedData,historyWin,statusBar,treeCopyPtr,timeRangeObj,callSequence,loadTree=loadTree,timeWidget=timeWidget
  compile_opt idl2,hidden
  
  ;load bitmap resources
  getresourcepath,rpath
  rightArrow = read_bmp(rpath + 'arrow_000_medium.bmp', /rgb)
  ;leftArrow = read_bmp(rpath + 'arrow_180_medium.bmp', /rgb)
  trashcan = read_bmp(rpath + 'trashcan.bmp', /rgb)
  
  thm_ui_match_background, tabid, rightArrow 
  ;thm_ui_match_background, tabid, leftArrow
  thm_ui_match_background, tabid, trashcan
  
  ;===== added iug_ui_load_data_event =====;
  topBase = Widget_Base(tabid, /Row, /Align_Top, /Align_Left, YPad=1,event_pro='iug_ui_load_data_event') 
 ; bottomBase=widget_base(topBase,/col,/align_bottom)
  leftBase = widget_base(topBase,/col)
  middleBase = widget_base(topBase,/col,/align_center)
  rightBase = widget_base(topBase,/col)
  
  ;===== Modified leftLabel =====;
  leftLabel = widget_label(leftBase,value='IUGONET Data Selection:',/align_left)
  rightLabel = widget_label(rightBase,value='Data Loaded:',/align_left)
  
  ;clearDataBase = widget_base(bottomBase,/align_bottom)
 ; NotesLabel = widget_label(clearDataBase,value='* in collaboration with ERG-SC')
  
  selectionBase = widget_base(leftBase,/col,/frame)
  
  treeBase = widget_base(rightBase,/col,/frame)

  addButton = Widget_Button(middleBase, Value=rightArrow, /Bitmap,  UValue='ADD', $
              ToolTip='Load data selection')
  minusButton = Widget_Button(middleBase, Value=trashcan, /Bitmap, $
                Uvalue='DEL', $
                ToolTip='Delete data selected in the list of loaded data')
  
  loadTree = Obj_New('thm_ui_widget_tree', treeBase, 'LOADTREE', loadedData, $
                     XSize=400, YSize=425, mode=0, /multi,/showdatetime)
                     
  loadTree->update,from_copy=*treeCopyPtr
  
  clearDataBase = widget_base(rightBase,/row,/align_center)
  clearDataButton = widget_button(clearDataBase,value='Delete All Data',uvalue='CLEARDATA',/align_center,ToolTip='Deletes all loaded data')
 
  ;===== Added the left-bottom label =============================================================================================================;
  NotesBase = widget_base(leftBase,/row,/align_left)
  NotesLabel = widget_label(NotesBase,value='Note: # means that the load procedure has been developed')
  NotesBase = widget_base(leftBase,/row,/align_left)
  NotesLabel = widget_label(NotesBase,value='       in collaboration with the ERG Science Center.')
  ;==================================================================================================================================================;
  timeWidget = thm_ui_time_widget(selectionBase,$
                                  statusBar,$
                                  historyWin,$
                                  timeRangeObj=timeRangeObj,$
                                  uvalue='TIME_WIDGET',$
                                  uname='time_widget')
  
  ;================================
  ;========== Instrument ==========
  ;================================
  instrumentBase = widget_base(selectionBase,/row) 
  
  instrumentLabel = widget_label(instrumentBase,value='Instrument Type: ')

  instrumentArray = ['Automatic_Weather_Station', 'Boundary_Layer_Radar', 'EISCAT_radar', $
                     'Equatorial_Atmosphere_Radar', 'geomagnetic_field_fluxgate', 'geomagnetic_field_induction', $
                     'geomagnetic_field_index', 'HF_Solar_Jupiter_radio_spectrometer', 'Iitate_Planetary_Radio_Telescope', $
                     'Imaging_Riometer', 'Ionosonde', 'Lower_Troposphere_Radar', $
                     'Low_Frequency_radio_transmitter', 'Medium_Frequency_radar', 'Meteor_Wind_radar', $
                     'Middle_Upper_atmosphere_radar', 'Radiosonde', 'Wind_Profiler_Radar_(LQ-7)']
  
  instrumentCombo = widget_combobox(instrumentBase,$
                                       value=instrumentArray,$
                                       uvalue='INSTRUMENT',$
                                       uname='instrument')

                                              
  ;================================
  ;=========== Data Type ==========
  ;================================
  typeArray = ptrarr(18)
  
  typeArray[0] = ptr_new(['troposphere']) 
  typeArray[1] = ptr_new(['troposphere'])
  typeArray[2] = ptr_new(['altitude_prof','latitude_prof','longitude_prof'])
  typeArray[3] = ptr_new(['troposphere','e_region','ef_region','v_region','f_region'])
  typeArray[4] = ptr_new(['magdas','210mm#','WDC_kyoto','NIPR_mag#'])
  typeArray[5] = ptr_new(['NIPR_mag#','STEL#'])
  typeArray[6] = ptr_new(['Dst_index','AE_index','ASY_index'])
  typeArray[7] = ptr_new(['Sun_or_Jupiter'])
  typeArray[8] = ptr_new(['Sun'])
  typeArray[9] = ptr_new(['30MHz','38.2MHz'])
  typeArray[10] = ptr_new(['ionosphere']) 
  typeArray[11] = ptr_new(['troposphere'])
  typeArray[12] = ptr_new(['ath','nal'])
  typeArray[13] = ptr_new(['thermosphere'])
  typeArray[14] = ptr_new(['thermosphere'])
  typeArray[15] = ptr_new(['troposphere','mesosphere','ionosphere','meteor'])
  typeArray[16] = ptr_new(['DAWEX','misc']) 
  typeArray[17] = ptr_new(['troposphere'])  
                                     
  dataBase = widget_base(selectionBase,/row)
  typeBase = widget_base(dataBase,/col)
  typeLabel = widget_label(typeBase,value='Data Type:')
  typeList = widget_list(typeBase,$
                          value=*typeArray[0],$
                          uname='typelist',$
                          uvalue='TYPELIST',$
                          xsize=16,$
                          ysize=15)
  
  widget_control,typeList,set_list_select=0
;===================================================================================================================================;
; The following programs consist of calling site or parameters 1 and parameters 2.
; The number of two elements of two dimensinal paramArray[*][*] and param2Array[*][*] must be the same value.
; For example, if the numbers of paramArray[a][b] elements are a=10, b=15, those of paramArray[c][d] must be c=10, d=15.
;  
;  
  ;============================================
  ;========== Sites and Parameters-1 ==========
  ;============================================
  paramArray = ptrarr(18)
  paramArray[0] = ptr_new(ptrarr(1))
  paramArray[1] = ptr_new(ptrarr(1))
  paramArray[2] = ptr_new(ptrarr(3))
  paramArray[3] = ptr_new(ptrarr(5))
  paramArray[4] = ptr_new(ptrarr(4))
  paramArray[5] = ptr_new(ptrarr(2))
  paramArray[6] = ptr_new(ptrarr(3))
  paramArray[7] = ptr_new(ptrarr(1))
  paramArray[8] = ptr_new(ptrarr(1))
  paramArray[9] = ptr_new(ptrarr(2))
  paramArray[10] = ptr_new(ptrarr(1))
  paramArray[11] = ptr_new(ptrarr(1))
  paramArray[12] = ptr_new(ptrarr(2))
  paramArray[13] = ptr_new(ptrarr(1))
  paramArray[14] = ptr_new(ptrarr(1))
  paramArray[15] = ptr_new(ptrarr(4)) 
  paramArray[16] = ptr_new(ptrarr(2))
  paramArray[17] = ptr_new(ptrarr(1))
  
  (*paramArray[0])[0] = ptr_new(['*(all)','bik','ktb','mnd','pon','sgk'])
  (*paramArray[1])[0] = ptr_new(['*(all)','ktb','sgk','srp'])
  (*paramArray[2])[0] = ptr_new(['*(all)','esr_32m','esr_42m','tro_vhf','tro_uhf','kir_uhf','sod_uhf'])
  (*paramArray[2])[1] = ptr_new(['*(all)','esr_32m','esr_42m','tro_vhf','tro_uhf','kir_uhf','sod_uhf'])
  (*paramArray[2])[2] = ptr_new(['*(all)','esr_32m','esr_42m','tro_vhf','tro_uhf','kir_uhf','sod_uhf'])
  (*paramArray[3])[0] = ptr_new(['*(all)'])
  (*paramArray[3])[1] = ptr_new(['*(all)','eb1p2a','eb1p2b','eb1p2c','eb2p1a','eb3p2a','eb3p2b','eb3p4a','eb3p4b','eb3p4c',$
                                 'eb3p4d','eb3p4e','eb3p4f','eb3p4g','eb3p4h','eb4p2c','eb4p2d','eb4p4','eb4p4a','eb4p4b','eb4p4d','eb5p4a'])
  (*paramArray[3])[2] = ptr_new(['*(all)','efb1p16','efb1p16a','efb1p16b'])                               
  (*paramArray[3])[3] = ptr_new(['*(all)','vb3p4a','150p8c8a','150p8c8b','150p8c8c','150p8c8d','150p8c8e','150p8c8b2a','150p8c8b2b','150p8c8b2c','150p8c8b2d','150p8c8b2e','150p8c8b2f'])
  (*paramArray[3])[4] = ptr_new(['*(all)','fb1p16a','fb1p16b','fb1p16c','fb1p16d','fb1p16e','fb1p16f','fb1p16g','fb1p16h','fb1p16i',$
                                 'fb1p16j1','fb1p16j2','fb1p16j3','fb1p16j4','fb1p16j5','fb1p16j6','fb1p16j7','fb1p16j8','fb1p16j9',$
                                 'fb1p16j10','fb1p16j11','fb1p16k1','fb1p16k2','fb1p16k3','fb1p16k4','fb1p16k5','fb1p16m2','fb1p16m3',$
                                 'fb1p16m4','fb8p16','fb8p16k1','fb8p16k2','fb8p16k3','fb8p16k4','fb8p16m1','fb8p16m2'])
  (*paramArray[4])[0] = ptr_new(['*(all)','anc','asb','cmd','cst','dav','daw','dvs','eus','her', $
                                 'hob','ilr','kuj','lkw','mcq','mgd','mlb','mnd','mut', $
                                 'onw','prp','ptk','roc','sma','tir','twv','wad','yap'])
  (*paramArray[4])[1] = ptr_new(['*(all)','adl','asa','bik','bji','bsw','can','cbi','chd','cst', $
                                 'dal','daw','ewa','gua','irt','kag','kat','kor','kot', $
                                 'ktb','ktn','lmt','lnp','mgd','mcq','msr','mut','onw', $
                                 'ppi','ptk','ptn','rik','tik','wep','wew','wtk','yak', $
                                 'yap','ymk','zgn','zyk'])
  (*paramArray[4])[2] = ptr_new(['*(all)','aaa','aae','abg','abk','abn','agn','aia','ale','alm','aml','ams',$
                                 'amt','amu','anc','ann','api','aqu','arc','are','ark','ars','art','asc','ash','aso','asp',$
                                 'bag','bde','bdv','bel','bfe','bfo','bgy','bji','bjn','blc','blt','bmt','bng','bou',$
                                 'box','brt','brw','bsl','byr','can','cao','cax','cbb','cbi','ccs','cdp','clf','clh',$
                                 'cmo','cnb','cnh','coi','cpa','csy','cta','cto','ctx','cwe','czt','dal','dav','dbn',$
                                 'dik','dlr','dnb','dob','dou','drv','dvs','ebr','egs','eic','elt','esa','esk','ett',$
                                 'eyr','fan','fcc','fra','frd','frn','fsp','ftn','fuq','fur','gck','gdh','gll','glm',$
                                 'gln','gna','grm','gua','gui','gwc','gzh','had','hba','hbk','her','his','hlp','hlw',$
                                 'hna','hon','hrb','hrn','hty','hua','hvn','hyb','ibd','ilm','iqa','irt','isk','izn',$
                                 'jai','jrv','kak','kdu','kgd','kgl','kir','kiv','kny','knz','kod','kom','kor','kou',$
                                 'krc','ksh','kzn','laa','ldv','len','ler','lgr','liv','lmm','lnn','lnp','lov','lpb',$
                                 'lpd','lqa','lrm','lrv','lua','lvv','lwi','lzh','mab','maw','mbc','mbo','mcp','mcq',$
                                 'mea','mfp','mgd','mid','mir','miz','mlt','mmb','mmk','mnk','mol','mos','mrn','mub',$
                                 'mut','mzl','nag','nai','naq','nck','new','ngk','ngp','nkk','nmp','nrd','nur','nvl',$
                                 'nvs','nws','oas','ode','ott','pab','paf','pag','pbq','pcu','peg','pen','pet','phu',$
                                 'pil','pio','piu','pmg','pnd','pod','pon','ppt','pru','psm','pst','ptu','qgz','qix','qsb',$
                                 'que','qzh','rbd','rdj','res','rob','rsv','sab','sba','sco','sfs','sge','shl','shu',$
                                 'sil','sit','sjg','skt','smg','sna','sod','spa','spt','ssh','sso','stj','sto','sua',$
                                 'sud','svd','swi','syo','szt','tah','tal','tam','tan','teh','ten','teo','tfs','thj','thl',$
                                 'thy','tik','tir','tkh','tkt','tmk','tnd','tng','tok','tol','too','trd','tro','trw',$
                                 'tsu','ttb','tuc','tun','uba','ujj','ups','val','vic','vla','vlj','vna','vos','vqs',$
                                 'vsk','vss','wat','whn','whs','wik','wil','wit','wmq','wng','yak','ycb','ykc','yss'])
  (*paramArray[4])[3] = ptr_new(['*(all)','aed','hus','isa','syo','tjo'])
  (*paramArray[5])[0] = ptr_new(['*(all)','syo'])
  (*paramArray[5])[1] = ptr_new(['*(all)','ath','mgd','ptk','msr','sta'])
  (*paramArray[6])[0] = ptr_new(['*(all)','WDC_kyoto'])
  (*paramArray[6])[1] = ptr_new(['*(all)','WDC_kyoto'])
  (*paramArray[6])[2] = ptr_new(['*(all)','WDC_kyoto'])
  (*paramArray[7])[0] = ptr_new(['*(all)','iit'])
  (*paramArray[8])[0] = ptr_new(['*(all)','iit']) 
  (*paramArray[9])[0] = ptr_new(['*(all)','syo']) 
  (*paramArray[9])[1] = ptr_new(['*(all)','syo']) 
  (*paramArray[10])[0] = ptr_new(['*(all)','sgk'])
  (*paramArray[11])[0] = ptr_new(['*(all)','sgk']) 
  (*paramArray[12])[0] = ptr_new(['*(all)','nau','ndk','nlk','npm','nrk','nwc','wwvb'])
  (*paramArray[12])[1] = ptr_new(['*(all)','dcf','gbz','msf','nrk'])
  (*paramArray[13])[0] = ptr_new(['*(all)','pam'])
  (*paramArray[14])[0] = ptr_new(['*(all)','ktb','srp'])
  (*paramArray[15])[0] = ptr_new(['*(all)'])
  (*paramArray[15])[1] = ptr_new(['*(all)','org','scr'])
  (*paramArray[15])[2] = ptr_new(['*(all)'])
  (*paramArray[15])[3] = ptr_new(['*(all)'])
  (*paramArray[16])[0] = ptr_new(['*(all)','drw','gpn','ktr'])
  (*paramArray[16])[1] = ptr_new(['*(all)','ktb','sgk','srp'])
  (*paramArray[17])[0] = ptr_new(['*(all)','bik','mnd','pon','sgk'])
   
  paramBase = widget_base(dataBase,/col)
  paramLabel = widget_label(paramBase,value='Site or parameter(s)-1:')
  paramList = widget_list(paramBase,$
                         value=*((*paramArray[0])[0]),$
                         /multiple,$
                         uname='paramlist',$
                         uvalue='PARAMLIST',$
                         xsize=24,$
                         ysize=15)
  
  widget_control,paramList,set_list_select=0 
  clearTypeButton = widget_button(paramBase,value='Clear Site or Parameters-1',uvalue='CLEARPARAM',ToolTip='Deselect all sites and parameters types') 

  ;============================================
  ;========== Parameters-2 ====================
  ;============================================  

  param2Array = ptrarr(18)
  param2Array[0] = ptr_new(ptrarr(1))
  param2Array[1] = ptr_new(ptrarr(1))
  param2Array[2] = ptr_new(ptrarr(3))
  param2Array[3] = ptr_new(ptrarr(5))
  param2Array[4] = ptr_new(ptrarr(4))
  param2Array[5] = ptr_new(ptrarr(2))
  param2Array[6] = ptr_new(ptrarr(3))
  param2Array[7] = ptr_new(ptrarr(1))
  param2Array[8] = ptr_new(ptrarr(1))
  param2Array[9] = ptr_new(ptrarr(2))
  param2Array[10] = ptr_new(ptrarr(1))
  param2Array[11] = ptr_new(ptrarr(1))
  param2Array[12] = ptr_new(ptrarr(2))
  param2Array[13] = ptr_new(ptrarr(1))
  param2Array[14] = ptr_new(ptrarr(1))
  param2Array[15] = ptr_new(ptrarr(4)) 
  param2Array[16] = ptr_new(ptrarr(2))
  param2Array[17] = ptr_new(ptrarr(1))
    
  (*param2Array[0])[0] = ptr_new(['*','press','precipi','rh','sr','temp','uwnd','vwnd','wnddir','wndspd'])
  (*param2Array[1])[0] = ptr_new(['*','uwnd','vwnd','wwnd','pwr1','pwr2','pwr3','pwr4','pwr5','wdt1','wdt2','wdt3','wdt4','wdt5'])
  (*param2Array[2])[0] = ptr_new(['*','ne','neerr','te','teerr','ti','tierr','vi','vierr','pulse','inttim',$
                                   'lat','long','alt','colf','comp','q','qflag'])
  (*param2Array[2])[1] = ptr_new(['*','ne','neerr','te','teerr','ti','tierr','vi','vierr','pulse','inttim',$
                                   'lat','long','alt','colf','comp','q','qflag'])
  (*param2Array[2])[2] = ptr_new(['*','ne','neerr','te','teerr','ti','tierr','vi','vierr','pulse','inttim',$
                                   'lat','long','alt','colf','comp','q','qflag'])
  (*param2Array[3])[0] = ptr_new(['*','uwnd','vwnd','wwnd','pwr1','pwr2','pwr3','pwr4','pwr5','wdt1','wdt2',$
                                  'wdt3','wdt4','wdt5','dpl1','dpl2','dpl3','dpl4','dpl5','pn1','pn2','pn3','pn4','pn5'])
  (*param2Array[3])[1] = ptr_new(['*','dpl1','dpl2','dpl3','dpl4','dpl5','pwr1','pwr2','pwr3','pwr4','pwr5',$
                                  'wdt1','wdt2','wdt3','wdt4','wdt5','pn1','pn2','pn3','pn4','pn5'])
  (*param2Array[3])[2] = ptr_new(['*','dpl1','pwr1','wdt1','pn1'])
  (*param2Array[3])[3] = ptr_new(['*','dpl1','dpl2','dpl3','pwr1','pwr2','pwr3','wdt1','wdt2','wdt3','pn1','pn2','pn3'])
  (*param2Array[3])[4] = ptr_new(['*','dpl1','dpl2','dpl3','dpl4','dpl5','dpl6','dpl7','dpl8','pwr1','pwr2','pwr3','pwr4','pwr5',$
                                  'pwr6','pwr7','pwr8','wdt1','wdt2','wdt3','wdt4','wdt5','wdt6','wdt7','wdt8','pn1',$
                                  'pn2','pn3','pn4','pn5','pn6','pn7','pn8']) 
  (*param2Array[4])[0] = ptr_new(['*'])
  (*param2Array[4])[1] = ptr_new(['*','1min','1h'])
  (*param2Array[4])[2] = ptr_new(['*','min','hour'])
  (*param2Array[4])[3] = ptr_new(['*','1sec'])  
  (*param2Array[5])[0] = ptr_new(['*'])
  (*param2Array[5])[1] = ptr_new(['*'])
  (*param2Array[6])[0] = ptr_new(['*','final','prov'])
  (*param2Array[6])[1] = ptr_new(['*','min','hour','prov_min','prov_hour'])
  (*param2Array[6])[2] = ptr_new(['*','asy','sym'])
  (*param2Array[7])[0] = ptr_new(['*','RH','LH'])
  (*param2Array[8])[0] = ptr_new(['*','iprt_sun_L','iprt_sun_R']) 
  (*param2Array[9])[0] = ptr_new(['*','N0-7E0','N0-7E1','N0-7E2','N0-7E3','N0-7E4','N0-7E5','N0-7E6','N0-7E7','N0E0-7','N1E0-7','N2E0-7','N3E0-7','N4E0-7','N5E0-7','N6E0-7','N7E0-7']) 
  (*param2Array[9])[1] = ptr_new(['*','N0-7E0','N0-7E1','N0-7E2','N0-7E3','N0-7E4','N0-7E5','N0-7E6','N0-7E7','N0E0-7','N1E0-7','N2E0-7','N3E0-7','N4E0-7','N5E0-7','N6E0-7','N7E0-7']) 
  (*param2Array[10])[0] = ptr_new(['*','2MHz','3MHz','4MHz','5MHz','6MHz','7MHz','8MHz','9MHz','10MHz','11MHz','12MHz','13MHz','14MHz','15MHz','16MHz','17MHz','18MHz']) 
  (*param2Array[11])[0] = ptr_new(['*','uwnd','vwnd','wwnd','pwr1','pwr2','pwr3','pwr4','pwr5','wdt1','wdt2','wdt3','wdt4','wdt5'])                            
  (*param2Array[12])[0] = ptr_new(['*','power','phase'])                              
  (*param2Array[12])[1] = ptr_new(['*','power','phase'])                              
  (*param2Array[13])[0] = ptr_new(['*','uwnd','vwnd','wwnd'])                              
  (*param2Array[14])[0] = ptr_new(['*','h2t60min00','h2t60min30','h4t60min00','h4t60min30','h4t240min00'])
  (*param2Array[15])[0] = ptr_new(['*','uwnd','vwnd','wwnd','pwr1','pwr2','pwr3','pwr4','pwr5','wdt1','wdt2',$
                                  'wdt3','wdt4','wdt5','dpl1','dpl2','dpl3','dpl4','dpl5','pn1','pn2','pn3','pn4','pn5'])
  (*param2Array[15])[1] = ptr_new(['*','uwnd','vwnd','wwnd','pwr1','pwr2','pwr3','pwr4','pwr5','wdt1','wdt2',$
                                  'wdt3','wdt4','wdt5','dpl1','dpl2','dpl3','dpl4','dpl5','pn1','pn2','pn3','pn4','pn5']) 
  (*param2Array[15])[2] = ptr_new(['*','Vperp_e','Vperp_n','Vpara_u','Vz_ew','Vz_ns','Vd_b','pwr1','pwr2','pwr3','pwr4','te','ti','er_te','er_ti','er_tr','snr'])
  (*param2Array[15])[3] = ptr_new(['*','h1t60min00','h1t60min30','h2t60min00','h2t60min30'])                                
  (*param2Array[16])[0] = ptr_new(['*','press','temp','rh','dewp','uwnd','vwnd'])
  (*param2Array[16])[1] = ptr_new(['*','press','temp','rh','dewp','uwnd','vwnd'])
  (*param2Array[17])[0] = ptr_new(['*','uwnd','vwnd','wwnd','pwr1','pwr2','pwr3','pwr4','pwr5','wdt1','wdt2','wdt3','wdt4','wdt5'])
                  
  paramBase = widget_base(dataBase,/col)
  paramLabel = widget_label(paramBase,value='Parameter(s)-2:')
  paramList2 = widget_list(paramBase,$
                         value=*((*param2Array[0])[0]),$
                         /multiple,$
                         uname='paramlist2',$
                         xsize=24,$
                         ysize=15)
  
  widget_control,paramList2,set_list_select=0
                           
  clearTypeButton = widget_button(paramBase,value='Clear Parameters-2',uvalue='CLEARPARAM2',ToolTip='Deselect all parameters types') 
;===================================================================================================================================;
   
  state = {baseid:topBase,$
           loadTree:loadTree,$
           treeCopyPtr:treeCopyPtr,$
           timeRangeObj:timeRangeObj,$
           statusBar:statusBar,$
           historyWin:historyWin,$
           loadedData:loadedData,$
           callSequence:callSequence,$
           instrumentArray:instrumentArray,$
           typeArray:typeArray,$
           paramArray:paramArray,$
           param2Array:param2Array} ;added this parameter
           
  widget_control,topBase,set_uvalue=state
                                  
  return
  
end
