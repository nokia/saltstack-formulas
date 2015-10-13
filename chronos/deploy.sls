

{% macro job_deploy(job) -%}

{% set job_name = job['id'] -%}
{% set job_merged = salt['chronos_client.merge'](job, pillar[job_name]) %}
{% set tmp_dir = pillar['system']['tmp'] -%}
{% set nameservice_names = salt['hdfs.nameservice_names']() -%}
{% set uris = job_merged.get('uris', []) -%}

{% for uri in uris -%}

{% set uri_basename = salt['system.basename'](uri) -%}

job-uri-file-{{ uri_basename }}:
  file.managed:
    - name: {{ tmp_dir }}/{{ uri_basename  }}
    - source: {{ uri }}
    - user: root
    - group: root
    - mode: 755

{% for nameservice in nameservice_names %}

{% set basepath = "hdfs://{0}{1}".format(nameservice, pillar['hdfs']['pkgs_path']) -%}
{% set filepath = "{0}/{1}".format(basepath, uri_basename) -%}

job-uri-file-in-hdfs-{{ nameservice }}-{{ uri_basename }}:
  cmd.run:
    - name: |
        hadoop fs -mkdir -p {{ basepath }}
        hadoop fs -chmod -R 1777 {{ basepath }}
        hadoop fs -copyFromLocal {{ tmp_dir }}/{{ uri_basename  }} {{ filepath }}
        hadoop fs -chmod -R 1777 {{ filepath }}
    - user: hdfs
    - group: hdfs
    - unless: hdfs dfsadmin -safemode wait && hdfs dfs -ls {{ filepath }}
    - timeout: 30
    - require:
      - file: job-uri-file-{{ uri_basename }}

{% endfor %}

{% endfor %}

{% do job_merged.update({'uris': salt['hdfs.map_uris'](uris)}) -%}

job-config-file-{{ job_name }}:
  file.managed:
    - name: {{ tmp_dir }}/{{ job_name }}.json
    - source: salt://chronos/files/job.json
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
        job: {{ job_merged }}

run-job-deploy-{{ job_name }}:
  module.run:
    - name: chronos_client.new_deploy
    - job_name: {{ job_name }}
    - job_file: {{ tmp_dir }}/{{ job_name }}.json
    - require:
      - file: job-config-file-{{ job_name }}
      {% for uri in uris -%}
      {% set uri_basename = salt['system.basename'](uri) -%}
      {% for nameservice in nameservice_names -%}
      - cmd: job-uri-file-in-hdfs-{{ nameservice }}-{{ uri_basename }}
      {% endfor %}
      {% endfor %}

run-job-redeploy-{{ job_name }}:
  module.wait:
    - name: chronos_client.re_deploy
    - job_name: {{ job_name }}
    - job_file: {{ tmp_dir }}/{{ job_name }}.json
    - require:
      - module: run-job-deploy-{{ job_name }}
    - watch:
      - file: job-config-file-{{ job_name }}

{%- endmacro %}


{% macro job_undeploy(job_id) -%}

run-job-undeploy-{{ job_id }}:
  module.run:
    - name: chronos_client.undeploy
    - job_name: {{ job_id }}

{%- endmacro %}


