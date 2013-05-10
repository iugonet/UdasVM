pro cp_udas2tdas, path_tdas_org, path_udas_org, path_tdas, path_udas

;----- Copy TDAS & UDAS to new TDAS & UDAS -----;
file_copy, path_tdas_org, path_tdas, /recursive
file_copy, path_udas_org, path_udas, /recursive

;----- Copy UDAS files with the same name as TDAS -----;
files_tdas = file_search(path_tdas, '*.pro', /windows_short_names)
files_udas = file_search(path_udas, '*.pro', /windows_short_names)

for i=0, n_elements(files_udas)-1 do begin
    fudas1=files_udas[i]
    fpos=strpos(fudas1, '/', /reverse_search)
    fpro=strmid(fudas1, fpos+1, strlen(fudas1)-fpos-1)
    print, fpro

    for j=0, n_elements(files_tdas)-1 do begin
        ftdas1=files_tdas[j]
        fpos=strpos(ftdas1, fpro)
        if fpos ne -1 then begin
            print, 'Copy '+fudas1+' to '+ftdas1
            print, 'Delete '+fudas1
            file_copy, fudas1, ftdas1, /overwrite
            file_delete, fudas1
        endif
    endfor
endfor

;----- Copy UDAS and fits -----;
file_copy, path_udas, path_tdas+'idl/', /recursive

end

