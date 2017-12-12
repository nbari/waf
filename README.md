# waf
nginx waf with lua + redis

Install python netaddr:

    pip install --user -r requirements.txt


Example:

    $ CIDR2ip.py https://www.spamhaus.org/drop/drop.txt


Adding CIDR to redis:

    HMSET cidr:8.8.0.0/18 broadcast 134758399 network 134742016

Creat the index using broadcast as the score:

    ZADD cidr:index 134758399 8.8.0.0/14

Find IP:

    127.0.0.1:6379> ZRANGEBYSCORE cidr:index 134744072 +inf limit 0 1
    1) "14.4.0.0/14"

Check that the IP is >= the network:

    127.0.0.1:6379> HGET cidr:14.4.0.0/14 network
    "235143168"

Help:

https://stackoverflow.com/a/9991303/1135424
https://mblum.me/2016/09/mapping-ip-addresses---sql-vs-redis/
