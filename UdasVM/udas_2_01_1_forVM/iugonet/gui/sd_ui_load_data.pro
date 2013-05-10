;+ 
;NAME:
;  sd_ui_load_data
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
pro sd_ui_load_data_event,event

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
        ;=== Call sd_ui_load_data_load_pro ===
        ;======================================
        sd_ui_load_data_load_pro, $
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
;***** sd_ui_load_data *****
;****************************
pro sd_ui_load_data,tabid,loadedData,historyWin,statusBar,treeCopyPtr,timeRangeObj,callSequence,loadTree=loadTree,timeWidget=timeWidget
  compile_opt idl2,hidden
  
  ;load bitmap resources
  getresourcepath,rpath
  rightArrow = read_bmp(rpath + 'arrow_000_medium.bmp', /rgb)
  ;leftArrow = read_bmp(rpath + 'arrow_180_medium.bmp', /rgb)
  trashcan = read_bmp(rpath + 'trashcan.bmp', /rgb)
  
  thm_ui_match_background, tabid, rightArrow 
  ;thm_ui_match_background, tabid, leftArrow
  thm_ui_match_background, tabid, trashcan
  
  ;===== added sd_ui_load_data_event =====;
  topBase = Widget_Base(tabid, /Row, /Align_Top, /Align_Left, YPad=1,event_pro='sd_ui_load_data_event') 
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

  instrumentArray = ['SuperDARN_radar']
  
  instrumentCombo = widget_combobox(instrumentBase,$
                                       value=instrumentArray,$
                                       uvalue='INSTRUMENT',$
                                       uname='instrument')

                                              
  ;================================
  ;=========== Data Type ==========
  ;================================
  typeArray = ptrarr(1)
  
  typeArray[0] = ptr_new(['All', 'Northern_Hemisphere', 'Southern_Hemisphere']) 
                                     
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
  paramArray = ptrarr(1)
  paramArray[0] = ptr_new(ptrarr(3))
  
  (*paramArray[0])[0] = ptr_new(['*(all)','bks','cve','cvw','fhe','fhw','gbr','han','hok','inv','kap',$
                                          'kod','ksr','pgr','pyk','rkn','sas','sto','sye','sys','tig',$
                                          'unw','wal'])
  (*paramArray[0])[1] = ptr_new(['*(all)','bks','cve','cvw','fhe','fhw','gbr','han','hok','inv','kap',$
                                          'kod','ksr','pgr','pyk','rkn','sas','sto','wal'])
  (*paramArray[0])[2] = ptr_new(['*(all)','sye','sys','tig','unw'])
   
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

  param2Array = ptrarr(1)
  param2Array[0] = ptr_new(ptrarr(3))
    
  (*param2Array[0])[0] = ptr_new(['*','azim_no','pwr','pwr_err','spec_width','spec_width_err','vlos','vlos_err',$
                                  'echo_flag','quality','quality_flag','vnorth','vnorth_iscat','vnorth_gscat',$
                                  'veast','veast_iscat','veast_gscat','vlos_iscat','vlos_gscat'])
  (*param2Array[0])[1] = ptr_new(['*','azim_no','pwr','pwr_err','spec_width','spec_width_err','vlos','vlos_err',$
                                  'echo_flag','quality','quality_flag','vnorth','vnorth_iscat','vnorth_gscat',$
                                  'veast','veast_iscat','veast_gscat','vlos_iscat','vlos_gscat'])
  (*param2Array[0])[2] = ptr_new(['*','azim_no','pwr','pwr_err','spec_width','spec_width_err','vlos','vlos_err',$
                                  'echo_flag','quality','quality_flag','vnorth','vnorth_iscat','vnorth_gscat',$
                                  'veast','veast_iscat','veast_gscat','vlos_iscat','vlos_gscat'])

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
