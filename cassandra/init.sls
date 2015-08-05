#{% set app_name = 'cassandra'%}

#{% set cassandra_home = salt['system.home_dir'](app_name) -%}
#{% set cassandra = pillar[app_name] -%}

#{% from 'system/install.sls' import install_tarball with context -%}
#{{ install_tarball(app_name, False) }}

#{% set env = {'CASSANDRA_NUM_TOKENS': cassandra['num_tokens'],
#               'CASSANDRA_CLUSTER_NAME': grains['cluster_name'],
#               'CASSANDRA_STORE_PATH': cassandra_home} %}

#{% set cassandra_command = 'cd {2} && launcher/configurator.py {0} {1} conf/cassandra.yaml && bin/cassandra -Dcassandra.consistent.rangemovement={3} -f'.format(app_name, cassandra['seed_ratio'], cassandra['dirname'], cassandra['rangemovement']) %}

#{% from 'marathon/deploy.sls' import service_deploy with context -%}
#{{ service_deploy({'id': app_name, 'cmd': cassandra_command, 'env': env}) }}

## need rework to use dedicated scheduler ##