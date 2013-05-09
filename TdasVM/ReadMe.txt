(a) How to compile the executable file that can run on IDL-VM.

Modify the path_tdas in build_vm.csh, and execute the command as follows;

./build_vm.csh > & all.log


(b) How to run the executable file.

idl -vm='idlvm_tdas/thm_gui_new/thm_gui_new.sav'


(c)Flow of compilation:

1. compile all files named "*.pro" in TDAS.
2. resolve_all, /continue_on_error
3. resolve_all, /continue_on_error, class=['???', '???', ....]
where ??? means a part of the filename '???__define.pro' included in TDAS.
4. Add a few files named "*.sav" and directories 'Resources' and 'help' to the package.

