#! /bin/csh

set path_tdas=/home/iugonet/analysis/UDAS_devel/tdas_8_00/

setenv IDL_PATH '<IDL_DEFAULT>:+'$path_tdas

idl < vm_script.txt

