{% set cloudera_root = pillar['cloudera'] -%}
{% set repo_version = cloudera_root['version'] -%}
{% set cloudera = pillar['cloudera_{0}'.format(repo_version)] -%}

gplextras-repository:
  pkgrepo.managed:
    - humanname: GPL extras PPA
    - names: 
      - {{ cloudera['gplextras_repository']}}
      - {{ cloudera['gplextras_repository_src']}}
    - file: /etc/apt/sources.list.d/gplextras.list

cloudera-repository:
  pkgrepo.managed:
    - humanname: Cloudera PPA
    - names: 
      - {{ cloudera['repository']}}
      - {{ cloudera['repository_src']}}
    - file: /etc/apt/sources.list.d/cloudera.list
    - key_url: {{ cloudera['repository_key_url']}}
    - require: 
        - pkgrepo: gplextras-repository 
