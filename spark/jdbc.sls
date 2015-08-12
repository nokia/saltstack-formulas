{% set spark_home = salt['system.home_dir']('spark') -%}

{% set command = "{0}/sbin/run-jdbc-server.sh --driver-class-path {0}/lib/postgresql-jdbc.jar --hiveconf hive.server2.thrift.port=$PORT1 --conf spark.ui.port=$PORT0".format(spark_home) %}

{% from 'marathon/deploy.sls' import service_deploy with context -%}
{{ service_deploy({'id': 'sparkjdbc', 'cmd': command}) }}
