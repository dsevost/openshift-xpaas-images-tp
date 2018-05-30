#!/bin/bash

set -ex

ADM_USER=${ADMIN_PASSWORD:-admin}
ADM_PASSWORD=${ADMIN_USER:-admin}

echo $HOSTNAME | grep '^[a-z0-9-]\+-0$' && MASTER_or_SLAVE=master || MASTER_or_SLAVE=slave

INSTANCE_HOME=/var/run/amq/broker

[ -z "$AMQ_CLUSTERED" ] || \
    CLUSTERED="\
	--replicated \
	--failover-on-shutdown \
	--clustered \
	--host $HOSTNAME \
	--cluster-user $ADM_USER \
	--cluster-password $ADM_PASSWORD \
	--max-hops 1 \
	--${MASTER_or_SLAVE} \
    "

$AMQ_HOME/bin/artemis create \
    --addresses=localhost,$HOSTNAME \
    --allow-anonymous \
    --password ${ADM_USER} \
    --role admin \
    --user ${ADM_PASSWORD} \
    --verbose \
    $CLUSTERED \
    $INSTANCE_HOME

LOGGING_LEVEL=${LOGGING_LEVEL:-INFO}

sed -ci.bak1 "\
    s/^loggers=\(.*\)/loggers=\1,aio.prometheus.jmx/ ; \
    s/logger.handlers=.*/logger.handlers=CONSOLE/ ; \
    s/handler.FILE/#handler.FILE/ ; \
    s/\.level=INFO/.level=$LOGGING_LEVEL/g ; \
    " $INSTANCE_HOME/etc/logging.properties

if [ -z "${AMQ_CONSOLE_PUBLIC_URL}" ] ; then
    sed -ci.bak1 \
	"s|<cors>|<cors>\n		<allow-origin>*amq-*</allow-origin>\n| ;" \
	$INSTANCE_HOME/etc/jolokia-access.xml
else
    sed -ci.bak1 \
	"s|<cors>|<cors>\n		<allow-origin>${AMQ_CONSOLE_PUBLIC_URL}</allow-origin>\n| ;" \
	$INSTANCE_HOME/etc/jolokia-access.xml
fi

sed -ci.bak1 \
    's|http://localhost:8161|http://0.0.0.0:8161|' \
    $INSTANCE_HOME/etc/bootstrap.xml

sed -ci.bak1 \
    '/JAVA_ARGS \\/a $JAVA_OPTS_APPEND \\' \
    $INSTANCE_HOME/bin/artemis

sed -ci.bak1 "\
    s/<master\/>/<master>\n		<check-for-live-server>true<\/check-for-live-server>\n		<\/master>/ ; \
    s/<slave\/>/<slave>\n		<allow-failback>true<\/allow-failback>\n		<\/slave>/ ; \
    /<broadcast-groups>/,/<\/discovery-groups>/d ; \
    s/<\/connector>/<\/connector>\n<connector name=\"discovery-connector\">tcp:\/\/${HOSTNAME}:61616<\/connector>/ ; \
    s/<discovery-group-ref discovery-group-name=\"dg-group1\"\/>/<static-connectors>\n		<connector-ref>discovery-connector<\/connector-ref>\n		<\/static-connectors>/ ; \
    " $INSTANCE_HOME/etc/broker.xml

exec $INSTANCE_HOME/bin/artemis run
