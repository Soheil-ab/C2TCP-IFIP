if [ $# -ne 1 ]
then
    echo "usage $0 name_of_(tsv)file"
    exit
fi
echo "reset" > tmp.gpl
echo "set logscale x" >> tmp.gpli
echo "set xlabel \"Average Delay (ms)\"" >>tmp.gpl
echo "set ylabel \"Throughput (Mbps)\"" >>tmp.gpl
echo 'set xrange [*:*] reverse' >> tmp.gpl
#echo "set term pngcairo size 350,262 enhanced font \"Helvetica,10\"" >> tmp.gpl
echo "set term postscript eps enhanced color font \"Helvetica,20\"" >> tmp.gpl
echo "set output \"avg_${1}.eps\"" >> tmp.gpl

#echo "plot \"<(sed -n '2p' $1)\"  using 4:3:1 with labels offset 3,-1 tc lt 1 point pointtype 5 ps 2 lc rgb \"0xF00000\"  notitle, \"<(sed -n '3p' $1)\"  using 4:3:1 with labels offset 0,1 tc lt 1 point pointtype 5 ps 2 lc rgb \"0xFF0000\"  notitle, \"<(sed -n '4p' $1)\"  using 4:3:1 with labels offset 3,-1 tc lt 2 point pointtype 5 ps 2 lc rgb \"0x00F000\"  notitle, \"<(sed -n '5p' $1)\"  using 4:3:1 with labels offset -3,1 tc lt 2 point pointtype 5 ps 2 lc rgb \"0x00FF00\"  notitle" >> tmp.gpl
cmd="plot "
#Cubic
D[0]="with labels offset 3,-1 tc lt 1 point pointtype 1 ps 2 lc rgb \"red\""
#Reno
D[1]="with labels offset -3,-1 tc lt 0 point pointtype 1 ps 2 lc rgb \"black\""
#vegas
D[2]="with labels offset 0,1 tc lt 2 point pointtype 2 ps 2 lc rgb \"green\""
#Verus
D[3]="with labels offset 0,-1 tc lt 4 point pointtype 2 ps 2 lc rgb \"violet\""
#Sprout
D[4]="with labels offset 0,1 tc lt 8 point pointtype 5 ps 2 lc rgb \"orange\""
#Codel
D[5]="with labels offset -3,-1 tc lt 0 point pointtype 12 ps 2 lc rgb \"black\""
#c2Tcp
D[6]="with labels offset 0,1 tc lt 3 point pointtype 3 ps 2 lc rgb \"blue\""

for cnt in `seq 0 6`
do

    cmd="$cmd \"<(sed -n '$((cnt+2))p' $1)\"  using 4:3:1 ${D[${cnt}]} notitle,"
done
cmd=${cmd%,};
echo $cmd >> tmp.gpl

gnuplot tmp.gpl 1>tmp


