import __builtin__
import kafka
import unittest
import logging


class TestingKafkaFunctions(unittest.TestCase):
    def setUp(self):
        __builtin__.__pillar__ = {}
        __builtin__.__grains__ = {}
        __builtin__.__salt__ = {}
        logging.basicConfig()

    def test_format_option(self):
        self.assertEqual(kafka._format_option(['alfa', 'gama']), '--alfa gama')
