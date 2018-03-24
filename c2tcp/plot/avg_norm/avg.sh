rm avg_results
rm norm_results
for i in sum*.tsv;do sed -i "s/c2Tcp/C2TCP/g" $i;done

for f in sum*.tsv
do
    python avg.py $f
done

for i in `seq 1 8`
do
    rm avg.tmp_$i
    rm norm.tmp_$i
    c=0
    for f in sum*.tsv
    do
        sed -n "${i}p" avg.$f >> avg.tmp_$i
        sed -n "${i}p" norm.$f >> norm.tmp_$i
        c=$((c+1));
    done
#    echo $c
#    cat avg.tmp_$i
    res=`cat avg.tmp_$i | awk -v cnt=$c 'BEGIN{util=0;power=0;p95=0;t=0;d=0;d95=0;sig=0;}{util=util+$6;t=t+$2;d=d+$3;d95=d95+$4;sig=sig+$5;name=$1;power=power+$2/$3;p95=p95+$2/$5}END{print name"\t"t/cnt"\t"d/cnt"\t"d95/cnt"\t"sig/cnt"\t"power/cnt"\t"p95/cnt"\t"util/cnt}'`
    echo $res >> avg_results
    res=`cat norm.tmp_$i | awk -v  cnt=$c 'BEGIN{t=0;d=0;d95=0;sig=0;}{t=t+$2;d=d+$3;d95=d95+$4;sig=sig+$5;name=$1;power=power+$2/$3;p95=p95+$2/$5}END{print name"\t"t/cnt"\t"d/cnt"\t"d95/cnt"\t"sig/cnt"\t"power/cnt"\t"p95/cnt}'`
    echo $res >> norm_results
done
cat avg_results
echo "----------------------------"
cat norm_results


