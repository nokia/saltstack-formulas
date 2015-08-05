#{% set app_name = 'kafka'%}
#{% set kafka_home = salt['system.home_dir'](app_name) -%}
#{% set kafka = pillar[app_name] -%}

#{% from 'system/install.sls' import install_tarball with context -%}
#{{ install_tarball(app_name, False) }}

#{% set zk_str = salt['zookeeper.ensemble_address']() -%}

#{% set env = {'KAFKA_NET_THREADS_NO': kafka['net_threads_no'],
#               'KAFKA_IO_THREADS_NO': kafka['io_threads_no'],
#               'KAFKA_PARTITIONS_NO': kafka['partitions_no'],
#               'KAFKA_LOG_RETENTION_HOURS': kafka['log_retention_hours'],
#               'ZK_CONNECTION': zk_str ,
#               'KAFKA_STORE_PATH': kafka_home} %}

#{% set kafka_command = 'cd {2} && launcher/configurator.py {0} {1} config/server.properties && JMX_PORT=$PORT1 bin/kafka-server-start.sh config/server.properties'.format(app_name, 0, kafka['dirname']) %}

#{% from 'marathon/deploy.sls' import service_deploy with context -%}
#{{ service_deploy({'id': app_name, 'cmd': kafka_command, 'env': env}) }}

### need rework to use dedicated scheduler ###
