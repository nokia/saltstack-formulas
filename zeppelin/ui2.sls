{% set zeppelin_home = salt['system.home_dir']('zeppelin') -%}

{% set command = "{0}/bin/zeppelin.sh".format(zeppelin_home) %}


{% from 'marathon/deploy.sls' import service_deploy with context -%}
{{ service_deploy({'id': 'zeppelin', 'cmd': command, 'uris':[]}) }}
