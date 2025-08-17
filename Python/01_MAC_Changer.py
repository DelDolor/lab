#!/usr/bin/env python3

""" This script allows you to change your MAC address on Linux Machine.
- Hide your Identity
- Impersonate other devices
- Bypass Filters
- Perform MAC Spoofing attack

Example of usage: ./01_MAC_Changer.py -i eth0 -m 00:11:00:11:00:11
"""

import subprocess
import optparse
import re

def logger(msg):
    print(msg)

def read_args():
    # object = module.Class()
    parser = optparse.OptionParser()
    parser.add_option("-i", "--interface", dest="interface", help="Interface which MAC-address you want to change")
    parser.add_option("-m", "--mac", dest="new_mac", help="New MAC-address to set in use")

    #options contains values from user, arguments contains titles of values (-i, -m)
    (options, arguments) = parser.parse_args()

    if not options.new_mac:
        #handle error
        parser.error("[-] Please specify a new MAC address. Use --help for more info. ")
    elif not options.interface:
        #handle error
        parser.error("[-] Please specify an interface. Use --help for more info. ")
    return options

def change_mac(iface, mac):
    # lets use argument list instead of string
    subprocess.call(["ifconfig", iface, "down"])
    subprocess.call(["ifconfig", iface, "hw", "ether", mac])
    subprocess.call(["ifconfig", iface, "up"])

def get_current_mac(iface):
    iface_config = subprocess.check_output(["ifconfig",iface])
    #build regex in pythex.org site
    mac_search_result = re.search(r"\w\w:\w\w:\w\w:\w\w:\w\w:\w\w",str(iface_config))

    if mac_search_result:
        return mac_search_result.group(0)
    else:
       logger("[-] Could not read MAC address. ")

#read user inputs.
options = read_args()

#check current mac
current_mac = get_current_mac(options.interface)
logger("[+] Current MAC address: " + str(current_mac))

# Call chance mac function with user given arguments
change_mac(options.interface, options.new_mac)

#re-check mac address
current_mac = get_current_mac(options.interface)

if current_mac == options.new_mac:
    logger("[+] MAC address succesfully changed to " + str(current_mac))
else:
    logger("[-] Failed to change MAC address for " + str(options.interface))
