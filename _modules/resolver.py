def get():
    with open('/etc/resolv.conf', 'r') as f:
        lines = f.readlines()
    ns = [x for x in lines if x.strip().startswith('nameserver')]
    ips = map(lambda x: x.split()[1], ns)
    local_dns_servers = __salt__['search.resolve_ips'](__salt__['search.mine_by_host']('roles:mesos.dns'))
    return [ip for ip in ips if ip not in local_dns_servers]
