rm avg_results
i=8
rm tmp_$i
for f in summary-20-*.tsv
do
    sed -n "${i}p" $f >> tmp_$i
done

for i in `seq 2 10`
do
    rm tmp_$i
    for f in summary-20-*.tsv
    do
        sed -n "${i}p" $f >> tmp_$i
    done
#    cat tmp_$i
    res=`cat tmp_$i | awk 'BEGIN{t=0;d=0}{t=t+$3;d=d+$6;name=$1}END{print name"\t"t"\t"d}'`
    echo $res >> avg_results
done
rm rel_results
: '
for i in `seq 2 9`
do
    rel_$i_thr=$((dd[$i][2]/dd[7][2]})) | bc -l
    rel_$i_d=$((dd_$i_3/dd_7_3)) | bc -l
    echo dd_$i_1"\t"rel_$i_thr"\t"rel_$i_d >> rel_results
done
'



