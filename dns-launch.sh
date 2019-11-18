#!/bin/bash

conf() {
	setconf -a /etc/powerdns/pdns.conf "$1=$2"
}

rm /etc/powerdns/pdns.conf

conf daemon no
conf loglevel 3
conf local-port 53
conf module-dir /usr/lib/powerdns

conf chroot /var/empty
conf distributor-threads 3
conf setgid nobody
conf setuid nobody

if [ "${WEBSERVER:-no}" == "yes" ]
then
	conf webserver yes
	conf webserver-port 80
	conf webserver-address 0.0.0.0
else
	conf webserver no
fi

case "${DNSMODE:-native}" in
slave)
	conf slave yes
	;;
master)
	conf master yes
esac

DBIP=${DBHOST:-postgresql}
echo "$DBIP" | grep -E "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$"
if [ "$?" -ne 0 ]
then
	DBIP=`getent hosts "${DBIP}" | awk '{ print $1 }'`
	if [ ! -n "$DBIP" ]
	then
		echo "Unable to resolve DB hostname: ${DBHOST:-postgresql}" >&2
		exit 1
	fi
fi

conf dnsupdate "${DNSUPDATE:-no}"

conf launch gpgsql
conf gpgsql-host "${DBIP}"
conf gpgsql-user "${DBUSER:-pdns}"
conf gpgsql-password "${DBPASS:-pdns}"
conf gpgsql-dbname "${DBNAME:-pdns}"


/usr/bin/pdns_server --guardian=yes
