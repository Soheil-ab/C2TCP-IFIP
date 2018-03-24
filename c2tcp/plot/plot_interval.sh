if [ $# -ne 1 ]
then
    echo "usage $0 name_of_(tsv)file "
    exit
fi
#gname=`echo $2 | sed "s/\-/\ /g"`
echo "reset" > tmp.gpl
#echo "set logscale x" >> tmp.gpl
#echo "set title \"${gname}\"" >>tmp.gpl
echo "set xlabel \"Interval (ms)\"" >>tmp.gpl
echo "set ylabel \"Throughput (Mbps)\"" >>tmp.gpl
#echo 'set xrange [*:*] reverse' >> tmp.gpl
#echo "set term pngcairo size 350,262 enhanced font \"Helvetica,10\"" >> tmp.gpl
#echo "set term postscript eps enhanced color font \"Helvetica,20\"" >> tmp.gpl
echo "set terminal svg size 230,200 dynamic enhanced fname 'arial'  fsize 8" >> tmp.gpl
#echo "set terminal epslatex color colortext standalone" >> tmp.gpl
#echo "set hidden3d" >> tmp.gpl
echo "set output \"interval.svg\"" >> tmp.gpl
#echo "set output \"avg_.svg\"" >> tmp.gpl

#echo "plot \"<(sed -n '2p' $1)\"  using 4:3:1 with labels offset 3,-1 tc lt 1 point pointtype 5 ps 2 lc rgb \"0xF00000\"  notitle, \"<(sed -n '3p' $1)\"  using 4:3:1 with labels offset 0,1 tc lt 1 point pointtype 5 ps 2 lc rgb \"0xFF0000\"  notitle, \"<(sed -n '4p' $1)\"  using 4:3:1 with labels offset 3,-1 tc lt 2 point pointtype 5 ps 2 lc rgb \"0x00F000\"  notitle, \"<(sed -n '5p' $1)\"  using 4:3:1 with labels offset -3,1 tc lt 2 point pointtype 5 ps 2 lc rgb \"0x00FF00\"  notitle" >> tmp.gpl
cmd="plot "
tmp=$1
#n=${tmp%.txt.tsv}
#source settings/avg-setting-$n.sh

#D[1]="with boxes labels offset 0,-1 tc rgb \"#0000FF\" point pointtype 3 ps 1 lc rgb \"#0000FF\""
#D[0]="with boxes labels offset 0,1 tc rgb \"#FF0000\" point pointtype 1 ps 1 lc rgb \"#FF0000\""

D[1]="with boxes lc rgb \"#0000FF\""
D[0]="with boxes lc rgb \"#FF0000\""

cat <<EOF >>tmp.gpl
set boxwidth 6
set style fill solid
#plot "data.dat" using 1:3:xtic(2) with boxes
EOF

#cmd="$cmd \"<(sed -n '1p' $1)\"  using 3:2:1 ${D[0]} notitle,"
cmd="$cmd \"<(sed -n '2,7p' $1)\"  using 1:3 ${D[1]} notitle,"

cmd=${cmd%,};
echo $cmd >> tmp.gpl

gnuplot tmp.gpl 1>tmp


