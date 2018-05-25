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

sed -ci.bak1 "s|\.level=INFO|.level=$LOGGING_LEVEL|g" /var/run/amq/$HOSTNAME/etc/logging.properties
sed -ci.bak1 '\
    /<restrict/a <remote><host>10.128.0.0/14</host></remote> ; \
    /<\/restrict/a <allow-origin>http://*.openshift.tk</allow-origin> <allow-origin>http://amq*:*/*</allow-origin> ; \
    ' /var/run/amq/$HOSTNAME/etc/jolokia-access.xml

exec /var/run/amq/$HOSTNAME/bin/artemis run
