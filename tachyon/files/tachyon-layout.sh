#!/usr/bin/env bash

{% set tachyon = pillar['tachyon'] -%}
{% set hdfs = pillar['hdfs'] -%}

export TACHYON_SYSTEM_INSTALLATION="TRUE"
export TACHYON_PREFIX="{{ tachyon_home }}"
export TACHYON_HOME=${TACHYON_PREFIX}
export TACHYON_CONF_DIR=${TACHYON_PREFIX}/conf
export TACHYON_LOGS_DIR="{{ tachyon_log }}"


# generate via mvn dependency:build-classpath
export TACHYON_JAR="{{ tachyon_home }}/{{ tachyon['classpath'] }}:{{ hdfs['conf'] }}"
export JAVA_HOME="{{ java_home }}"

if [ -z "JAVA_HOME" ]; then
  export JAVA="/usr/bin/java"
else
  export JAVA="$JAVA_HOME/bin/java"
fi

# Environment settings should override * and are administrator controlled.
if [ -e $TACHYON_CONF_DIR/tachyon-env.sh ] ; then
  . $TACHYON_CONF_DIR/tachyon-env.sh
fi
