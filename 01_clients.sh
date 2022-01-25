curl -o oc.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz
tar -xzvf oc.tar.gz
install -t /usr/local/bin {kubectl,oc}
dnf -y install podman
test -f /root/openshift_pull.json && podman login registry.redhat.io --authfile /root/openshift_pull.json
