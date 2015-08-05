#!/usr/bin/env bash

# This file contains environment variables required to run Tachyon. Copy it as tachyon-env.sh and
# edit that to configure Tachyon for your site. At a minimum,
# the following variables should be set:
#
# - JAVA_HOME, to point to your JAVA installation
# - TACHYON_MASTER_ADDRESS, to bind the master to a different IP address or hostname
# - TACHYON_UNDERFS_ADDRESS, to set the under filesystem address.
# - TACHYON_WORKER_MEMORY_SIZE, to set how much memory to use (e.g. 1000mb, 2gb) per worker
# - TACHYON_RAM_FOLDER, to set where worker stores in memory data
#
# The following gives an example:

{% set tachyon = pillar['tachyon'] -%}
export TACHYON_RAM_FOLDER={{ ramdisk }}
export JAVA_HOME={{ java_home }}

{% if 'tachyon.master' in salt['grains.get']('roles') %}
export TACHYON_MASTER_ADDRESS={{ salt['search.my_host']() }}
{% else %}
export TACHYON_MASTER_ADDRESS={{ tachyon_masters | first }}
{% endif %}
export TACHYON_UNDERFS_ADDRESS=hdfs://{{ nameservice_names | first }}
export TACHYON_WORKER_MEMORY_SIZE={{ tachyon['executor.memory'] }}

CONF_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export TACHYON_JAVA_OPTS+="
  -Dtachyon.home={{ tachyon_home }}
  -Dlog4j.configuration=file:$CONF_DIR/log4j.properties
  -Dtachyon.debug=false
  -Dtachyon.underfs.address=$TACHYON_UNDERFS_ADDRESS
  -Dtachyon.worker.memory.size=$TACHYON_WORKER_MEMORY_SIZE
  -Dtachyon.usezookeeper=true
  -Dtachyon.log.dir=$TACHYON_LOGS_DIR
  -Dtachyon.master.web.port={{ tachyon['ui.port'] }}
  -Dtachyon.zookeeper.address={{ zk_str }}
  -Dtachyon.worker.data.folder=$TACHYON_RAM_FOLDER/tachyonworker/
  -Dtachyon.master.worker.timeout.ms=60000
  -Dtachyon.master.hostname=$TACHYON_MASTER_ADDRESS
  -Dtachyon.max.columns={{ tachyon['max.columns'] }}
  -Dtachyon.max.table.metadata.byte={{ tachyon['max.metadata'] }}
  -Dtachyon.master.journal.folder=hdfs://{{ nameservice_names | first }}{{ tachyon['journal'] }}
  -Dtachyon.master.pinlist=/pinfiles;/pindata
"

# Master specific parameters. Default to TACHYON_JAVA_OPTS.
export TACHYON_MASTER_JAVA_OPTS="$TACHYON_JAVA_OPTS"

# Worker specific parameters that will be shared to all workers. Default to TACHYON_JAVA_OPTS.
export TACHYON_WORKER_JAVA_OPTS="$TACHYON_JAVA_OPTS"
