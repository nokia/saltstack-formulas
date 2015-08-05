{% set hdfs = pillar['hdfs'] -%}
{% set roles = salt['grains.get']('roles') -%}
{% set conf_dir = hdfs['conf_dir'] -%}
include:
  - java.openjdk
  - cloudera.repository

hadoop-pkgs:
  pkg.installed:
  - names:
    {% if 'hdfs.datanode' in roles -%}
    - hadoop-hdfs-datanode
    {%- endif %}
    {% if 'hdfs.namenode' in roles -%}
    - hadoop-hdfs-namenode
    - hadoop-hdfs-zkfc
    {%- endif %}
    {% if 'hdfs.journalnode' in roles -%}
    - hadoop-hdfs-journalnode
    {%- endif %}
    - hadoop-client
  - require:
    - pkgrepo: cloudera-repository
    - pkg: jdk

hadoop-conf:
  cmd.run:
    - name: cp -r /etc/hadoop/{{ hdfs['conf_dist_dir'] }} /etc/hadoop/{{ conf_dir }}
    - unless: ls /etc/hadoop/{{ conf_dir }}
    - require:
      - pkg: hadoop-pkgs

hadoop-conf-install:
  alternatives.install:
    - name: hadoop-conf
    - link: /etc/hadoop/conf
    - path: /etc/hadoop/{{ conf_dir }}
    - priority: 50
    - watch:
      - cmd: hadoop-conf

hadoop-conf-set:
  alternatives.set:
    - name: hadoop-conf
    - path: /etc/hadoop/{{ conf_dir }}
    - require:
      - alternatives: hadoop-conf-install

