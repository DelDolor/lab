#!/usr/bin/env python3

""" Utility that helps me to log things while coding and learning.

logging.debug('This is a debug message')
logging.info('This is an info message')
logging.warning('This is a warning message')
logging.error('This is an error message')
logging.critical('This is a critical message')
"""

import logging


# create logger
module_logger = logging.getLogger('')

class Lokittaja:
    def __init__(self):
        self.lokker = logging.getLogger('lokittaja')
        self.lokker.info('1. creating an instance of lokittaja')
        self.lokker.setLevel(logging.DEBUG)

    def kirjoita(self, level, msg):
        if level == "debug":
            self.lokker.debug(msg)
        elif level == "info":
            self.lokker.info(msg)
        elif level == "warning":
            self.lokker.warning(msg)
        elif level == "error":
            self.lokker.error(msg)
        elif level == "critical":
            self.lokker.critical(msg)
        else:
            self.lokker.error("[-] Cant read log level.")
