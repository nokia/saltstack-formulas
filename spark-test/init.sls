
{% set datasets = pillar['spark-test']['datasets'] -%}
{% set deploy_home = salt['system.home_dir']('deploy') -%}

bdastest-work-directory:
  file.directory:
    - name: {{ deploy_home }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
    - unless: ls {{ deploy_home }}

{% for dataset in datasets %}

{{ deploy_home }}/{{ dataset['filename'] }}:
  file.managed:
    - source: {{ pillar['spark-test']['url'] }}/{{ dataset['filename'] }}
    - source_hash: {{ dataset['checksum'] }}
    - user: root
    - group: root
    - mode: 755
    - require:
      - file: bdastest-work-directory

{{ dataset['filename'] }}_to_hdfs:
  cmd.run:
    - name: hdfs dfs -put {{ deploy_home }}/{{ dataset['filename'] }} /tmp
    - user: root
    - group: root
    - mode: 755
    - unless: hdfs dfs -ls /tmp/{{ dataset['filename'] }}
    - require:
      - file: {{ deploy_home }}/{{ dataset['filename'] }}
{% endfor %}
