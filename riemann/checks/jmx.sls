{% macro jmx_check(my_host, server, server_port, home, interval, timeout, is_tcp) -%}

{% set jmx_checks = salt['riemann.jmx_checks'](my_host) + salt['riemann.cassandra_jmx_checks'](my_host) %}

{% for jmx_check in jmx_checks %}

{% set my_jmx_host = jmx_check.get('my_host', my_host) -%}
{% set my_event_host = jmx_check.get('event_host', my_host) -%}

{{ home }}/{{ jmx_check['name'] }}.yml:
  file.managed:
    - source: salt://riemann/files/jmx.yaml
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
        riemann_server: {{ server }}
        riemann_port: {{ server_port }}
        jmx_port: {{ jmx_check['port'] }}
        my_host: {{ my_jmx_host }}
        my_event_host: {{ my_event_host }}
        jmx_queries:
          {{ jmx_check['queries'] | yaml }}

{% endfor %}

/etc/init/riemann-jmx.conf:
  file.managed:
    - source: salt://riemann/files/riemann-check.conf
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
        home_dir: {{ home }}
        name: riemann-jmx
        check_cmd: java -jar riemann-jmx.jar {{ salt['riemann.as_file_names'](jmx_checks) }}
        default_settings: ''

riemann-jmx-service:
  {% if jmx_checks | length > 0 -%}
  service.running:
    - name: riemann-jmx
    - enable: True
    - watch:
      - file: /etc/init/riemann-jmx.conf
      {% for jmx_check in jmx_checks -%}
      - file: {{ home }}/{{ jmx_check['name'] }}.yml
      {% endfor -%}
  {% else -%}
  service.dead:
    - name: riemann-jmx
    - enable: False
  {% endif -%}


{%- endmacro %}
