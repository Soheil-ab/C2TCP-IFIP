if [ $# == 9 ]
then
	sudo sysctl -w net.ipv4.ip_forward=1
	sudo sysctl -w net.ipv4.tcp_no_metrics_save=1
	latency_=20
	./run.sh $1 $2 $3 $4 $5 $6 $7 $8 $9 ${latency_} 2>sum/log.txt
#	./analysis.sh $1 $2 $3 $4 $5 $6 $7 $8 $9 ${latency_} 1>tmp
else
	echo "usage: $0 c2tcp cubic newreno vegas sprous verus codel bbr port"
fi

