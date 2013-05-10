#! /bin/csh

set path_tdas=/home/iugonet/analysis/UDAS_devel/tdas_7_01/
set path_udas=udas_2_01_1_forVM/

setenv IDL_PATH '<IDL_DEFAULT>:+'$path_tdas':+'$path_udas

idl < vm_script.txt

