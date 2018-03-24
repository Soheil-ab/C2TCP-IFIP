
#Usage: ./name latency 1> tmp
DOWNLINKS=("ATT-LTE-driving.down"  "TMobile-LTE-driving.down" "TMobile-UMTS-driving.down" "Verizon-EVDO-driving.down" "Verizon-LTE-driving.down")
UPLINKS=("ATT-LTE-driving.up"  "TMobile-LTE-driving.up" "TMobile-UMTS-driving.up" "Verizon-EVDO-driving.up" "Verizon-LTE-driving.up")

duration=("790" "480" "930" "1065" "1365");
num=1;
sel=1;
do_calculations=1;
c2tcp=$1;
cubic=$2;
reno=$3;
vegas=$4;
sprout=$5;
verus=$6;
codel=$7
bbr=$8
port=$9
latency=${10}

dir="`pwd`/"
#mkdir sum
cd sum
for i in `seq $sel $num`
do
    file1=""
    name=${DOWNLINKS[$i]}-${UPLINKS[$i]}-${latency}-${duration[$i]}
    graph_name=${DOWNLINKS[$i]}
    graph_name=`echo $graph_name | sed "s/\|.up\|.down\|//g"`
    graph_name=`echo $graph_name | sed "s/\|driving//g"`

    name2=`echo $name | sed "s/\-${duration[$i]}//"`
if [ $c2tcp -eq 1 ]
    then
    for int in 100
    do
       for tar in 100
       do
            file_tmp=${dir}'up-c2tcp-'${tar}"-"${int}'-'${name}
            file1="$file1 $file_tmp"
        done
    done
fi
if [ $cubic -eq 1 ]
    then
	file1="$file1 ${dir}up-cubic-${name}"
fi
if [ $reno -eq 1 ]
    then
	file1="$file1 ${dir}up-newreno-${name}"
fi
if [ $vegas -eq 1 ]
    then
	file1="$file1 ${dir}up-vegas-${name}"
fi
if [ $verus -eq 1 ]
    then
	file1="$file1 ${dir}down-verus-${name}"
fi

if [ $sprout -eq 1 ]
    then
	file1="$file1 ${dir}up-sprout-${name2}"
fi

if [ $codel -eq 1 ]
    then
	file1="$file1 ${dir}up-codel-${name}"
fi
if [ $bbr -eq 1 ]
then
      file1="$file1 ${dir}up-bbr-${name}"
fi
    f="summary-${latency}-${name}.txt"
    echo "" > $f
    for file in $file1
    do
        name_=`echo $file | sed "s/${name2}\|${name}//g"`
        name_=`echo $name_ | sed "s/\|up\|down\|\-//g"`
        name_=${name_#$dir}
        if [ $name_ == "c2tcp100100" ]
        then
            name_="c2tcp"
        fi
        echo ${name} >&2
        echo ${name_} >&2
        echo ${name_} >> $f
        echo "" >> $f
        echo $file >&2
        echo $f >&2
        ../mm-throughput-graph-modified 500 $file 2>> $f
        echo "" >> $f
    done
done
cd ..

