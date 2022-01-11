curl -o oc.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz
tar -xzvf oc.tar.gz
install -t /usr/local/bin {kubectl,oc}
CRIO_VERSION=1.$(kubectl version -o yaml | grep minor | cut -d: -f2 | sed 's/"//g' | xargs)
OS="CentOS_8"
curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/devel:kubic:libcontainers:stable.repo
curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.repo https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION/$OS/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.repo
yum -y install cri-o conntrack
sed -i 's@conmon = .*@conmon = "/bin/conmon"@' /etc/crio/crio.conf
systemctl enable --now crio
