#!/bin/bash

filePath="./tb/sim_inc/tb_defines.vh"
arg0=$1
if [ ! -f "$filePath" ];then
touch $filePath
echo "\`define $1" > $filePath
else
echo -n "" > $filePath
echo "\`define $1" > $filePath
fi
