{% set zookeeper = pillar['zookeeper'] -%}
{% set work_dir = salt['system.work_dir']('zookeeper') -%}
{% set conf_dir = zookeeper['conf_dir'] -%}
{% set zookeepers = salt['zookeeper.hosts']() -%}
{% set tools_dir = salt['system.custom_dir']('zookeeper', 'tools') -%}
{% set log_dir = salt['system.log_dir']('zookeeper') -%}
include:
  - java
  - cloudera.repository
  - git

zookeeper:
  pkg.installed:
    - version: {{ zookeeper['version'] }}
    - require:
      - pkgrepo: cloudera-repository
      - pkg: jdk

zookeeper-conf:
  cmd.run:
    - name: cp -r /etc/zookeeper/{{ zookeeper['conf_dist_dir'] }} /etc/zookeeper/{{ conf_dir }}
    - unless: ls /etc/zookeeper/{{ conf_dir }}
    - require:
      - pkg: zookeeper

zookeeper-conf-install:
  alternatives.install:
    - name: zookeeper-conf
    - link: /etc/zookeeper/conf
    - path: /etc/zookeeper/{{ conf_dir }}
    - priority: 50
    - watch:
      - cmd: zookeeper-conf

zookeeper-conf-set:
  alternatives.set:
    - name: zookeeper-conf
    - path: /etc/zookeeper/{{ conf_dir }}
    - require:
      - alternatives: zookeeper-conf-install

{{ work_dir }}:
  file.directory:
    - user: zookeeper
    - group: zookeeper
    - mode: 755
    - makedirs: True
    - require:
      - alternatives: zookeeper-conf-set

{{ log_dir }}:
  file.directory:
    - user: zookeeper
    - group: zookeeper
    - mode: 755
    - makedirs: True
    - require:
      - alternatives: zookeeper-conf-set

/etc/init/zookeeper-server.conf:
  file.managed:
    - source: salt://zookeeper/files/zookeeper-server.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        log_dir: {{ log_dir }}
    - require:
      - alternatives: zookeeper-conf-set



/etc/zookeeper/{{ conf_dir }}/zoo.cfg:
  file.managed:
    - source: salt://zookeeper/files/zoo.cfg
    - user: zookeeper
    - group: zookeeper
    - mode: 644
    - template: jinja
    - context:
        work_dir: {{ work_dir }}
        zookeepers:
          {{ zookeepers | yaml }}
    - require:
      - alternatives: zookeeper-conf-set

{{ work_dir}}/myid:
  file.managed:
    - source: salt://zookeeper/files/myid
    - user: zookeeper
    - group: zookeeper
    - mode: 644
    - template: jinja
    - context:
        zookeepers:
          {{ zookeepers | yaml }}
    - require:
      - alternatives: zookeeper-conf-set

zookeeper-service:
  service:
    - running
    - name: zookeeper-server
    - enable: True
    - require:
      - alternatives: zookeeper-conf-set
      - file: /etc/init/zookeeper-server.conf
    - watch:
        - file: /etc/zookeeper/{{ conf_dir }}/zoo.cfg
        - file: {{ work_dir }}/myid

https://github.com/phunt/zktop.git:
  git.latest:
    - target: {{ tools_dir }}
    - rev: master
    - unless: ls {{ tools_dir }}/zktop
