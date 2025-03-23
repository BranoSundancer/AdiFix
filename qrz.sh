#!/bin/bash
QRZ_URL_XML=https://xmldata.qrz.com/xml/current/
if [ -z $3 ] ; then
	echo "Usage: $0 CALLSIGN callsign|dxcc QUERY"
	exit
fi
CALLSIGN=$(echo "${1^^}" | sed -r "s/[^A-Z0-9]//")
QUERYCALLSIGN=$(echo "${3^^}" | sed -r "s/[^A-Z0-9]//")
if [ -e "$CALLSIGN" ] ; then
	. "$CALLSIGN"
	QRZ_KEY=$(curl -k -sS "$QRZ_URL_XML?username=$QRZ_USER&password=$QRZ_PASS" | sed -rn "s/^.*<key>([^<]*)<\/key>.*$/\1/ip")
	if [ -n "$QRZ_KEY" ] ; then
		curl -k -sS "$QRZ_URL_XML?s=$QRZ_KEY;$2=$QUERYCALLSIGN"
	fi
fi
