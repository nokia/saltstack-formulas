{% set riemann = pillar['riemann'] -%}
{% set home = salt['system.home_dir']('riemann_client') -%}

include:
  - java.openjdk
  - ruby

rieman_group:
  group.present:
    - name: riemann

riemann_user:
  user.present:
    - name: riemann
    - groups:
      - riemann
    - require:
      - group: rieman_group

riemann-meta-directories:
  file.directory:
    - names:
        - {{ salt['system.log_dir']('riemann_client') }}
        - {{ home }}
        - /etc/riemann
    - user: riemann
    - group: riemann
    - mode: 755
    - makedirs: True
    - require:
      - user: riemann_user

riemann-client:
  gem.installed:
    - version: {{ riemann['client.version'] }}

riemann-tools:
  gem.installed:
    - version: {{ riemann['tools.version'] }}

lsof_pkg:
  pkg.installed:
    - name: lsof

{% if 'postgresql' in salt['grains.get']('roles') -%}

postgresql-server-dev:
  pkg.installed:
    - name: postgresql-server-dev-9.3

riemann-postgresql:
  gem.installed:
    - version: {{ riemann['postgresql.version'] }}
{% endif %}

riemann-hadoop:
  gem.installed:
    - version: {{ riemann['hadoop.version'] }}

riemann-jmx-jar:
  file.managed:
    - name: {{ home }}/riemann-jmx.jar
    - source: {{ riemann['jmx_url'] }}
    - source_hash: {{ riemann['jmx_checksum'] }}
    - user: riemann
    - group: riemann
    - mode: 755

{% include 'riemann/agent_checks.sls' %}
