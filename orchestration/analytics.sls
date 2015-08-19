mine.update:
  salt.function:
    - tgt: '*'

saltutil.sync_modules:
  salt.function:
    - tgt: '*'

tachyon-master-format:
  salt.state:
    - tgt: 'roles:tachyon.master'
    - tgt_type: grain
    - concurrent: True
    - sls: tachyon.format
    - require:
      - salt: mine.update
      - salt: saltutil.sync_modules

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

spark-history:
  salt.state:
    - tgt: 'roles:spark.history'
    - tgt_type: grain
    - concurrent: True
    - sls:
      - spark.history
    - require:
      - salt: spark

spark-jdbc:
  salt.state:
    - tgt: 'roles:spark.jdbc'
    - tgt_type: grain
    - concurrent: True
    - sls:
      - spark.jdbc
    - require:
      - salt: spark-history

zeppelin:
  salt.state:
    - tgt: 'roles:zeppelin'
    - tgt_type: grain
    - concurrent: True
    - sls:
      - zeppelin.ui
    - require:
      - salt: spark-history
