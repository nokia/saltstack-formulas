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
