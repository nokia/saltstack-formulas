include:
  - mesos.service_common

{% set app_name = 'ignite-mesos' -%}
{% set ignite = pillar[app_name] -%}
{% set ignite_env = ignite['environment'] -%}
{% set zk_str = salt['zookeeper.ensemble_address']() -%}
{% set env = {'MESOS_MASTER_URL': 'zk://{0}/mesos'.format(zk_str)} -%}
{% do env.update(ignite_env) -%}

{% set ignite_command = 'IGNITE_HTTP_SERVER_HOST=$HOST IGNITE_HTTP_SERVER_PORT=$PORT0 java -jar ignite-mesos-1.3.0-incubating-jar-with-dependencies.jar' %}

{% from 'marathon/deploy.sls' import service_deploy with context -%}
{{ service_deploy({'id': app_name, 'cmd': ignite_command, 'env': env}) }}
