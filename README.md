# front-end-sync
Scripts for syncing the Cypher front-end from the Neo4j mono-repo to the openCypher front-end.
This will take all changes to the frontend in Neo4j after a certain cutoff point, and apply equivalent commits to the openCypher frontend.
For this to work a previous synchronization point is needed, where both repos contained identical front-end sources. 
To define this point, two commits are needed, one from openCypher and one from Neo4j in 3.5.
All changes in versions prior to 3.5 will appear to have been made in merge commits, i.e. the actual commits on 3.4 and previous are not synchronized, but their changes will appear in openCypher frontend.


To publish changes from neo4j to the opencypher frontend, run `./publish-opencypher-frontend.sh`. 
This needs certain environment variables to be defined before running the script.
In TeamCity, these are defined in the build configuration.
If you want to run/test this locally. you can run the following block before invoking the script.

```
# The openCypher repository:
export OPENCYPHER_REPO=sherfert/front-end.git
# This is the last commit in the openCypher frontend:
export OPENCYPHER_COMMIT=01148edb5ca9b49c3173a6f8d7c79c877ddb2f74
# The branch in the openCypher frontend to synchronize changes to:
export OPENCYPHER_BRANCH_NAME=9.0-sync-test2

# The Neo4j repository:
export NEO4J_REPO=sherfert/neo4j.git
# This is the first commit that gets moved from neo4j to the frontend. 
# It must be a commit with frontend changes. 
# It must be a 3.5 commit.
export NEO4J_COMMIT=9705f5073612c669c1861bab4a513c4c84154938
# The branch in the Neo4j to synchronize changes from:
export NEO4J_BRANCH_NAME=4.0-sync-test
```
