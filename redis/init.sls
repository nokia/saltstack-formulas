{% set app_name = 'redis'%}
{% set redis_home = salt['system.home_dir'](app_name) -%}
{% set redis = pillar[app_name] -%}

{% from 'system/install.sls' import install_tarball with context -%}
{{ install_tarball(app_name, False) }}

{% set env = {'REDIS_MAX_MEMORY': '{0}mb'.format(redis['mem']) } %}

{% set redis_command = 'rm -rf nodes.conf && cd {2} && ( (launcher/configurator.py {0} {1} ./redis.conf,./seed_uri.yml) && (launcher/launcher.py seed_uri.yml > ./client.log 2>&1 &) && src/redis-server ./redis.conf)'.format(app_name, redis['seed_ratio'], redis['dirname']) %}

{% from 'marathon/deploy.sls' import service_deploy with context -%}
{{ service_deploy({'id': app_name, 'cmd': redis_command, 'env': env}) }}

