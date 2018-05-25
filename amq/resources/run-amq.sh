#!/bin/bash

$AMQ_HOME/bin/artemis create --user ${ADMIN_USER:-admin} --password ${ADMIN_PASSWORD:-admin} --allow-anonymous /var/run/amq/$HOSTNAME

LOGGING_LEVEL=${LOGGING_LEVEL:-INFO}

for f in bootstrap.xml broker.xml logging.properties ; do 
	envsubst < $AMQ_HOME/conf/$f > /var/run/amq/$HOSTNAME/etc/$f
done

find /var/run/amq -name slf4j-log4j12-1.7.22.redhat-1.jar -exec rm -f {} \;

exec /var/run/amq/$HOSTNAME/bin/artemis run

