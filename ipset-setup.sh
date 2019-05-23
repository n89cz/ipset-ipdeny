#!/bin/bash
#
# countries ipblocks -> ipset -> iptables = drop traffic from specified country
#

# To disable mailing leave $MAIL empty
#MAIL=
MAIL="mailto@net.com"

CURL_OK="200"

IPSET="ipset"
IPTABLES="iptables"
#SETNAME="ipblocks"
COUNTRYCODE="ccodes.list"


function preflight_check()
{
#first check if ipdeny.com is accesible:
ISOK=$(curl --connect-timeout 10 --max-time 10 -s -o /dev/null -w "%{http_code}" http://www.ipdeny.com)

if [ "$ISOK" == "$CURL_OK" ] ; then
    echo "OK"
    #ipset_setup
elif [ "$ISOK" != "$CURL_OK" ] ; then
    #send mail with alert and exit
    echo "curl error $CURL_OUTPUT"
    exit 1
fi
}

function ipset_setup()
{
    while read CODE
    do
	ipset create $CODE-set hash:net
	for IP in $(curl -s http://www.ipdeny.com/ipblocks/data/countries/$CODE.zone)
	    do
		ipset add $CODE-set $IP
	    done
	iptables -I INPUT -m set --match-set $CODE-set src -j DROP
    done < $COUNTRYCODE
    exit 0
}

preflight_check
