#!/bin/bash

# https://git.fkurz.net/dj1yfk/dxcc/raw/branch/master/dxcc uses updated /usr/local/share/dxcc/cty.dat

# https://github.com/k0swe/dxcc-json/raw/refs/heads/main/dxcc.json
DXCCJSON="/usr/local/share/dxcc/dxcc.json"

. xml.inc.sh
. $1
>&2 echo -n $(date -u +'%F %T %Z')
#ADI="$(</dev/stdin)"
ADI="$(cat)"
if echo "$ADI" | grep -qi "<eor>" ; then
	CALL=$(echo $ADI | sed -rn 's/^.*<call:[0-9]+>([^ ]+) .*$/\1/ip')
	DXCC=$(echo $ADI | sed -rn 's/^.*<dxcc:[0-9]+>([^ ]+) .*$/\1/ip')
	NAME=$(echo $ADI | sed -rn 's/^.*<name:[0-9]+>([^<]+) .*$/\1/ip')
	MAINPREFIX=
	COUNTRY=$(echo $ADI | sed -rn 's/^.*<country:[0-9]+>([^ ]+) .*$/\1/ip')
	if [ -z "$DXCC" ] ; then
		{ read MAINPREFIX ; read COUNTRY ; } < <(./dxcc $CALL | sed -rn 's/^(Main Prefix|Country Name): +(.*)$/\2/p')
		[ "$COUNTRY" == "Unknown" ] && COUNTRY=
		[ "$MAINPREFIX" == "?" ] && MAINPREFIX=
		if [ -n "$MAINPREFIX" ] ; then
			XML=$(./qrz.sh $QRZ_USER dxcc "$MAINPREFIX")
			[[ $XML =~ \< ]] && while read_dom ; do
				[ "$ENTITY" == "dxcc" ] && DXCC="${CONTENT//[!0-9]/}"
				[ "$ENTITY" == "name" ] && [ -z "$COUNTRY" ] && COUNTRY="$CONTENT"
			done <<< "$(echo "$XML")"
		fi
		if [ -z "$DXCC" ] ; then
			XML=$(./qrz.sh $QRZ_USER dxcc "$CALL")
			[[ $XML =~ \< ]] && while read_dom ; do
				[ "$ENTITY" == "dxcc" ] && DXCC="${CONTENT//[!0-9]/}"
				[ "$ENTITY" == "name" ] && [ -z "$COUNTRY" ] && COUNTRY="$CONTENT"
			done <<< "$(echo "$XML")"
		fi
	fi
	if [ -n "$DXCC" ] && [ -e "$DXCCJSON" ] ; then
		DXCCCOUNTRY=$(jq -r --argjson code $DXCC '.dxcc[] | select(.entityCode == $code) | .name' "$DXCCJSON")
		[ -n "$DXCCCOUNTRY" ] && COUNTRY="$DXCCCOUNTRY"
	fi
	if [ -z "$NAME" ] || [ -z "$COUNTRY" ] ; then
		XML=$(./qrz.sh $QRZ_USER callsign "$CALL")
		[[ $XML =~ \< ]] && while read_dom ; do
			[ "$ENTITY" == "fname" ] && FNAME="$CONTENT"
			[ "$ENTITY" == "name" ] && NAME="$CONTENT"
			[ "$ENTITY" == "country" ] && [ -z "$COUNTRY" ] && COUNTRY="$CONTENT"
		done <<< "$(echo "$XML")"
		NAME=$(echo "$FNAME" "$NAME" | sed -r 's/^ +| +$//g')
	fi
	COUNTRY="${COUNTRY^^}"
	# FIXME: If COUNTRY was set but not DXCC, result might be not consistent and we should replace COUNTRY
	if ! echo "$ADI" | grep -qi "<country:" && [ -n "$COUNTRY" ] ; then
		ADI=$(echo "$ADI" | sed -r "s/(<eor>)/<COUNTRY:${#COUNTRY}>$COUNTRY \1/i")
	fi
	if ! echo "$ADI" | grep -qi "<dxcc:" && [[ $DXCC =~ ^[0-9]+$ ]] ; then
		ADI=$(echo "$ADI" | sed -r "s/(<eor>)/<DXCC:${#DXCC}>$DXCC \1/i")
	fi
	if ! echo "$ADI" | grep -qi "<name:" && [ -n "$NAME" ] ; then
		ADI=$(echo "$ADI" | sed -r "s/(<eor>)/<NAME:${#NAME}>$NAME \1/i")
	fi
	>&2 echo " CALL:$CALL NAME:$NAME COUNTRY:$COUNTRY DXCC:$DXCC"
	echo -n "$ADI"
else
	>&2 echo
fi
