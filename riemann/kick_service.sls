{% set event_type = data['post']['eventType'] %}

{% if event_type == 'deployment_success' or event_type == 'deployment_failed' %}

kick_riemann:
  local.state.sls:
    - tgt: '*'
    - arg:
      - riemann.agent_checks
    - kwarg:
        concurrent: True

{% endif %}
