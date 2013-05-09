PRO chk_dir, path_tdas, path_vm

;----- Check TDAS directory -----;
if ~file_test(path_tdas, /directory) then begin
    print, 'There is no TDAS directory!'
    exit
endif

if file_test(path_vm, /directory) then begin
    print, 'Remove '+path_vm+'.'
    file_delete, path_vm, /recursive
endif

end

