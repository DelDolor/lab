#!/usr/bin/env python3

""" This script uses ARP protocol to scan given network and discover all clients from it.
    This script doesnt use arping because I wanted to write my own and learn more about python and scapy.
       scapy.arping("192.168.104.1/24")

    Some other points about scapy that can be handy when modifying this script:
        scapy.ls(scapy.ARP()) >> lists all attributes that we can set to ARP request
        arp_request.show() >> prints out content of arp request. similar can be used with ether.
        arp_request.summary()) >> ARP who has Net("192.168.104.150/24") says 192.168.104.150

        answered_list, unanswered_list = scapy.srp(broadcast_ARP_req, timeout=2)
        print(answered_list.summary())

    **********************************************************
    Example of usage: ./02_Network_scanner.py -t 192.168.104.2/24
    **********************************************************

"""


import argparse
import scapy.all as scapy
from Lokittaja import Lokittaja

log_util = Lokittaja()

def read_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-t", "--target", dest="ip_range", help="IP range (ip/subnet) that you want to scan")
    options = parser.parse_args()

    if not options.ip_range:
        #handle error
        parser.error("[-] Please specify IP range for scanner. Use --help for more info. ")
        log_util.kirjoita("error", "Args doesnt contain IP range")
    return options

def scan(ip):
    arp_request = scapy.ARP(pdst=ip)
    broadcast = scapy.Ether(dst="ff:ff:ff:ff:ff:ff")

    #BUILD packet
    broadcast_ARP_req = broadcast/arp_request
    #broadcast_ARP_req.show()

    #SEND packet
    # using srp instead of sr because it allows to use custom ether.
    # srp returns couple of value lists (answered & unanswered). We are interested only answers
    answered_list = scapy.srp(broadcast_ARP_req, timeout=2, verbose=False)[0]
    log_util.kirjoita("info","ARP packet sent to Broadcast MAC")

    #HANDLE responses and create list of dictionaries to return
    clients_list = []
    for element in answered_list:
        #element is still a list containing request and response.
        #we are interested of response object. Element[1].show() shows all the fields.
        log_util.kirjoita("info", "Response from " + element[1].psrc + " " + element[1].hwsrc)
        client_info = {"IP":element[1].psrc,"MAC":element[1].hwsrc}
        clients_list.append(client_info)

    return clients_list

def print_output(clients):
    print("IP\t\t\tMAC Address\n---------------------------------------------------")
    for client in clients:
        print(client["IP"] + "\t\t" + client["MAC"])


log_util.kirjoita("info","Reading user inputs")
options = read_args()

log_util.kirjoita("info","SCAN STARTS")
client_list = scan(options.ip_range)

log_util.kirjoita("info","Printing results")
print_output(client_list)

log_util.kirjoita("info","All done")
