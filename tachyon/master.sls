include:
  - tachyon.common

{% set tachyon = pillar['tachyon'] -%}
{% set tachyon_home = salt['system.home_dir']('tachyon') -%}

tachyon-service:
  service.running:
    - name: tachyon-master
    - enable: True
    - require:
        - file: tachyon-ramdisk-directory
        - file: {{ tachyon_home }}/bin/tachyon-wrapper.sh
        - file: tachyon-log-directory
    - watch:
        - file: {{ tachyon_home }}/conf/log4j.properties
        - file: {{ tachyon_home }}/conf/tachyon-env.sh
        - file: {{ tachyon_home }}/libexec/tachyon-layout.sh
        - file: /etc/init/tachyon-master.conf
        - file: {{ tachyon_home }}/libexec/tachyon-config.sh
