if [ $# -ne 2 ]
then
    echo "usage $0 name_of_(tsv)file graph_name"
    exit
fi
gname=`echo $2 | sed "s/\-/\ /g"`
echo "reset" > tmp.gpl
echo "set logscale x" >> tmp.gpl
echo "set title \"${gname}\"" >>tmp.gpl
echo "set xlabel \"95th%tile Signal Delay (ms)\"" >>tmp.gpl
echo "set ylabel \"Throughput (Mbps)\"" >>tmp.gpl
echo 'set xrange [*:*] reverse' >> tmp.gpl
#echo "set term pngcairo size 350,262 enhanced font \"Helvetica,10\"" >> tmp.gpl
echo "set terminal svg size 300,200 dynamic enhanced fname 'arial'  fsize 8" >> tmp.gpl
#echo "set term postscript eps enhanced color font \"Helvetica,20\"" >> tmp.gpl
echo "set output \"95_sig_${1}.svg\"" >> tmp.gpl

#echo "plot \"<(sed -n '2p' $1)\"  using 4:3:1 with labels offset 3,-1 tc lt 1 point pointtype 5 ps 2 lc rgb \"0xF00000\"  notitle, \"<(sed -n '3p' $1)\"  using 4:3:1 with labels offset 0,1 tc lt 1 point pointtype 5 ps 2 lc rgb \"0xFF0000\"  notitle, \"<(sed -n '4p' $1)\"  using 4:3:1 with labels offset 3,-1 tc lt 2 point pointtype 5 ps 2 lc rgb \"0x00F000\"  notitle, \"<(sed -n '5p' $1)\"  using 4:3:1 with labels offset -3,1 tc lt 2 point pointtype 5 ps 2 lc rgb \"0x00FF00\"  notitle" >> tmp.gpl
cmd="plot "
source graph_setting.sh

for cnt in `seq 0 7`
do

    cmd="$cmd \"<(sed -n '$((cnt+2))p' $1)\"  using 4:3:1 ${D[${cnt}]} notitle,"
done
cmd=${cmd%,};
echo $cmd >> tmp.gpl

gnuplot tmp.gpl 1>tmp


