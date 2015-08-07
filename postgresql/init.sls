{% from "postgresql/map.jinja" import postgres with context -%}
{% set postgresql = pillar['postgresql'] -%}
{% set data_dir = postgresql['config']['data_directory'] -%}
{% set home_dir = postgresql['dir'] -%}
postgresql:
  pkg.installed:
    - names:
      - {{ postgres.pkg }}

stop-postgres-after-install:
  cmd.wait:
    - name: service {{ postgres.service }} stop
    - user: root
    - group: root
    - unless: ls {{ data_dir }}/PG_VERSION
    - watch:
        - pkg: postgresql

{{ home_dir }}/postgresql.conf:
  file.managed:
    - source: salt://postgresql/files/postgresql.conf
    - user: postgres
    - group: postgres
    - mode: 600
    - template: jinja
    - require:
      - pkg: postgresql
      - cmd: stop-postgres-after-install

{{ home_dir }}/pg_hba.conf:
  file.managed:
    - source: salt://postgresql/files/pg_hba.conf
    - user: postgres
    - group: postgres
    - mode: 600
    - template: jinja
    - require:
      - pkg: postgresql
      - cmd: stop-postgres-after-install

postgresql-data-directory:
  file.directory:
    - names:
        - {{ data_dir }}
    - user: postgres
    - group: postgres
    - mode: 700
    - makedirs: True

init-postgresql-data-directory:
  cmd.run:
    - name: {{ postgresql['bin'] }}/initdb {{ data_dir }}
    - user: postgres
    - group: postgres
    - unless: ls {{ data_dir }}/PG_VERSION
    - require:
      - file: postgresql-data-directory
      - cmd: stop-postgres-after-install

postgresql-service:
  service.running:
    - enable: true
    - name: {{ postgres.service }}
    - watch:
      - file: {{ home_dir }}/postgresql.conf
      - file: {{ home_dir }}/pg_hba.conf
    - require:
      - pkg: {{ postgres.pkg }}
      - file: postgresql-data-directory
      - cmd: stop-postgres-after-install

assign-postgres-password:
  cmd.run:
    - name: echo "ALTER ROLE postgres ENCRYPTED PASSWORD '{{ postgresql['password'] }}'" | psql
    - user: postgres
    - group: postgres
    - unless: echo '\\connect' | PGPASSWORD={{ postgresql['password'] }} psql --username=postgres --no-password -h localhost
    - require:
        - service: postgresql-service

{% set users = pillar['postgresql.users'] -%}
{% for user in users %}

{{ user['name'] }}:
  postgres_user.present:
    - createdb: {{ user['createdb'] }}
    - createroles: {{ user['createroles'] }}
    - superuser: {{ user['superuser'] }}
    - password: {{ user['password'] }}
    - require:
        - service: postgresql-service

{% endfor %}

{% set databases = pillar['postgresql.databases'] -%}
{% for db in databases %}

{{ db['name'] }}:
  postgres_database.present:
    - encoding: {{ db['encoding'] }}
    - owner: {{ db['owner'] }}
    - template: {{ db['template'] }}
    - require:
        - service: postgresql-service

{% endfor %}

{% set scripts = pillar['postgresql.scripts'] -%}
{% for script in scripts %}

{{ home_dir }}/{{ script['name'] }}:
  file.managed:
    - source: {{ script['source'] }}
    - user: postgres
    - group: postgres
    - mode: 755
    - template: jinja
    - require:
        - service: postgresql-service

execute-script-{{ script['name'] }}:
  cmd.wait:
    - name: psql -U {{ script['user'] }} -d {{ script['database'] }} -f {{ home_dir }}/{{ script['name'] }}
    - user: postgres
    - group: postgres
    - watch:
        - file: {{ home_dir }}/{{ script['name'] }}
    - require:
        - service: postgresql-service

{% endfor %}

