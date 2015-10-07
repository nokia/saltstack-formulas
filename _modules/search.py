import socket
import logging
import time

log = logging.getLogger(__name__)


# mine('x')
def mine(query, expr_target='grain', attribute=None):
    search_info = {}
    for t in range(0, 5):
        search_info = __salt__['mine.get'](query, 'grains.item', expr_target)
        if len(search_info) == 0:
            log.warn(
                'Mine[{4}] {0}, expr_target {1}, attribute {2}: {3}'.format(query, expr_target, attribute, search_info,
                                                                            t))
            time.sleep(1)
        else:
            break
    if attribute is None:
        return search_info.values()
    else:
        return sorted([attrs[attribute] for attrs in search_info.values()])


def mine_by_host(query, expr_target='grain'):
    return mine(query, expr_target, 'fqdn')


def all_hosts():
    return mine_by_host('*', 'glob')


def resolve_ips(addresses):
    return [socket.gethostbyname(x) for x in addresses]


def my_host():
    return __grains__['fqdn']


def is_primary_host(role):
    search_info = __salt__['search.mine'](role)
    ms = [(attrs['fqdn'], attrs.get('instance_creation_date', 0)) for attrs in search_info]
    ms_sorted = sorted(ms, key=lambda x: (x[1], x[0]))
    my_host = __salt__['search.my_host']()
    return len(ms_sorted > 0) and my_host == ms_sorted[0][0]
