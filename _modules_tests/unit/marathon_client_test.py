import __builtin__
import system
import marathon_client
import unittest
import logging
import mock
from marathon import models
from marathon import exceptions
import httpretty
from httmock import urlmatch, HTTMock


@urlmatch(netloc=r'.*')
def all_requests(url, request):
    return 'ok'


class TestingMarathonClientFunctions(unittest.TestCase):

    def setUp(self):
        __builtin__.__pillar__ = {}
        __builtin__.__grains__ = {}
        __builtin__.__salt__ = {'search.mine_by_host': lambda a: ['localhost'], 'system.wait_for': system.wait_for}
        logging.basicConfig()
        self.cli = mock.Mock()

    def test_fetch_tasks_empty(self):
        self.cli.list_tasks.return_value = []
        self.assertEqual(marathon_client._fetch_tasks(self.cli, 'chronos'), {})

    @unittest.expectedFailure
    def test_fetch_tasks_error(self):
        response = mock.Mock()
        response.json.return_value = {'message': 'Not found'}
        response.status_code = 404
        self.cli.list_tasks.side_effect = exceptions.MarathonHttpError(response)
        self.assertEqual(marathon_client._fetch_tasks(self.cli, 'chronos'), {})

    def test_fetch_tasks_some_tasks(self):
        self.cli.list_tasks.return_value = [
            models.MarathonTask(app_id='/chronos', host='host1', id='task1', staged_at='2014-12-10T11:44:55.001Z'),
            models.MarathonTask(app_id='/chronos', host='host2', id='task2', staged_at='2014-12-10T11:43:55.001Z')]
        self.assertEqual(marathon_client._fetch_tasks(self.cli, 'chronos'),
                         {'chronos': [models.MarathonTask(app_id='/chronos', host='host2', id='task2',
                                                          staged_at='2014-12-10T11:43:55.001Z'),
                                      models.MarathonTask(app_id='/chronos', host='host1', id='task1',
                                                          staged_at='2014-12-10T11:44:55.001Z')]})

    def test_fetch_tasks_all_tasks(self):
        self.cli.list_tasks.return_value = [
            models.MarathonTask(app_id='/chronos', host='host1', id='task1', staged_at='2014-12-10T11:44:55.001Z'),
            models.MarathonTask(app_id='/docker', host='host2', id='task2', staged_at='2014-12-10T11:23:55.001Z'),
            models.MarathonTask(app_id='/chronos', host='host2', id='task2', staged_at='2014-12-10T11:43:55.001Z')]
        results = marathon_client._fetch_tasks(self.cli, None)
        self.assertEqual(results,
                         {'chronos': [models.MarathonTask(app_id='/chronos', host='host2', id='task2',
                                                          staged_at='2014-12-10T11:43:55.001Z'),
                                      models.MarathonTask(app_id='/chronos', host='host1', id='task1',
                                                          staged_at='2014-12-10T11:44:55.001Z')],
                          'docker': [models.MarathonTask(app_id='/docker', host='host2', id='task2',
                                                         staged_at='2014-12-10T11:23:55.001Z')]})

    def test_addresses(self):
        self.assertEqual(marathon_client._addresses(), ['http://localhost:8080'])

    def test_addresses_empty(self):
        __builtin__.__salt__['search.mine_by_host'] = lambda a: []
        self.assertEqual(marathon_client._addresses(), [])

    def test_addresses_custom_port(self):
        __builtin__.__pillar__ = {'marathon': {'http.port': 7070}}
        self.assertEqual(marathon_client._addresses(), ['http://localhost:7070'])

    def test_healthy_task(self):
        self.cli.list_tasks.return_value = [models.MarathonTask(app_id='/chronos', host='host1', id='task1')]
        app = marathon_client._healthy_tasks(self.cli, 'chronos', 1)
        self.assertEquals(len(app['chronos']), 1)

    def test_unhealthy_task(self):
        self.cli.list_tasks.return_value = [models.MarathonTask(app_id='/chronos', id='task1')]
        app = marathon_client._healthy_tasks(self.cli, 'chronos', 1)
        self.assertEquals(app, None)

    def test_unhealthy_task2(self):
        self.cli.list_tasks.return_value = [models.MarathonTask(app_id='/chronos', host='host1', id='task1',
                                                           health_check_results=[
                                                               models.task.MarathonHealthCheckResult(alive=False)])]
        app = marathon_client._healthy_tasks(self.cli, 'chronos', 1)
        self.assertEquals(app, None)

    @httpretty.activate
    def test_healthy_api(self):
        httpretty.register_uri(httpretty.GET, "http://localhost:8080/v2/apps/kafka-mesos/tasks",
                               body='''{"tasks":
                               [{"appId": "/kafka-mesos",
                                "host": "localhost",
                                "id": "kafka1",
                                "ports": [19990],
                                "stagedAt": "2015-08-26T20:23:39.463Z"}]}''',
                               content_type="application/json")
        httpretty.register_uri(httpretty.GET, "http://localhost:19990/api/brokers/status", body='ok')
        self.assertEqual(marathon_client.wait_for_healthy_api('kafka-mesos', '/api/brokers/status'),
                         'http://localhost:19990')
