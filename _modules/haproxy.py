import re

# import marathon_client
# marathon_addresses = ['http://hadoop-ha-1:8773', 'http://hadoop-ha-2:8773']
# apps = marathon_client._apps(marathon_addresses, None)
# haproxy_settings = {'elasticsearch': [{'service_port':2400}],
# 'cassandra': [{'service_port':2444, 'mode':'tcp', 'balancing_mode':'rr'}],
# 'roles':[{'query':'roles:xx', 'name':'tachyon', 'port':8031, 'service_port':2000}] }


def services():
    apps = __salt__['marathon_client.apps']()
    haproxy_settings = __pillar__['haproxy_apps']
    by_roles = haproxy_settings.get('roles', [])
    haproxy_settings = {i: haproxy_settings[i] for i in haproxy_settings if i != 'roles'}
    return _services_by_roles(by_roles) + _services_by_marathon(haproxy_settings, apps)


def _services_by_roles(by_roles):
    return [{'id': role_settings['name'], 'services': [_as_service(role_settings)]} for role_settings in by_roles]


def _services_by_marathon(haproxy_settings, apps):
    return [{'id': str(app_id), 'services': _as_services(app_id, tasks, _get_settings(app_id, haproxy_settings))} for
            app_id, tasks in apps.iteritems()]


def _get_settings(app_id, haproxy_settings):
    if app_id in haproxy_settings:
        return haproxy_settings[app_id]
    else:
        matches = [f for f in haproxy_settings if re.match(f, app_id)]
        if len(matches) > 0:
            return haproxy_settings[matches[0]]
        else:
            return []


# tasks = apps['cassandra']
# app_id = 'cassandra'
# settings = haproxy_settings.get(app_id, [])
def _as_services(app_id, tasks, settings):
    service_ports = [t.service_ports for t in tasks]
    service_ports = service_ports[0] if len(service_ports) > 0 else []
    services_settings = [_merge(service_port, setting) for service_port, setting in zip(service_ports, settings)]
    for idx, service in enumerate(services_settings):
        service['tasks'] = [{'host': str(t.host), 'port': t.ports[idx]} for t in tasks]
        if 'client_cert' in service:
            service['client_cert_name'] = "{0}-{1}.crt".format(app_id, idx)
    return services_settings


def _merge(service_port, settings):
    x = {'service_port': service_port}
    if settings is not None:
        x.update(settings)
    return x


# role_settings = {'name': 'tachyon', 'port': 8031, 'query': 'roles:xx', 'service_port': 2000}
# hosts = ['hadop-worker-1', 'hadoop-worker-2']
def _as_service(role_settings):
    query = role_settings['query']
    hosts = __salt__['search.mine_by_host'](query)
    if 'client_cert' in role_settings:
        role_settings['client_cert_name'] = "{0}.crt".format(role_settings['name'])
    service = {x: role_settings[x] for x in role_settings if not (x == 'name' or x == 'query' or x == 'port')}
    service['tasks'] = [{'host': str(h), 'port': role_settings['port']} for h in hosts]
    return service
