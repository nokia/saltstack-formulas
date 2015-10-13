include:
  - mesos.service_common

{% set chronos = pillar['chronos'] -%}
{% set zk_str = salt['zookeeper.ensemble_address']() -%}

{% set chronos_command = "java -cp *.jar org.apache.mesos.chronos.scheduler.Main --master zk://{0}/mesos --zk_hosts {0} --http_port $PORT".format(zk_str ) -%}

{% from 'marathon/deploy.sls' import service_deploy with context -%}
{{ service_deploy({'id': 'chronos', 'cmd': chronos_command}) }}
