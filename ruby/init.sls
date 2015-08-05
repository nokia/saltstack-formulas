{% set ruby = pillar['ruby'] -%}
{% set url = ruby['url'] -%}
{% set checksum = ruby['checksum'] -%}
{% set source = ruby.get('source_root', '/usr/local/src') -%}
{% set tarball = ruby['tarball'] -%}
{% set dirname = ruby['dirname'] -%}

old_ruby_purged:
  pkg.purged:
    - names:
      - ruby1.8
      - ruby1.9.1
      - ruby1.9.3
      - rubygems
      - rake
      - ruby-dev
      - libreadline5
      - libruby1.8
      - ruby1.8-dev

get_ruby:
  pkg.installed:
      - names:
        - libcurl4-openssl-dev
        - libexpat1-dev
        - gettext
        - libz-dev
        - libssl-dev
        - build-essential
  file.managed:
    - name: {{ source }}/{{ tarball }}
    - source: {{ url }}/{{ tarball }}
    - source_hash: {{ checksum }}
  cmd.wait:
    - cwd: {{ source }}
    - name: tar -zxf {{ tarball }}
    - require:
      - pkg: get_ruby
    - watch:
      - file: get_ruby

ruby:
  cmd.wait:
    - cwd: {{ source }}/{{ dirname }}
    - name: ./configure && make && make install
    - watch:
      - cmd: get_ruby
    - require:
      - cmd: get_ruby
      - pkg: old_ruby_purged
