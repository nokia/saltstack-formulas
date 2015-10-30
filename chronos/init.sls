include:
  - mesos.service_common

{% set chronos = pillar['chronos'] -%}
{% set zk_str = salt['zookeeper.ensemble_address']() -%}

{% set smtp = chronos.get('smtp', {}) -%}
{% set server = ' --mail_server {0} '.format(smtp['server']) if smtp['server'] is defined else '' -%}
{% set user = ' --mail_user {0} '.format(smtp['user']) if smtp['user'] is defined else '' -%}
{% set pass = ' --mail_password {0} '.format(smtp['password']) if smtp['password'] is defined else '' -%}
{% set from = ' --mail_from {0} '.format(smtp['from']) if smtp['from'] is defined else '' -%}
{% set ssl = ' --mail_ssl ' if smtp.get('ssl', True) else '' -%}
{% set smtp_str = '{0}{1}{2}{3}{4}'.format(server, user, pass, from, ssl) -%}

{% set chronos_command = "java -cp *.jar org.apache.mesos.chronos.scheduler.Main --master zk://{0}/mesos --zk_hosts {0} --http_port $PORT {1}".format(zk_str, smtp_str) -%}

{% from 'marathon/deploy.sls' import service_deploy with context -%}
{{ service_deploy({'id': 'chronos', 'cmd': chronos_command}) }}
