import logging
import requests
import random
import time

log = logging.getLogger(__name__)


def format_options(options):
    return ' '.join(map(_format_option, options.iteritems()))


# hosts = ['as-master', 'as-ha-1', 'as-ha-2']
# port = 2416
def reconfigure(config, no_of_instances):
    log.warn('Config: ' + str(config))
    scheduler_addr = _wait_for_healthy_scheduler()
    if scheduler_addr is None:
        raise ValueError('Scheduler is not healthy')
    initial_no_of_instances = len(_get_broker_status(scheduler_addr))
    scale_out = map(lambda x: _process_broker_reconfiguration(config, scheduler_addr, x), range(0, no_of_instances))
    current_no_of_instances = len(_get_broker_status(scheduler_addr))
    scale_down = map(lambda x: _remove_broker(scheduler_addr, x), range(no_of_instances, current_no_of_instances))
    rebalance_response = []
    if initial_no_of_instances != no_of_instances:
        rebalance_response += [_rebalance_brokers(scheduler_addr)]
    no_of_errors = len(filter(lambda x: x != 200, map(lambda x: x['start'].get('code', 200), scale_out)))
    if no_of_errors > 0:
        raise ValueError('Some of the brokers didnt succeed to start')
    response = scale_out + scale_down + rebalance_response
    log.warn('Output: ' + str(response))
    if len(response) == 0:
        return None
    else:
        return response


def _format_option(option):
    if isinstance(option[1], dict):
        option1 = ','.join(map(lambda x: '{0}={1}'.format(x[0], x[1]), option[1].iteritems()))
        return '--{0} {1}'.format(option[0], option1)
    else:
        return '--{0} {1}'.format(option[0], option[1])


def _process_broker_reconfiguration(config, address, index):
    response = dict()
    response['stop'] = _stop_broker(index, address)
    response['update_or_add'] = _update_or_add_broker(index, config, address)
    response['start'] = _start_broker(index, address)
    return response


def _wait_for_healthy_scheduler():
    for t in range(0, 100):
        apps = __salt__['marathon_client.wait_for_healthy_tasks']('kafka-mesos')
        addresses = ['http://{0}:{1}'.format(app.host, app.ports[0]) for app in apps.get('kafka-mesos', [])]
        if len(addresses) > 0:
            current_uri = addresses[random.randrange(0, len(addresses))]
            r = requests.get(url=current_uri + '/api/brokers/status')
            if r.status_code == 200:
                return current_uri
        time.sleep(3)
    return None


def _remove_broker(address, index):
    response = dict()
    response['stop'] = _stop_broker(index, address)
    response['remove'] = requests.get(url=address + '/api/brokers/remove', params={'id': index}).json()
    return response


def _rebalance_brokers(address):
    return requests.get(url=address + '/api/brokers/rebalance', params={'id': '*'}).json()


def _stop_broker(index, address):
    r = requests.get(url=address + '/api/brokers/stop', params={'id': index})
    return r.json()


def _start_broker(index, address):
    r = requests.get(url=address + '/api/brokers/start', params={'id': index})
    return r.json()


def _update_or_add_broker(index, config, address):
    response = {}
    payload = {}
    payload.update(dict(map(_format_nested_dicts, config.iteritems())))
    payload.update({'id': index})
    update_response = requests.get(url=address + '/api/brokers/update', params=payload)
    response['update'] = update_response.json()
    if update_response.status_code != 200:
        add_response = requests.get(url=address + '/api/brokers/add', params=payload)
        response['add'] = add_response.json()
    return response


def _format_nested_dicts(option):
    if isinstance(option[1], dict):
        option1 = ','.join(map(lambda x: '{0}={1}'.format(x[0], x[1]), option[1].iteritems()))
        return option[0], option1
    else:
        return option[0], option[1]


def _get_broker_status(address):
    return requests.get(url=address + '/api/brokers/status').json()['brokers']
