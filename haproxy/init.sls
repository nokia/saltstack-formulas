{% set log_dir = salt['system.log_dir']('haproxy') -%}

{% set haproxy = pillar['haproxy'] %}

haproxy-repo:
  pkgrepo.managed:
    - humanname: HAPROXY 15 PPA
    - names:
      - {{ haproxy['repository']}}
      - {{ haproxy['repository_src']}}
    - file: /etc/apt/sources.list.d/haproxy.list

haproxy-pkg:
  pkg.installed:
    - name: haproxy
    - version: {{ haproxy['version'] }}
    - skip_verify: True
    - require:
      - pkgrepo: haproxy-repo

haproxy-enabled:
  file.replace:
    - name: /etc/default/haproxy
    - pattern: ^ENABLED=0
    - repl: ENABLED=1

haproxy-log-directory:
  file.directory:
    - name: {{ log_dir }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
    - unless: ls {{ log_dir }}

haproxy-rsyslog-config:
  file.managed:
    - name: /etc/rsyslog.d/49-haproxy.conf
    - source: salt://haproxy/files/haproxy-rsyslog.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        log_dir: {{ log_dir }}
    - require:
      - file: haproxy-log-directory

haproxy-rsyslog-restart:
  cmd.wait:
    - name: service rsyslog restart
    - user: root
    - group: root
    - watch:
      - file: haproxy-rsyslog-config

{% if haproxy['cert_server'] is defined -%}
/etc/haproxy/server.pem:
  file.managed:
    - source: {{ haproxy['cert_server'] }}
    {% if haproxy['cert_server_checksum'] is defined  -%}
    - source_hash: {{ haproxy['cert_server_checksum'] }}
    {% endif -%}
    - user: root
    - group: root
    - mode: 644
{% endif -%}

{% if haproxy['cert_ca'] is defined -%}
/etc/haproxy/ca.crt:
  file.managed:
    - source: {{ haproxy['cert_ca'] }}
    {% if haproxy['cert_ca_checksum'] is defined  -%}
    - source_hash: {{ haproxy['cert_ca_checksum'] }}
    {% endif -%}
    - user: root
    - group: root
    - mode: 644
{% endif -%}

{% include 'haproxy/reload_cfg.sls' %}
