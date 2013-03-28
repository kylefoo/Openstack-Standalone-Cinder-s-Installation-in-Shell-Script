Openstack-Standalone-Cinder-s-Installation-in-Shell-Script
==========================================================

This script aims to install a Cinder node to a existing OpenStack Folsom environment.
Simply modify the parameters such as IP addresses and Authentications to adapt to the current setup of your OpenStack Cloud and run the script for installation.

In the script, locate the following parameters to be modified:

Please modify the following to your envoronment's specifications
--------------------------------------------------
CONTROLLER_IP=%keystone_management_interface%

CONTROLLER_API_IP=%keystone_api_interface%

ADMIN_TENANT=%service%

ADMIN_USER=%cinder%

ADMIN_PASS=%service_pass%

--------------------------------------------------

MYSQL_CINDER_USER=%mysql_cinder_user%

MYSQL_CINDER_PASS=%mysql_cinder_pass%

MYSQL_HOST=%mysql_host_ip%

MYSQL_CINDER_TABLE=%cinder%

RABBIT_HOST=%rabbit_host_ip%

-------------------------------------------------

The script with such parameters will run accordingly to adapt to your current Openstack setup provided the parameters are correct.
Please use at your own risk, checks /var/log/syslog for bugs occurred during installation. Simply discard the node if failure occurred.
