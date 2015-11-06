import __builtin__
import system
import unittest
import logging


def exceptions(x):
    raise ValueError('HiThere')


def always_none(x):
    return None


def always_ok(x):
    return {}


class TestingSystemFunctions(unittest.TestCase):

    def setUp(self):
        __builtin__.__pillar__ = {}
        logging.basicConfig()

    def test_log_dir_no_system(self):
        self.assertEqual('/mnt/var/xyz/log', system.log_dir('xyz'))

    def test_log_dir(self):
        __builtin__.__pillar__ = {'system': {'var': '/var/log'}}
        self.assertEqual('/var/log/xyz/log', system.log_dir('xyz'))

    def test_work_dir_no_system(self):
        self.assertEqual('/mnt/var/xyz/work', system.work_dir('xyz'))

    def test_work_dir(self):
        __builtin__.__pillar__ = {'system': {'var': '/var/lib'}}
        self.assertEqual('/var/lib/xyz/work', system.work_dir('xyz'))

    def test_custom_dir_no_system(self):
        self.assertEqual('/mnt/var/xyz/a', system.custom_dir('xyz', 'a'))

    def test_custom_dir(self):
        __builtin__.__pillar__ = {'system': {'var': '/mnt/var1'}}
        self.assertEqual('/mnt/var1/xyz/b', system.custom_dir('xyz', 'b'))

    def test_lib_dir_no_system(self):
        self.assertEqual('/mnt/lib/xyz', system.home_dir('xyz'))

    def test_lib_dir(self):
        __builtin__.__pillar__ = {'system': {'lib': '/mnt/lib1'}}
        self.assertEqual('/mnt/lib1/xyz', system.home_dir('xyz'))

    def test_wait_all_exceptions(self):
        self.assertEqual(None, system.wait_for(exceptions, 1, 1))

    def test_wait_all_none(self):
        self.assertEqual(None, system.wait_for(always_none, 1, 1))

    def test_wait_all_ok(self):
        self.assertEqual({}, system.wait_for(always_ok, 1, 1))
