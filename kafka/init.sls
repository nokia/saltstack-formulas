{% set app_name = 'kafka-mesos'%}
{% set kafka_home = salt['system.home_dir'](app_name) -%}
{% set kafka = pillar[app_name] -%}

{% set zk_str = salt['zookeeper.ensemble_address']() -%}
{% set api_url = 'http://$HOST:$PORT0' -%}
{% set config = {'api': api_url, 'master': 'zk://{0}/mesos'.format(zk_str), 'zk': zk_str} -%}
{% do config.update(kafka.get('schedulerConfiguration', {})) -%}
{% set cmd_line = salt['kafka.format_options'](config, '\"') -%}

{% set kafka_command = 'chmod u+x ./kafka-mesos.sh && ./kafka-mesos.sh scheduler {0}'.format(cmd_line) %}

{% from 'marathon/deploy.sls' import service_deploy with context -%}
{{ service_deploy({'id': app_name, 'cmd': kafka_command}) }}

{% set haproxy_hosts = salt['search.mine_by_host']('roles:haproxy') -%}
{% set scheduler_port = kafka['ports'][0] -%}
{% set broker_instances = kafka.get('brokerInstances', 1) -%}
{% set broker_config = {'instances': broker_instances} -%}
{% do broker_config.update(kafka.get('brokerConfiguration', {})) -%}
{% set tmp_dir = pillar['system']['tmp'] -%}


broker-configuration:
  file.managed:
    - name: {{ tmp_dir }}/kafka-mesos-broker-config.json
    - source: salt://kafka/files/kafka-mesos-broker-config.json
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
        config: {{ broker_config | yaml  }}

broker-reconfigure:
  module.wait:
    - name: kafka.reconfigure
    - config: {{ broker_config | yaml }}
    - hosts: {{ haproxy_hosts | yaml }}
    - port: {{ scheduler_port }}
    - require:
      - module: run-service-deploy-kafka-mesos
      - module: run-service-redeploy-kafka-mesos
    - watch:
      - file: broker-configuration
