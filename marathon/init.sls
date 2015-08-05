{% set marathon = pillar['marathon'] -%}
{% set marathon_home = salt['system.home_dir']('marathon') -%}
{% set salt_api_port = pillar['salt']['rest.port'] -%}
{% set zk_str = salt['zookeeper.ensemble_address']() -%}
include:
  - java.openjdk

{% from 'system/install.sls' import install_tarball with context -%}
{{ install_tarball('marathon', False) }}

/etc/init/marathon.conf:
  file.managed:
    - source: salt://marathon/files/marathon.conf
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
        marathon_home: {{ marathon_home }}
        zk_str: {{ zk_str}}
        marathon_port: {{ marathon['http.port'] }}
        callback_url: http://{{ grains['master'] }}:{{ salt_api_port }}/hook/marathon/events
    - require:
      - archive: marathon-pkg
      - file: marathon-pkg-link

marathon-service:
  service.running:
    - name: marathon
    - enable: True
    - watch:
      - file: /etc/init/marathon.conf
