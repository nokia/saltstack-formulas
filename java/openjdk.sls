{% set version = pillar['java']['version'] -%}
{% set arch = pillar['java']['arch'] -%}
{% set parent_home = pillar['java']['parent_home'] -%}
{% set path_tmp = "java-{0}-openjdk{1}" -%}
{% set path = path_tmp.format(version, arch) -%}
{% set home = "{0}/{1}".format(parent_home, path) -%}
{% set java_home = "{0}/jre".format(home) -%}
jdk-pkg:
  pkg.installed:
    - names:
      - openjdk-{{ version }}-jdk
      - default-jre-headless

java_alternatives_installation:
  cmd.wait:
    - name: {{ salt['java.alternatives_install_cmd'](home) }}
    - watch:
        - pkg: jdk-pkg

java_alternatives_setup:
  cmd.run:
    - name: {{ salt['java.alternatives_set_cmd'](home) }}
    - unless: |
        update-alternatives --query java | grep 'Value: {{ home }}/jre/bin/java'
    - require:
        - cmd: java_alternatives_installation

/etc/profile.d/jdk.sh:
  file.managed:
    - contents: export JAVA_HOME={{ home }}
    - makedirs: True
    - mode: 0755
    - require:
      - cmd: java_alternatives_setup
      - pkg: jdk-pkg

/etc/environment:
  file.append:
    - text: JAVA_HOME={{ home }}
    - require:
      - file: /etc/profile.d/jdk.sh
      - pkg: jdk-pkg
      - file: sed_etc_env

sed_etc_env:
  file.replace:
    - name: /etc/environment
    - pattern: '^JAVA_HOME.*$'
    - repl: JAVA_HOME={{ home }}
    - require:
      - pkg: jdk-pkg

jdk:
  pkg.installed:
    - name: default-jre-headless
    - require:
      - file: /etc/environment
      - file: /etc/profile.d/jdk.sh
