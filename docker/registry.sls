include:
  - mesos.service_common

{% set app_name = 'dockerregistry'%}
{% set docker = pillar[app_name] -%}

{% set bucket = grains['s3_bucket_data'] if grains['s3_bucket_data'] is defined else 'base' %}
{% set region = grains['ec2']['region'] if grains['ec2'] is defined else 'us-east-1' %}
{% set command = 'docker run -p $PORT:5000 -e SETTINGS_FLAVOR=s3 -e REGISTRY_STORAGE=s3 -e REGISTRY_STORAGE_S3_BUCKET={2} -e REGISTRY_STORAGE_S3_ROOTDIRECTORY={1} -e REGISTRY_STORAGE_S3_REGION={0} --name $MESOS_TASK_ID registry:2'.format(region, docker['base_path'], bucket) %}

{% from 'marathon/deploy.sls' import service_deploy with context -%}
{{ service_deploy({'id': app_name, 'cmd': command}) }}

