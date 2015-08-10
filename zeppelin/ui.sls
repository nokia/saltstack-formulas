{% set zeppelin_home = salt['system.home_dir']('zeppelin') -%}

include:
  - zeppelin

/etc/init/zeppelin-server.conf:
  file.managed:
    - source: salt://zeppelin/files/zeppelin-server.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        zeppelin_home: {{ zeppelin_home }}
    - require:
      - archive: zeppelin-pkg


zeppelin-service:
  service.running:
    - name: zeppelin-server
    - enable: True
    - watch:
        - file: {{ zeppelin_home }}/conf/zeppelin-site.xml
        - file: {{ zeppelin_home }}/conf/zeppelin-env.sh
        - file: /etc/init/zeppelin-server.conf
