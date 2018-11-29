#!/bin/bash

# This script synchronizes the front-end from a Neo4j mono-repo into a opencypher front-end repo
#
# For this to work a previous synchronization point is needed, where both repos contained identical
# front-end sources. To define this point, two commits are needed:
#
#	OpenCypher front-end		Neo4j mono-repo front-end
#	commit7						commit 415		<- commits where sources are the same
#	commit6						commit 414
#	commit5						commit 413

# CONFIGURATION
OPENCYPHER_REPO=sherfert/front-end.git
# This is the last commit in the frontend. Export since we need it in another script as well
export OPENCYPHER_COMMIT=01148edb5ca9b49c3173a6f8d7c79c877ddb2f74
OPENCYPHER_BRANCH_NAME=9.0-sync-test2

NEO4J_REPO=sherfert/neo4j.git
# This is the first commit that gets moved from neo4j to the frontend. It must be a commit with frontend changes.
# This must be a 3.5 commit, otherwise we will get conflicts during the rebase
NEO4J_COMMIT=9705f5073612c669c1861bab4a513c4c84154938
NEO4J_BRANCH_NAME=4.0-sync-test

# INTERNALS
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
CONVERT_PACKAGES_BIN="$DIR/convert-packages.sh"
RESTORE_FILES_BIN="$DIR/restore-pom-license-notices.sh"

NEO4J_BRANCH=origin/$NEO4J_BRANCH_NAME

# fetch source trees
git clone git@github.com:$NEO4J_REPO neo4j
cd neo4j
git remote add pub git@github.com:$OPENCYPHER_REPO
git fetch pub

# The commit before the synchronization point
NEO4J_CUTOFF=`git log --format='%H' "$NEO4J_COMMIT^" | head -n 1`

# remove everything apart from the front-end subdirectory
git filter-branch --force --prune-empty --subdirectory-filter public/community/cypher/front-end -- $NEO4J_BRANCH --not $NEO4J_CUTOFF

# change directories and packages in all commits to org.opencypher.v9_0
git filter-branch --force --prune-empty --tree-filter "$CONVERT_PACKAGES_BIN" -- $NEO4J_BRANCH --not $NEO4J_CUTOFF

# change all commits, such that they keep poms/notice/license files untouched
git filter-branch --force --prune-empty --tree-filter "$RESTORE_FILES_BIN" -- $NEO4J_BRANCH --not $NEO4J_CUTOFF

# put the history on top of the opencypher history
git replace $NEO4J_CUTOFF $OPENCYPHER_COMMIT
git filter-branch --force $OPENCYPHER_COMMIT..$NEO4J_BRANCH

# Clean-up after filter-branch
rm -rf .git/refs/original

# switch to the branch (will be detached HEAD)
git checkout $NEO4J_BRANCH

# Ensure things compile and tests are green, if so, push. Afterwards clean up
mvn clean test && git push pub HEAD:$OPENCYPHER_BRANCH_NAME && cd .. && rm -rf neo4j
