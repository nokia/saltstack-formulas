
def masters():
    """Gets tachyon masters

    :return:
    """
    return __salt__['search.mine_by_host']('roles:tachyon.master')


def is_primary_master():
    """Checks whether current host is the first one created as tachyon master

    :return:
    """
    return __salt__['search.is_primary_host']('roles:tachyon.master')
