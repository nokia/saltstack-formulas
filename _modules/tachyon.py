
def masters():
    return __salt__['search.mine_by_host']('roles:tachyon.master')

def is_primary_master():
    ms = masters()
    my_host = __salt__['search.my_host']()
    return my_host == ms[0]
