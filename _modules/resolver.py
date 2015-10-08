def get():
    return list(set(pillar['mesos-dns']['configuration'].get('resolvers', [])))
