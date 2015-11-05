{% macro health_check(my_host, server, server_port, home, interval, timeout, is_tcp) -%}

{% set cmd = 'riemann-health --tag health' %}
{% from 'riemann/checks/check.sls' import check with context -%}
{{ check('riemann-health', cmd, server, server_port, home, interval, timeout, is_tcp, True) }}

{%- endmacro %}

{% macro net_check(my_host, server, server_port, home, interval, timeout, is_tcp) -%}

{% set cmd = 'riemann-net --interfaces {0} --tag health'.format(' '.join(pillar['ip_interfaces'].keys())) %}
{% from 'riemann/checks/check.sls' import check with context -%}
{{ check('riemann-net', cmd, server, server_port, home, interval, timeout, is_tcp, True) }}

{%- endmacro %}

{% macro fd_check(my_host, server, server_port, home, interval, timeout, is_tcp) -%}

{% set cmd = 'riemann-fd --tag health' %}
{% from 'riemann/checks/check.sls' import check with context -%}
{{ check('riemann-fd', cmd, server, server_port, home, interval, timeout, is_tcp, True) }}

{%- endmacro %}


{% macro disks_check(my_host, server, server_port, home, interval, timeout, is_tcp) -%}

{% set cmd = 'riemann-diskstats --devices "{0}" --tag health'.format(pillar['system']['root_device']) %}
{% from 'riemann/checks/check.sls' import check with context -%}
{{ check('riemann-diskstats', cmd, server, server_port, home, interval, timeout, is_tcp, True) }}

{%- endmacro %}


{% macro proc_check(my_host, server, server_port, home, interval, timeout, is_tcp) -%}

{% set proc_check = salt['riemann.proc_checks']() %}

{% for proc in proc_check %}

{% set cmd = 'riemann-proc --proc-regex "{0}" --tag proc'.format(proc['regexp']) %}
{% from 'riemann/checks/check.sls' import check with context -%}
{{ check('riemann-proc-{0}'.format(proc['name']), cmd, server, server_port, home, interval, timeout, is_tcp, True) }}

{% endfor %}

{%- endmacro %}

{% macro zookeeper_check(my_host, server, server_port, home, interval, timeout, is_tcp) -%}

{% set cmd = 'riemann-zookeeper --tag zookeeper --zookeeper-host {0}'.format(my_host) %}
{% from 'riemann/checks/check.sls' import check with context -%}
{{ check('riemann-zookeeper', cmd, server, server_port, home, interval, timeout, is_tcp, 'zookeeper.server' in salt['grains.get']('roles')) }}

{%- endmacro %}


