#!/bin/bash
#Purpose: To automate Cinder Installation
#Author: Kyle Foo
#Date/Time: 02-26-2013.19:10
#Modified date: 02-27-2013: added patitions, volume group creations for persistency on every reboot.


LIST_OF_APPS="cinder-api cinder-scheduler cinder-volume iscsitarget open-iscsi python-cinderclient python-mysqldb iscsitarget-dkms"

apt-get update -y
apt-get install -y $LIST_OF_APPS

sed -i 's/false/true/g' /etc/default/iscsitarget

service iscsitarget start
service open-iscsi start

#Please enter the following parameters
CONTROLLER_IP=%keystone_management_interface%
CONTROLLER_API_IP=%keystone_api_interface%
ADMIN_TENANT=service
ADMIN_USER=cinder
ADMIN_PASS=service_pass

sed -i "s/\(.*service_host.*\)/service_host=${CONTROLLER_API_IP}/g" /etc/cinder/api-paste.ini
sed -i "s/\(.*auth_host.*\)/auth_host=${CONTROLLER_IP}/g" /etc/cinder/api-paste.ini
sed -i "s/\(.*admin_tenant_name.*\)/admin_tenant_name=${ADMIN_TENANT}/g" /etc/cinder/api-paste.ini
sed -i "s/\(.*admin_user.*\)/admin_user=${ADMIN_USER}/g" /etc/cinder/api-paste.ini
sed -i "s/\(.*admin_password.*\)/admin_password=${ADMIN_PASS}/g" /etc/cinder/api-paste.ini

#Please enter the following parameters
MYSQL_CINDER_USER=%mysql_cinder_user%
MYSQL_CINDER_PASS=%mysql_cinder_pass%
MYSQL_HOST=%mysql_host_ip%
MYSQL_CINDER_TABLE=cinder
RABBIT_HOST=%rabbit_host_ip%

if [grep -q "sql_connection" /etc/cinder/cinder.conf];
then sed -i "s/\(.*sql_connection.*\)/sql_connection=mysql://${MYSQL_CINDER_USER}:${MYSQL_CINDER_PASS}@${MYSQL_HOST}/${MYSQL_CINDER_TABLE}/g" /etc/cinder/cinder.conf
else sed -i "2i sql_connection=mysql://${MYSQL_CINDER_USER}:${MYSQL_CINDER_PASS}@${MYSQL_HOST}/${MYSQL_CINDER_TABLE}" /etc/cinder/cinder.conf
fi

if [grep -q "rabbit_host" /etc/cinder/cinder.conf];
then sed -i "s/\(.*rabbit_host.*\)/rabbit_host=${RABBIT_HOST}/g" /etc/cinder/cinder.conf
else sed -i "3i rabbit_host=${RABBIT_HOST}" /etc/cinder/cinder.conf
fi

sed -i 's/\(.*iscsi_helper.*\)/iscsi_helper=tgtadm/g' /etc/cinder/cinder.conf

cinder-manage db sync

#Below set up a partition for cinder-volumes
dd if=/dev/zero of=cinder-volumes bs=1 count=0 seek=2G
losetup /dev/loop2 cinder-volumes
cat << EOF | fdisk /dev/loop2
n
p
1
 
 
t
8e
w
EOF

#below create physical voulme and volume group
cat << EOF | pvcreate /dev/loop2 -ff
y
EOF
vgcreate cinder-volumes /dev/loop2

service cinder-volume restart
service cinder-api restart
service cinder-scheduler restart
service tgt restart
