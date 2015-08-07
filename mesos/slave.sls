include:
  - mesos.common

mesos-service:
  service:
    - running
    - name: mesos-slave
    - enable: True
    - require:
        - file: mesos-directories
        - cmd: reset-slave-state
    - watch:
        - file: /etc/mesos/zk
        - file: /etc/default/mesos
        - file: /etc/mesos-slave/work_dir
        - file: /etc/mesos-slave/port
        - file: /etc/mesos-slave/resources
