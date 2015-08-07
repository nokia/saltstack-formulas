runner:
  group.present:
    - name: runner

salt:
  user.present:
    - fullname: Salt UI
    - shell: /bin/bash
    - home: /home/salt
    - password: {{ pillar['salt']['password'] }}
    - groups:
      - runner

halite:
  pip.installed:
    - name: halite

CherryPy:
  pip.installed:
    - name: CherryPy

salt_master_d_dir:
  file.directory:
    - name: /etc/salt/master.d
    - mode: 755
    - makedirs: True

reactor-config:
  file.managed:
    - name: /etc/salt/master.d/reactor.conf
    - source: salt://salt/files/reactor.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja

halite-service:
  service.running:
    - names:
        - salt-master
        - salt-api
    - enable: True
    - watch:
        - pip: halite
        - pip: CherryPy
        - file: reactor-config
