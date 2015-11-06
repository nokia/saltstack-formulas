import __builtin__
import system
import search
import unittest
import logging


class TestingSearchFunctions(unittest.TestCase):
    def setUp(self):
        __builtin__.__pillar__ = {}
        __builtin__.__grains__ = {}
        __builtin__.__salt__ = {'mine.get': lambda a, b, c: {}, 'system.wait_for': system.wait_for}
        logging.basicConfig()

    def test_mine_empty_mine(self):
        self.assertEqual(search.mine('roles:zookeeper'), [])

    def test_mine_zookeepers_mine(self):
        __builtin__.__salt__['mine.get'] = lambda query, func, expr_target: {'host1': {'a': 1, 'b': 2}}
        self.assertEqual(search.mine('roles:zookeeper'), [{'a': 1, 'b': 2}])

    def test_mine_zookeepers_mine(self):
        __builtin__.__salt__['mine.get'] = lambda query, func, expr_target: {'host1': {'a': 1, 'b': 2}}
        self.assertEqual(search.mine('roles:zookeeper', attribute='a'), [1])

    def test_mine_empty_mine_with_attribute(self):
        self.assertEqual(search.mine('roles:zookeeper', attribute='a'), [])

    def test_mine_by_host_empty_mine(self):
        self.assertEqual(search.mine_by_host('roles:zookeeper'), [])

    def test_mine_by_host_zookeepers_mine(self):
        __builtin__.__salt__['mine.get'] = lambda query, func, expr_target: {'host1': {'fqdn': 1, 'b': 2},
                                                                             'host2': {'fqdn': 2, 'b': 2}}
        self.assertEqual(search.mine_by_host('roles:zookeeper'), [1, 2])

    def test_mine_by_host_zookeepers_mine_no_fqdn(self):
        __builtin__.__salt__['mine.get'] = lambda query, func, expr_target: {'host1': {'a': 1, 'b': 2}}
        self.assertEqual(search.mine_by_host('roles:zookeeper'), [])

    def test_all_hosts_empty_mine(self):
        self.assertEqual(search.all_hosts(), [])

    def test_all_hosts_empty_mine_with_attribute(self):
        __builtin__.__salt__['mine.get'] = lambda a, b, c: {'host1': {'fqdn': 1, 'b': 2}, 'host2': {'fqdn': 2, 'b': 2}}
        self.assertEqual(search.all_hosts(), [1, 2])

    def test_resolve_ips_empty(self):
        self.assertEqual(search.resolve_ips([]), [])

    def test_resolve_ips(self):
        self.assertEqual(search.resolve_ips(['localhost']), ['127.0.0.1'])

    def test_my_host(self):
        __builtin__.__grains__ = {'fqdn': 'host1'}
        self.assertEqual(search.my_host(), 'host1')

    def test_is_primary_host_no_instance_creation_date(self):
        __builtin__.__grains__ = {'fqdn': 'host1'}
        __builtin__.__salt__['mine.get'] = lambda a, b, c: {'host2': {'fqdn': 'host2'}, 'host1': {'fqdn': 'host1'}}
        self.assertEqual(search.is_primary_host('roles:zookeeper'), True)

    def test_is_primary_host(self):
        __builtin__.__grains__ = {'fqdn': 'host2'}
        __builtin__.__salt__['mine.get'] = lambda a, b, c: {'host2': {'fqdn': 'host2', 'instance_creation_date': 1},
                                                            'host1': {'fqdn': 'host1', 'instance_creation_date': 2},
                                                            'host3': {'fqdn': 'host3', 'instance_creation_date': 1}}
        self.assertEqual(search.is_primary_host('roles:zookeeper'), True)
