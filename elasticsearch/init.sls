include:
  - mesos.service_common

{% set app_name = 'elasticsearch-mesos'%}
{% set elasticsearch_home = salt['system.home_dir'](app_name) -%}
{% set elasticsearch = pillar[app_name] -%}

{% set env = {'JAVA_OPTS': elasticsearch['java_opts']} %}

{% set zk_str = salt['zookeeper.ensemble_ips']() -%}

{% set es_command = '/tmp/start-scheduler.sh -zk zk://{0}/mesos -n {1} -ram {2} -m $PORT0'.format(zk_str, elasticsearch['worker_instances'], elasticsearch['worker_mem']) %}

{% from 'marathon/deploy.sls' import service_deploy with context -%}
{{ service_deploy({'id': app_name, 'cmd': es_command, 'env': env}) }}
