#!/bin/bash
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
{% set zeppelin = pillar['zeppelin'] -%}
# export JAVA_HOME=
export MASTER=mesos://zk://{{ zk_str }}/mesos                 		# Spark master url. eg. spark://master_addr:7077. Leave empty if you want to use local mode.
export MESOS_NATIVE_LIBRARY="{{ pillar['mesos']['libmesos'] }}"

{{ 'export ZEPPELIN_JAVA_OPTS="{0}"'.format(zeppelin['java_opts']) if zeppelin['java_opts'] is defined else '# export ZEPPELIN_JAVA_OPTS' }} # Additional jvm options. for example, export ZEPPELIN_JAVA_OPTS="-Dspark.executor.memory=8g -Dspark.cores.max=16"

{{ 'export ZEPPELIN_MEM="{0}"'.format(zeppelin['jvm_mem']) if zeppelin['jvm_mem'] is defined else '# export ZEPPELIN_MEM' }}            		# Zeppelin jvm mem options Default -Xmx1024m -XX:MaxPermSize=512m
# export ZEPPELIN_INTP_MEM       		# zeppelin interpreter process jvm mem options. Default = ZEPPELIN_MEM
# export ZEPPELIN_INTP_JAVA_OPTS 		# zeppelin interpreter process jvm options. Default = ZEPPELIN_JAVA_OPTS

# export ZEPPELIN_LOG_DIR        		# Where log files are stored.  PWD by default.
# export ZEPPELIN_PID_DIR        		# The pid files are stored. /tmp by default.
{{ 'export ZEPPELIN_NOTEBOOK_DIR={0}'.format(zeppelin['notebook_dir']) if zeppelin['notebook_dir'] is defined else '# export ZEPPELIN_NOTEBOOK_DIR' }}    		# Where notebook saved
{{ 'export ZEPPELIN_NOTEBOOK_HOMESCREEN={0}'.format(zeppelin['notebook_homescreen']) if zeppelin['notebook_homescreen'] is defined else '# export ZEPPELIN_NOTEBOOK_HOMESCREEN' }}  # Id of notebook to be displayed in homescreen. ex) 2A94M5J1Z
# export ZEPPELIN_NOTEBOOK_HOMESCREEN_HIDE	# hide homescreen notebook from list when this value set to "true". default "false"
{{ 'export ZEPPELIN_NOTEBOOK_S3_BUCKET={0}'.format(zeppelin['notebook_s3_bucket']) if zeppelin['notebook_s3_bucket'] is defined else '# export ZEPPELIN_NOTEBOOK_S3_BUCKET' }}     # Bucket where notebook saved
{{ 'export ZEPPELIN_NOTEBOOK_S3_USER={0}'.format(zeppelin['notebook_s3_user']) if zeppelin['notebook_s3_user'] is defined else '# export ZEPPELIN_NOTEBOOK_S3_USER' }}       # User in bucket where notebook saved. For example bucket/user/notebook/2A94M5J1Z/note.json
# export ZEPPELIN_IDENT_STRING   		# A string representing this instance of zeppelin. $USER by default.
# export ZEPPELIN_NICENESS       		# The scheduling priority for daemons. Defaults to 0.


#### Spark interpreter configuration ####

## Use provided spark installation ##
## defining SPARK_HOME makes Zeppelin run spark interpreter process using spark-submit
##
export SPARK_HOME="{{ spark_home }}"                             # (required) When it is defined, load it instead of Zeppelin embedded Spark libraries
{{ 'export SPARK_SUBMIT_OPTIONS="{0}"'.format(zeppelin['spark_submit_options']) if zeppelin['spark_submit_options'] is defined else '# export SPARK_SUBMIT_OPTIONS ' }}         # (optional) extra options to pass to spark submit. eg) "--driver-memory 512M --executor-memory 1G".

## Use embedded spark binaries ##
## without SPARK_HOME defined, Zeppelin still able to run spark interpreter process using embedded spark binaries.
## however, it is not encouraged when you can define SPARK_HOME
##
# Options read in YARN client mode
export HADOOP_CONF_DIR="{{ hdfs_conf_path }}"          		# yarn-site.xml is located in configuration directory in HADOOP_CONF_DIR.
# Pyspark (supported with Spark 1.2.1 and above)
# To configure pyspark, you need to set spark distribution's path to 'spark.home' property in Interpreter setting screen in Zeppelin GUI
# export PYSPARK_PYTHON          		# path to the python command. must be the same path on the driver(Zeppelin) and all workers.
# export PYTHONPATH

## Spark interpreter options ##
##
{{ 'export ZEPPELIN_SPARK_USEHIVECONTEXT={0}'.format(zeppelin['spark_usehivecontext']) if zeppelin['spark_usehivecontext'] is defined else '# export ZEPPELIN_SPARK_USEHIVECONTEXT ' }}  # Use HiveContext instead of SQLContext if set true. true by default.
{{ 'export ZEPPELIN_SPARK_CONCURRENTSQL={0}'.format(zeppelin['spark_concurrent_sql']) if zeppelin['spark_concurrent_sql'] is defined else '# export ZEPPELIN_SPARK_CONCURRENTSQL ' }}   # Execute multiple SQL concurrently if set true. false by default.
{{ 'export ZEPPELIN_SPARK_MAXRESULT={0}'.format(zeppelin['spark_spark_maxresult']) if zeppelin['spark_spark_maxresult'] is defined else '# export ZEPPELIN_SPARK_MAXRESULT ' }}       # Max number of SparkSQL result to display. 1000 by default.

export ZEPPELIN_PORT={{ zeppelin['server_port'] }}
