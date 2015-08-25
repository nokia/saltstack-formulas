include:
  - mesos.common

mesos-service:
  service:
    - running
    - name: mesos-master
    - enable: True
    - require:
        - file: mesos-directories
    - watch:
        - file: /etc/mesos/zk
        - file: /etc/default/mesos
        - file: /etc/default/mesos-master
        - file: /etc/mesos-master/cluster
