;*******************************
; resolve_vm
;*******************************
pro resolve_vm, path_tdas

;----- resolve_all -----;
resolve_all, /continue_on_error

;----- resolve_all class files -----;
cmd_class='resolve_all, /continue_on_error, class=['

files_tdas = file_search(path_tdas, '*.pro', /windows_short_names)

nclass=0
for i=0L, n_elements(files_tdas)-1 do begin
    pos=strpos(files_tdas[i],'/',/reverse_search)
    fname=strmid(files_tdas[i], pos+1, strlen(files_tdas[i])-pos)

    if strlen(fname) gt 12 then begin
        fname_define=strmid(fname, strlen(fname)-12, 12)
        if fname_define eq '__define.pro' then begin
            if nclass gt 0 then begin
                cmd_class = cmd_class + ','
            endif
            class1 = strmid(fname, 0, strlen(fname)-12)
            cmd_class = cmd_class + '''
            cmd_class = cmd_class + class1
            cmd_class = cmd_class + '''
            nclass++
        endif
    endif
endfor

if nclass eq 0 then begin
    print, 'There is no class!!'
    stop
endif

cmd_class = cmd_class + ']'

print, cmd_class

r=execute(cmd_class)

end

