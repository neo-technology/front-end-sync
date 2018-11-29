#!/bin/bash

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

# go to root directory
cd ..
