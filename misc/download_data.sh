#!/bin/sh

set -x

WD=`pwd`

curl -OL 'https://github.com/v2ray/domain-list-community/releases/latest/download/dlc.dat' && mv dlc.dat PacketTunnel/site.dat

cd /tmp && \
	curl -OL 'https://web.archive.org/web/20191227182412/https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz' && \
	tar xf GeoLite2-Country.tar.gz

cd $WD && \
	mv /tmp/GeoLite2-Country_20191224/GeoLite2-Country.mmdb PacketTunnel/geo.mmdb

# https://curl.se/docs/caextract.html
curl -L 'https://curl.se/ca/cacert.pem' > PacketTunnel/cacert.pem
