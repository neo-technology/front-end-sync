#/bin/bash -e

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
OPENCYPHER_REPO=fickludd/front-end.git
OPENCYPHER_COMMIT=01148edb5ca9b49c3173a6f8d7c79c877ddb2f74
OPENCYPHER_BRANCH=3.5-frontend2

NEO4J_REPO=sherfert/neo4j.git
NEO4J_COMMIT=a135561a7530469de03e85c16164452ddec6ac80
NEO4J_BRANCH=3.5-frontend2

# INTERNALS
NEO4J_CUTOFF=`git log --format='%H' "$NEO4J_COMMIT^" | head -n 1`
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
CONVERT_PACKAGES_BIN="$DIR/convert-packages.sh"


# fetch source trees
#git clone git@github.com:$NEO4J_REPO neo4j
#cd neo4j
#git remote add pub git@github.com:$OPENCYPHER_REPO
#git fetch pub


# remove everything apart from the front-end subdirectory
git filter-branch --force --prune-empty --subdirectory-filter public/community/cypher/front-end -- $NEO4J_BRANCH --not $NEO4J_CUTOFF


# remove poms
git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch pom.xml */pom.xml' -- $NEO4J_BRANCH --not $NEO4J_CUTOFF


# change directories and packages in all commits to org.opencypher.v9_0
git filter-branch --force --prune-empty --tree-filter "$CONVERT_PACKAGES_BIN" -- $NEO4J_BRANCH --not $NEO4J_CUTOFF


# rebase commits onto opencypher/front-end history
NEO4J_REBASE_ROOT=`git log $NEO4J_CUTOFF..HEAD --reverse --format='%H' | head -n 1`
git rebase $NEO4J_REBASE_ROOT --onto $OPENCYPHER_COMMIT --committer-date-is-author-date


# Change commit meta-data to not leave any traces of the history manipulation
git filter-branch --force --commit-filter '
	export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"; 
	export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"; 
	export GIT_COMMITTER_DATE="$GIT_AUTHOR_DATE"; 
	git commit-tree "$@"' -- $OPENCYPHER_COMMIT..HEAD


# Clean-up after filter-branch
rm -rf .git/refs/original


# Ensure things compile
mvn clean test


# push it
git push $OPENCYPHER_REPO $OPENCYPHER_BRANCH