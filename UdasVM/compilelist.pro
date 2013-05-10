;*******************************
;  compilelist_sub
;*******************************
pro compilelist_sub, path_tdas, file_compilelist, file_compilelog

DEBUG=0

files_tdas = file_search(path_tdas, '*.pro', /windows_short_names)
opt1='idl2'
opt2='strictarr'
;opt3='defint32'

openw, lun, file_compilelist, /get_lun

printf, lun, 'journal,'''+file_compilelog+''''  ; Save complie log.
printf, lun, 'print,''Compile begins'''

;///// Put *.pro WITHOUT compile_opt first /////;
;----- TDAS library -----;
for i=0L, n_elements(files_tdas)-1 do begin
    find_text, files_tdas[i], 'compile_opt', res, line
    if res eq 0 then begin
        if DEBUG eq 1 then begin
            printf, lun, 'No compile_opt'
        endif else begin
            pos=strpos(files_tdas[i],'/',/reverse_search)
            fname=strmid(files_tdas[i], pos+1, strlen(files_tdas[i])-pos)
            if fname ne 'thm_gui_new.pro' then begin
                printf, lun, "print,'.complie "+files_tdas[i]+"'"
                printf, lun, ".compile '"+files_tdas[i]+"'"
            endif
        endelse
    endif
endfor


;///// Then, *.pro files WITH "compile_opt" follow (but not idl2 or strictarr) /////;
;----- TDAS library -----;
for i=0L, n_elements(files_tdas)-1 do begin
    find_text, files_tdas[i], 'compile_opt', res, line

    if res eq 1 then begin
        find_text2, files_tdas[i], 'compile_opt', opt1, res1, line
        if res1 eq 0 then begin
            find_text2, files_tdas[i], 'compile_opt', opt2, res2, line
	    if res2 eq 0 then begin
                if DEBUG eq 1 then begin
                    printf, lun, 'Find compile_opt'
                endif else begin
                    pos=strpos(files_tdas[i],'/',/reverse_search)
                    fname=strmid(files_tdas[i], pos+1, strlen(files_tdas[i])-pos)
                    if fname ne 'thm_gui_new.pro' then begin
                        printf, lun, "print,'.complie "+files_tdas[i]+"'"
                        printf, lun, ".compile '"+files_tdas[i]+"'"
                    endif
                endelse
            endif
        endif
    endif
endfor


;///// Then, *.pro files WITH "compile_opt strictarr" follow /////;
;----- TDAS library -----;
for i=0L, n_elements(files_tdas)-1 do begin
    find_text, files_tdas[i], 'compile_opt', res, line

    if res eq 1 then begin
        find_text2, files_tdas[i], 'compile_opt', opt1, res1, line
        if res1 eq 0 then begin
            find_text2, files_tdas[i], 'compile_opt', opt2, res2, line
            if res2 eq 1 then begin
                if DEBUG eq 1 then begin
                    printf, lun, strcompress(line)
                endif else begin
                    pos=strpos(files_tdas[i],'/',/reverse_search)
                    fname=strmid(files_tdas[i], pos+1, strlen(files_tdas[i])-pos)
                    if fname ne 'thm_gui_new.pro' then begin
                        printf, lun, "print,'.complie "+files_tdas[i]+"'"
                        printf, lun, ".compile '"+files_tdas[i]+"'"
                    endif
                endelse
            endif
        endif
    endif
endfor


;///// Then, *.pro files WITH "compile_opt idl2" follow /////;
;----- TDAS library -----;
for i=0L, n_elements(files_tdas)-1 do begin
    find_text, files_tdas[i], 'compile_opt', res, line

    if res eq 1 then begin
        find_text2, files_tdas[i], 'compile_opt', opt1, res1, line
        if res1 eq 1 then begin
            if DEBUG eq 1 then begin
                printf, lun, strcompress(line)
            endif else begin
                pos=strpos(files_tdas[i],'/',/reverse_search)
                fname=strmid(files_tdas[i], pos+1, strlen(files_tdas[i])-pos)
                if fname ne 'thm_gui_new.pro' then begin
                    printf, lun, "print,'.complie "+files_tdas[i]+"'"
                    printf, lun, ".compile '"+files_tdas[i]+"'"
                endif
            endelse
        endif
    endif
endfor

;----- thm_gui_new -----;
for i=0L, n_elements(files_tdas)-1 do begin
    pos=strpos(files_tdas[i],'/',/reverse_search)
    fname=strmid(files_tdas[i], pos+1, strlen(files_tdas[i])-pos)
    if fname eq 'thm_gui_new.pro' then begin
        printf, lun, "print,'.complie "+files_tdas[i]+"'"
        printf, lun, ".compile '"+files_tdas[i]+"'"
        break
    endif
endfor

printf, lun, "journal"

free_lun, lun

end

;*******************************
;  find_text
;*******************************
pro find_text, filename, text, res, line

res=0

openr, lun, filename, /get_lun
line=' '
while not EOF(lun) do begin
    readf, lun, line
    res_tmp=strpos(strlowcase(line), strlowcase(text))
    if res_tmp ne -1 then begin
        cline=strcompress(line, /remove_all)
        head=strmid(cline,0,1)
        if head ne ';' then begin
            res=1
            break
        endif
    endif
endwhile

free_lun, lun

end

;*******************************
;  find_text2
;*******************************
pro find_text2, filename, text1, text2, res, line

res=0

openr, lun, filename, /get_lun
line=' '
while not EOF(lun) do begin
    readf, lun, line
    res_tmp1=strpos(strlowcase(line), strlowcase(text1))
    if res_tmp1 ne -1 then begin
        res_tmp2=strpos(strlowcase(line), strlowcase(text2))
	if res_tmp2 ne -1 then begin
            cline=strcompress(line, /remove_all)
            head=strmid(cline,0,1)
            if head ne ';' then begin
                res=1
	        break
            endif
        endif
    endif
endwhile

free_lun, lun

end


;===============================
;  Main Program
;     compilelist
;===============================
pro compilelist, path_tdas

;----- Make compile file list -----;
file_compilelist='compile_list'
file_compilelog='compile_log.txt'

print, 'Make compile list.'
compilelist_sub, path_tdas, file_compilelist, file_compilelog

end

