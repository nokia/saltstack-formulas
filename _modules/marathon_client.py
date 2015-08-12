import logging
import time
import json
from itertools import groupby
from marathon import MarathonClient
from marathon import models
from marathon import exceptions

log = logging.getLogger(__name__)


# make http request
# marathon_addresses = ['http://hadoop-ha-1:8773', 'http://hadoop-ha-2:8773']
def apps(app_id=None):
  marathon_addresses = _addresses()
  return _apps(marathon_addresses, app_id)

def _apps(marathon_addresses, app_id):
  cli = MarathonClient(marathon_addresses)
  for t in range(0,5):
    try:
      if app_id is None:
        tasks = cli.list_tasks()
      else:
        tasks = cli.list_tasks(app_id)
      sortkeyfn = key=lambda s:s.app_id
      apps = {str(key):[v for v in valuesiter] for key,valuesiter in groupby(tasks, key=sortkeyfn)}
      sorted_apps = {k[1:]:sorted(v, key=lambda app: app.staged_at) for k,v in apps.iteritems()}
      return sorted_apps
    except exceptions.MarathonError as e:
      log.warn('Error in talking to marathon: ' + str(e))
      time.sleep(6)
  return {}

def merge(app_settings, default_settings):
  marathon_addresses = _addresses()
  settings = default_settings
  if settings is None:
    settings = {}
  marathon_env = {'MARATHON': ','.join(marathon_addresses)}
  if 'url' in settings and 'tarball' in settings:
    def_uris = {'uris': ["{0}/{1}".format(settings['url'], settings['tarball'])] }
    settings = dict(settings.items() + def_uris.items())
  settings.update(app_settings)
  if 'env' in settings:
    settings['env'].update(marathon_env)
  else:
    settings['env'] = marathon_env
  return settings

def _is_deployed(cli, app_id):
  try:
    cli.get_app(app_id)
    return True
  except exceptions.NotFoundError as e:
    return False

# port = 8773
# hosts = ['hadoop-ha-1', 'hadoop-ha-2']
# marathon_addresses = ['http://{0}:{1}'.format(host, port) for host in hosts]
# app = cli
def _addresses():
  port = __pillar__['marathon']['http.port']
  hosts = __salt__['search.mine_by_host']('roles:marathon')
  return ['http://{0}:{1}'.format(host, port) for host in hosts]

# app_file = "/Users/lukaszjastrzebski/Downloads/EXTRACTED-FOR-SPLM_PROSPER-BSD_Telkomsel_Indonesia_OMS_Sumalpua1_OMS-log_collection.pl_18112014_0605/script_error.txt"
# app_name = "redis2"
def new_deploy(app_name, app_file):
  marathon_addresses = _addresses()
  with open(app_file, 'r') as content_file:
    content = content_file.read()
  app_attr = json.loads(content)
  cli = MarathonClient(marathon_addresses)
  if not _is_deployed(cli, app_name):
    mApp = models.MarathonApp.from_json(app_attr)
    app = cli.create_app(app_name, mApp)
    return {'output': str(app)}
  else:
    return {}

def re_deploy(app_name, app_file):
  with open(app_file, 'r') as content_file:
    content = content_file.read()
  app_attr = json.loads(content)
  marathon_addresses = _addresses()
  cli = MarathonClient(marathon_addresses)
  if _is_deployed(cli, app_name):
    app = cli.update_app(app_name, models.MarathonApp.from_json(app_attr))
    return {'output': str(app)}
  else:
    return {}


def undeploy(app_name):
  marathon_addresses = _addresses()
  cli = MarathonClient(marathon_addresses)
  if _is_deployed(cli, app_name):
    cli.delete_app(app_name)
