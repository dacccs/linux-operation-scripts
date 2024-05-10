#!/bin/bash
###########################################################
# Dell iDRAC Service Module install                       #
# Created: dacccs                                         #
# Last modification: 2022.10.31                           #
###########################################################
VERSION=1.0003;
ENABLE=0; DISABLE=0; STATUS=0; HELP=0; FLAG=1;

function info {
	echo -en '\e[1;32m'$*'\e[0m';
}

function error {
	echo -en '\e[1;31m'$*'\e[0m';
}

# Argument extra option check
case $1 in
	[hH][eE][lL][pP]) HELP=1;;
	[sS][tT][aA][tT][uU][sS]) STATUS=1; FLAG=0;;
	[eE][nN][aA][bB][lL][eE]) ENABLE=1; FLAG=0;;
	[dD][iI][sS][aA][bB][lL][eE]) DISABLE=1; FLAG=0;;
	*) echo 'Invalid argument! '$arg;
esac;

# If argument list empty
if (( ! $# )); then HELP=1; fi;

# Script informations
if (( $HELP )); then 
	echo -e 'Version: '$VERSION'\nUsage:\t dcism-service [<parameter>]\n\n   Available parameters:\n';
	echo -e '\tenable\t- Enable dcism service
\tdisable\t- Disable dcism service
\tstatus\t- dcism service status';
	echo -e '\n';
	exit;
fi

# DCISM Hardware specified tools install / uninstall
if (( ( $ENABLE || $DISABLE ) || $FLAG )); then 
	if [[ ! -f /opt/dell/srvadmin/bin/idracadm7 ]]; then 
		yum install srvadmin-idracadm7 -y;
		ln -s /opt/dell/srvadmin/bin/idracadm7 /bin/racadm;
	fi;	
	# Enable the service
	if (( $ENABLE )); then 
		if [[ -n "$(yum repolist all | egrep -i "(ossbasesetup|tsi|security)")" ]]; then
			racadm set idrac.OS-BMC.AdminState 1
			racadm set idrac.OS-BMC.PTMode 1
			yum install dcism -y;
			installer scripts
			fix-interface-name
			systemctl enable dcismeng.service;
			systemctl start dcismeng.service;
			else error 'Repository not configured! Dell iDRAC Service Module is not installed!\n';
		fi;
	fi;	
	# Disable the service and the 
	if (( $DISABLE )); then 
		systemctl stop dcismeng.service;
		yum remove dcism -y;
		racadm set idrac.OS-BMC.AdminState 0
	fi;	
fi;

if (( $STATUS )); then
	if (( $(systemctl list-unit-files | grep -i dcism -c) )); then 
		case $(systemctl is-enabled dcismeng.service) in
			'enabled') servenab=$(info 'enabled');;
			'disabled') servenab=$(error 'disabled');;
		esac
		case $(systemctl status dcismeng.service | grep -i "active:" | cut -d':' -f2 | cut -d' ' -f2) in
			'active') servstat=$(info 'active');;
			'inactive') servstat=$(error 'inactive');;
		esac
		echo -e '\nThe dcism service '$servenab' and '$servstat'.\n'
	else echo -e '\nThe dcism service is not installed.\n';	
	fi;
	if [[ -f /opt/dell/srvadmin/bin/idracadm7 ]]; then 
		echo -e 'OS to iDRAC Pass-through is '$(info $(racadm get idrac.OS-BMC.AdminState | grep -i AdminState | cut -d'=' -f2))' on RSB board.\n';
	fi;	
fi;	
