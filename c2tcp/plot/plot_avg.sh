if [ $# -ne 2 ]
then
    echo "usage $0 name_of_(tsv)file graph_name"
    exit
fi
gname=`echo $2 | sed "s/\-/\ /g"`
echo "reset" > tmp.gpl
echo "set logscale x" >> tmp.gpl
echo "set title \"${gname}\"" >>tmp.gpl
echo "set xlabel \"Average Delay (ms)\"" >>tmp.gpl
echo "set ylabel \"Throughput (Mbps)\"" >>tmp.gpl
echo 'set xrange [*:*] reverse' >> tmp.gpl
echo 'set yrange [0:*]' >> tmp.gpl
#echo "set term pngcairo size 350,262 enhanced font \"Helvetica,10\"" >> tmp.gpl
#echo "set term postscript eps enhanced color font \"Helvetica,20\"" >> tmp.gpl
echo "set terminal svg size 220,220 dynamic enhanced fname 'arial'  fsize 10" >> tmp.gpl
#echo "set terminal epslatex color colortext standalone" >> tmp.gpl


echo "set output \"avg_${1}.svg\"" >> tmp.gpl
#echo "set output \"avg_.svg\"" >> tmp.gpl

#echo "plot \"<(sed -n '2p' $1)\"  using 4:3:1 with labels offset 3,-1 tc lt 1 point pointtype 5 ps 2 lc rgb \"0xF00000\"  notitle, \"<(sed -n '3p' $1)\"  using 4:3:1 with labels offset 0,1 tc lt 1 point pointtype 5 ps 2 lc rgb \"0xFF0000\"  notitle, \"<(sed -n '4p' $1)\"  using 4:3:1 with labels offset 3,-1 tc lt 2 point pointtype 5 ps 2 lc rgb \"0x00F000\"  notitle, \"<(sed -n '5p' $1)\"  using 4:3:1 with labels offset -3,1 tc lt 2 point pointtype 5 ps 2 lc rgb \"0x00FF00\"  notitle" >> tmp.gpl
cmd="plot "
tmp=$1
n=${tmp%.tr.tsv}
#echo "$n    avg-setting-$n.sh"
source settings/avg-setting-$n.sh

for cnt in `seq 0 6`
do
    cmd="$cmd \"<(sed -n '$((cnt+2))p' $1)\"  using 6:3:1 ${D[${cnt}]} notitle,"
done
cmd=${cmd%,};
echo $cmd >> tmp.gpl

gnuplot tmp.gpl 1>tmp


