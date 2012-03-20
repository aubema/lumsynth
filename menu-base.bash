#!/bin/bash
nbd=2
nzd=0
nbc=-1
nzc=-1
li1=0
lf1=300
li2=900
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
ninterv=$(zenity --list --text="Fitting zones" --checklist --separator="\n" --print-column=ALL --column activer --column "Min Wavelength" --column "Max wavelength" 1 300 320 2 320 340 3 340 360 4 360 380 5 380 400 6 400 410 8 420 430 8 430 440 9 440 450 10 450 460 11 460 470 12 470 480 13 480 490 14 490 500 15 500 510 16 510 520 17 520 530 18 530 540 19 540 550 20 550 560 21 560 570 22 570 580 23 580 590 24 590 600 25 600 610 26 610 620 27 620 630 28 630 640 29 640 650 30 650 660 31 660 670 32 670 680 33 680 690 34 690 700 35 700 720 36 720 740 37 740 760 38 760 780 39 780 800 40 800 850 41 850 900 )
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
nzero=$(zenity --list --text="Zero zones" --checklist --separator="\n" --print-column=ALL --column "Set to 0" --column "Min Wavelength" --column "Max wavelength" 1 300 320 2 320 340 3 340 360 4 360 380 5 380 400 6 400 410 8 420 430 8 430 440 9 440 450 10 450 460 11 460 470 12 470 480 13 480 490 14 490 500 15 500 510 16 510 520 17 520 530 18 530 540 19 540 550 20 550 560 21 560 570 22 570 580 23 580 590 24 590 600 25 600 610 26 610 620 27 620 630 28 630 640 29 640 650 30 650 660 31 660 670 32 670 680 33 680 690 34 690 700 35 700 720 36 720 740 37 740 760 38 760 780 39 780 800 40 800 850 41 850 900 )
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
    echo "set xrange [300:900]" >> $expfolder/gnuplot.in
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


