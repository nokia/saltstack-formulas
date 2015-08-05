include:
  - riemann.agent

{% set riemann = pillar['riemann'] -%}
{% set riemann_home = salt['system.home_dir']('riemann') -%}
{% set riemann_server = salt['riemann.master']() -%}

riemann-dash:
  gem.installed:
    - version: {{ riemann['dash.version'] }}

{% from 'system/install.sls' import install_tarball with context -%}
{{ install_tarball('riemann', False) }}

change-owner-to-riemann:
  cmd.wait:
    - name: chown -R riemann:riemann {{ riemann_home }}/.
    - user: root
    - group: root
    - watch:
      - archive: riemann-pkg
      - file: riemann-pkg-link

riemann-extra-jar:
  file.managed:
    - name: {{ riemann_home }}/lib/riemann-extra.jar
    - source: {{ riemann['extra_url'] }}
    - source_hash: {{ riemann['extra_checksum'] }}
    - user: riemann
    - group: riemann
    - mode: 755
    - require:
      - archive: riemann-pkg
      - file: riemann-pkg-link

# create layout.json
/etc/riemann/layout.json:
  file.managed:
    - source: salt://riemann/files/layout.json
    - user: riemann
    - group: riemann
    - mode: 755
    - template: jinja
    - context:
        ws_port: {{ riemann['ws.port'] }}
        riemann_host: {{ riemann_server }}
    - require:
      - file: riemann-meta-directories

/etc/riemann/riemann-dash.rb:
  file.managed:
    - source: salt://riemann/files/riemann-dash.rb
    - user: riemann
    - group: riemann
    - mode: 755
    - template: jinja
    - context:
        port: {{ riemann['dash.port'] }}
    - require:
      - file: riemann-meta-directories

# create riemann.config

/etc/riemann/riemann.config:
  file.managed:
    - source: salt://riemann/files/riemann.config
    - user: riemann
    - group: riemann
    - mode: 755
    - template: jinja
    - context:
        log_dir: {{ salt['system.log_dir']('riemann') }}
        server_port: {{ riemann['server.port'] }}
        ws_port: {{ riemann['ws.port'] }}
        repl_port: {{ riemann['repl.port'] }}
    - require:
      - file: riemann-meta-directories

# register service riemann dash

/etc/init/riemann-dash.conf:
  file.managed:
    - source: salt://riemann/files/riemann-dash.conf
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
        home_dir: {{ riemann_home }}
    - require:
      - archive: riemann-pkg
      - file: riemann-pkg-link
      - gem: riemann-dash

riemann-dash-service:
  service.running:
    - name: riemann-dash
    - enable: True
    - watch:
      - file: /etc/init/riemann-dash.conf
      - file: /etc/riemann/layout.json
      - file: /etc/riemann/riemann-dash.rb

# register service riemann server

{{ riemann_home }}/bin/riemann:
  file.managed:
    - source: salt://riemann/files/riemann
    - user: riemann
    - group: riemann
    - mode: 755
    - template: jinja
    - require:
      - archive: riemann-pkg
      - file: riemann-pkg-link

/etc/init/riemann-server.conf:
  file.managed:
    - source: salt://riemann/files/riemann-server.conf
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
        home_dir: {{ riemann_home }}
    - require:
      - archive: riemann-pkg
      - file: riemann-pkg-link
      - file: riemann-extra-jar

riemann-server-service:
  service.running:
    - name: riemann-server
    - enable: True
    - watch:
      - file: /etc/init/riemann-server.conf
      - file: /etc/riemann/riemann.config
      - file: {{ riemann_home }}/bin/riemann
