for i in sum-*.tsv
do
    a=${i/sum-}
    a=${a/-driving.down/-Downlink}
    a=${a/-driving-2016.down/-2016-Downlink}
    a=${a/.tr.tsv}
    echo $a
    ./plot_avg.sh $i $a
    ./plot_95_pkt.sh $i $a
done


