#!/bin/bash

# CONFIGURATION
OPENCYPHER_DIRS="org/opencypher/v9_0"
NEO4J_DIRS="org/neo4j/cypher/internal/v4_0" #TODO previous versions as well!
OPENCYPHER_PACKAGE=`echo $OPENCYPHER_DIRS | sed "s|/|.|g"`
NEO4J_PACKAGE=`echo $NEO4J_DIRS | sed "s|/|.|g"`

OPENCYPHER_LICENSE='/*
 * Copyright © 2002-2018 Neo4j Sweden AB (http://neo4j.com)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */'

echo "CONVERTING PACKAGES FROM $NEO4J_PACKAGE TO $OPENCYPHER_PACKAGE"
# Go through all relevant folders
for d in ast expressions frontend parser rewriting util; do
	for use in main test; do
		for lang in java scala; do
			sourceDir="$d/src/$use/$lang"
			if [ -d $sourceDir ]; then
				# Move the files to the right place
				mkdir -p "$sourceDir/$OPENCYPHER_DIRS"
				rm -r "$sourceDir/$OPENCYPHER_DIRS"
				mv "$sourceDir/$NEO4J_DIRS" "$sourceDir/$OPENCYPHER_DIRS"

				# For all .java/.scala files:
				for sourceFile in `find "$sourceDir/$OPENCYPHER_DIRS" -type f -name "*.$lang"`; do
					# change to open cypher packages
					cat "$sourceFile" | sed "s/$NEO4J_PACKAGE/$OPENCYPHER_PACKAGE/g" > "$sourceFile.temp"
					
					# add open cypher license
					echo $OPENCYPHER_LICENSE > "$sourceFile"
					
					# copy in rest of code, but omitting any previous license
					sed -n '/package /,$p' "$sourceFile.temp" >> "$sourceFile"
					rm "$sourceFile.temp"
				done
			fi
		done
	done
done
