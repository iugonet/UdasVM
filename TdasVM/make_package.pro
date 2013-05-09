;===============================
;  make_package
;     
;===============================
pro make_package, path_tdas, path_vm

path_vm_sub=path_vm+'thm_gui_new'
file_vm='thm_gui_new.sav'

;----- Save executable file -----;
; cd, path_tdas+'idl/themis/thm_ui_new', current=path_home
save, file=file_vm, /routines
; cd, path_home

;----- Copy directories and files needed for IDL-VM -----;
file_mkdir, path_vm
file_mkdir, path_vm_sub

file_copy, path_tdas+'idl/themis/thm_ui_new/Resources', $
  path_vm, /recursive, /overwrite
file_copy, path_tdas+'idl/themis/thm_ui_new/help', $
  path_vm, /recursive, /overwrite
file_copy, path_tdas+'idl/ssl_general/mini/grammar.sav', $
  path_vm_sub, /overwrite
file_copy, path_tdas+'idl/ssl_general/mini/parse_tables.sav', $
  path_vm_sub, /overwrite
file_copy, path_tdas+'idl/themis/spacecraft/fields/spin_harmonic_template.dat', $
  path_vm_sub, /overwrite

file_copy, './colors1.tbl', path_vm_sub, /overwrite

file_move, './'+file_vm, path_vm_sub, /overwrite
file_move, './compile_list', path_vm, /overwrite
file_move, './compile_log.txt', path_vm, /overwrite

end
