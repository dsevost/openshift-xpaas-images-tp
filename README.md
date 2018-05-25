
```
$ export REDHAT_REPO_URL=<>
$ export AMQ_IMAGE=amq-paas

$ oc new-build \
    https://github.com/dsevost/openshift-xpaas-images-tp \
    --context-dir=amq \
    -e REDHAT_COMPONENT_NAME=amq-broker-7.1.0-bin.zip \
    -e REDHAT_REPO_URL=$REDHAT_REPO_URL \
    --name=$AMQ_IMAGE \
    --strategy=docker \
    --image-stream=redhat-openjdk18-openshift:1.2

$ oc new-app \
    $AMQ_IMAGE \
    --name=amq-test-01 \

```