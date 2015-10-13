{% set conf_dir = pillar['hdfs']['conf_dir'] -%}

include:
  - java
  - hdfs.configuration

hadoop-journal-service:
  service.running:
    - names:
        - hadoop-hdfs-journalnode
    - enable: True
    - require:
        - file: hadoop-journal-directories
    - watch:
        - file: /etc/hadoop/{{ conf_dir }}/core-site.xml
        - file: /etc/hadoop/{{ conf_dir }}/hdfs-site.xml
        - file: /etc/hadoop/{{ conf_dir }}/hadoop-env.sh
