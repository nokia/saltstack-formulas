{% from 'chronos/deploy.sls' import job_deploy with context -%}
{{ job_deploy({'id': 'test_job', 'cmd': 'echo Test'}) }}
