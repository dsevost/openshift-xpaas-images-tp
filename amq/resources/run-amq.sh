#!/bin/bash

$AMQ_HOME/bin/artemis create \
    --addresses=localhost,$HOSTNAME \
    --aio \
    --user ${ADMIN_USER:-admin} \
    --password ${ADMIN_PASSWORD:-admin} \
    --allow-anonymous \
    --verbose \
    /var/run/amq/$HOSTNAME

LOGGING_LEVEL=${LOGGING_LEVEL:-INFO}

sed -ci.bak1 /var/run/amq/$HOSTNAME/etc/logging.properties "s|\.level=INFO|.level=$LOGGING_LEVEL|g"

#for f in bootstrap.xml broker.xml logging.properties ; do 
#	envsubst < $AMQ_HOME/conf/$f > /var/run/amq/$HOSTNAME/etc/$f
#done

#find /var/run/amq -name slf4j-log4j12-1.7.22.redhat-1.jar -exec rm -f {} \;

exec /var/run/amq/$HOSTNAME/bin/artemis run
