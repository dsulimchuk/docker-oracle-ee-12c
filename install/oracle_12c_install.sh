#!/bin/bash

set -e

if [ -z "$1" ]; then
    echo "No rsp file specified"
    exit 1
elif [ ! -f $1 ]; then
	echo "Can't find RSP file $1"
	exit 1
fi
if [ -z "$DB_DOWNLOAD_URL_P1" ]; then echo "ERROR!  arg DB_DOWNLOAD_URL_P1 is unset"; exit 1; fi
if [ -z "$DB_DOWNLOAD_URL_P2" ]; then echo "ERROR! val DB_DOWNLOAD_URL_P2 is unset"; exit 1; fi


#sysctl workaround
echo 'exit 0' > /usr/sbin/sysctl

groupadd dba && useradd -m -G dba oracle
mkdir /u01 && chown oracle:dba /u01 && chmod 775 /u01

#Download oracle database zip
echo "Downloading oracle database zip"
wget -q -O /oracle_database_p1.zip "$DB_DOWNLOAD_URL_P1"
wget -q -O /oracle_database_p2.zip "$DB_DOWNLOAD_URL_P2"

echo "Extracting oracle database zip"
su oracle -c 'unzip -q /oracle_database_p1.zip -d /home/oracle/'
su oracle -c 'unzip -q /oracle_database_p2.zip -d /home/oracle/'
rm -f /oracle_database_p1.zip
rm -f /oracle_database_p2.zip

#Run installer
su oracle -c "cd /home/oracle/database && ./runInstaller -ignorePrereq -silent -responseFile $1 -waitForCompletion"
#Cleanup
echo "Cleaning up"
rm -rf /home/oracle/database /tmp/*

#Move product to custom location
mv /u01/app/oracle/product /u01/app/oracle-product