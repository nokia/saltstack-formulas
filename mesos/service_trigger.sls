{% set triggers = pillar['mesos-services'] -%}

{% if triggers|length > 0 and salt['search.is_primary_host']('roles:mesos.service_trigger') -%}

include:
{% for trigger in triggers  -%}
  - {{ trigger }}
{% endfor %}

{% else -%}

empty_state_at_mesos_trigger:
  cmd.run:
    - name: echo 'empty state'
    - unless: True

{% endif -%}
