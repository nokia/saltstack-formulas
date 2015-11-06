import __builtin__
import system
import unittest
import riemann
import logging
from marathon import models


class TestingRiemannFunctions(unittest.TestCase):

    def setUp(self):
        logging.basicConfig()
        __builtin__.__pillar__ = {}
        __builtin__.__grains__ = {}
        __builtin__.__salt__ = {'system.wait_for': system.wait_for, 'marathon_client.apps': lambda: {
            'chronos': [models.MarathonTask(app_id='chronos', host='host1', ports=[11]),
                        models.MarathonTask(app_id='chronos', host='host2', ports=[12])],
            'kafka-mesos': [models.MarathonTask(app_id='kafka-mesos', host='host1', ports=[12])]}}

    def test_jmx_checks_empty(self):
        __builtin__.__pillar__ = {'riemann_checks': {}}
        self.assertEqual(riemann.jmx_checks('host1'), [])

    def test_jmx_checks_with_kafka_only(self):
        __builtin__.__pillar__ = {'riemann_checks': {'jmx': {'kafka-mesos': [{'obj': 'x'}]}}}
        self.assertEqual(riemann.jmx_checks('host1'), [])

    def test_jmx_checks(self):
        __builtin__.__pillar__ = {'riemann_checks': {'jmx': {'kafka-mesos': [{'obj': 'x'}], 'chronos': [{'obj': 'x'}]}},
                                  'chronos': {'check_port_index': 0}}
        self.assertEqual(riemann.jmx_checks('host1'),
                         [{'app_id': 'chronos', 'name': 'chronos-11', 'port': 11, 'queries': [{'obj': 'x'}]}])
