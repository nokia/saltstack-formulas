
{% macro postgresql_check(my_host, server, server_port, home, interval, timeout, is_tcp) -%}

{% set riemann = pillar['riemann'] -%}

{% set cmd = 'riemann-postgresql --postgresql-password {0} --postgresql-host {1} --tag postgresql'.format(pillar.get('postgresql', {}).get('password', ''), my_host) %}
{% from 'riemann/checks/check.sls' import check with context -%}
{{ check('riemann-postgresql', cmd, server, server_port, home, interval, timeout, is_tcp, 'postgresql' in salt['grains.get']('roles')) }}


{%- endmacro %}



