PRO rm_dir, path_tdas, path_udas

;----- Remove directories -----;
if file_test(path_tdas, /directory) then begin
    print, 'Remove '+path_tdas+'.'
    file_delete, path_tdas, /recursive
endif

if file_test(path_udas, /directory) then begin
    print, 'Remove '+path_udas+'.'
    file_delete, path_udas, /recursive
endif

end
