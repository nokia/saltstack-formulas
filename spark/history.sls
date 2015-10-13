include:
  - mesos.service_common

{% set spark_home = salt['system.home_dir']('spark') -%}
{% set spark = pillar['spark'] -%}
{% set nameservice_names = salt['hdfs.nameservice_names']() -%}

{% for nameservice in nameservice_names %}

{% set remote_path = "hdfs://{0}{1}".format(nameservice,spark['eventlog.dir']) -%}
spark-event-log-hdfs-directory_{{ nameservice }}:
  cmd.run:
    - name: hadoop fs -mkdir {{ remote_path }} && hadoop fs -chmod -R 1777 {{ remote_path }}
    - user: hdfs
    - group: hdfs
    - unless: hdfs dfsadmin -safemode wait && hdfs dfs -ls {{ remote_path }}
    - timeout: 30

{% endfor %}


{% set history_server_command = "{0}/sbin/run-history-server.sh $PORT".format(spark_home) %}

{% from 'marathon/deploy.sls' import service_deploy with context -%}
{{ service_deploy({'id': 'sparkhistory', 'cmd': history_server_command}) }}
