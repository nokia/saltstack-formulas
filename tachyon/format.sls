include:
  - tachyon.common

{% set tachyon = pillar['tachyon'] -%}
{% set nameservice_names = salt['hdfs.nameservice_names']() -%}
{% set tachyon_home = salt['system.home_dir']('tachyon') -%}

{% if salt['tachyon.is_primary_master']() %}
format-tachyon:
  cmd.run:
    - name: {{ tachyon_home }}/bin/tachyon format
    - user: root
    - group: root
    - unless: hdfs dfsadmin -safemode wait && hdfs dfs -ls hdfs://{{ nameservice_names | first }}{{ tachyon['journal'] }}
    - timeout: 30
    - require:
      - file: tachyon-ramdisk-directory
      - file: tachyon-log-directory
      - file: {{ tachyon_home }}/conf/tachyon-env.sh
      - file: {{ tachyon_home }}/libexec/tachyon-layout.sh
      - file: {{ tachyon_home }}/bin/tachyon-wrapper.sh
      - file: /etc/init/tachyon-master.conf

{% endif %}
