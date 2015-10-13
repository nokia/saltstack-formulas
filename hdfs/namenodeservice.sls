{% set conf_dir = pillar['hdfs']['conf_dir'] -%}

hadoop-service:
  service.running:
    - names:
        - hadoop-hdfs-namenode
        - hadoop-hdfs-zkfc
    - enable: True
    - require:
        - file: hadoop-namedata-directories
    - watch:
        - file: /etc/hadoop/{{ conf_dir }}/core-site.xml
        - file: /etc/hadoop/{{ conf_dir }}/hdfs-site.xml
        - file: /etc/hadoop/{{ conf_dir }}/hadoop-env.sh
