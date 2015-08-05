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

#start up tachyon

bin=`cd "$( dirname "$0" )"; pwd`

ensure_dirs() {
  if [ ! -d "$TACHYON_LOGS_DIR" ]; then
    echo "TACHYON_LOGS_DIR: $TACHYON_LOGS_DIR"
    mkdir -p $TACHYON_LOGS_DIR
  fi
}

get_env() {
  DEFAULT_LIBEXEC_DIR="$bin"/../libexec
  TACHYON_LIBEXEC_DIR=${TACHYON_LIBEXEC_DIR:-$DEFAULT_LIBEXEC_DIR}
  . $TACHYON_LIBEXEC_DIR/tachyon-config.sh
}

check_mount_mode() {
  case "${1}" in
    Mount);;
    SudoMount);;
    NoMount);;
    *)
      if [ -z $1 ] ; then
        echo "This command requires a mount mode be specified"
      else
        echo "Invalid mount mode: $1"
      fi
      echo -e "$Usage"
      exit 1
  esac
}

# pass mode as $1
do_mount() {
  MOUNT_FAILED=0
  case "${1}" in
    Mount)
      $bin/tachyon-mount.sh $1
      MOUNT_FAILED=$?
      ;;
    SudoMount)
      $bin/tachyon-mount.sh $1
      MOUNT_FAILED=$?
      ;;
    NoMount)
      ;;
    *)
      echo "This command requires a mount mode be specified"
      echo -e "$Usage"
      exit 1
  esac
}

start_master() {
  MASTER_ADDRESS=$TACHYON_MASTER_ADDRESS
  if [ -z $TACHYON_MASTER_ADDRESS ] ; then
    MASTER_ADDRESS=localhost
  fi
  $JAVA -cp $TACHYON_JAR -Dtachyon.home=$TACHYON_HOME -Dtachyon.logger.type="MASTER_LOGGER" -Dlog4j.configuration=file:$TACHYON_CONF_DIR/log4j.properties $TACHYON_MASTER_JAVA_OPTS tachyon.master.TachyonMaster
}

start_worker() {
  do_mount $1
  if  [ $MOUNT_FAILED -ne 0 ] ; then
    echo "Mount failed, not starting worker"
    exit 1
  fi
  $JAVA -cp $TACHYON_JAR -Dtachyon.home=$TACHYON_HOME -Dtachyon.logger.type="WORKER_LOGGER" -Dlog4j.configuration=file:$TACHYON_CONF_DIR/log4j.properties $TACHYON_WORKER_JAVA_OPTS tachyon.worker.TachyonWorker `hostname`
}

WHAT=$1

# get environment
get_env

# ensure log/data dirs
ensure_dirs

case "${WHAT}" in
  master)
    start_master
    ;;
  worker)
    check_mount_mode $2
    start_worker $2
    ;;
  *)
    echo "Error: Invalid WHAT: $WHAT"
    echo -e "$Usage"
    exit 1
esac
