import logging
import requests


log = logging.getLogger(__name__)


def format_option(option, quotation):
    if isinstance(option[1], dict):
        option1 = ','.join(map(lambda x: '{0}={1}'.format(x[0], x[1]), option[1].iteritems()))
        return '--{0} {1}'.format(option[0], option1, quotation)
    else:
        return '--{0} {1}'.format(option[0], option[1], quotation)


def format_options(options, quotation):
    return ' '.join(map(lambda x: format_option(x, quotation), options.iteritems()))


def wait_for_healthy_scheduler():
    return False


def reconfigure(config, hosts, port):
    log.warn('Config: ' + str(config))
    log.warn('Hosts: ' + str(hosts))
    log.warn('Port: ' + str(port))
    is_healty = wait_for_healthy_scheduler()
    if (not is_healty):
        raise ValueError('Scheduler is not healthy')
    return {}
