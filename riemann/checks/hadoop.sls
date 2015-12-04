
{% macro hadoop_check(type, my_host, server, server_port, home, interval, timeout, is_tcp) -%}

{% set hadoop_port = pillar['hdfs']['{0}.ui.port'.format(type)] %}

{% set cmd = 'riemann-hadoop-{0} --{0}-port {1} --tag hadoop'.format(type, hadoop_port) %}
{% from 'riemann/checks/check.sls' import check with context -%}

{% if type == 'namenode' %}
{{ check('riemann-hadoop-{0}'.format(type), cmd, server, server_port, home, interval, timeout, is_tcp, 'hdfs.{0}'.format(type) in salt['grains.get']('roles')
    and (salt['hdfs.is_secondary_namenode']() or salt['hdfs.is_primary_namenode']()) ) }}
{% else %}
{{ check('riemann-hadoop-{0}'.format(type), cmd, server, server_port, home, interval, timeout, is_tcp, 'hdfs.{0}'.format(type) in salt['grains.get']('roles')) }}
{% endif %}

{%- endmacro %}
