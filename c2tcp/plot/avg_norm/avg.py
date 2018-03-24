import os
import sys

if len(sys.argv) != 2:
  print 'Usage: python graph_results.py <filename>'
  sys.exit(1)

results = []

infile = open(sys.argv[1], 'r')
protocol = None
throughput = None
sig_del = None
avg_del = None
del_95 = None
cap = None
for line in infile:
  l = line.strip()
  l = l.split()
#  print l[0]
  if l[0]=="C2TCP":
    throughput = float(l[2])
    avg_del = float(l[5])
    del_95 = float(l[4])
    sig_del = float(l[3])
    cap = float(l[6])
    print str(cap)+"\n"
#print str(throughput)+" "+str(delay)
infile = open(sys.argv[1], 'r')
avg = open("avg."+sys.argv[1], 'w')
norm = open("norm."+sys.argv[1], 'w')

#outfile.write('protocol\tdown\tthroughput\tdelay\tdelay_95th\tavg_delay\tavg_capacity\n')
for line in infile:
  l = line.strip()
  l = l.split()
  if l[0] != "protocol":
 #  print thtoughput+ avg_del+" "+del_95+" "+del_sig+"\n"
   norm.write(l[0]+"\t"+str(float(l[2])/throughput)+"\t"+str(float(l[5])/avg_del)+"\t"+str(float(l[4])/del_95)+"\t"+str(float(l[3])/sig_del)+"\n")
   avg.write(l[0]+"\t"+str(float(l[2]))+"\t"+str(float(l[5]))+"\t"+str(float(l[4]))+"\t"+str(float(l[3]))+"\t"+str(float(l[2])/cap)+"\n")
#   avg.write(l[0]+"\t"+str(float(l[2]))+"\t"+str(float(l[5]))+"\n")

#  else:
#    print "sdfsdfg"
norm.close()
avg.close()


