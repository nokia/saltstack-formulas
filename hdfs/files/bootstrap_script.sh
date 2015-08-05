#!/usr/bin/env bash

cluster_name="$1"
nameservice="$2"
somebody_active=0

shift
shift

for peer in "$@"
do
	hdfs haadmin -ns $nameservice -getServiceState $peer | grep active
	if [ $? == 0 ]
	then
		somebody_active=1
		break	
	fi
done

if [ $somebody_active == 1 ]
then	
	hdfs namenode -bootstrapStandby
else	
	hdfs namenode -format -clusterid $cluster_name -nonInteractive
	hdfs zkfc -formatZK -nonInteractive
fi
