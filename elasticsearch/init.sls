#{% set app_name = 'elasticsearch'%}
#{% set elasticsearch_home = salt['system.home_dir'](app_name) -%}
#{% set elasticsearch = pillar[app_name] -%}

#{% from 'system/install.sls' import install_tarball with context -%}
#{{ install_tarball(app_name, False) }}

#{% set env = {'ES_CLUSTER_NAME': grains['cluster_name'],
#               'ES_SHARDS_NO': elasticsearch['shards_no'],
#               'ES_REPLICAS_NO': elasticsearch['replicas_no'],
#               'ES_STORE_PATH': elasticsearch_home} %}

#{% set es_command = 'cd {2} && launcher/configurator.py {0} {1} config/elasticsearch.yml && bin/elasticsearch'.format(app_name, elasticsearch['seed_ratio'], elasticsearch['dirname']) %}

#{% from 'marathon/deploy.sls' import service_deploy with context -%}
#{{ service_deploy({'id': app_name, 'cmd': es_command, 'env': env}) }}

# need rework to use dedicated scheduler #