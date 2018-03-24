rm avg_results_c2VScodel
rm norm_results_c2VScodel
for i in avg_c2tcp-vs-codel-20-*.tsv;do sed "s/c2Tcp/C2Tcp/g" $i > $i.1;mv $i.1 $i;done

for f in avg_c2tcp-vs-codel-20-*.tsv
do
    python avg.py $f
done

for i in `seq 1 10`
do
    rm avg.tmp_$i
    rm norm.tmp_$i
    c=0
    for f in avg_c2tcp-vs-codel-20-*.tsv
    do
        sed -n "${i}p" avg.$f >> avg.tmp_$i
        sed -n "${i}p" norm.$f >> norm.tmp_$i
        c=$((c+1));
    done
#    echo $c
#    cat avg.tmp_$i
    res=`cat avg.tmp_$i | awk -v cnt=$c 'BEGIN{t=0;d=0;d95=0;sig=0;}{t=t+$2;d=d+$3;d95=d95+$4;sig=sig+$5;name=$1}END{print name"\t"t/cnt"\t"d/cnt"\t"d95/cnt"\t"sig/cnt}'`
    echo $res >> avg_results_c2VScodel
    res=`cat norm.tmp_$i | awk -v  cnt=$c 'BEGIN{t=0;d=0;d95=0;sig=0;}{t=t+$2;d=d+$3;d95=d95+$4;sig=sig+$5;name=$1}END{print name"\t"t/cnt"\t"d/cnt"\t"d95/cnt"\t"sig/cnt}'`
    echo $res >> norm_results_c2VScodel
done
cat avg_results_c2VScodel
echo "----------------------------"
cat norm_results_c2VScodel


