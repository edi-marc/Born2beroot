#!/bin/bash
#
#	script that shows some information of the system
#
# Path compatibility for cron
PATH=$PATH:/usr/sbin
#
#	Architecture info
#
arch=$(uname -srv)
os=$(uname -om)
#
#	"physical processor" means all the physical processing unit present in the system:
#
cpu_phy=$(grep "physical id" /proc/cpuinfo | sort -u | wc -l)
#
#	"virtual processors" means all the processing units recognised by the system:
#
vcpu=$(grep "processor" /proc/cpuinfo | wc -l)
#
#	Memory Usage
#
used_m=$(free --mega | awk 'NR==2 {print $3}')
ava_m=$(free --mega | awk 'NR==2 {print $7}')
tot_m=$(free --mega | awk 'NR==2 {print $2}')
perc_m=$(free --mega | awk 'NR==2 {printf("(%.2f)"), $3/$2*100}')
#
#	Disk Usage
#
#	print the amount of storage/disk used in MB
#	the total size of the disk in GB
#	the percentage of the used space
#
disk_total=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_t += $2} END {printf ("%.1fGb"), disk_t/1024}')
disk_use=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_u += $3} END {print disk_u}')
disk_percent=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_u += $3} {disk_t+= $2} END {printf("%d"), disk_u/disk_t*100}')
#
#	CPU Load
#
cpu_f=$(vmstat 1 2 | tail -1 | awk '{printf $15}')
cpu_u=$(expr 100 - $cpu_f)
cpu_p=$(printf "%.1f" $cpu_u)
#
#	System last boot
#
time_lb=$(who -b | sed -n 's/[[:space:]]\+system boot[[:space:]]\+//p')
#
#	Using LVM
#
lvmu=$(lsblk | awk -v str="no" '{if ($6 == "lvm") str="yes"}END{print str}')
#
#	Number of active connections
#	"ss -atunp" shows all services that use tcp or udp
#	"ss -t" instead shows not listening connections using tcp
#
tcpc=$(ss -ta | awk -v c=0 'NR>1 {if ($1 == "ESTAB") c++ } END{print c}')
#
#	Users logged to the server
#
ulog=$(who | wc -l)
#
#	IPv4 and MAC addresses of the server
#
ip=$(hostname -I)
mac=$(ip -0 a | awk '/link\/ether/ {print $2}')
#
#	Numbers of commands executed with sudo
#
cmdn=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

wall "
  #Architecture:	
  $arch
  #OS: $os
  #CPU physical: $cpu_phy
  #vCPU: $vcpu
  #Memory Usage: $used_m MB $perc_m% | available: $ava_m MB | total: $tot_m MB
  #Disk Usage: $disk_use / $disk_total ($disk_percent%)
  #CPU load: $cpu_p%
  #Last boot: $time_lb
  #LVM use: $lvmu
  #Connections TCP: $tcpc ESTABLISHED
  #User log: $ulog
  #Network: IP $ip ($mac)
  #Sudo: $cmdn cmd"
