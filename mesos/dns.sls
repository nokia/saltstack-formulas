{% set mesos_dns_home = salt['system.home_dir']('mesos_dns') -%}
{% set mesos_dns = pillar['mesos-dns'] -%}
{% set zk_str = salt['zookeeper.ensemble_address']() -%}

{{ mesos_dns_home }}/mesos-dns:
  file.managed:
    - source: {{ mesos_dns['url'] }}/{{ mesos_dns['tarball'] }}
    - source_hash: {{ mesos_dns['checksum'] }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

/etc/init/mesos-dns.conf:
  file.managed:
    - source: salt://mesos/files/mesos-dns.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        config_file: {{ mesos_dns_home }}/config.json
        script_file: {{ mesos_dns_home }}/mesos-dns
        log_file: {{ mesos_dns_home }}/mesos-dns.log
    - require:
      - file: {{ mesos_dns_home }}/mesos-dns

{% set my_ip = salt['search.resolve_ips']([salt['search.my_host']()])[0] -%}
{% set config_map = {'zk': 'zk://{0}/mesos'.format(zk_str), 'listener': my_ip} -%}
{% set pillar_config = mesos_dns.get('configuration', {}) -%}
{% do config_map.update(pillar_config) -%}

{{ mesos_dns_home }}/config.json:
  file.managed:
    - source: salt://mesos/files/mesos-dns-config.json
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - context:
        params: {{config_map | yaml}}
    - require:
      - file: {{ mesos_dns_home }}/mesos-dns

mesos-dns:
  service.running:
    - enable: True
    - watch:
      - file: {{ mesos_dns_home }}/config.json
      - file: /etc/init/mesos-dns.conf
