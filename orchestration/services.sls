mine.update:
  salt.function:
    - tgt: '*'

saltutil.sync_modules:
  salt.function:
    - tgt: '*'

cassandra:
  salt.state:
    - tgt: 'roles:cassandra'
    - tgt_type: grain
    - concurrent: True
    - sls:
      - cassandra
    - require:
      - salt: mine.update
      - salt: saltutil.sync_modules

kafka:
  salt.state:
    - tgt: 'roles:kafka'
    - tgt_type: grain
    - concurrent: True
    - sls:
      - kafka
    - require:
      - salt: mine.update
      - salt: saltutil.sync_modules

elasticsearch:
  salt.state:
    - tgt: 'roles:elasticsearch'
    - tgt_type: grain
    - concurrent: True
    - sls:
      - kafka
    - require:
      - salt: mine.update
      - salt: saltutil.sync_modules

ignite:
  salt.state:
    - tgt: 'roles:ignite'
    - tgt_type: grain
    - concurrent: True
    - sls:
      - ignite
    - require:
      - salt: mine.update
      - salt: saltutil.sync_modules
