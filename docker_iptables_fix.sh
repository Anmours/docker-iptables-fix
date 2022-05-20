#!/bin/bash
currentAttempt=0
totalAttempts=10
delay=15
#日志路径
logfile=/volume1/docker/docker_iptables_fix.log

while [ $currentAttempt -lt $totalAttempts ]
do
	currentAttempt=$(( $currentAttempt + 1 ))
	
	echo "$(date -d today +"%Y-%m-%d %H:%M:%S")：尝试$totalAttempts次中的$currentAttempt次..." | tee -a  $logfile
	
	result=$(iptables-save)

	if [[ $result =~ "-A DOCKER -i docker0 -j RETURN" ]]; then
		echo "$(date -d today +"%Y-%m-%d %H:%M:%S")：Docker规则找到了！正在修改..." | tee -a  $logfile
		
		iptables -t nat -A PREROUTING -m addrtype --dst-type LOCAL -j DOCKER
		iptables -t nat -A PREROUTING -m addrtype --dst-type LOCAL ! --dst 172.16.0.0/12 -j DOCKER
		
		echo "$(date -d today +"%Y-%m-%d %H:%M:%S")：修改完成！" | tee -a  $logfile
		
		break
	fi
	
	echo "$(date -d today +"%Y-%m-%d %H:%M:%S")：未找到Docker规则！ 睡眠 $delay 秒后重新检查..." | tee -a  $logfile
	
	sleep $delay
done