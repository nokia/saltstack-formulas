#!/usr/bin/env bash

sbin=`dirname "$0"`
sbin=`cd "$sbin"; pwd`

. "$sbin/spark-config.sh"
. "$SPARK_PREFIX/bin/load-spark-env.sh"

export SPARK_HISTORY_OPTS="$SPARK_HISTORY_OPTS -Dspark.history.ui.port=$1"

"$SPARK_PREFIX"/bin/spark-class org.apache.spark.deploy.history.HistoryServer
