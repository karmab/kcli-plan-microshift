dnf copr enable -y @redhat-et/microshift{{ '-nightly' if nightly else ''}}
dnf install -y microshift firewalld
systemctl enable crio --now
systemctl enable microshift --now
