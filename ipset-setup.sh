#!/bin/bash
#
# countries ipblocks -> ipset -> iptables = drop traffic from specified coutry
#


IPSET="ipset"
IPTABLES="iptables"
SETNAME="ipblocks"
COUNTRYCODE="ccodes.list"

while read CODE
do
ipset create $CODE-set hash:net

for IP in $(curl -s http://www.ipdeny.com/ipblocks/data/countries/$CODE.zone)
do
    ipset add $CODE-set $IP
done

iptables -I INPUT -m set --match-set $CODE-set src -p tcp --dport 22 -j DROP

done < $COUNTRYCODE
