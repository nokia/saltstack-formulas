import logging
import heapq

log = logging.getLogger(__name__)


def journal():
    return __salt__['search.mine_by_host']('roles:hdfs.journalnode')


def nameservices():
    namenodes = _namenodes()
    res = {}
    for host, data in namenodes.items():
        nameservice_name = 'default'
        if 'attributes' in data and 'nameservice' in data['attributes']:
            nameservice_name = data['attributes']['nameservice']
        if nameservice_name not in res:
            res[nameservice_name] = []
        heapq.heappush(res[nameservice_name], host)
    return sorted([{name: hosts} for name, hosts in res.items()])


def my_nameservice():
    my_host = __salt__['search.my_host']()
    return _my_nameservice(my_host)


def nameservice_names():
    name_def = nameservices()
    return sorted([name.keys()[0] for name in name_def])


def is_primary_namenode():
    my_host = __salt__['search.my_host']()
    peers = _all_hosts_for_nameservice(my_host)
    return my_host == peers[0]

def is_secondary_namenode():
    my_host = __salt__['search.my_host']()
    peers = _all_hosts_for_nameservice(my_host)
    return len(peers) > 1 and my_host == peers[1]

def my_nameservice_peers():
    my_host = __salt__['search.my_host']()
    all_peers_including_me = _all_hosts_for_nameservice(my_host)
    return [peer for peer in all_peers_including_me if peer != my_host]


def _namenodes():
    search_info = __salt__['search.mine']('roles:hdfs.namenode')
    return {attrs['fqdn']: attrs for attrs in search_info}


def _all_hosts_for_nameservice(my_host):
    name_def = nameservices()
    hosts = [nameservice.values()[0] for nameservice in name_def]
    my_bucket = [host for host in hosts if my_host in host]
    return [y for x in my_bucket for y in x]


def _my_nameservice(my_host):
    name_def = nameservices()
    ns = [name.keys()[0] for name in name_def if my_host in name.values()[0]]
    if len(ns) == 0:
        return ""
    else:
        return ns[0]
