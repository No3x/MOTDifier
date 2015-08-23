#!/bin/bash
#
# @author Sebastian Kaiser <kaiser.seb@gmail.com>
# @license http://opensource.org/licenses/mit-license.php MIT
#
# script that should be in root cronjob running 5 or 10 minutes or whatever u like :-)
# updates the motd
#
# (sudo) su
# copy the script to "/var/opt/motdifier.sh"
# chmod +x /var/opt/motdifier.sh
# crontab -e
# */10 * * * * /var/opt/motdifier/motdifier.sh > /etc/motd
#
#####

# get uptime
iTimeUP=`cat /proc/uptime | awk '{sub(/\.[0-9]+/,"");print $1'}`
iTimestampNOW=`date +%s`
iTimestampUP=$(( $iTimestampNOW - $iTimeUP ))

# get disk space usage
sDiskUsage=`df -h`
sDiskSpaceFirstLine=`echo "$sDiskUsage" | head -n 1`
sDiskSpaceOtherLines=`echo "$sDiskUsage" | grep -E "(^rootfs\|^\/dev\/sd)|(^\/dev\/vzfs)" | sed -e "s/^/# /g"`;

# get traffic for each network
sIfConfig=`/sbin/ifconfig`
iCountNetworks=`echo "$sIfConfig" | grep -oPc '(?<=RX bytes:)[0-9]*'`
aNetworks=`echo "$sIfConfig" | grep -oP '^[^ ]*'`;
sNetworkTraffic=""

for (( iCount=1; iCount<=$iCountNetworks; iCount++ )); do
	
	# get network name
	sNetworkName=`echo "$sIfConfig" | grep -oP '^[^ ]*' | head -$iCount | tail -1`
	sNetworkName=`printf "%-10s" \"$sNetworkName\"`

	# get down bytes
	sDownLoadBytes=`echo "$sIfConfig" | grep -oP 'RX bytes:[0-9]* \(.*?\)' | grep -oP '\(.*?\)' | head -$iCount | tail -1`
	sDownLoadBytes=`printf "%-15s" "$sDownLoadBytes"`

	# get up bytes
	sUpLoadBytes=`echo "$sIfConfig" | grep -oP 'TX bytes:[0-9]* \(.*?\)' | grep -oP '\(.*?\)' | head -$iCount | tail -1`
	sUpLoadBytes=`printf "%-15s" "$sUpLoadBytes"`
	
	
	# build networktraffic string
	sNetworkTraffic="$sNetworkTraffic# Traffic $sNetworkName Down@ $sDownLoadBytes Up@ $sUpLoadBytes"

done

# write motd
echo "# Welcome on "`cat /etc/hostname`" ! (Kernel: "`cat /proc/sys/kernel/osrelease`")"
echo "#"
echo "# Up since "`date --date "1970-01-01 $iTimestampUP sec" "+%Y-%m-%d %T"`" ("`uptime | awk '{sub(/\,/,"");print $3" "$4 }'`")"
echo "#"
echo "# Users online: "`users`
echo "#"
echo "# Average Load: "`cat /proc/loadavg | awk '{sub(/[0-9]\/[0-9]+ [0-9]+/,"");print $1" "$2" "$3}'`
echo "#"
echo "$sNetworkTraffic#"
echo "# $sDiskSpaceFirstLine"
echo "$sDiskSpaceOtherLines"
echo "#"