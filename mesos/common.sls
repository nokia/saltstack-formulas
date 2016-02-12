{% set mesos = pillar['mesos'] -%}
{% set log_dir = salt['system.log_dir']('mesos') -%}
{% set zk_str = salt['zookeeper.ensemble_address']() -%}
{% set work_dir = salt['system.work_dir']('mesos') -%}

include:
  - java

mesos-dependencies:
  pkg.installed:
    - pkgs:
      - curl
      - python-protobuf
      - python-setuptools
    - skip_verify: True

mesos-pkg:
  pkg.installed:
    - skip_verify: True
    - sources:
      - mesos: {{ mesos['url'] }}
    - require:
      - pkg: jdk
      - pkg: mesos-dependencies

mesos_python_binding:
  pip.installed:
    - name: mesos.cli
    - require:
      - pkg: mesos-dependencies
      - pkg: mesos-pkg

mesos_python_config:
  file.managed:
    - name: /etc/.mesos.json
    - source: salt://mesos/files/mesos.json
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
        zk_str: {{ zk_str }}
        log_dir: {{ log_dir }}
    - require:
      - pip: mesos_python_binding

docker-repository:
  pkgrepo.managed:
    - humanname: Docker PPA
    - name: deb https://apt.dockerproject.org/repo ubuntu-{{ grains['oscodename'].lower() }} main
    - file: /etc/apt/sources.list.d/docker.list

docker-pkgs:
  pkg.installed:
  - name: docker-engine
  - version: {{ mesos['docker_version'] }}
  - skip_verify: True
  - require:
    - pkgrepo: docker-repository

/etc/mesos/zk:
  file.managed:
    - source: salt://mesos/files/zk
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        zk_str: {{ zk_str }}
    - require:
      - pkg: mesos-pkg

mesos-directories:
  file.directory:
    - names:
        - {{ log_dir }}
        - {{ work_dir }}
        - /etc/mesos-slave
        - /etc/mesos-master
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
    - require:
      - pkg: mesos-pkg

/etc/mesos-slave/work_dir:
  file.managed:
    - source: salt://mesos/files/value_file
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        value: {{ work_dir }}
    - require:
      - pkg: mesos-pkg
      - file: mesos-directories

/etc/default/mesos:
  file.managed:
    - source: salt://mesos/files/mesos
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        log_dir: {{ log_dir }}
    - require:
      - pkg: mesos-pkg

/etc/default/mesos-master:
  file.managed:
    - source: salt://mesos/files/mesos-master
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        master_port: {{ mesos['master.port'] }}
    - require:
      - pkg: mesos-pkg

/etc/mesos-master/cluster:
  file.managed:
    - source: salt://mesos/files/value_file
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        value: {{ grains['cluster_name'] }}
    - require:
      - pkg: mesos-pkg
      - file: mesos-directories

/etc/mesos-slave/port:
  file.managed:
    - source: salt://mesos/files/value_file
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        value: {{ mesos['slave.port'] }}
    - require:
      - pkg: mesos-pkg
      - file: mesos-directories

/etc/mesos-slave/resources:
  file.managed:
    - source: salt://mesos/files/value_file
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        value: {{ mesos['resources'] }}
    - require:
      - pkg: mesos-pkg
      - file: mesos-directories

reset-slave-state:
  cmd.wait:
    - name: rm -f {{ work_dir }}/meta/slaves/latest
    - user: root
    - group: root
    - watch:
      - file: /etc/mesos-slave/resources

/etc/mesos-slave/containerizers:
  file.managed:
    - source: salt://mesos/files/value_file
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        value: docker,mesos
    - require:
      - pkg: mesos-pkg
      - file: mesos-directories

/etc/mesos-slave/executor_registration_timeout:
  file.managed:
    - source: salt://mesos/files/value_file
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        value: 5mins
    - require:
      - pkg: mesos-pkg
      - file: mesos-directories

/etc/mesos-slave/isolation:
  file.managed:
    - source: salt://mesos/files/value_file
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        value: {{ mesos.get('isolation', 'posix/cpu,posix/mem') }}
    - require:
      - pkg: mesos-pkg
      - file: mesos-directories

{% if grains['ec2'] is defined -%}
/etc/mesos-slave/attributes:
  file.managed:
    - source: salt://mesos/files/value_file
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        value: availability_zone:{{ grains['ec2']['availability_zone'] }};region:{{ grains['ec2']['region'] }};{{ mesos.get('attributes', '') }}
    - require:
      - pkg: mesos-pkg
      - file: mesos-directories
{% elif mesos['attributes'] is defined  -%}
/etc/mesos-slave/attributes:
  file.managed:
    - source: salt://mesos/files/value_file
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        value: {{ mesos['attributes'] }}
    - require:
      - pkg: mesos-pkg
      - file: mesos-directories
{% else -%}
/etc/mesos-slave/attributes:
  file.absent: []
{% endif -%}

{{ log_dir }}/clean_logs.sh:
  file.managed:
    - source: salt://mesos/files/clean_logs.sh
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
        max_files: {{ mesos.get('max_logs_no', 1) }}
    - require:
      - pkg: mesos-pkg
      - file: mesos-directories

mesos_clean_logs:
  cron.present:
    - name: {{ log_dir }}/clean_logs.sh
    - user: root
    - minute: 0
    - hour: 0
    - require:
      - file: {{ log_dir }}/clean_logs.sh
