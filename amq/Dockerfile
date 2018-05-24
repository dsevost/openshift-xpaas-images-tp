FROM redhat-openjdk-18/openjdk18-openshift

ARG REDHAT_COMPONENT_NAME
ARG REDHAT_REPO_URL

USER 0

RUN \
    yum install -y \
	gettext \
	hostname \
	libaio \
	procps \
	qpid-dispatch-router \
	qpid-dispatch-tools \
    && \
    yum clean all

RUN \
    set -x ; \
    curl  -o /tmp/$REDHAT_COMPONENT_NAME $REDHAT_REPO_URL/$REDHAT_COMPONENT_NAME && \
    unzip -d /opt /tmp/$REDHAT_COMPONENT_NAME && \
    rm -f /tmp/$REDHAT_COMPONENT_NAME && \
    mkdir -p /var/run/amq /etc/qpid-dispatch && \
    chgrp 0 /var/run/amq /etc/qpid-dispatch && \
    chmod g+w /var/run/amq /etc/qpid-dispatch

USER jboss
