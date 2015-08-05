{% set apps = salt['haproxy.services']() %}

/etc/haproxy/haproxy.cfg:
  file.managed:
    - source: salt://haproxy/files/haproxy.cfg
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        apps:
          {{ apps | yaml }}

haproxy-service:
  service.running:
    - name: haproxy
    - enable: True
    - reload: True
    - watch:
      - file: /etc/haproxy/haproxy.cfg
