sbin=`dirname "$0"`
sbin=`cd "$sbin"; pwd`

if [ $# -lt 1 ]; then
  echo "Usage: ./start-history-server.sh <base-log-dir>"
  echo "Example: ./start-history-server.sh /tmp/spark-events"
  exit
fi

LOG_DIR=$1
SET_PORT=$2

. "$sbin/spark-config.sh"

command=org.apache.spark.deploy.history.HistoryServer

. "$SPARK_PREFIX/bin/load-spark-env.sh"

if [ "$SPARK_IDENT_STRING" = "" ]; then
  export SPARK_IDENT_STRING="$USER"
fi

export SPARK_PRINT_LAUNCH_COMMAND="1"

# some variables
export SPARK_ROOT_LOGGER="INFO,DRFA"

cd "$SPARK_PREFIX"
export SPARK_HISTORY_OPTS="$SPARK_HISTORY_OPTS -Dspark.history.ui.port=$SET_PORT"
export SPARK_HISTORY_OPTS="$SPARK_HISTORY_OPTS -Dspark.history.fs.logDirectory=$LOG_DIR"

"$SPARK_PREFIX"/bin/spark-class $command
