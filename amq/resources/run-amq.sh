#!/bin/bash

$AMQ_HOME/bin/artemis create --user ${ADMIN_USER:-admin} --password ${ADMIN_PASSWORD:-admin} --allow-anonymous /var/run/amq/$HOSTNAME

for f in bootstrap.xml broker.xml logging.properties ; do 
	envsubst < $AMQ_HOME/conf/$f > /var/run/amq/$HOSTNAME/etc/$f
done

exec /var/run/amq/$HOSTNAME/bin/artemis run

