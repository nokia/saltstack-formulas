{% from 'chronos/deploy.sls' import job_deploy with context -%}
{{ job_deploy({'name': 'test_job', 'command': 'echo Test'}) }}
