def get():
    return list(set(__pillar__['mesos-dns']['configuration'].get('resolvers', [])))
