if [ $# -ne 2 ]
then
    echo "$0 file latency"
    exit
fi

f=$1
latency=$2
python process_log.py $f ${f}.tsv
python make_graphs.py ${f}.tsv avg_${latency}
python make_graphs_95th_sig.py ${f}.tsv 95th_sig_${latency}
python make_graphs_95th_pkt.py ${f}.tsv 95th_pkt_${latency}

