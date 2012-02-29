#!/bin/bash
# usage: synthsp input_name.txt 
# output = input_name_out.txt
# les noms des bases doivent commencer par le mot base
nb=0
nbdat=`grep -c "" $1 `
cp -f $1 spi.txt
list=`ls -1 base* | sed 's/*//g'`
for i in $list
   do let nb=nb+1
done

echo $nb > synthetiseur.in
for i in $list
  do echo $i >> synthetiseur.in
done
echo $nbdat >> synthetiseur.in 
./synthetiseur33 
echo "set style data lines" > gnuplot.in
echo "set xrange [300:900]" >> gnuplot.in
echo "plot 'spi.txt'" >> gnuplot.in
echo "replot 'spo.txt'" >> gnuplot.in
gnuplot -p < gnuplot.in
