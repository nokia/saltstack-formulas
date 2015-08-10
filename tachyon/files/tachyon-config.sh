#!/usr/bin/env bash

# Included in all the Tachyon scripts with source command should not be executable directly also
# should not be passed any arguments, since we need original $*

# resolve links - $0 may be a softlink
this="${BASH_SOURCE-$0}"
common_bin=$(cd -P -- "$(dirname -- "$this")" && pwd -P)
script="$(basename -- "$this")"
this="$common_bin/$script"

# convert relative path to absolute path
config_bin=`dirname "$this"`
script=`basename "$this"`
config_bin=`cd "$config_bin"; pwd`
this="$config_bin/$script"

# Allow for a script which overrides the default settings for system integration folks.
[ -f "$common_bin/tachyon-layout.sh" ] && . "$common_bin/tachyon-layout.sh"

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

export CLASSPATH="$TACHYON_CONF_DIR/:$TACHYON_CLASSPATH:$TACHYON_JAR"
