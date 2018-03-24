echo "do it!"
echo "reset" > tmp.gpl
echo "set terminal svg size 600,800 dynamic enhanced fname 'arial'  fsize 7" >> tmp.gpl
echo "set output \"test.svg\"" >> tmp.gpl
echo "set multiplot layout 6,3" >>tmp.gpl
for i in `seq 1 18`
do
  echo "set title \"Graph Number $i\"" >>tmp.gpl
  echo "set xlabel \"Average Delay (ms)\"" >>tmp.gpl
  echo "set ylabel \"Throughput (Mbps)\"" >>tmp.gpl
  echo "plot sin(x)" >>tmp.gpl
done

gnuplot tmp.gpl


