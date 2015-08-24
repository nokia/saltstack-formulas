import logging
import requests
import random
import time

log = logging.getLogger(__name__)


def format_option(option, quotation):
    if isinstance(option[1], dict):
        option1 = ','.join(map(lambda x: '{0}={1}'.format(x[0], x[1]), option[1].iteritems()))
        return '--{0} {1}'.format(option[0], option1, quotation)
    else:
        return '--{0} {1}'.format(option[0], option[1], quotation)


def format_options(options, quotation):
    return ' '.join(map(lambda x: format_option(x, quotation), options.iteritems()))


def wait_for_healthy_scheduler(addresses):
    for t in range(0,10):
        current_host = addresses[random.randrange(0, len(addresses))]
        r = requests.get(url='http://' + current_host + '/api/brokers/status')
        if r.status_code == 200:
            return 'http://' + current_host
        time.sleep(3)
    return None


# hosts = ['as-master', 'as-ha-1', 'as-ha-2']
# port = 2416
def reconfigure(config, no_of_instances, hosts, port):
    log.warn('Config: ' + str(config))
    log.warn('Hosts: ' + str(hosts))
    log.warn('Port: ' + str(port))
    addresses = map(lambda x: '{0}:{1}'.format(x, port), hosts)
    scheduler_addr = wait_for_healthy_scheduler(addresses)
    if (scheduler_addr is None):
        raise ValueError('Scheduler is not healthy')
    scale_out = map(lambda x: process_broker_reconfiguration(config, scheduler_addr, x), range(0, no_of_instances))
    current_no_of_instances = len(get_broker_status(scheduler_addr))
    scale_down = map(lambda x: remove_broker(scheduler_addr, x), range(no_of_instances, current_no_of_instances))
    return scale_out + scale_down


def process_broker_reconfiguration(config, address, index):
    response = {}
    response['stop'] = stop_broker(index, address)
    response['update_or_add'] = update_or_add_broker(index, config, address)
    response['start'] = start_broker(index, address)
    return response


def remove_broker(address, index):
    response = {}
    response['stop'] = stop_broker(index, address)
    response['remove'] = requests.get(url=address + '/api/brokers/remove', params={'id': index}).json()
    return response


def stop_broker(index, address):
    r = requests.get(url=address + '/api/brokers/stop', params={'id': index})
    return r.json()


def start_broker(index, address):
    r = requests.get(url=address + '/api/brokers/start', params={'id': index})
    return r.json()


def update_or_add_broker(index, config, address):
    response = {}
    payload = {}
    payload.update(dict(map(format_nested_dicts, config.iteritems())))
    payload.update({'id': index})
    update_response = requests.get(url=address + '/api/brokers/update', params=payload)
    response['update'] = update_response.json()
    if update_response.status_code != 200:
        add_response = requests.get(url=address + '/api/brokers/add', params=payload)
        response['add'] = add_response.json()
    return response


def format_nested_dicts(option):
    if isinstance(option[1], dict):
        option1 = ','.join(map(lambda x: '{0}={1}'.format(x[0], x[1]), option[1].iteritems()))
        return (option[0], option1)
    else:
        return (option[0], option[1])

def get_broker_status(address):
    return requests.get(url=address + '/api/brokers/status').json()['brokers']