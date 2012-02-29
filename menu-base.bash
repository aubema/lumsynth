#!/bin/bash
nbd=2
nzd=0
nbc=-1
nzc=-1
li1=0
lf1=400
li2=700
lf2=2000
while true; do
choice="$(zenity --width=200 --height=250 --list --column "Command" --title="SynthSP main window" \
        "1) Define experiment folder"\
        "2) Define target spectrum"\
        "3) Add one or many bases" \
        "4) Exclude spectrum parts" \
        "5) Set spectrum parts to 0" \
        "6) Execute ")"
case "${choice}" in
   "1) Define experiment folder" )
    expfolder=$(zenity --file-selection --title="Choisir un spectre de base" --directory --save);
    echo $expfolder
    ;;
   "2) Define target spectrum" )
    nomt=$(zenity --file-selection --title="Choisir un spectre cible" );  
    echo $nomt
    cp -f $nomt $expfolder
    ;;
   "3) Add one or many bases" )
    nomf=$(zenity --file-selection --title="Choisir un spectre de base" --multiple);  
    echo $nomf
    baselist=`echo $nomf | sed 's/|/ /g'`
    for i in $baselist
    do o=$i.base
       cp -f $i $o
       mv -f $o $expfolder
       echo "Copying "$i
    done
    ;;
    "4) Exclude spectrum parts")
ninterv=$(zenity --list --text="Fitting zones" --checklist --separator="\n" --print-column=ALL --column activer --column "Min Wavelength" --column "Max wavelength" 1 400 410 2 420 430 3 430 440 4 440 450 5 450 460 6 460 470 7 470 480 8 480 490 9 490 500 10 500 510 11 510 520 12 520 530 13 530 540 14 540 550 15 550 560 16 560 570 17 570 580 18 580 590 19 590 600 20 600 610 21 610 620 22 620 630 23 630 640 24 640 650 25 650 660 26 660 670 27 670 680 28 680 690 29 690 700 )
echo $ninterv
nbc=`echo $ninterv | wc -w`
if [ ! $nbc ] 
then nbc=0
fi
 let nbd=nbc/2+2
   echo $nbd >>$expfolder/synthetiseur.in
   bornes=($ninterv)
   nb1=0
   nb2=1
   while [ $nb1 -le $nbc ]
   do echo ${bornes[$nb1]} ${bornes[$nb2]}
      let nb1=nb1+2
      let nb2=nb2+2
   done
    ;;

    "5) Set spectrum parts to 0")
nzero=$(zenity --list --text="Zero zones" --checklist --separator="\n" --print-column=ALL --column "Set to 0" --column "Min Wavelength" --column "Max wavelength" 1 400 410 2 420 430 3 430 440 4 440 450 5 450 460 6 460 470 7 470 480 8 480 490 9 490 500 10 500 510 11 510 520 12 520 530 13 530 540 14 540 550 15 550 560 16 560 570 17 570 580 18 580 590 19 590 600 20 600 610 21 610 620 22 620 630 23 630 640 24 640 650 25 650 660 26 660 670 27 670 680 28 680 690 29 690 700 )
echo $nzero
nzc=`echo $nzero | wc -w`
if [ ! $nzc ]
then nzc=0
fi
 let nzd=nzc/2
   echo $nzd >>$expfolder/synthetiseur.in
   zero=($nzero)
   nz1=0
   nz2=1
   while [ $nz1 -le $nzc ]
   do echo ${zero[$nz1]} ${zero[$nz2]}
      let nz1=nz1+2
      let nz2=nz2+2
   done
    ;;
    "6) Execute " )
    cd $expfolder
    nb=0
    nbdat=`grep -c "" $nomt `
    cp -f $nomt $expfolder/spi.txt
    list=`ls -1 *.base  | sed 's/*//g'`
    for i in $list
    do let nb=nb+1
    done
    echo $nb > $expfolder/synthetiseur.in
    for i in $list
    do echo $i >> $expfolder/synthetiseur.in
    done
    echo $nbdat >> $expfolder/synthetiseur.in 
    echo $nbd >>$expfolder/synthetiseur.in
    echo $li1 $lf1 >> $expfolder/synthetiseur.in
    echo $li2 $lf2 >> $expfolder/synthetiseur.in
    nb1=0
    nb2=1
echo "nbc="$nbc
    while [ $nb1 -lt $nbc ]
    do echo ${bornes[$nb1]} ${bornes[$nb2]} >> $expfolder/synthetiseur.in
      let nb1=nb1+2
      let nb2=nb2+2
    done    
    echo $nzd >>$expfolder/synthetiseur.in
    nz1=0
    nz2=1
    while [ $nz1 -lt $nzc ]
    do echo ${zero[$nz1]} ${zero[$nz2]} >> $expfolder/synthetiseur.in
      let nz1=nz1+2
      let nz2=nz2+2
    done

    zenity --text-info --width=400 --height=500 --filename=$expfolder/synthetiseur.in &
    synthetiseur33 
    echo "set style data lines" > $expfolder/gnuplot.in
    echo "set xrange [400:730]" >> $expfolder/gnuplot.in
    echo "set zeroaxis" >> $expfolder/gnuplot.in
    echo "plot 'spi.txt'" >> $expfolder/gnuplot.in
    echo "replot 'spo.txt'" >> $expfolder/gnuplot.in
    echo "replot 'res.txt'" >> $expfolder/gnuplot.in
    gnuplot -p < $expfolder/gnuplot.in
    zenity --text-info --width=700 --height=500 --filename=$expfolder/coefficient.txt
    ;;
    *)
    break
    ;;
esac
done


