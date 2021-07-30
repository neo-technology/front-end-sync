# front-end-sync
Scripts for syncing the Cypher front-end from the Neo4j mono-repo to the openCypher front-end.
This will take all changes to the frontend in Neo4j after a certain cutoff point, and apply equivalent commits to the openCypher frontend.
For this to work a previous synchronization point is needed, where both repos contained identical front-end sources. 
To define this point, two commits are needed, one from openCypher and one from Neo4j.

Be aware that this all fails horribly if there are no commits in neo4j, after the synchronization point, that touch the frontend. I don't know why.
So, whenever you touch the synchronization point, make sure there is at least one commit afterwards that will be synchronized.

## Run locally

To publish changes from neo4j to the opencypher frontend, run 
```
./checkout-neo4j.sh
./synchronize-commits.sh
cd neo4j && mvn test && cd ..
./publish.sh
./cleanup.sh
```
This needs certain environment variables to be defined before running the script.
In TeamCity, these are defined in the build configuration.
If you want to run/test this locally. you can run the following block (or similar, depending on the actual repos/branches) before invoking the script.

```
# The openCypher repository:
export OPENCYPHER_REPO=openCypher/front-end.git
# This is the last commit in the openCypher frontend:
export OPENCYPHER_COMMIT=2f59c37f8d5bac8e27bd5519c0016dab36321e03
# The branch in the openCypher frontend to synchronize changes to:
export OPENCYPHER_BRANCH_NAME=9.0

# The Neo4j repository:
export NEO4J_REPO=neo-technology/neo4j.git
# This is the last commit that got already synchronized previously.
# It must be a commit with frontend changes. 
export NEO4J_COMMIT=4f3f3e9511b2960a2acd25bfa8142f752ece0455
# The branch in the Neo4j to synchronize changes from:
export NEO4J_BRANCH_NAME=dev
```

## Dealing with failures

If the sync job starts failing or you have a PR that you are certain/afraid it will break the sync job, this should hopefully help you.
The sync job can start failing because you made changes to pom files, you changed modules or directory structures or something similar.
To  get it to work again, follow these steps:

1. Pause the sync job in [Team City](https://live.neo4j-build.io/viewType.html?buildTypeId=Monorepo_PublishFrontend).
1. Merge your PR (if you haven't already done so anyway).
1. Follow the steps above to run locally.
   After locating the failure:
   * Make any changes to the sync job itself necessary to reflect the new situation (e.g. there is a new module).
     You don't need to worry about having to deal with both the old and the new situation, since you'll be synchronizing only after this change in the future.
     Don't forget to push these changes to `git@github.com:neo-technology/front-end-sync.git` if it works.
   * Make any necessary commits to the frontend to make it work, e.g. port over any pom changes you made in neo4j.
     You can do this in the `neo4j` folder after having run  `./synchronize-commits.sh` so that your commit will end on top of the commits that actually broke the sync job.
     If it works, push your changes directly to opencypher, with `./publish.sh`. Do not create merge commits!
     If you don't have push access to the opencypher frontend, ask one of the administrators to grant you access temporarily.
1. Wait until there is at least one commit in neo4j that touches the frontend _after_ the one that broke the sync job.
1. Determine the sha1 of the last commit in neo4j that was successfully synchronized before.
   Determine the sha1 of the last commit in opencypher. This is likely the one you created in step 3 and pushed manually. This must not be a merge commit!
   Put both these shas in this readme in the Run locally section and in the Team City job.
1. Re-enable the Team City job.
