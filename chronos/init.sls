{% set chronos = pillar['chronos'] -%}
{% set zk_str = salt['zookeeper.ensemble_address']() -%}

{% set chronos_command = "java -cp {0} org.apache.mesos.chronos.scheduler.Main --master zk://{1}/mesos --zk_hosts {1} --http_port $PORT".format(chronos['tarball'], zk_str ) -%}

{% from 'marathon/deploy.sls' import service_deploy with context -%}
{{ service_deploy({'id': 'chronos', 'cmd': chronos_command}) }}
