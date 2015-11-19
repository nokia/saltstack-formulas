

{% macro service_deploy(app) -%}

{% set app_name = app['id'] -%}
{% set app_merged = salt['marathon_client.merge'](app, pillar[app_name]) %}
{% set tmp_dir = pillar['system']['tmp'] -%}
{% set nameservice_names = salt['hdfs.nameservice_names']() -%}
{% set uris = app_merged.get('uris', []) -%}

{% for uri in uris -%}

{% set uri_basename = salt['system.basename'](uri) -%}

app-uri-file-{{ uri_basename }}:
  file.managed:
    - name: {{ tmp_dir }}/{{ uri_basename  }}
    - source: {{ uri }}
    - user: root
    - group: root
    - mode: 755

{% for nameservice in nameservice_names %}

{% set basepath = "hdfs://{0}{1}".format(nameservice, pillar['hdfs']['pkgs_path']) -%}
{% set filepath = "{0}/{1}".format(basepath, uri_basename) -%}

app-uri-file-in-hdfs-{{ nameservice }}-{{ uri_basename }}:
  cmd.wait:
    - name: |
        hadoop fs -mkdir -p {{ basepath }}
        hadoop fs -chmod -R 1777 {{ basepath }}
        hadoop fs -copyFromLocal -f {{ tmp_dir }}/{{ uri_basename  }} {{ filepath }}
        hadoop fs -chmod -R 1777 {{ filepath }}
    - user: hdfs
    - group: hdfs
    - timeout: 30
    - watch:
      - file: app-uri-file-{{ uri_basename }}

{% endfor %}

{% endfor %}

{% do app_merged.update({'uris': salt['hdfs.map_uris'](uris)}) -%}

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
      {% for uri in uris -%}
      {% set uri_basename = salt['system.basename'](uri) -%}
      {% for nameservice in nameservice_names -%}
      - cmd: app-uri-file-in-hdfs-{{ nameservice }}-{{ uri_basename }}
      {% endfor %}
      {% endfor %}

run-service-redeploy-{{ app_name }}:
  module.wait:
    - name: marathon_client.re_deploy
    - app_name: {{ app_name }}
    - app_file: {{ tmp_dir }}/{{ app_name }}.json
    - require:
      - module: run-service-deploy-{{ app_name }}
    - watch:
      - file: app-config-file-{{ app_name }}

run-service-restart-{{ app_name }}:
  module.wait:
    - name: marathon_client.restart
    - app_name: {{ app_name }}
    - require:
      - module: run-service-deploy-{{ app_name }}
      - module: run-service-redeploy-{{ app_name }}
    - watch:
      {% for uri in uris -%}
      {% set uri_basename = salt['system.basename'](uri) -%}
      - file: app-uri-file-{{ uri_basename }}
      {% endfor %}

{%- endmacro %}


{% macro service_undeploy(app_id) -%}

run-service-undeploy-{{ app_id }}:
  module.run:
    - name: marathon_client.undeploy
    - app_name: {{ app_id }}

{%- endmacro %}


