{% set postgresql = pillar['postgresql'] -%}
{% set home_dir = postgresql['dir'] -%}

{% set scripts = pillar['metastore.scripts'] -%}
{% for script in scripts %}

{% set srcFiles = script['files'] -%}

{% for srcFile in srcFiles %}
{{ home_dir }}/{{ srcFile['name'] }}:
  file.managed:
    - source: {{ srcFile['source'] }}
    - user: postgres
    - group: postgres
    - mode: 755
    - template: jinja
{% endfor %}

execute-script-{{ script['executable'] }}:
  cmd.wait:
    - name: psql -U {{ script['user'] }} -d {{ script['database'] }} -f {{ script['executable'] }}
    - user: postgres
    - group: postgres
    - cwd: {{ home_dir }}
    - watch:
        - file: {{ home_dir }}/{{ script['executable'] }}

{% endfor %}
