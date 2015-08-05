{% macro check(name, cmd, server, server_port, home, interval, timeout, is_tcp, enabled) -%}

/etc/init/{{ name }}.conf:
  file.managed:
    - source: salt://riemann/files/riemann-check.conf
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
        home_dir: {{ home }}
        name: {{ name }}
        check_cmd: {{ cmd }}
        default_settings: --host {{ server }} --port {{ server_port }} --interval {{ interval }} --timeout {{ timeout }} --tcp {{ is_tcp }}

{{ name }}-service:
  {% if enabled -%}
  service.running:
    - name: {{ name }}
    - enable: True
    - watch:
      - file: /etc/init/{{ name }}.conf
  {% else -%}
  service.dead:
    - name: {{ name }}
    - enable: False
  {% endif -%}

{%- endmacro %}
