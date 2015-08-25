elasticsearch-mesos:
  worker_mem: 2048
  cpus: 0.2
  mem: 512
  ports: [2612]
  instances: 1
  worker_instances: 3
  java_opts: -Xms128m -Xmx256m
  container:
    docker:
      image: mesos/elasticsearch-scheduler:0.2.1
      network: HOST
  healthChecks:
    -  gracePeriodSeconds: 120
       intervalSeconds: 30
       path: /v1/cluster
       portIndex: 0
       protocol: HTTP
       timeoutSeconds: 5
