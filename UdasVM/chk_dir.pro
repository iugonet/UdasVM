PRO chk_dir, path_tdas_org, path_udas_org, $
         path_tdas, path_udas, path_vm

;----- Check directories -----;
if ~file_test(path_tdas_org, /directory) then begin
    print, 'There is no TDAS directory!'
    exit
endif

if ~file_test(path_udas_org, /directory) then begin
    print, 'There is no UDAS directory!'
    exit
endif

if file_test(path_tdas, /directory) then begin
    print, 'Remove '+path_tdas+'.'
    file_delete, path_tdas, /recursive
endif

if file_test(path_udas, /directory) then begin
    print, 'Remove '+path_udas+'.'
    file_delete, path_udas, /recursive
endif

if file_test(path_vm, /directory) then begin
    print, 'Remove '+path_vm+'.'
    file_delete, path_vm, /recursive
endif

end

