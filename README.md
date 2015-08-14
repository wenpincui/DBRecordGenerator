DBRecordGenerator
=================

This small program help you generating massive records in SQL server.

Usage:
```bash
$ ./bin/generator -h 192.168.90.109 -n hugedb -u vchs -p vCHS_password_0 -c 100

$ ./bin/generator -?
Usage: dbscriptomate COMMAND [OPTIONS]

Commands
     setupdb:    will setup the database for initial user. A journaling table will be created
     migrate:    run all the migration files
     generate:   generate a new migration script

Options
    -h, --host [HOST]                the IP address or machine name of where the database is running
    -n, --dbname [DBNAME]            the database against which we need to run the scripts
    -u, --username [USERNAME]        username used to connect to the database
    -p, --password [PASSWORD]        password of the user used to connect to the database
    -o, --port [PORT]                the port used to connect to the database
    -s, --sql [SQL]                  the file store sql procedure
    -c, --count [COUNT]              count of db records, in MB unit
    -?, --help                       Show this message
```
