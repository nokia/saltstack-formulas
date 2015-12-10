import ntpath
import sys
import time
import logging
import glob

log = logging.getLogger(__name__)


def log_dir(name):
    """Creates string that represents path to logs for library name

    :param name: library name
    :return:
    """
    return "{0}/{1}/log".format(__pillar__.get('system', {}).get('var', '/mnt/var'), name)


def work_dir(name):
    """Creates string that represents path to work directory for library name

    :param name: library name
    :return:
    """
    return "{0}/{1}/work".format(__pillar__.get('system', {}).get('var', '/mnt/var'), name)


def custom_dir(name, dirname):
    """Creates string that represents path to custom dir for library name

    :param name: library name
    :return:
    """
    return "{0}/{1}/{2}".format(__pillar__.get('system', {}).get('var', '/mnt/var'), name, dirname)


def home_dir(name):
    """Creates string that represents path to home dir for library name

    :param name: library name
    :return:
    """
    return "{0}/{1}".format(__pillar__.get('system', {}).get('lib', '/mnt/lib'), name)


def basename(uri):
    """Extracts basename from URI

    :param uri: URI to extract basename
    :return:
    """
    head, tail = ntpath.split(uri)
    return tail or ntpath.basename(head)


def wait_for(func, no_of_times=10, sleep_interval=5):
    """Waits until func returns sth else that None

    :param func: function to be run every couple of seconds
    :param no_of_times: how many times we should call function
    :param sleep_interval: how much time we will sleep between function invocation
    :return: func result
    """
    for t in range(0, no_of_times):
        try:
            result = func(t)
            if not (result is None):
                return result
            else:
                time.sleep(sleep_interval)
        except (KeyboardInterrupt, SystemExit):
            raise
        except:
            log.warn('Exception occured at step: ' + str(t) + ' ' + str(sys.exc_info()))
            time.sleep(sleep_interval)
    return None


def eval_path_patterns(path_patterns):
    """Evaluates list of path patterns to list all matching files

    :param path_patterns: path patterns to evaluate
    :return:
    """
    matching_files = [glob.glob(path_pattern) for path_pattern in path_patterns]
    return [item for sublist in matching_files for item in sublist]
