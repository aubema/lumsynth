#!/bin/bash
# usage: resamplesp input_name
# output = input_name"_rs.txt"
out=$1"_rs.txt"
cp -f $1 bresamp.txt
resamplesp
mv -f aresamp.txt $out


