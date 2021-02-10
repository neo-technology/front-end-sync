#!/bin/bash
set -e

# INTERNALS
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
CONVERT_PACKAGES_BIN="$DIR/convert-packages.sh"
RESTORE_FILES_BIN="$DIR/restore-pom-license-notices.sh"

NEO4J_BRANCH=origin/$NEO4J_BRANCH_NAME

#Suppress warning
export FILTER_BRANCH_SQUELCH_WARNING=1

# fetch source trees
git clone git@github.com:$NEO4J_REPO neo4j
cd neo4j
git remote add pub git@github.com:$OPENCYPHER_REPO
git fetch pub

# Checkout correct neo4j branch
git checkout $NEO4J_BRANCH

# Make a new branch
git checkout -b sync-branch

# remove everything apart from the front-end subdirectory
git filter-branch --force --prune-empty --subdirectory-filter public/community/cypher/front-end -- $NEO4J_COMMIT..sync-branch

# change directories and packages in all commits to org.opencypher.v9_0
git filter-branch --force --prune-empty --tree-filter "$CONVERT_PACKAGES_BIN" -- $NEO4J_COMMIT..sync-branch

# change all commits, such that they keep poms/notice/license files untouched
git filter-branch --force --prune-empty --tree-filter "$RESTORE_FILES_BIN" -- $NEO4J_COMMIT..sync-branch

# linearize the history (every commit gets only a single parent)
git filter-branch --force --parent-filter 'cut -f 2,3 -d " "' -- $NEO4J_COMMIT..sync-branch

# put the history on top of the opencypher history
git replace $NEO4J_COMMIT $OPENCYPHER_COMMIT
git filter-branch --force -- $OPENCYPHER_COMMIT..sync-branch

# Safety checks
# Number of commits must be smaller than 1000
NUMBER_OF_COMMITS=$( git rev-list --count HEAD )
echo Number of commits to sync: $NUMBER_OF_COMMITS
test $NUMBER_OF_COMMITS -lt 10000
# Should not contain some certain key commits from neo4j
git branch --contains 20c2e0b0d0a813806e729ec248c9d18cf9b1cc47 | (! grep sync-branch) # the creation of the private/pom.xml
git branch --contains 9c4f3c010b03070098c2102d46d347bac809f4e5 | (! grep sync-branch) # the creation of the neo repo
# Check if there are (in any commit) files in the git index that start with "private" and if so abort
git filter-branch --force --index-filter "git ls-files | (! grep '^private.*')" --  $OPENCYPHER_COMMIT..sync-branch

# Clean-up after filter-branch
rm -rf .git/refs/original

# go to root directory
cd ..

