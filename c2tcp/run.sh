#!/bin/bash
# this will be the script for getting stuff run
#DOWNLINKS=("ATT-LTE-driving.down"  "TMobile-LTE-driving.down" "TMobile-UMTS-driving.down" "Verizon-EVDO-driving.down" "Verizon-LTE-driving.down")
#UPLINKS=("ATT-LTE-driving.up"  "TMobile-LTE-driving.up" "TMobile-UMTS-driving.up" "Verizon-EVDO-driving.up" "Verizon-LTE-driving.up" )
UPLINKS=("ATT-LTE-driving.down"  "TMobile-LTE-driving.down" "TMobile-UMTS-driving.down" "Verizon-EVDO-driving.down" "Verizon-LTE-driving.down")
DOWNLINKS=("ATT-LTE-driving.up"  "TMobile-LTE-driving.up" "TMobile-UMTS-driving.up" "Verizon-EVDO-driving.up" "Verizon-LTE-driving.up" )

duration=("790" "480" "930" "1065" "1365");

source setup.sh
num=4;
sel=0;

c2tcp=$1;
cubic=$2;
reno=$3;
vegas=$4;
sprout=$5;
verus=$6;
tcp_codel=$7
bbr=$8
port=$9
latency=${10}

if [ $bbr -eq 1 ]
then
for i in `seq $sel $num`;
do
  echo "BBR: ${DOWNLINKS[$i]} ${UPLINKS[$i]}"
  echo "BBR" 1>&2
  echo "Down linkfile: ${DOWNLINKS[$i]}" 1>&2
  echo "Up linkfile: ${UPLINKS[$i]}" 1>&2
#  sudo modprobe tcp_cubic
  sudo su <<EOF
 echo "bbr" > /proc/sys/net/ipv4/tcp_congestion_control
EOF
#  sudo su <<EOF
# echo "0" > /proc/sys/net/ipv4/tcp_c2tcp_enable
#EOF

    ./run-iperf ${DOWNLINKS[$i]} ${UPLINKS[$i]} bbr-${DOWNLINKS[$i]}-${UPLINKS[$i]} $((port+400+2*i)) $latency ${duration[$i]}
done
fi

if [ $verus -eq 1 ]
then
echo "Running Verus"
for i in `seq $sel $num`;
do
  echo "VERUS: ${DOWNLINKS[$i]} ${UPLINKS[$i]}"
  echo "VERUS" 1>&2
  echo "Down linkfile: ${DOWNLINKS[$i]}" 1>&2
  echo "Up linkfile: ${UPLINKS[$i]}" 1>&2
  ./run-verus ${DOWNLINKS[$i]} ${UPLINKS[$i]} verus-${DOWNLINKS[$i]}-${UPLINKS[$i]} $((port+2*i)) $latency ${duration[$i]}
done
fi

if [ $sprout -eq 1 ]
then
echo "Running Sprout"
for i in `seq $sel $num`;
do
  echo "SPROUT: ${DOWNLINKS[$i]} ${UPLINKS[$i]}"
  echo "SPROUT" 1>&2
  echo "Down linkfile: ${DOWNLINKS[$i]}" 1>&2
  echo "Up linkfile: ${UPLINKS[$i]}" 1>&2
#  echo "./run-sprout ${DOWNLINKS[$i]} ${UPLINKS[$i]} sprout-${DOWNLINKS[$i]}-${UPLINKS[$i]} $((port+200+2*i)) $latency"

  ./run-sprout ${DOWNLINKS[$i]} ${UPLINKS[$i]} sprout-${DOWNLINKS[$i]}-${UPLINKS[$i]} $((port+20+2*i)) $latency
done
fi
#echo $reno"*******************************"
#echo $reno"*******************************"
if [ $cubic -eq 1 ]
then
for i in `seq $sel $num`;
do
  echo "TCP CUBIC: ${DOWNLINKS[$i]} ${UPLINKS[$i]}"
  echo "TCP CUBIC" 1>&2
  echo "Down linkfile: ${DOWNLINKS[$i]}" 1>&2
  echo "Up linkfile: ${UPLINKS[$i]}" 1>&2
  sudo modprobe tcp_cubic
  sudo su <<EOF
 echo "cubic" > /proc/sys/net/ipv4/tcp_congestion_control
