import logging
import json
from itertools import groupby
import random
import requests
from marathon import MarathonClient
from marathon import models
from marathon import exceptions
from itertools import chain

log = logging.getLogger(__name__)


def apps(app_id=None):
    """Returns marathon apps together with corresponding tasks

    :param str app_id: application id
    """
    marathon_addresses = _addresses()
    return _apps(marathon_addresses, app_id)


def merge(app_settings, default_settings):
    """Merge application dict with pillar dict

    :param dict app_settings: application settings
    :param dict default_settings: pillar settings
    """
    marathon_addresses = _addresses()
    settings = default_settings
    if settings is None:
        settings = {}
    marathon_env = {'MARATHON': ','.join(marathon_addresses)}
    if 'url' in settings and 'tarball' in settings:
        def_uris = {'uris': ["{0}/{1}".format(settings['url'], settings['tarball'])]}
        settings = dict(settings.items() + def_uris.items())
    settings.update(app_settings)
    if 'env' in settings:
        settings['env'].update(marathon_env)
    else:
        settings['env'] = marathon_env
    return settings


def new_deploy(app_name, app_file):
    """Calls marathon API to make new deployment of application given file as request body

    :param app_name:
    :param app_file:
    :return:
    """
    marathon_addresses = _addresses()
    with open(app_file, 'r') as content_file:
        content = content_file.read()
    app_attr = json.loads(content)
    cli = MarathonClient(marathon_addresses)
    if not _is_deployed(cli, app_name):
        m_app = models.MarathonApp.from_json(app_attr)
        created_app = cli.create_app(app_name, m_app)
        return created_app.to_json()
    else:
        return None


def re_deploy(app_name, app_file):
    """Calls marathon API to redeploy application with new file as request body

    :param app_name:
    :param app_file:
    :return:
    """
    with open(app_file, 'r') as content_file:
        content = content_file.read()
    app_attr = json.loads(content)
    marathon_addresses = _addresses()
    cli = MarathonClient(marathon_addresses)
    if _is_deployed(cli, app_name):
        return cli.update_app(app_name, models.MarathonApp.from_json(app_attr))
    else:
        return None


def restart(app_name):
    """Calls marathon restart API to rolling restart if file artifacts changed

    :param app_name:
    :return:
    """
    marathon_addresses = _addresses()
    cli = MarathonClient(marathon_addresses)
    if _is_deployed(cli, app_name):
        apps = __salt__['system.wait_for'](lambda x: _non_empty_deployments(cli), 3, 1)
        deploy_name = '/' + app_name
        if apps and deploy_name in apps:
            return None
        else:
            r = requests.post(url=marathon_addresses[0] + '/v2/apps/' + app_name + '/restart?force=true')
            return r.status_code
    else:
        return None


def _non_empty_deployments(cli):
    deployments = cli.list_deployments()
    apps = list(chain.from_iterable([d.affected_apps for d in deployments]))
    if len(apps) > 0:
        return apps
    else:
        return None


def undeploy(app_name):
    """Calls marathon API to undeploy application

    :param app_name:
    :return:
    """
    marathon_addresses = _addresses()
    cli = MarathonClient(marathon_addresses)
    if _is_deployed(cli, app_name):
        return cli.delete_app(app_name)
    else:
        return None


def wait_for_healthy_tasks(app_id, tasks_no=1):
    """Waits for at least tasks_no tasks to be healthy in application

    :param app_id: application id
    :param tasks_no: amount of tasks to wait for
    :return:
    """
    marathon_addresses = _addresses()
    cli = MarathonClient(marathon_addresses)
    sorted_apps = __salt__['system.wait_for'](lambda x: _fetch_tasks(cli, app_id), 10, 6)
    if sorted_apps is None:
        return {}
    else:
        healthy_app = __salt__['system.wait_for'](lambda x: _healthy_tasks(cli, app_id, tasks_no), 10, 6)
        return {} if healthy_app is None else healthy_app


def wait_for_healthy_api(app_id, path):
    """ Waits for health API, given path, and tasks retrieved from Marathon

    :param app_id: application id
    :param path: path to be appended to the host:port combination retrieved from marathon
    :return: API address in form of http://{host}:{port}
    """
    apps = wait_for_healthy_tasks(app_id)
    tasks = apps.get(app_id, [])
    if len(tasks) > 0:
        addresses = ['http://{0}:{1}'.format(app.host, app.ports[0]) for app in tasks]
        return __salt__['system.wait_for'](lambda x: _healthy_api(addresses, path), 10, 6)
    else:
        return None


def _healthy_api(addresses, path):
    current_uri = addresses[random.randrange(0, len(addresses))]
    r = requests.get(url=current_uri + path)
    if r.status_code == 200:
        return current_uri
    else:
        return None


def _healthy_tasks(cli, app_id, tasks_no=1):
    app = _fetch_tasks(cli, app_id)
    tasks = app.get(app_id, [])
    healthy_tasks = filter(lambda x: x, [reduce(lambda x, y: x and y, [not(t.host is None)] +
                                                map(lambda x: x.alive, t.health_check_results)) for t in tasks])
    if len(healthy_tasks) >= tasks_no:
        return app
    else:
        return None


def _apps(marathon_addresses, app_id):
    cli = MarathonClient(marathon_addresses)
    sorted_apps = __salt__['system.wait_for'](lambda x: _fetch_tasks(cli, app_id), 10, 6)
    return {} if sorted_apps is None else sorted_apps


def _fetch_tasks(cli, app_id):
    if app_id is None:
        tasks = cli.list_tasks()
    else:
        tasks = cli.list_tasks(app_id)
    sorted_tasks = sorted(tasks, key=lambda t: t.app_id)
    applications = {str(key): [v for v in values_iter] for key, values_iter in groupby(sorted_tasks, key=lambda s: s.app_id)}
    sorted_apps = {k[1:]: sorted(v, key=lambda app: app.staged_at) for k, v in applications.iteritems()}
    return sorted_apps


def _is_deployed(cli, app_id):
    try:
        cli.get_app(app_id)
        return True
    except exceptions.MarathonError:
        return False


# port = 8773
# hosts = ['hadoop-ha-1', 'hadoop-ha-2']
# marathon_addresses = ['http://{0}:{1}'.format(host, port) for host in hosts]
# app = cli
def _addresses():
    port = __pillar__.get('marathon', {}).get('http.port', 8080)
    hosts = __salt__['search.mine_by_host']('roles:marathon')
    return ['http://{0}:{1}'.format(host, port) for host in hosts]
