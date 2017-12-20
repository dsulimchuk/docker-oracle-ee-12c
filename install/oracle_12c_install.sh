#!/bin/bash

set -e

if [ -z "$1" ]; then
    echo "No rsp file specified"
    exit 1
elif [ ! -f $1 ]; then
	echo "Can't find RSP file $1"
	exit 1
fi
if [ -z "$DB_DOWNLOAD_URL" ]; then echo "ERROR!  arg $DB_DOWNLOAD_URL is unset"; exit 1; fi


#sysctl workaround
echo 'exit 0' > /usr/sbin/sysctl

groupadd dba && useradd -m -G dba oracle
mkdir /u01 && chown oracle:dba /u01 && chmod 775 /u01

#Download oracle database zip
echo "Downloading oracle database zip"
wget -q -O /tmp/linuxamd64_12102_database_1of2.zip "$DB_DOWNLOAD_URL/linuxamd64_12102_database_1of2.zip"
wget -q -O /tmp/linuxamd64_12102_database_2of2.zip "$DB_DOWNLOAD_URL/linuxamd64_12102_database_2of2.zip"
wget -q -O /tmp/p6880880_121010_Linux-x86-64.zip   "$DB_DOWNLOAD_URL/p6880880_121010_Linux-x86-64.zip"
wget -q -O /tmp/p26635880_121020_Linux-x86-64.zip  "$DB_DOWNLOAD_URL/p26635880_121020_Linux-x86-64.zip"

echo "Extracting oracle database zip"
su oracle -c 'unzip -q /tmp/linuxamd64_12102_database_1of2.zip -d /home/oracle/'
su oracle -c 'unzip -q /tmp/linuxamd64_12102_database_2of2.zip -d /home/oracle/'
su oracle -c 'unzip -q /tmp/p6880880_121010_Linux-x86-64.zip   -d /tmp'
su oracle -c 'unzip -q /tmp/p26635880_121020_Linux-x86-64.zip  -d /tmp'

#Run installer
su oracle -c "cd /home/oracle/database && ./runInstaller -ignorePrereq -silent -responseFile $1 -waitForCompletion"

#OPatch
rm -rf $ORACLE_HOME/OPatch
mv /tmp/OPatch $ORACLE_HOME

echo "Patching"
ls -al /tmp
cd /tmp/26635880/26717470
su oracle -c "$ORACLE_HOME/OPatch/opatch apply -silent"

#Cleanup
echo "Cleaning up"
rm -rf /home/oracle/database /tmp/*

#Move product to custom location
mv /u01/app/oracle/product /u01/app/oracle-product
