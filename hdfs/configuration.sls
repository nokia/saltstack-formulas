{% set hdfs = pillar['hdfs'] -%}
{% set journal = salt['hdfs.journal']() -%}
{% set zk_str = salt['zookeeper.ensemble_address']() -%}
{% set nameservice_names = salt['hdfs.nameservice_names']() -%}
{% set nameservices = salt['hdfs.nameservices']() -%}

{% set conf_dir = hdfs['conf_dir'] -%}
{% set journal_dir = salt['system.custom_dir']('hdfs', 'journal') -%}
{% set log_dir = salt['system.log_dir']('hdfs') -%}

include:
  - hdfs.common

hadoop-security-limits:
  file.blockreplace:
    - name: /etc/security/limits.conf
    - marker_start: "# START managed zone hadoop -DO-NOT-EDIT-"
    - marker_end: "# END managed zone hadoop --"
    - content: |
        @hadoop    hard    nofile  32768
        @hadoop    soft    nofile  32768
        @hadoop    hard  nproc  32000
        @hadoop    soft  nproc  32000
    - append_if_not_found: True
    - backup: '.bak'
    - show_changes: True

/etc/hadoop/{{ conf_dir }}/core-site.xml:
  file.managed:
    - source: salt://hdfs/files/core-site.xml
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        zk_str: {{ zk_str }}
        nameservice_names:
          {{ nameservice_names | yaml }}
    - require:
      - alternatives: hadoop-conf-set
      - file: hadoop-security-limits

/etc/hadoop/{{ conf_dir }}/hadoop-env.sh:
  file.managed:
    - source: salt://hdfs/files/hadoop-env.sh
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
        log_dir: {{ log_dir }}
    - require:
      - alternatives: hadoop-conf-set

/etc/hadoop/{{ conf_dir }}/hdfs-site.xml:
  file.managed:
    - source: salt://hdfs/files/hdfs-site.xml
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        nameservice_names:
          {{ nameservice_names | yaml }}
        nameservices:
          {{ nameservices | yaml }}
        journal:
          {{ journal | yaml }}
        journal_dir: {{ journal_dir }}
        myhost: {{ salt['search.my_host']() }}
    - require:
      - alternatives: hadoop-conf-set

hadoop-meta-directories:
  file.directory:
    - names:
      - {{ log_dir }}
    - user: hdfs
    - group: hdfs
    - mode: 755
    - makedirs: True
    - require:
      - alternatives: hadoop-conf-set

hadoop-data-directories:
  file.directory:
    - names: {{ hdfs['data_dir'] | yaml }}
    - user: hdfs
    - group: hdfs
    - mode: 700
    - makedirs: True
    - require:
      - alternatives: hadoop-conf-set
      - file: hadoop-meta-directories

hadoop-namedata-directories:
  file.directory:
    - names: {{  hdfs['name_data_dir'] | yaml }}
    - user: hdfs
    - group: hdfs
    - mode: 700
    - makedirs: True
    - require:
      - alternatives: hadoop-conf-set
      - file: hadoop-meta-directories

hadoop-journal-directories:
  file.directory:
    - name: {{ journal_dir }}
    - user: hdfs
    - group: hdfs
    - mode: 700
    - makedirs: True
    - require:
      - alternatives: hadoop-conf-set
      - file: hadoop-meta-directories