#!/bin/sh

file="/media/daten/scripts/statusbar/netpeed.stat"

read oldRx oldTx oldTime < $file

read newRx < /sys/class/net/wlp0s20f3/statistics/rx_bytes
read newTx < /sys/class/net/wlp0s20f3/statistics/tx_bytes
newTime=$(date +%s)
timeDiff=$((newTime - oldTime))

downB=$(( (newRx-oldRx) / timeDiff ))
  upB=$(( (newTx-oldTx) / timeDiff ))

printf "%s %s %s\n" "$newRx" "$newTx" "$newTime" > $file

formatPrintD="%2d,%.2d%2s" #alternative:  
formatPrintU="%2d,%.2d%2s\n" #alternative: 

if [ "$downB" -lt 0 ]
then
	downVk="00"
	downNk="00"
	unitD=B
elif [ "$downB" -lt 100 ]
then
	baseD=1
	downVk=$(( downB / baseD ))
	downNk="00"
	unitD=B
else
	if [ "$downB" -lt 100000 ]
	then
		baseD=1000
		unitD=KB
	else
		baseD=1000000
		unitD=MB
	fi
	downVk=$(( downB / baseD ))
	downNk=$(( (downB % baseD) / (baseD/100) ))
fi
printf "$formatPrintD" "$downVk" "$downNk" "${unitD}"

printf " " #delimiter

if [ "$upB" -lt 0 ]
then
	upVk="00"
	upNk="00"
	unitU=B
elif [ "$upB" -lt 100 ]
then
	baseU=1
	upVk=$(( upB / baseU ))
	upNk="00"
	unitU=B
else
	if [ "$upB" -lt 100000 ]
	then
		baseU=1000
		unitU=KB
	else
		baseU=1000000
		unitU=MB
	fi
	upVk=$(( upB / baseU ))
	upNk=$(( (upB % baseU) / (baseU/100) ))
fi
printf "$formatPrintU" "$upVk" "$upNk" "${unitU}"

exit
