## Setup
* Run docker-compose up superset-init
* Run docker-compose up -d (after superset-init completes)

Superset available at localhost:8088

Presto UI available at localhost:8080

Example jupyter notebooks for adding data to mongo and elasticsearch available in scripts_and_examples/jupyter_notebooks folder.  requirements.txt file contains all python requirements needed.  Create a virtual environment and run the notebooks in jupyter lab to easily add data.

### Connect Superset to Presto through Superset "Add Dashboard" in UI
To add Mongodb Presto, use connection string presto://presto:8080/mongodb
To add Elasticsearch Presto, use connection string presto://presto:8080/elasticsearch