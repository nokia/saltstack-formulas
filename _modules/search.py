import socket
import logging

log = logging.getLogger(__name__)


def mine(query, expr_target='grain', attribute=None):
    """Search in mine with additional short waits if mine is empty

    :param query: grains we are looking for, e.g. roles:zookeeper.server
    :param expr_target: grain, glob, compound, etc.
    :param attribute: which attribute to extract from grains
    :return:
    """
    search_info = __salt__['system.wait_for'](lambda x: __from_mine(query, expr_target, attribute), 3, 1)
    if search_info is None:
        search_info = {}
    if attribute is None:
        return search_info.values()
    else:
        return sorted([attrs[attribute] for attrs in search_info.values() if attribute in attrs])


def __from_mine(query, expr_target, attribute):
    search_info = __salt__['mine.get'](query, 'grains.item', expr_target)
    return search_info if len(search_info) > 0 else None


def mine_by_host(query, expr_target='grain'):
    """Gives list of fqdns matching query

    :param query: grains we are looking for, e.g. roles:zookeeper.server
    :param expr_target: grain, glob, compound, etc.
    :return: list of fqdns matching query
    """
    return mine(query, expr_target, 'fqdn')


def all_hosts():
    """Gives all hosts in cluster

    :return: all hosts in cluster
    """
    return mine_by_host('*', 'glob')


def resolve_ips(addresses):
    """ Resolve hosts by IP

    :param addresses: DNS names
    :return: IPs
    """
    return [socket.gethostbyname(x) for x in addresses]


def my_host():
    """ My FQDN

    :return: my FQDN
    """
    return __grains__['fqdn']


def is_primary_host(role):
    """Returns true if my host has role specified and has been created first or my name is alphabetically first

    :param role: grain we are looking for, e.g. roles:zookeeper.server
    :return: True or false depending of sorting order and role
    """
    search_info = mine(role)
    ms = [(attrs['fqdn'], attrs.get('instance_creation_date', 0)) for attrs in search_info]
    ms_sorted = sorted(ms, key=lambda x: (x[1], x[0]))
    return len(ms_sorted) > 0 and my_host() == ms_sorted[0][0]
