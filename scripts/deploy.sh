{% if nip %}
IP=`ip a l  eth0 | grep 'inet ' | cut -d' ' -f6 | awk -F'/' '{ print $1}'`
echo $IP.nip.io > /etc/hostname
hostnamectl set-hostname $IP.nip.io
{% endif %}
/root/scripts/01_clients.sh
/root/scripts/02_crio.sh
/root/scripts/03_microshift.sh
{% if register_acm %}
/root/scripts/04_acm.sh
{% endif %}
