if [ -d /root/manifests ] ; then
  mkdir -p /var/lib/microshift/manifests
  cp /root manifests/*y*ml /var/lib/microshift/manifests
fi

{% if podman %}
dnf install -y podman
curl -o /etc/systemd/system/microshift.service https://raw.githubusercontent.com/redhat-et/microshift/main/packaging/systemd/microshift-containerized.service
systemctl enable microshift --now
KUBEADMINDIR=/var/lib/microshift/resources/kubeadmin
mkdir -p $KUBEADMINDIR
while true ; do podman cp microshift:$KUBEADMINDIR/kubeconfig $KUBEADMINDIR && break ; sleep 10 ; done
{% else %}
dnf copr enable -y @redhat-et/microshift{{ '-nightly' if nightly else ''}}
dnf install -y microshift firewalld
systemctl enable microshift --now
{% endif %}
