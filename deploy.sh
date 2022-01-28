{% if nip %}
IP=`ip a l  eth0 | grep 'inet ' | cut -d' ' -f6 | awk -F'/' '{ print $1}'`
echo $IP.nip.io > /etc/hostname
hostnamectl set-hostname $IP.nip.io
{% endif %}
/root/01_clients.sh
/root/02_crio.sh
/root/03_microshift.sh
