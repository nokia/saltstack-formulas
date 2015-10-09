{% set tachyon = pillar['tachyon'] -%}
{% set journal = salt['hdfs.journal']() -%}
{% set zk_str = salt['zookeeper.ensemble_address']() -%}
{% set nameservice_names = salt['hdfs.nameservice_names']() -%}
{% set tachyon_masters = salt['tachyon.masters']() -%}
{% set tachyon_home = salt['system.home_dir']('tachyon') -%}
{% set tachyon_log = salt['system.log_dir']('tachyon') -%}
{% set ramdisk = salt['system.custom_dir']('tachyon', 'ramdisk') -%}

include:
  - java

{% from 'system/install.sls' import install_tarball with context %}
{{ install_tarball('tachyon', False) }}

{% from 'java/openjdk.sls' import java_home with context -%}

tachyon-ramdisk-directory:
  file.directory:
    - name: {{ ramdisk }}
    - user: root
    - group: root
    - mode: 777
    - makedirs: True
    - unless: ls {{ ramdisk }}

{{ tachyon_home }}/conf/tachyon-env.sh:
  file.managed:
    - source: salt://tachyon/files/tachyon-env.sh
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
        tachyon_masters:
          {{ tachyon_masters | yaml }}
        nameservice_names:
          {{ nameservice_names | yaml }}
        zk_str: {{ zk_str }}
        java_home: {{ java_home }}
        tachyon_home: {{ tachyon_home }}
        ramdisk: {{ ramdisk }}
    - require:
      - archive: tachyon-pkg

{{ tachyon_home }}/libexec/tachyon-layout.sh:
  file.managed:
    - source: salt://tachyon/files/tachyon-layout.sh
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
        java_home: {{ java_home }}
        tachyon_home: {{ tachyon_home }}
        tachyon_log: {{ tachyon_log }}
    - require:
      - archive: tachyon-pkg

{{ tachyon_home }}/libexec/tachyon-config.sh:
  file.managed:
    - source: salt://tachyon/files/tachyon-config.sh
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
        java_home: {{ java_home }}
        tachyon_home: {{ tachyon_home }}
        tachyon_log: {{ tachyon_log }}
    - require:
      - archive: tachyon-pkg

{{ tachyon_home }}/bin/tachyon-wrapper.sh:
  file.managed:
    - source: salt://tachyon/files/tachyon-wrapper.sh
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - require:
      - archive: tachyon-pkg

{{ tachyon_home }}/conf/log4j.properties:
  file.managed:
    - source: salt://tachyon/files/log4j.properties
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - require:
      - archive: tachyon-pkg

/etc/init/tachyon-master.conf:
  file.managed:
    - source: salt://tachyon/files/tachyon-master.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        tachyon_home: {{ tachyon_home }}
    - require:
      - archive: tachyon-pkg

/etc/init/tachyon-slave.conf:
  file.managed:
    - source: salt://tachyon/files/tachyon-slave.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        tachyon_home: {{ tachyon_home }}
    - require:
      - archive: tachyon-pkg

