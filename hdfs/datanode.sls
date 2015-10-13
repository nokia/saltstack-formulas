{% set conf_dir = pillar['hdfs']['conf_dir'] -%}

include:
  - java
  - hdfs.configuration

hadoop-data-service:
  service.running:
    - names:
        - hadoop-hdfs-datanode
    - enable: True
    - require:
        - file: hadoop-data-directories
    - watch:
        - file: /etc/hadoop/{{ conf_dir }}/core-site.xml
        - file: /etc/hadoop/{{ conf_dir }}/hdfs-site.xml
        - file: /etc/hadoop/{{ conf_dir }}/hadoop-env.sh
