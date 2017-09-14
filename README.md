Oracle EE 12.1 Release 1
============================
forked from [MaksymBilenko/docker-oracle-ee-12c](#https://github.com/MaksymBilenko/docker-oracle-ee-12c)

### Build instruction

To build container you must provide URLs where installation script can download Oracle Enterprise Edition Software (12.1.0.2.0) [http://www.oracle.com/technetwork/database/enterprise-edition/downloads/index.html]. 
It consists of 2 parts, so you define DB_DOWNLOAD_URL_P1 & DB_DOWNLOAD_URL_P2:
    
    docker build --tag company.name/oracle-ee:12.1.0.2 \
    --build-arg DB_DOWNLOAD_URL_P1="http://example.com/linuxamd64_12102_database_1of2.zip"  \
    --build-arg DB_DOWNLOAD_URL_P2="http://example.com/linuxamd64_12102_database_2of2.zip" \
    .
### Usage

Run with 8080 and 1521 ports opened:

    docker run -d -p 8080:8080 -p 1521:1521 company.name/oracle-ee:12.1.0.2

Run with data on host and reuse it:

    docker run -d -p 8080:8080 -p 1521:1521 -v /my/oracle/data:/u01/app/oracle company.name/oracle-ee:12.1.0.2

Run with Custom DBCA_TOTAL_MEMORY (in Mb):

    docker run -d -p 8080:8080 -p 1521:1521 -v /my/oracle/data:/u01/app/oracle -e DBCA_TOTAL_MEMORY=1024 company.name/oracle-ee:12.1.0.2

Connect database with following setting:

    hostname: localhost
    port: 1521
    sid: xe
    service name: xe
    username: system
    password: oracle

To connect using sqlplus:

<pre>
sqlplus system/oracle@//localhost:1521/xe
</pre>

Password for SYS & SYSTEM:

    oracle

Connect to Oracle Application Express web management console with following settings:

    http://localhost:8080/apex
    workspace: INTERNAL
    user: ADMIN
    password: 0Racle$

Apex upgrade up to v 5.*

    docker run -it --rm --volumes-from ${DB_CONTAINER_NAME} --link ${DB_CONTAINER_NAME}:oracle-database -e PASS=YourSYSPASS sath89/apex install

Details could be found here: https://github.com/MaksymBilenko/docker-oracle-apex

Connect to Oracle Enterprise Management console with following settings:

    http://localhost:8080/em
    user: sys
    password: oracle
    connect as sysdba: true

By Default web management console is enabled. To disable add env variable:

    docker run -d -e WEB_CONSOLE=false -p 1521:1521 -v /my/oracle/data:/u01/app/oracle company.name/oracle-ee:12.1.0.2
    #You can Enable/Disable it on any time

Start with additional init scripts or dumps:

    docker run -d -p 1521:1521 -v /my/oracle/data:/u01/app/oracle -v /my/oracle/init/SCRIPTSorSQL:/docker-entrypoint-initdb.d company.name/oracle-ee:12.1.0.2
    
By default Import from `docker-entrypoint-initdb.d` is enabled only if you are initializing database (1st run).

To customize dump import use `IMPDP_OPTIONS` env variable like `-e IMPDP_OPTION="REMAP_TABLESPACE=FOO:BAR"`
To run import at any case add `-e IMPORT_FROM_VOLUME=true`

**In case of using DMP imports dump file should be named like ${IMPORT_SCHEME_NAME}.dmp**

**User credentials for imports are  ${IMPORT_SCHEME_NAME}/${IMPORT_SCHEME_NAME}**

If you have an issue with database init like DBCA operation failed, please reffer to this [issue](https://github.com/MaksymBilenko/docker-oracle-12c/issues/16)
