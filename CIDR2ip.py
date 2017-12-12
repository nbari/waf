#!/usr/bin/env python
"""
Example of URLS to use:
    https://www.spamhaus.org/drop/drop.txt
    https://check.torproject.org/exit-addresses
    https://rules.emergingthreats.net/fwrules/emerging-Block-IPs.txt
    https://zeustracker.abuse.ch/blocklist.php?download=ipblocklist
    https://www.binarydefense.com/banlist.txt

Usage:
    CIDR2ip.py URL
"""

import argparse
import re
import redis
import requests

from netaddr import IPNetwork

""" regex to match a single IPv4 and CIDR """
IP_CIDR_RX = r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(?:/\d{1,2}|)'


def GetIPs(url, redis_host, redis_port, redis_db, ttl):
    ip_re = re.compile(IP_CIDR_RX)
    red = redis.StrictRedis(host=redis_host,
                            port=redis_port,
                            db=redis_db)
    r = requests.get(url, stream=True)
    for line in r.iter_lines():
        if line:
            ips = ip_re.findall(line)
            if ips:
                """ Currently only one ip per line """
                for ip in IPNetwork(ips[0]):
                    print ip
                    red.setex(ip, ttl, 1)


def main():
    parser = argparse.ArgumentParser(
        description="Parse IP's from a URL")

    parser.add_argument('url', metavar='url',
                        type=unicode,
                        help="URL containing list of IPv4 or CIDR")
    parser.add_argument('redis_host', metavar='host',
                        type=unicode, nargs='?', default='localhost',
                        help="redis host to store the IP's, default: localhost")
    parser.add_argument('redis_port', metavar='port',
                        type=int, nargs='?', default=6379,
                        help="redis port, default: 6379")
    parser.add_argument('redis_db', metavar='db',
                        type=int, nargs='?', default=0,
                        help="redis db, default: 0")
    parser.add_argument('ttl', metavar='ttl',
                        type=int, nargs='?', default=604800,
                        help='TTL used for storing keys in redis, default: 604800')

    args = parser.parse_args()

    if args.url:
        GetIPs(args.url,
               args.redis_host,
               args.redis_port,
               args.redis_db,
               args.ttl)
    elif len(args.url) is 0:
        parser.print_usage()
        exit(1)


if __name__ == "__main__":
    main()
