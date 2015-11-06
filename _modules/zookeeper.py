
def hosts():
    """Gets zookeeper hosts

    :return:
    """
    return __salt__['search.mine_by_host']('roles:zookeeper.server')


def ensemble_address():
    """Zookeeper ensemble address

    :return:
    """
    zk_port = __pillar__['zookeeper']['port']
    return '{0}:{1}'.format(':{0},'.format(zk_port).join(hosts()), zk_port)


def ensemble_ips():
    """Zookeeper ensemble address using IPs

    :return:
    """
    zk_port = __pillar__['zookeeper']['port']
    hs = hosts()
    ips = __salt__['search.resolve_ips'](hs)
    return '{0}:{1}'.format(':{0},'.format(zk_port).join(ips), zk_port)
