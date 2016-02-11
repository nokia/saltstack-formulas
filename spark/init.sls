{% set zk_str = salt['zookeeper.ensemble_address']() -%}
{% set hdfs = pillar['hdfs'] -%}
{% set spark = pillar['spark'] -%}
{% set spark_home = salt['system.home_dir']('spark') -%}
{% set tachyon_home = salt['system.home_dir']('tachyon') -%}
{% set tachyon_masters = salt['tachyon.masters']() -%}
{% set postgres = salt['search.mine_by_host']('roles:postgresql') -%}
{% set nameservice_names = salt['hdfs.nameservice_names']() -%}
{% set tmp_dir = pillar['system']['tmp'] %}
{% from "postgresql/map.jinja" import jdbc with context -%}

jblas-deps:
  pkg.installed:
    - names:
      - libgfortran3

include:
  - java
  - postgresql.jdbc

{% from 'system/install.sls' import install_tarball with context -%}
{{ install_tarball('spark', False) }}

{{ spark_home }}/conf/spark-env.sh:
  file.managed:
    - source: salt://spark/files/spark-env.sh
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
        hdfs_conf_path: {{ hdfs['conf'] }}
        tmp_dir: {{ tmp_dir }}
    - require:
      - archive: spark-pkg
      - file: spark-pkg-link

{{ spark_home }}/conf/java-opts:
  file.managed:
    - source: salt://spark/files/java-opts
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
        zk_str: {{ zk_str }}
        tachyon_home: {{ tachyon_home }}
    - require:
      - archive: spark-pkg
      - file: spark-pkg-link

{{ spark_home }}/conf/metrics.properties:
  file.managed:
    - source: salt://spark/files/metrics.properties
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
        show_sample: {{ spark.get('sample', 'true') }}
    - require:
      - archive: spark-pkg
      - file: spark-pkg-link

{{ spark_home }}/conf/spark-defaults.conf:
  file.managed:
    - source: salt://spark/files/spark-defaults.conf
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
        zk_str: {{ zk_str }}
        tmp_dir: {{ tmp_dir }}
        tachyon_masters: {{ tachyon_masters }}
        event_log_dir: hdfs://{{ nameservice_names | first }}{{ spark['eventlog.dir'] }}
        spark_home: {{ spark_home }}
        extra_classpath: {{ salt['system.eval_path_patterns'](spark.get('extra_classpath', [])) | yaml }}
    - require:
      - archive: spark-pkg
      - file: spark-pkg-link


{{ spark_home }}/conf/hive-site.xml:
  file.managed:
    - source: salt://spark/files/hive-site.xml
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
        metadata_db: {{ postgres[0] }}
        zk_str: {{ zk_str }}
        nameservice_names:
          {{ nameservice_names | yaml }}
    - require:
      - archive: spark-pkg
      - file: spark-pkg-link

{{ spark_home }}/sbin/run-history-server.sh:
  file.managed:
    - source: salt://spark/files/run-history-server.sh
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - require:
      - archive: spark-pkg
      - file: spark-pkg-link

{{ spark_home }}/sbin/run-jdbc-server.sh:
  file.managed:
    - source: salt://spark/files/run-jdbc-server.sh
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - require:
      - archive: spark-pkg
      - file: spark-pkg-link

sparksql-jdbc-jar-link:
  file.symlink:
    - name: {{ spark_home }}/lib/postgresql-jdbc.jar
    - target: {{ pillar['java']['share_dir'] }}/{{ jdbc.postgresql_jdbc }}
    - force: True
    - require:
      - archive: spark-pkg
      - file: spark-pkg-link

