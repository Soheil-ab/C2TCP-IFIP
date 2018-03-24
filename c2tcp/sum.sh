#DOWNLINKS=("ATT-LTE-driving-2016.down" "ATT-LTE-driving.down"  "TMobile-LTE-driving.down" "TMobile-UMTS-driving.down" "Verizon-EVDO-driving.down" "Verizon-LTE-driving.down")
DOWNLINKS=("ATT-LTE-driving.down"  "TMobile-LTE-driving.down" "TMobile-UMTS-driving.down" "Verizon-EVDO-driving.down" "Verizon-LTE-driving.down")
UPLINKS=("ATT-LTE-driving.up"  "TMobile-LTE-driving.up" "TMobile-UMTS-driving.up" "Verizon-EVDO-driving.up" "Verizon-LTE-driving.up" )
#UPLINKS=("wired48" "wired48" "wired48" "wired48" "wired48" "wired48" "wired48" "wired48")
for j in `seq 0 4`
do
    down=${DOWNLINKS[$j]}
    rm sum-$down.tr
done
for i in 'up-cubic' 'up-newreno' 'up-vegas' 'down-verus' 'up-sprout' 'up-bbr' 'up-c2tcp' 'up-codel' #"up-cubic" "up-codel" "up-newreno" "up-vegas" "down-verus" "up-sprout" "up-bbr"  "up-c2tcp"
do
    for j in `seq 0 5`
    do
        down=${DOWNLINKS[$j]}
#        rm sum-$down.tr
        for f in $i*$down*${UPLINKS[$j]}*
        do
            echo $i >>sum-$down.tr
            ./mm-throughput-graph-modified 500 $f 1>thr-$f 2>>sum-$down.tr
            echo "++++++++++++++++++++++++++++++++" >>sum-$down.tr
        done
        python process_log.py sum-$down.tr sum-$down.tr.tsv
        sed -i "s/up-cubic/Cubic/g" sum-$down.tr.tsv
        sed -i "s/up-codel/Codel_Cubic/g" sum-$down.tr.tsv
        sed -i "s/up-newreno/NReno/g" sum-$down.tr.tsv
        sed -i "s/up-vegas/Vegas/g" sum-$down.tr.tsv
        sed -i "s/down-verus/Verus/g" sum-$down.tr.tsv
        sed -i "s/up-sprout/Sprout/g" sum-$down.tr.tsv
        sed -i "s/up-bbr/BBR/g" sum-$down.tr.tsv
        sed -i "s/up-c2tcp/C2TCP/g" sum-$down.tr.tsv
#        ./plot_avg.sh
    done
done



