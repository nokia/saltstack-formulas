
def masters():
    return __salt__['search.mine_by_host']('roles:tachyon.master')


def is_primary_master():
	return __salt__['search.is_primary_host']('roles:tachyon.master')
