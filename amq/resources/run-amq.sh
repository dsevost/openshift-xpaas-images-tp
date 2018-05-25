#!/bin/bash

set -x

$AMQ_HOME/bin/artemis create \
    --addresses=localhost,$HOSTNAME \
    --user ${ADMIN_USER:-admin} \
    --password ${ADMIN_PASSWORD:-admin} \
    --allow-anonymous \
    --verbose \
    /var/run/amq/$HOSTNAME

LOGGING_LEVEL=${LOGGING_LEVEL:-INFO}

sed -ci.bak1 "s|\.level=INFO|.level=$LOGGING_LEVEL|g" /var/run/amq/$HOSTNAME/etc/logging.properties

sed -ci.bak1 \
    '/<cors>/a         <allow-origin>http://*.apps.openshift.tk/*</allow-origin> <allow-origin>http://amq*:*/*</allow-origin>' \
    /var/run/amq/$HOSTNAME/etc/jolokia-access.xml

sed -ci.bak1 \
    's|http://localhost:8161|http://0.0.0.0:8161|' \
    /var/run/amq/$HOSTNAME/etc/bootstrap.xml

sed -ci.bak1 \
    '/JAVA_ARGS \\/a $JAVA_OPTS_APPEND \\' \
    /var/run/amq/$HOSTNAME/bin/artemis

cp -f $AMQ_HOME/templates/management.xml /var/run/amq/$HOSTNAME/etc

exec /var/run/amq/$HOSTNAME/bin/artemis run
