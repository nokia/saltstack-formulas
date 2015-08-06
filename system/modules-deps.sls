jinja:
  pip.installed:
    - name: Jinja2

{% set system = pillar['system'] -%}
{% set client_version = system['client.version'] -%}

marathon_client:
  pip.installed:
    - name: marathon == {{ client_version }}

minion-service-watching-marathon-client:
  service.running:
    - names:
        - salt-minion
    - enable: True
    - watch:
        - pip: marathon_client
