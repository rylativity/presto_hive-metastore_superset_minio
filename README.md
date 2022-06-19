# Hive Standalone Metastore with Postgres Backend and Minio (S3 Compatible Object Storage) in Docker

This project contains all files needed to set up and test a Hive Standalone Metastore.  The docker-compose.yml file defines the following services: a Postgres container (backend for Hive), a Hive Metastore Container, a Minio Container (which you can use as a drop-in replacement for AWS S3) for testing the Hive metastore on an Object Store, a Presto container for querying data out of S3(Minio) using the Hive Metastore, and the four services that make up Superset for dashboarding data through Presto.

## Setup
- Run `docker-compose up -d` (This will bring up the containers, initalize the metastore postgres database, create a 'test' bucket with public permissions in Minio, and create a Minio service account access-key/secret)
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
Credentials for Minio (including the admin username, password, and service account credentials) can be found in the docker-compose.yml file.

You can access the minio console at http://localhost:9090. You can create buckets and upload files through the Minio Console.  

Buckets in the Minio Object Store are programatically accessable at http://localhost:9000.  Any operations you would performa against an S3 bucket can be performed against the Minio Object Store.  

You can use the AWS CLI v2 to interact with a Minio bucket as if it were an S3 bucket by specifying the endpoint URL.  For example, to list the objects in a **public** Minio bucket called `test`, you would run:
`aws --endpoint-url http://localhost:9000 s3 ls s3://test/ --no-sign-request`.

To add some sample data to Minio, run `./dataload_scripts/load_taxidata_to_minio.sh`, which will download the NYC Yellow Cab trip data in parquet format and upload it to the Minio "test" bucket (which is created by the 'createbuckets' container defined in docker-compose.yml)

### Presto
Once you have sample data in Minio, you can register schemas and tables in Hive using the Presto CLI.  If you loaded the sample NYC Yellow Cab trip data to Minio (as described above), you can run `./dataload_scripts/register_presto_hive_tables.sh`, which will execute the Presto commands to create a new schema and add a table with the external Minio data location as the source.

***

## Roadmap
- [x] Initalize Minio (by creating bucket and adding taxi Parquet data - https://registry.opendata.aws/nyc-tlc-trip-records-pds/) 
- [x] Initialize Presto (by creating a hive table from Parquet taxi data in Minio)
- [x] Resolve bug in Standalone Metastore (NoSuchObjectException 'hive.<schema>.<table>' no such table) when attempting to create hive table
- [ ] Update README.md with explanation of services
- [ ] Update README.md with instructions for using example data & init scripts
- [x] Add Superset to Project for Data Exploration
- [x] Add instructions for using Superset

## Tips & Troubleshooting
 - Stick with bucketnames that use only lowercase letters and no special characters.  