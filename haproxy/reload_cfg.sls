{% set apps = salt['haproxy.services']() %}

{% set haproxy = pillar['haproxy'] %}

{% if haproxy['server_cert'] is defined -%}
/etc/haproxy/server.pem:
  file.managed:
    - source: {{ haproxy['server_cert'] }}
    {% if haproxy['server_cert_checksum'] is defined  -%}
    - source_hash: {{ haproxy['server_cert_checksum'] }}
    {% endif -%}
    - user: root
    - group: root
    - mode: 644
{% else -%}
/etc/haproxy/server.pem:
  file.absent: []
{% endif -%}

{% if haproxy['default_client_cert'] is defined -%}
/etc/haproxy/ca.crt:
  file.managed:
    - source: {{ haproxy['default_client_cert'] }}
    {% if haproxy['default_client_cert_checksum'] is defined  -%}
    - source_hash: {{ haproxy['default_client_cert_checksum'] }}
    {% endif -%}
    - user: root
    - group: root
    - mode: 644
{% else -%}
/etc/haproxy/ca.crt:
  file.absent: []
{% endif -%}

{% for app in apps %}
{% for service  in app['services'] %}
{% if service['client_cert'] is defined -%}
/etc/haproxy/{{ service['client_cert_name'] }}:
  file.managed:
    - source: {{ service['client_cert'] }}
    {% if service['client_cert_checksum'] is defined  -%}
    - source_hash: {{ service['client_cert_checksum'] }}
    {% endif -%}
    - user: root
    - group: root
    - mode: 644
{% endif -%}
{% endfor -%}
{% endfor -%}

/etc/haproxy/haproxy.cfg:
  file.managed:
    - source: salt://haproxy/files/haproxy.cfg
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        apps:
          {{ apps | yaml }}

haproxy-service:
  service.running:
    - name: haproxy
    - enable: True
    - reload: True
    - watch:
      - file: /etc/haproxy/haproxy.cfg
      - file: /etc/haproxy/server.pem
      - file: /etc/haproxy/ca.crt
