#!/usr/bin/env python

import argparse

from netaddr import IPNetwork


def GetIPs(cidr):
    try:
        ip = IPNetwork(cidr)
    except Exception as e:
        print e
        exit(1)
    if ip.size > 1:
        print "min: %s  network:   %s" % (ip.first, ip.network)
        max = "max: %s  broadcast: %s " % (ip.last, ip.broadcast)
        print max
        print '-' * (len(max) - 1)
        print "Add CIDR to redis:"
        print "ZADD cidr:ipv4 %s %s\n" % (ip.last, ip.first)
        print "Remove CIDR:"
        print "ZREM cidr:ipv4 %s\n" % ip.first
    else:
        print "mask missing: %s/? <---" % ip.network


def main():
    parser = argparse.ArgumentParser(
        description="Convert CIDR to INT")

    parser.add_argument('cidr', metavar='cidr',
                        type=unicode,
                        help="IP in CIDR notation")

    args = parser.parse_args()

    if args.cidr:
        GetIPs(args.cidr)
    elif len(args.cidr) is 0:
        parser.print_usage()
        exit(1)


if __name__ == "__main__":
    main()
