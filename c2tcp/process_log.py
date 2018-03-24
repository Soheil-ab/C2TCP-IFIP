import os
import sys

if len(sys.argv) != 3:
  print 'Usage: python graph_results.py <filename> <output_tsv>'
  sys.exit(1)

results = []

infile = open(sys.argv[1], 'r')
protocol = None
downlink = None
uplink = None
throughput = None
delay = None
avg_capacity = None
avg_delay = None
down = None
up = None
delay_95th = None
for line in infile:
  l = line.strip()
#  if l in ['c2Tcp2','bbr','LEDBAT', 'Codel+Cubic', 'Sprout', 'Vegas', 'c2Tcp', 'Cubic', 'Verus' , 'NewReno','c2Tcp45100', 'c2Tcp50100', 'c2Tcp60100', 'c2Tcp70100', 'c2Tcp80100', 'c2Tcp90100','c2Tcp100100','c2Tcp100120','c2Tcp100150']:
  if l in ['up-cubic','up-newreno','up-vegas', 'down-verus' ,'up-sprout', 'up-bbr','up-c2tcp','up-codel']:
#  if l in ['c2Tcp2','bbr','LEDBAT', 'Codel+Cubic', 'Sprout', 'Vegas', 'c2Tcp', 'Cubic', 'Verus' , 'NewReno','c2Tcp525', 'c2Tcp1025', 'c2Tcp2025', 'c2Tcp3025', 'c2Tcp4025', 'c2Tcp5025', 'c2Tcp6025', 'c2Tcp7025', 'c2Tcp8025', 'c2Tcp9025', 'c2Tcp10025-', 'c2Tcp550', 'c2Tcp1050', 'c2Tcp2050', 'c2Tcp3050', 'c2Tcp4050','c2Tcp5050', 'c2Tcp6050', 'c2Tcp7050', 'c2Tcp8050', 'c2Tcp9050', 'c2Tcp10050', 'c2Tcp5100', 'c2Tcp10100', 'c2Tcp20100', 'c2Tcp30100', 'c2Tcp40100', 'c2Tcp50100', 'c2Tcp60100', 'c2Tcp70100', 'c2Tcp80100', 'c2Tcp90100','c2Tcp100100','c2Tcp100200']:
#  if l in ['c2Tcp2','bbr','LEDBAT', 'Codel+Cubic', 'Sprout', 'Vegas', 'c2Tcp', 'Cubic', 'Verus' , 'NewReno','c2Tcp525', 'c2Tcp1025', 'c2Tcp2025', 'c2Tcp3025', 'c2Tcp4025', 'c2Tcp5025', 'c2Tcp6025', 'c2Tcp7025', 'c2Tcp8025', 'c2Tcp9025', 'c2Tcp10025-', 'c2Tcp550', 'c2Tcp1050', 'c2Tcp2050', 'c2Tcp3050', 'c2Tcp4050','c2Tcp5050', 'c2Tcp6050', 'c2Tcp7050', 'c2Tcp8050', 'c2Tcp9050', 'c2Tcp10050-', 'c2Tcp5100', 'c2Tcp10100', 'c2Tcp20100', 'c2Tcp30100', 'c2Tcp40100', 'c2Tcp50100', 'c2Tcp60100', 'c2Tcp70100', 'c2Tcp80100', 'c2Tcp90100','c2Tcp100100','c2Tcp100200-']:
# if l in ['Sprout', 'Vegas', 'c2Tcp', 'Cubic', 'Verus' , 'NewReno','c2Tcp525', 'c2Tcp550', 'c2Tcp5100', 'c2Tcp1025', 'c2Tcp1050', 'c2Tcp10100', 'c2Tcp2025', 'c2Tcp2050', 'c2Tcp20100', 'c2Tcp3025', 'c2Tcp3050', 'c2Tcp30100', 'c2Tcp4025', 'c2Tcp4050', 'c2Tcp40100', 'c2Tcp5025','c2Tcp5050', 'c2Tcp50100', 'c2Tcp6025', 'c2Tcp6050', 'c2Tcp60100', 'c2Tcp7025', 'c2Tcp7050', 'c2Tcp70100', 'c2Tcp8025', 'c2Tcp8050', 'c2Tcp80100', 'c2Tcp9025', 'c2Tcp9050', 'c2Tcp90100', 'c2Tcp10025-', 'c2Tcp10050-','c2Tcp100100']:
    if not protocol is None:
      results.append((protocol, down, throughput, delay, delay_95th, avg_delay,avg_capacity ))
      protocol = None
      downlink = None
      uplink = None
      throughput = None
      delay = None
      avg_capacity = None
      avg_delay = None
    protocol = l
  elif l.startswith('Average throughput:'):
    throughput = l.split(':')[1].strip().split(' ')[0]
  elif l.startswith('95th percentile per-packet queueing delay:'):
    delay_95th = l.split(':')[1].strip().split(' ')[0]
  elif l.startswith('95th percentile signal delay:'):
    delay = l.split(':')[1].strip().split(' ')[0]
  elif l.startswith('Average capacity:'):
    avg_capacity = l.split(':')[1].strip().split(' ')[0]
  elif l.startswith('average per packet delay:'):
    avg_delay = l.split(':')[1].strip().split(' ')[0]
  down = sys.argv[1]

if not protocol is None:
  results.append((protocol, down, throughput, delay, delay_95th,avg_delay,avg_capacity))

# now write it out nicely formatted
outfile = open(sys.argv[2], 'w')
outfile.write('protocol\tdown\tthroughput\tdelay\tdelay_95th\tavg_delay\tavg_capacity\n')
for result in results:
  print result
  outfile.write('\t'.join(result))
  outfile.write('\n')
outfile.close()
