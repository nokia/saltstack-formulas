
{% if grains['provider']['ephemeral']['should_mount'] %}
mount_ephemeral:
  mount.mounted:
    - name: /mnt
    - device: {{ grains['provider']['ephemeral']['device'] }}
    - fstype: {{ grains['provider']['ephemeral']['fstype'] }}
    - mkmnt: True
    - opts:
      - defaults

{% elif grains['provider']['ephemeral']['should_symlink'] %}

mount_ephemeral:
  file.symlink:
    - name: /mnt
    - target: {{ grains['provider']['ephemeral']['mount_path'] }}
    - user: root
    - group: root
    - force: True

{% else %}

mount_ephemeral:
  file.directory:
    - names:
        - /mnt
    - user: root
    - group: root
    - mode: 777
    - makedirs: True

{% endif %}


{% if grains['provider']['ephemeral']['should_mount'] or grains['provider']['ephemeral']['should_symlink']  %}

move_var_log_of_device:
  cmd.run:
    - name: mv /var/log /mnt/varlog && ln -s /mnt/varlog /var/log
    - user: root
    - group: root
    - unless: ls /mnt/varlog

move_usr_local_of_device:
  cmd.run:
    - name: mv /usr/local /mnt/usrlocal && ln -s /mnt/usrlocal /usr/local
    - user: root
    - group: root
    - unless: ls /mnt/usrlocal

move_var_cache_of_device:
  cmd.run:
    - name: mv /var/cache /mnt/varcache && ln -s /mnt/varcache /var/cache
    - user: root
    - group: root
    - unless: ls /mnt/varcache

{% endif %}
