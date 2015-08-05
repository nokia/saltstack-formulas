{% if 'roles' in grains -%}
{% set grain_roles = grains['roles'] -%}
base:
  {% for role in grain_roles -%}
  'roles:{{ role }}':
    - match: grain
    - {{ role }}
  {% endfor %}
{% endif %}
