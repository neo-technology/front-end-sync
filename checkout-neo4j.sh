#!/bin/bash
set -e

NEO4J_BRANCH=origin/$NEO4J_BRANCH_NAME

# fetch neo4j
git clone git@github.com:$NEO4J_REPO neo4j

cd neo4j
# Checkout correct neo4j branch
git checkout $NEO4J_BRANCH

cd ..
