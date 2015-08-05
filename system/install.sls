{% macro install_tarball(name, add_env) -%}
{% set system = pillar['system'] -%}
{% set settings = pillar[name] -%}
{% set home_dir = salt['system.home_dir'](name) -%}
{% set log_dir = salt['system.log_dir'](name) -%}
{% set work_dir = salt['system.work_dir'](name) -%}

{{ name }}-pkg:
  archive.extracted:
    - name: {{ system['lib'] }}
    - source: {{ settings['url'] }}/{{ settings['tarball'] }}
    - source_hash: {{ settings['checksum'] }}
    - archive_format: tar
    - tar_options: {{ settings.get('extract_options', 'x') }}
    - if_missing: {{ system['lib'] }}/{{ settings['dirname'] }}

{{ name }}-pkg-link:
  file.symlink:
    - name: {{ home_dir }}
    - target: {{ system['lib'] }}/{{ settings['dirname'] }}
    - user: {{ settings.get('user', 'root') }}
    - group: {{ settings.get('group', 'root') }}
    - force: True

{% if add_env -%}
/etc/profile.d/{{ name }}.sh:
  file.managed:
    - contents: export {{ name | upper }}_HOME={{ home_dir }}
    - makedirs: True
    - mode: 0755
    - require:
      - archive: {{ name }}-pkg
      - file: {{ name }}-pkg-link

append-{{ name }}-etc-env:
  file.append:
    - name: /etc/environment
    - text: {{ name | upper }}_HOME={{ home_dir }}
    - require:
      - file: /etc/profile.d/{{ name }}.sh
      - archive: {{ name }}-pkg
      - file: {{ name }}-pkg-link
      - file: sed-{{ name }}-etc-env

sed-{{ name }}-etc-env:
  file.sed:
    - name: /etc/environment
    - before: '^{{ name | upper }}_HOME.*$'
    - after: {{ name | upper }}_HOME={{ home_dir }}
    - require:
      - archive: {{ name }}-pkg
      - file: {{ name }}-pkg-link

{% endif -%}

{{ name }}-work-directory:
  file.directory:
    - name: {{ work_dir }}
    - user: {{ settings.get('user', 'root') }}
    - group: {{ settings.get('group', 'root') }}
    - mode: 755
    - makedirs: True
    - unless: ls {{ work_dir }}

{{ name }}-log-directory:
  file.directory:
    - name: {{ log_dir }}
    - user: {{ settings.get('user', 'root') }}
    - group: {{ settings.get('group', 'root') }}
    - mode: 755
    - makedirs: True
    - unless: ls {{ log_dir }}

{%- endmacro %}
