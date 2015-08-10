{% set zk_str = salt['zookeeper.ensemble_address']() -%}
{% set spark_home = salt['system.home_dir']('spark') -%}
{% set zeppelin_home = salt['system.home_dir']('zeppelin') -%}
{% from "postgresql/map.jinja" import jdbc with context -%}

include:
  - java.openjdk
  - postgresql.jdbc

{% from 'system/install.sls' import install_tarball with context -%}
{{ install_tarball('zeppelin', False) }}

{{ zeppelin_home }}/conf/zeppelin-env.sh:
  file.managed:
    - source: salt://zeppelin/files/zeppelin-env.sh
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
        spark_home: {{ spark_home }}
        zk_str: {{ zk_str }}
        hdfs_conf_path: {{ pillar['hdfs']['conf'] }}
    - require:
      - archive: zeppelin-pkg
      - file: zeppelin-pkg-link

{{ zeppelin_home }}/conf/zeppelin-site.xml:
  file.managed:
    - source: salt://zeppelin/files/zeppelin-site.xml
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
        zeppelin_server_port: {{ pillar['zeppelin']['port'] }}
    - require:
      - archive: zeppelin-pkg
      - file: zeppelin-pkg-link

zeppelin-sparksql-jdbc-jar-link:
  file.symlink:
    - name: {{ zeppelin_home }}/lib/postgresql-jdbc.jar
    - target: {{ pillar['java']['share_dir'] }}/{{ jdbc.postgresql_jdbc }}
    - force: True
    - require:
      - archive: zeppelin-pkg
      - file: zeppelin-pkg-link
