{% set event_type = data['post']['eventType'] %}

{% if event_type == 'deployment_success' or event_type == 'deployment_failed' %}

kick_haproxy:
  local.state.sls:
    - tgt: 'roles:haproxy'
    - expr_form: grain
    - arg:
      - haproxy.reload_cfg
    - kwarg:
        concurrent: True

{% endif %}
