FROM redhat-openjdk-18/openjdk18-openshift

USER 0

#	--disablerepo \* \
#        --enablerepo amq-clients-2-for-rhel-7-server-rpms \
#	--enablerepo amq-interconnect-1-for-rhel-7-server-rpms \
#	--enablerepo rhel-7-server-rpms \
#	qpid-dispatch-router \
#	qpid-dispatch-tools \

RUN \
    yum install -y \
	gettext \
	hostname \
	libaio \
	procps \
    && \
    yum clean all

ARG REDHAT_COMPONENT_NAME
ARG REDHAT_REPO_URL

RUN \
    set -x ; \
    curl -vo /tmp/$REDHAT_COMPONENT_NAME $REDHAT_REPO_URL/$REDHAT_COMPONENT_NAME && \
    unzip -d /opt /tmp/$REDHAT_COMPONENT_NAME && \
    rm -f /tmp/$REDHAT_COMPONENT_NAME && \
    mkdir -p /var/run/amq /etc/qpid-dispatch && \
    chgrp 0 /var/run/amq /etc/qpid-dispatch && \
    chmod g+w /var/run/amq /etc/qpid-dispatch && \
    ln -sf /opt/amq-broker-* /opt/amq-broker
#     && \
#    rm -f /opt/amq-broker/lib/slf4j-jboss-logmanager-1.0.3.GA-redhat-2.jar

USER jboss

ENV \
   AMQ_HOME=/opt/amq-broker

CMD /bin/bash -c "/bin/bash $AMQ_HOME/conf/run-amq.sh"

COPY resources/* $AMQ_HOME/conf/

