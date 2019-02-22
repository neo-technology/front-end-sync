# front-end-sync
Scripts for syncing the Cypher front-end from the Neo4j mono-repo to the openCypher front-end.
This will take all changes to the frontend in Neo4j after a certain cutoff point, and apply equivalent commits to the openCypher frontend.
For this to work a previous synchronization point is needed, where both repos contained identical front-end sources. 
To define this point, two commits are needed, one from openCypher and one from Neo4j.
All changes in versions prior to the version of the commit you choose will appear to have been made in merge commits, i.e. the actual commits on older versions will not be synchronized, but their changes will appear in openCypher frontend.

Be aware that this all fails horribly if there are no commits in neo4j, after the synchronization point, that touch the frontend. I don't know why.
So, whenever you touch the synchronization point, make sure there is at least one commit afterwards that will be synchronized.


To publish changes from neo4j to the opencypher frontend, run 
```
./synchronize-commits.sh
cd neo4j && mvn test && cd ..
./publish.sh
./cleanup.sh
```
This needs certain environment variables to be defined before running the script.
In TeamCity, these are defined in the build configuration.
If you want to run/test this locally. you can run the following block before invoking the script.

```
# The openCypher repository:
export OPENCYPHER_REPO=sherfert/front-end.git
# This is the last commit in the openCypher frontend:
export OPENCYPHER_COMMIT=e5efc31518af2036c0a61dc561c6bf130c87f6d2
# The branch in the openCypher frontend to synchronize changes to:
export OPENCYPHER_BRANCH_NAME=9.0-sync-test2

# The Neo4j repository:
export NEO4J_REPO=sherfert/neo4j.git
# This is the first commit that gets moved from neo4j to the frontend. 
# It must be a commit with frontend changes. 
# Be aware that, if this is e.g. a 4.0 commit, all commits from older neo4j branches (e.g. 3.5) will in the frontend appear to be made in merge commits.
export NEO4J_COMMIT=9ec076386c7dbb6e30771ae9a6d7e821d39e70f8
# The branch in the Neo4j to synchronize changes from:
export NEO4J_BRANCH_NAME=4.0-sync-test
```
