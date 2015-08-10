mine.update:
  salt.function:
    - tgt: '*'

saltutil.sync_modules:
  salt.function:
    - tgt: '*'

system-setup:
  salt.state:
    - tgt: '*'
    - concurrent: True
    - sls: system
    - require:
      - salt: mine.update
      - salt: saltutil.sync_modules

setup-master:
  salt.state:
    - tgt: 'roles:salt.master'
    - tgt_type: grain
    - concurrent: True
    - sls: salt.master
    - require:
      - salt: system-setup

metastore-db:
  salt.state:
    - tgt: 'roles:postgresql'
    - tgt_type: grain
    - concurrent: True
    - sls: postgresql
    - require:
      - salt: system-setup

zookeepers:
  salt.state:
    - tgt: 'roles:zookeeper.server'
    - tgt_type: grain
    - concurrent: True
    - sls:
      - zookeeper.server
    - require:
      - salt: system-setup

hdfs-journalnodes:
  salt.state:
    - tgt: 'roles:hdfs.journalnode'
    - tgt_type: grain
    - concurrent: True
    - sls: hdfs.journalnode
    - require:
      - salt: zookeepers

hdfs-namenode-format:
  salt.state:
    - tgt: 'roles:hdfs.namenode'
    - tgt_type: grain
    - concurrent: True
    - sls: hdfs.format
    - require:
      - salt: hdfs-journalnodes

hdfs-namenodes:
  salt.state:
    - tgt: 'roles:hdfs.namenode'
    - tgt_type: grain
    - concurrent: True
    - sls: hdfs.bootstrap
    - require:
      - salt: hdfs-namenode-format

hdfs-datanodes:
  salt.state:
    - tgt: 'roles:hdfs.datanode'
    - tgt_type: grain
    - concurrent: True
    - sls: hdfs.datanode
    - require:
      - salt: hdfs-namenodes

hdfs-post-install:
  salt.state:
    - tgt: 'roles:hdfs.namenode'
    - tgt_type: grain
    - concurrent: True
    - sls: hdfs.post-install
    - require:
      - salt: hdfs-datanodes

mesos-masters:
  salt.state:
    - tgt: 'roles:mesos.master'
    - tgt_type: grain
    - concurrent: True
    - sls: mesos.master
    - require:
      - salt: hdfs-post-install

mesos-slaves:
  salt.state:
    - tgt: 'roles:mesos.slave'
    - tgt_type: grain
    - concurrent: True
    - sls: mesos.slave
    - require:
      - salt: mesos-masters

tachyon-master-format:
  salt.state:
    - tgt: 'roles:tachyon.master'
    - tgt_type: grain
    - concurrent: True
    - sls: tachyon.format
    - require:
      - salt: hdfs-post-install

tachyon-masters:
  salt.state:
    - tgt: 'roles:tachyon.master'
    - tgt_type: grain
    - concurrent: True
    - sls: tachyon.master
    - require:
      - salt: tachyon-master-format

tachyon-slaves:
  salt.state:
    - tgt: 'roles:tachyon.slave'
    - tgt_type: grain
    - concurrent: True
    - sls: tachyon.slave
    - require:
      - salt: tachyon-masters

spark:
  salt.state:
    - tgt: 'roles:spark'
    - tgt_type: grain
    - concurrent: True
    - sls:
      - spark
    - require:
      - salt: tachyon-slaves
      - salt: mesos-slaves
      - salt: metastore-db

marathon-service:
  salt.state:
    - tgt: 'roles:marathon'
    - tgt_type: grain
    - concurrent: True
    - sls: marathon
    - require:
      - salt: mesos-slaves

spark-history:
  salt.state:
    - tgt: 'roles:spark.history'
    - tgt_type: grain
    - concurrent: True
    - sls:
      - spark.history
    - require:
      - salt: spark
      - salt: marathon-service

spark-jdbc:
  salt.state:
    - tgt: 'roles:spark.jdbc'
    - tgt_type: grain
    - concurrent: True
    - sls:
      - spark.jdbc
    - require:
      - salt: spark-history

haproxy-service:
  salt.state:
    - tgt: 'roles:haproxy'
    - tgt_type: grain
    - concurrent: True
    - sls: haproxy
    - require:
      - salt: marathon-service

riemann-server:
  salt.state:
    - tgt: 'roles:riemann.server'
    - tgt_type: grain
    - concurrent: True
    - sls: riemann.server
    - require:
      - salt: system-setup
      - salt: marathon-service

riemann-agents:
  salt.state:
    - tgt: '*'
    - concurrent: True
    - sls: riemann.agent
    - require:
      - salt: riemann-server

zeppelin:
  salt.state:
    - tgt: 'roles:zeppelin'
    - tgt_type: grain
    - concurrent: True
    - sls:
      - zeppelin.ui
    - require:
      - salt: spark-history

chronos:
  salt.state:
    - tgt: 'roles:chronos'
    - tgt_type: grain
    - concurrent: True
    - sls:
      - chronos
    - require:
      - salt: marathon-service
