if [ $# -ne 2 ]
then
    echo "usage $0 name_of_loss_res_file graph_name"
    exit
fi
gname=`echo $2 | sed "s/\-/\ /g"`
cat << EOF > tmp.gpl
reset
#set label 11 "label with textcolor lt 1"  at -1.5, 1.8  front nopoint tc lt 1
#set label 10 "label with tc default" at -1.5, 1.6  front nopoint tc def
#set label 12 "label with tc lt 2"    at -1.5, 1.4  front nopoint tc lt 2
#set label 13 "label with tc lt 3"    at -1.5, 1.2  front nopoint tc lt 3
set logscale x
set key right
#set title "${gname}"
set xlabel "Loss Ratio"
set ylabel "Normalized Throughput"
#set xrange [0:0.12]'
#set term pngcairo size 350,262 enhanced font "Helvetica,10"
#set term postscript eps enhanced color font "Helvetica,20"
set terminal svg size 300,200 dynamic enhanced fname 'arial'  fsize 8
#echo "set terminal epslatex color colortext standalone" >> tmp.gpl
set output "loss.svg"
#echo "set output "avg_.svg"" >> tmp.gpl

EOF

#echo "plot \"<(sed -n '2p' $1)\"  using 4:3:1 with labels offset 3,-1 ,tc lt 1 pointtype 5 ps 2 lc rgb \"0xF00000\"  notitle, \"<(sed -n '3p' $1)\"  using 4:3:1 with labels offset 0,1 ,tc lt 1 pointtype 5 ps 2 lc rgb \"0xFF0000\"  notitle, \"<(sed -n '4p' $1)\"  using 4:3:1 with labels offset 3,-1 ,tc lt 2 pointtype 5 ps 2 lc rgb \"0x00F000\"  notitle, \"<(sed -n '5p' $1)\"  using 4:3:1 with labels offset -3,1 ,tc lt 2 pointtype 5 ps 2 lc rgb \"0x00FF00\"  notitle" >> tmp.gpl
cmd="plot "
tmp=$1
#n=${tmp%.txt.tsv}
#source settings/avg-setting-$n.sh

L[0]="Vegas"
D[3]="with linespoints pointtype 9 ps 1 lc rgb \"#000080\" lt 1 title \"BBR\" "
L[1]="Cubic"
D[1]="with linespoints pointtype 4 ps 1 lc rgb \"#ff0000\" lt 1 title \"Cubic\""
L[2]="Verus"
D[0]="with linespoints pointtype 2 ps 1 lc rgb \"#00FF00\" lt 2 title \"Vegas\""
D[2]="with linespoints pointtype 7 ps 1 lc rgb \"#EE82EE\" lt 3 title \"Verus\""
L[2]="BBR"
D[4]="with linespoints pointtype 5 ps 1 lc rgb \"#FFA500\" lt 4 title \"Sprout\""
L[4]="Sprout"
L[5]="C2TCP"
D[5]="with linespoints pointtype 3 ps 1 lc rgb \"#0000FF\" lt 6 title \"C2TCP\""


for c in `seq 0 5`
do
    cmd="$cmd \"<(sed -n '3,7p' $1)\"  using 1:$((c+2)) ${D[$c]} ,"
done


cmd=${cmd%,};
echo $cmd >> tmp.gpl

gnuplot tmp.gpl 1>tmp


