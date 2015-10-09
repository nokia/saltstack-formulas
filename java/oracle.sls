{% set version = pillar['java']['version'] -%}
{% set java_home = '/usr/lib/jvm/java-{0}-oracle'.format(version) -%}

oraclejdk_repo:
  pkgrepo.managed:
    - humanname: Oracle JDK PPA
    - name: ppa:webupd8team/java
    - file: /etc/apt/sources.list.d/oraclejdk.list

java_autoaccept:
  cmd.wait:
    - name: echo oracle-java{{ version }}-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
    - watch:
      - pkgrepo: oraclejdk_repo

jdk-pkg:
  pkg.installed:
    - names:
      - oracle-java{{ version }}-installer
      - oracle-java{{ version }}-set-default
    - require:
      - pkgrepo: oraclejdk_repo
      - cmd: java_autoaccept

java_alternatives_installation:
  cmd.wait:
    - name: update-java-alternatives -s java-{{ version }}-oracle
    - watch:
      - pkg: jdk-pkg

java_alternatives_setup:
  cmd.run:
    - name: update-java-alternatives -s java-{{ version }}-oracle
    - unless: |
        update-alternatives --query java | grep 'Value: {{ java_home }}/jre/bin/java'
    - require:
        - cmd: java_alternatives_installation

/etc/profile.d/jdk.sh:
  file.managed:
    - contents: export JAVA_HOME={{ java_home }}
    - makedirs: True
    - mode: 0755
    - require:
      - cmd: java_alternatives_setup
      - pkg: jdk-pkg

/etc/environment:
  file.append:
    - text: JAVA_HOME={{ java_home }}
    - require:
      - pkg: jdk-pkg
      - file: sed_etc_env

sed_etc_env:
  file.replace:
    - name: /etc/environment
    - pattern: '^JAVA_HOME.*$'
    - repl: JAVA_HOME={{ java_home }}
    - require:
      - pkg: jdk-pkg

jdk:
  pkg.installed:
    - name: oracle-java{{ version }}-set-default
    - require:
      - file: /etc/environment
      - file: /etc/profile.d/jdk.sh
