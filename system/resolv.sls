{% set dns_servers = salt['search.resolve_ips'](salt['search.mine_by_host']('roles:mesos.dns')) -%}
{% if dns_servers|length > 0 -%}
{% set dns_servers_entries = 'nameserver ' + '\nnameserver '.join(dns_servers) -%}
{% else -%}
{% set dns_servers_entries = '' -%}
{% endif -%}

manage_dns_servers:
  file.blockreplace:
    - name: {{ pillar['system']['resolv_conf'] }}
    - marker_start: "# START managed zone system -DO-NOT-EDIT-"
    - marker_end: "# END managed zone system --"
    - content: |
        {{ dns_servers_entries|indent(8) }}
    - append_if_not_found: True
    - backup: '.bak'
    - show_changes: True

manage_dns_servers_post_update_script:
  cmd.wait:
    - name: {{ pillar['system']['resolv_cmd_update'] }}
    - watch:
        - file: manage_dns_servers
