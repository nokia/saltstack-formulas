{% macro redis_check(my_host, server, server_port, home, interval, timeout, is_tcp) -%}

{% for check_data in salt['riemann.checks']('redis', my_host) %}

{% set check_port = check_data['port'] -%}
{% set cmd = 'riemann-redis --event-host {0}-{1} --redis-host {0} --redis-port {1} --tag redis'.format(check_data['host'], check_port) %}
{% set name = 'riemann-redis-{0}'.format(check_port) %}

{% from 'riemann/checks/check.sls' import check with context -%}
{{ check(name, cmd, server, server_port, home, interval, timeout, is_tcp, check_data['enabled'] ) }}

{% endfor %}

{%- endmacro %}
