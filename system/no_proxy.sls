{% set hosts = salt['search.all_hosts']() -%}
{% set ips = salt['search.resolve_ips'](hosts) -%}

{% if grains['provider']['noproxy'] is defined %}
{% set provider_no_proxy = '{0},'.format(grains['provider']['noproxy']) %}
{% else %}
{% set provider_no_proxy = '' %}
{% endif %}

append_no_proxy_env:
  file.replace:
    - name: /etc/environment
    - pattern: ^no_proxy=.*$
    - repl: no_proxy="{{ provider_no_proxy }}{{ hosts|join(',') }},{{ ips|join(',') }}"

append_no_proxy_capital_env:
  file.replace:
    - name: /etc/environment
    - pattern: ^NO_PROXY=.*$
    - repl: NO_PROXY="{{ provider_no_proxy }}{{ hosts|join(',') }},{{ ips|join(',') }}"

append_no_proxy_minion:
  file.replace:
    - name: /etc/default/salt-minion
    - pattern: ^export no_proxy=.*$
    - repl: export no_proxy="{{ provider_no_proxy }}{{ hosts|join(',') }},{{ ips|join(',') }}"

append_no_proxy_capital_minion:
  file.replace:
    - name: /etc/default/salt-minion
    - pattern: ^export NO_PROXY=.*$
    - repl: export NO_PROXY="{{ provider_no_proxy }}{{ hosts|join(',') }},{{ ips|join(',') }}"

minion-service:
  service.running:
    - names:
        - salt-minion
    - enable: True
    - watch:
        - file: append_no_proxy_env
        - file: append_no_proxy_capital_env
        - file: append_no_proxy_minion
        - file: append_no_proxy_capital_minion
