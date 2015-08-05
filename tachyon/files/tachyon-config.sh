#!/usr/bin/env bash

#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

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
