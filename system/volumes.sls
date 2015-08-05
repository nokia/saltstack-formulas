
/mnt:
  mount.mounted:
    - device: {{ grains['provider']['ephemeral']['device'] }}
    - fstype: {{ grains['provider']['ephemeral']['fstype'] }}
    - mkmnt: True
    - opts:
      - defaults

move_var_log_of_device:
  cmd.run:
    - name: mv /var/log /mnt/varlog && ln -s /mnt/varlog /var/log
    - user: root
    - group: root
    - unless: ls /mnt/varlog
    - require:
      - mount: /mnt

move_usr_local_of_device:
  cmd.run:
    - name: mv /usr/local /mnt/usrlocal && ln -s /mnt/usrlocal /usr/local
    - user: root
    - group: root
    - unless: ls /mnt/usrlocal
    - require:
      - mount: /mnt

move_var_cache_of_device:
  cmd.run:
    - name: mv /var/cache /mnt/varcache && ln -s /mnt/varcache /var/cache
    - user: root
    - group: root
    - unless: ls /mnt/varcache
    - require:
      - mount: /mnt
