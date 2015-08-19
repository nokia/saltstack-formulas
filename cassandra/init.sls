{% set app_name = 'cassandra-mesos' -%}
{% set cassandra = pillar[app_name] -%}
{% set cassandra_env = cassandra['environment'] -%}
{% set cluster_name = cassandra_env['CASSANDRA_CLUSTER_NAME'] -%}
{% set zk_str = salt['zookeeper.ensemble_address']() -%}
{% set env = {'MESOS_ZK': 'zk://{0}/mesos'.format(zk_str),
              'CASSANDRA_ZK': 'zk://{0}/cassandra-mesos-{1}'.format(zk_str, cluster_name)} -%}
{% do env.update(cassandra_env) -%}

{% set cassandra_command = '$(pwd)/jre*/bin/java $JAVA_OPTS -classpath cassandra-mesos-framework.jar io.mesosphere.mesos.frameworks.cassandra.framework.Main' %}

{% from 'system/install.sls' import install_tarball with context -%}
{{ install_tarball('cassandra', False) }}

{% from 'marathon/deploy.sls' import service_deploy with context -%}
{{ service_deploy({'id': app_name, 'cmd': cassandra_command, 'env': env}) }}