EOF
  sudo su <<EOF
 echo "0" > /proc/sys/net/ipv4/tcp_c2tcp_enable
EOF
 ./run-iperf ${DOWNLINKS[$i]} ${UPLINKS[$i]} cubic-${DOWNLINKS[$i]}-${UPLINKS[$i]} $((port+400+2*i)) $latency ${duration[$i]}
done
fi
if [ $tcp_codel -eq 1 ]
then
for i in `seq $sel $num`;
do
  echo "TCP+CODEL: ${DOWNLINKS[$i]} ${UPLINKS[$i]}"
  echo "TCP+CODEL" 1>&2
  echo "Down linkfile: ${DOWNLINKS[$i]}" 1>&2
  echo "Up linkfile: ${UPLINKS[$i]}" 1>&2
  sudo modprobe tcp_cubic
  sudo su <<EOF
 echo "cubic" > /proc/sys/net/ipv4/tcp_congestion_control
EOF
  sudo su <<EOF
 echo "0" > /proc/sys/net/ipv4/tcp_c2tcp_enable
EOF
 ./run-iperf-codel ${DOWNLINKS[$i]} ${UPLINKS[$i]} codel-${DOWNLINKS[$i]}-${UPLINKS[$i]} $((port+400+2*i)) $latency ${duration[$i]}
done
fi
#echo $reno"*******************************"
if [ ${c2tcp} -eq 1 ]
then
for i in `seq $sel $num`;
do
  echo "TCP C2TCP: ${DOWNLINKS[$i]} ${UPLINKS[$i]}"
  echo "TCP C2TCP" 1>&2
  echo "Down linkfile: ${DOWNLINKS[$i]}" 1>&2
  echo "Up linkfile: ${UPLINKS[$i]}" 1>&2
  sudo modprobe tcp_cubic
  sudo su <<EOF
 echo "cubic" > /proc/sys/net/ipv4/tcp_congestion_control
EOF
  sudo su <<EOF
 echo "1" > /proc/sys/net/ipv4/tcp_c2tcp_enable
EOF
    for target in 100
    do
        sudo su <<EOF
 echo "$target" > /proc/sys/net/ipv4/tcp_c2tcp_target
EOF
        for interval in 100
        do
            sudo su <<EOF
 echo "$interval" > /proc/sys/net/ipv4/tcp_c2tcp_interval
EOF
            ./run-iperf ${DOWNLINKS[$i]} ${UPLINKS[$i]} c2tcp-${target}-${interval}-${DOWNLINKS[$i]}-${UPLINKS[$i]} $((port+600+2*i)) $latency  ${duration[$i]}
        done
    done
done
fi

if [ $reno -eq 1 ]
then

for i in `seq $sel $num`;
do
  echo "TCP Reno: ${DOWNLINKS[$i]} ${UPLINKS[$i]}"
  echo "TCP Reno" 1>&2
  echo "Down linkfile: ${DOWNLINKS[$i]}" 1>&2
  echo "Up linkfile: ${UPLINKS[$i]}" 1>&2
  sudo modprobe tcp_reno
  sudo su <<EOF
 echo "reno" > /proc/sys/net/ipv4/tcp_congestion_control
EOF
./run-iperf ${DOWNLINKS[$i]} ${UPLINKS[$i]} newreno-${DOWNLINKS[$i]}-${UPLINKS[$i]} $((port+800+2*i)) $latency ${duration[$i]}
done
fi
if [ $vegas -eq 1 ]
then
#echo "Running Vegas"

for i in `seq $sel $num`;
do
  echo "TCP VEGAS: ${DOWNLINKS[$i]} ${UPLINKS[$i]}"
  echo "TCP VEGAS" 1>&2
  echo "Down linkfile: ${DOWNLINKS[$i]}" 1>&2
  echo "Up linkfile: ${UPLINKS[$i]}" 1>&2
  sudo modprobe tcp_vegas
  sudo su <<EOF
  echo "vegas" > /proc/sys/net/ipv4/tcp_congestion_control
EOF
  ./run-iperf ${DOWNLINKS[$i]} ${UPLINKS[$i]} vegas-${DOWNLINKS[$i]}-${UPLINKS[$i]} $((port+1000+2*i)) $latency ${duration[$i]}
done
fi

