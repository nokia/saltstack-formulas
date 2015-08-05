
{% set my_nameservice = salt['hdfs.my_nameservice']() -%}

{% if salt['hdfs.is_primary_namenode']() -%}

{% for nameservice in salt['hdfs.nameservice_names']() %}

{% set remote_path = "hdfs://{0}/tmp".format(nameservice) -%}

hadoop-hdfs-directory_{{ nameservice }}:
  cmd.run:
    - name: hadoop fs -mkdir {{ remote_path }} && hadoop fs -chmod -R 1777 {{ remote_path }}
    - user: hdfs
    - group: hdfs
    - unless: hdfs dfsadmin -safemode wait && hdfs dfs -ls {{ remote_path }}
    - timeout: 30

{% endfor %}

{% else %}

hadoop-hdfs-dummy-command:
  {{ pillar['empty_state'] | yaml }}

{% endif -%}
