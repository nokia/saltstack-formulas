def get():
    with open('/etc/resolv.conf', 'r') as f:
        lines = f.readlines()
    ns = [x for x in lines if x.strip().startswith('nameserver')]
    return map(lambda x: x.split()[1], ns)
