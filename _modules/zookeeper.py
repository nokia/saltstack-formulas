
def hosts():
	return __salt__['search.mine_by_host']('roles:zookeeper.server')

def ensemble_address():
  zk_port = __pillar__['zookeeper']['port']
  return '{0}:{1}'.format(':{0},'.format(zk_port).join(hosts()), zk_port)
