{% macro service_deploy(app) -%}

{% set app_name = app['id'] -%}
{% set app_merged = salt['marathon_client.merge'](app, pillar[app_name]) %}
{% set tmp_dir = pillar['system']['tmp'] -%}

app-config-file-{{ app_name }}:
  file.managed:
    - name: {{ tmp_dir }}/{{ app_name }}.json
    - source: salt://marathon/files/application.json
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
        app: {{ app_merged }}

run-service-deploy-{{ app_name }}:
  module.run:
    - name: marathon_client.new_deploy
    - app_name: {{ app_name }}
    - app_file: {{ tmp_dir }}/{{ app_name }}.json
    - require:
      - file: app-config-file-{{ app_name }}

run-service-redeploy-{{ app_name }}:
  module.wait:
    - name: marathon_client.re_deploy
    - app_name: {{ app_name }}
    - app_file: {{ tmp_dir }}/{{ app_name }}.json
    - require:
      - module: run-service-deploy-{{ app_name }}
    - watch:
      - file: app-config-file-{{ app_name }}

{%- endmacro %}


{% macro service_undeploy(app_id) -%}

run-service-undeploy-{{ app_id }}:
  module.run:
    - name: marathon_client.undeploy
    - app_name: {{ app_id }}

{%- endmacro %}


