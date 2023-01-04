# Hive Standalone Metastore with Postgres Backend, Presto Query Engine, Minio (S3 Compatible Object Storage), and Superset Frontend in Docker

This project is no longer supported. For an actively supported project with similar (and additional) functionality, see https://github.com/rylativity/container-analytics-platform

## Overview

This project contains all configuration files needed to set up a modern distributed analytics environment, allowing you to query data where it lies (in this case, in a S3 object store, in ElasticSearch, and in MongoDB). The docker-compose.yml file defines the following services: a Postgres container (backend for Hive Metastore), a Hive Metastore Container, a Minio Container (which you can use as a drop-in replacement for AWS S3) for testing the Hive metastore on an Object Store, a Presto container for querying data out of S3(Minio) using the Hive Metastore, and the four services that make up Superset for dashboarding data through Presto.  There are also examples and usage instructions for interacting with the various services.

The docker-compose.yml also defines an ElasticSearch service and a MongoDB service (both of which are commented out).  If you wish to use ElasticSearch and/or MongoDB, uncomment the relevant lines in the docker-compose.yml (including their volume definitions at the bottom of the docker-compose.yml), and modify the relevant filenames in presto/catalog to remove ".template" (e.g. elasticsearch.properties.template -> elasticsearch.properties).  Presto will read any files in the presto/catalog folder that ends with ".properties".

