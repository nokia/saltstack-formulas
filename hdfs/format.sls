{% set hdfs = pillar['hdfs'] %}
include:
  - java
  - hdfs.configuration

{% if salt['hdfs.is_primary_namenode']() %}

{% set my_nameservice = salt['hdfs.my_nameservice']() -%}
{% set my_peers = salt['hdfs.my_nameservice_peers']() -%}

bootstrap_primary_namenode:
  cmd.script:
    - source: salt://hdfs/files/bootstrap_script.sh
    - user: hdfs
    - group: hdfs
    - args: {{ grains['cluster_name'] }} {{ my_nameservice }} {{ my_peers | join(' ') }}
    - unless: ls {{ hdfs['name_data_dir'] | first }}/current/VERSION
    - require:
      - file: hadoop-namedata-directories
    - require_in:
      - service: hadoop-service

{% include 'hdfs/namenodeservice.sls' %}

{% endif %}
