{% set system = pillar['system'] -%}

system-root-dirs:
  file.directory:
    - names:
        - {{ system['var'] }}
        - {{ system['lib'] }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

system-tmp:
  file.directory:
    - names:
        - {{ system['tmp'] }}
    - user: root
    - group: root
    - mode: 777
    - makedirs: True
