import logging
import os
import re
import requests
import socket

log = logging.getLogger(__name__)


def master():
    return __salt__['search.mine_by_host']('roles:riemann.server')[0]


def kafka_jmx_checks(my_host):
    apps = __salt__['marathon_client.wait_for_healthy_tasks']('kafka-mesos')
    status_endpoint = ['http://{0}:{1}'.format(app.host, app.ports[0])
                       for app in apps.get('kafka-mesos', [])][0]

    jmx_queries = __pillar__['riemann_checks'].get('jmx', {}).get('kafka_server', [])
    if len(jmx_queries) == 0:
        return []
    r = requests.get(url=status_endpoint + '/api/brokers/status')
    if r.status_code != 200:
        return []
    kafka_meta = r.json()
    kafka_servers = map(lambda x: x['task']['hostname'], kafka_meta['brokers'])
    jmx_port = __pillar__['kafka-mesos'].get('jmxPort', -1)
    if len(filter(lambda x: x == my_host, kafka_servers)) == 0 or jmx_port == -1:
        return []
    return [{'name': 'kafka-{0}'.format(jmx_port), 'app_id': 'kafka_server', 'port': jmx_port, 'queries': jmx_queries}]


def cassandra_jmx_checks(my_host):
    apps = __salt__['marathon_client.wait_for_healthy_tasks']('cassandra-mesos')
    live_node_endpoint = ['http://{0}:{1}'.format(app.host, app.ports[0])
                          for app in apps.get('kafka-mesos', [])][0]
    r = requests.get(url=live_node_endpoint + '/live-nodes')
    if r.status_code != 200:
        return []
    jmx_queries = __pillar__['riemann_checks'].get('jmx', {}).get('cassandra_server', [])
    if len(jmx_queries) == 0:
        return []
    cassandra_meta = r.json()
    my_ip = socket.gethostbyname(my_host)
    jmx_port = cassandra_meta['jmxPort']
    cassandra_servers = cassandra_meta['liveNodes']
    if len(filter(lambda x: x == my_ip, cassandra_servers)) == 0:
        return []
    return [{'name': 'cassandra-{0}'.format(jmx_port), 'my_host': 'localhost', 'app_id': 'cassandra_server',
             'port': jmx_port, 'queries': jmx_queries}]


# jmx_map = {'cassandra': [{'obj':'x', 'attr':'x'}], 'kafka': [{'obj':'z'}, {'attr':'ww'}]}
# my_host = 'hadoop-worker-8'
def jmx_checks(my_host):
    apps = __salt__['marathon_client.apps']()
    jmx_map = __pillar__['riemann_checks'].get('jmx', {})
    return _join(jmx_map, apps, my_host)


# import marathon_client
# marathon_addresses = ['http://hadoop-ha-1:8773', 'http://hadoop-ha-2:8773']
# app_name = 'redis'
# apps = marathon_client._apps(marathon_addresses, None)
# app = marathon_client._apps(marathon_addresses, app_name)
# port_index = 0
# my_host = 'hadoop-worker-2'
# result = {}
def checks(app_name, my_host):
    app = __salt__['marathon_client.apps'](app_name)
    port_index = __pillar__.get(app_name, {}).get('check_port_index', 0)
    if app_name in app:
        tasks = [{'host': str(t.host), 'enabled': True, 'port': t.ports[port_index]} for t in app[app_name] if
                 t.host == my_host]
    else:
        tasks = []
    current_tasks = _list_current_services(app_name, my_host)
    result = {'{0}-{1}'.format(t['host'], t['port']): t for t in current_tasks}
    result.update({'{0}-{1}'.format(t['host'], t['port']): t for t in tasks})
    return [t for n, t in result.iteritems()]


def _join(check_defs, apps, my_host):
    result = []
    for name, queries in check_defs.iteritems():
        for app_id, tasks in apps.iteritems():
            if not re.match(name, app_id):
                continue
            port_index = __pillar__[app_id].get('check_port_index', 0)
            for t in tasks:
                if t.host != my_host:
                    continue
                port = t.ports[port_index]
                result.append(
                    {'name': '{0}-{1}'.format(app_id, port), 'app_id': str(app_id), 'port': port, 'queries': queries})
    return result


# jmx_checks = [{'name':'x'}, {'name':'y'}]
# jmx_checks = []
# as_file_names(jmx_checks)
def as_file_names(checks_names):
    if len(checks_names) == 0:
        return ''
    else:
        return '{0}.yml'.format('.yml '.join([check['name'] for check in checks_names]))


# _list_current_services()
# root_dir = "/Users/lukaszjastrzebski/Downloads/init"
# app_name = 'redis'
# my_host = 'hadoop-worker-2'
# current_tasks = [{'host':my_host, 'enabled':False, 'port': int(x.group(1))} for x in current_services]
def _list_current_services(app_name, my_host):
    root_dir = '/etc/init/'
    service_regexp = 'riemann-{0}-(\d+).conf'.format(app_name)
    try:
        files = os.listdir(root_dir)
        current_services = [re.search(service_regexp, f) for f in files if re.match(service_regexp, f)]
        return [{'host': str(my_host), 'enabled': False, 'port': int(x.group(1))} for x in current_services]
    except OSError:
        return []


# to_check = {'hdfs.namenode': [{'regexp':'NameNode', 'name':'n'}, {'regexp':'DFSZK', 'name':'z'}], 'mesos.master':
# [{'regexp':'mesos-master', 'name':'m'}]}
# roles = ['hdfs.namenode', 'mesos.master']
def proc_checks():
    to_check = __pillar__['riemann_checks']['proc']
    roles = __salt__['grains.get']('roles')
    my_proc = [settings for app_name, settings in to_check.items() if app_name in roles]
    regexps = [item for sublist in my_proc for item in sublist]
    return regexps
