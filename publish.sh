#!/bin/bash
set -e

cd neo4j
git push pub HEAD:$OPENCYPHER_BRANCH_NAME
cd ..
