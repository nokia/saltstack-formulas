{% set home = salt['system.home_dir']('riemann_client') -%}
{% set riemann = pillar['riemann'] %}
{% set server = salt['riemann.master']() -%}
{% set server_port = riemann['server.port'] %}
{% set interval  = riemann['interval'] %}
{% set timeout  = riemann['timeout'] %}
{% set is_tcp  = riemann['tcp'] %}
{% set my_host = salt['search.my_host']() -%}

{% from 'riemann/checks/hadoop.sls' import hadoop_check with context -%}
{{ hadoop_check('datanode', my_host, server, server_port, home, interval, timeout, is_tcp) }}

{% from 'riemann/checks/hadoop.sls' import hadoop_check with context -%}
{{ hadoop_check('namenode', my_host, server, server_port, home, interval, timeout, is_tcp) }}

{% from 'riemann/checks/postgresql.sls' import postgresql_check with context -%}
{{ postgresql_check(my_host, server, server_port, home, interval, timeout, is_tcp) }}

{% from 'riemann/checks/tools.sls' import health_check with context -%}
{{ health_check(my_host, server, server_port, home, interval, timeout, is_tcp) }}

{% from 'riemann/checks/tools.sls' import net_check with context -%}
{{ net_check(my_host, server, server_port, home, interval, timeout, is_tcp) }}

{% from 'riemann/checks/tools.sls' import fd_check with context -%}
{{ fd_check(my_host, server, server_port, home, interval, timeout, is_tcp) }}

{% from 'riemann/checks/tools.sls' import disks_check with context -%}
{{ disks_check(my_host, server, server_port, home, interval, timeout, is_tcp) }}

{% from 'riemann/checks/tools.sls' import proc_check with context -%}
{{ proc_check(my_host, server, server_port, home, interval, timeout, is_tcp) }}

{% from 'riemann/checks/tools.sls' import zookeeper_check with context -%}
{{ zookeeper_check(my_host, server, server_port, home, interval, timeout, is_tcp) }}

{% from 'riemann/checks/jmx.sls' import jmx_check with context -%}
{{ jmx_check(my_host, server, server_port, home, interval, timeout, is_tcp) }}