## Pre-Requisites
- Working installations of Docker and docker-compose (if you do not have either of these installed, Google the installation instructions, follow the official installation instructions for your operating system, and then return here to continue)
- Experience with Docker & docker-compose (if you do not have experience with Docker or docker-compose, it would help to get some experience by following the official Docker quick-start guides; while not required, it will definitely be easier to understand this project if you understand Docker and docker-compose)
- A high level understanding of Presto (or Trino), Hive Standalone Metastore, and S3 or Minio (if you don't know about any of these, spend a few minutes researching them and then return here to continue)

## Setup
- Run `docker-compose up -d` (This will bring up the containers, initalize the metastore postgres database, create a 'test' bucket with public permissions in Minio, and create a Minio service account access-key & secret-key)
- Once the containers are running and the initialization is complete, run `./scripts_and_examples/dataload_scripts/load_taxidata_to_minio.sh` (This will download NYC Taxi Data from the year 2022 and store in in the public 'test' bucket in Minio)
- Once the taxi data is available in Minio, you can exec into the Presto container to create the Hive schemas and tables.  Run `docker-compose exec presto presto` to open the Presto shell in the Presto container.  See ./dataload_scripts/presto_commands.txt for examples of how to create Hive schemas and tables. Alternatively, if you are using the NYC Taxi example data, you can run `./scripts_and_examples/dataload_scripts/register_presto_hive_tables.sh`, which will pass the commands in presto_commands.txt to the Presto shell in the Presto container for execution.

Minio UI - http://localhost:9090

Presto UI - http://localhost:8080

Presto Shell - `docker-compose exec presto presto` (Use this to run SQL commands against data in Minio)

Superset UI - TODO

***

## Explanation and Usage of Services in the Docker-Compose.yml
**TODO**

### Minio
Minio is an S3-Compatible object store that can be run locally or on any cloud platform.  In other words, Minio is a free, drop-in replacement for S3 that you have full control over.  In addition to countless other uses, Minio is a great standin for S3 while doing local development.

Credentials for Minio (including the admin username, password, and service account credentials) can be found in the docker-compose.yml file.

You can access the minio console at http://localhost:9090. You can create buckets and upload files through the Minio Console.  

Buckets in the Minio Object Store are programatically accessable at http://localhost:9000.  Any operations you would performa against an S3 bucket can be performed against the Minio Object Store.  

You can use the AWS CLI v2 to interact with a Minio bucket as if it were an S3 bucket by specifying the endpoint URL.  For example, to list the objects in a **public** Minio bucket called `test`, you would run:
`aws --endpoint-url http://localhost:9000 s3 ls s3://test/ --no-sign-request`.

To add some sample data to Minio, run `./dataload_scripts/load_taxidata_to_minio.sh`, which will download the NYC Yellow Cab trip data in parquet format and upload it to the Minio "test" bucket (which is created by the 'createbuckets' container defined in docker-compose.yml)

### Presto
Presto is a distributed query engine that can connect to many different datasources including SQL databases, document databases (e.g. MongoDB), and even data files sitting in S3 (by leveraging a Hive Standalone Metastore).  Presto will even allow you to execute queries that pull in data from different datasources (e.g. you can query data from S3 and left join in a SQL table in a single query).

Once you have sample data in Minio, you can register schemas and tables in Hive using the Presto CLI.  If you loaded the sample NYC Yellow Cab trip data to Minio (as described above), you can run `./dataload_scripts/register_presto_hive_tables.sh`, which will execute the Presto commands to create a new schema and add a table with the external Minio data location as the source.

Example Commands - https://prestodb.io/docs/current/connector/hive.html#examples

### Metastore (Hive Standalone Metastore)
The Hive Metastore allows us to project a table-like structure onto data sitting in Minio (or S3).  We connect the Hive Metastore to Presto, and then use SQL commands issued to Presto to "create" tables out of data (JSON, CSV, ORC, PARQUET, etc...) in S3 and query the data.

The Hive Metastore does not need to be interacted with directly.  Presto's Hive Connector is used to configure the connection with Presto (see the file presto/catalog/hive.properties), and Presto handles updating the Hive Metastore.

If you are interested in seeing the contents of the Hive Metastore, you can use `docker-compose exec metastore bash` to open a terminal in the Hive Metastore container.  The actual Metastore data is stored at /etc/hive_metastore inside the container (Note: you will need to use `ls -a` to list the contents of folders in /etc/hive_metastore, since many of the files are "hidden")

### Superset
Apache Superset is arguably one of the best BI tools available, ignoring the fact that it is completely free and open-source.  In this project, Superset serves as a front-end for Presto.  You can use its SQL Lab Editor to write and execute queries against any datasource registered in Presto, and you can use it to create visuals and dashboards.

Superset is accessible at http://localhost:8088 (Username: admin, Password: admin) once you have gone through the setup steps.  To connect Superset to Presto using Superset's Presto connector, login to the Superset UI and add Presto as a Database (select "Data" > "Databases" > "+Database" > "Presto", the SQLALCHEMY URI should be "presto://presto:8080/hive" - the hostname/URL "presto" is simply the docker service name of presto).

Once connected, Superset's SQL Lab Editor can be used as a frontend for the Presto query engine (which in turn can be used to query/manage data in of S3 using the Hive Standalone Metastore).

The file scripts_and_examples/presto_commands.txt contains an example of using Presto to connect to a read-only dataset in S3.  To create a Presto managed dataset (i.e. read-write), first create a bucket in Minio (http://localhost:9090 after you've started the containers), and then run the commands below (substituting your S3 bucket name and your desired table structure) in the Superset SQL Lab Editor:
```
-- Create a Presto-managed Hive schema using the S3 bucket
CREATE SCHEMA hive.mybucket
WITH (location = 's3a://mybucket/');

-- Create an example Hive table in the Presto-managed schema
CREATE TABLE hive.mybucket.users (
  user_id bigint,
  username varchar,
  country varchar
)
WITH (
  format = 'ORC',
  partitioned_by = ARRAY['country'],
  bucketed_by = ARRAY['user_id'],
  bucket_count = 50
);

-- Insert sample data into the Presto-managed Hive table
INSERT INTO hive.mybucket.users (user_id, username, country)
VALUES (1, 'first_username', 'USA'),
        (2, 'second_username', 'Mexico');

-- Drop tables and schemas if desired (YOU MUST STILL MANUALLY DELETE THE DATA FROM S3)
-- DROP TABLE hive.mybucket.users;
-- DROP SCHEMA hive.mybucket;
```


## Roadmap
- [x] Initalize Minio (by creating bucket and adding taxi Parquet data - https://registry.opendata.aws/nyc-tlc-trip-records-pds/) 
- [x] Initialize Presto (by creating a hive table from Parquet taxi data in Minio)
- [x] Resolve bug in Standalone Metastore (NoSuchObjectException 'hive.<schema>.<table>' no such table) when attempting to create hive table
- [ ] Update README.md with explanation of services
- [ ] Update README.md with instructions for using example data & init scripts
- [x] Add Superset to Project for Data Exploration
- [x] Add instructions for using Superset
- [ ] Add Spark+Jupyter & Delta containers and examples

## Tips & Troubleshooting
 - Stick with Minio bucketnames that use only lowercase letters and no special characters.  
