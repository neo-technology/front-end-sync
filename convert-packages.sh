#!/bin/bash

openCypherDirs="org/opencypher/v9_0"
neo4jDirs="org/neo4j/cypher/internal/v3_5"
openCypherPackage=`echo $openCypherDirs | sed "s|/|.|g"`
neo4jPackage=`echo $neo4jDirs | sed "s|/|.|g"`

echo $openCypherPackage
echo $neo4jPackage

openCypherLicense='/*
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

echo "CONVERTING PACKAGES FROM $neo4jPackage TO $openCypherPackage"
for d in ast expressions frontend parser rewriting util; do 
	echo "  $d"
	for use in main test; do
		for lang in java scala; do
			sourceDir="$d/src/$use/$lang"
			if [ -d $sourceDir ]; then
				echo "    $sourceDir"
				mkdir -p "$sourceDir/$openCypherDirs"
				rm -r "$sourceDir/$openCypherDirs"
				mv "$sourceDir/$neo4jDirs" "$sourceDir/$openCypherDirs"
				for sourceFile in `find "$sourceDir/$openCypherDirs" -type f -name "*.$lang"`; do
					# change to open cypher packages
					cat "$sourceFile" | sed "s/$neo4jPackage/$openCypherPackage/g" > "$sourceFile.temp"
					
					# add open cypher license
					echo $openCypherLicense > "$sourceFile"
					
					# copy in rest of code, but omitting any previous license
					sed -n '/package /,$p' "$sourceFile.temp" >> "$sourceFile"
					rm "$sourceFile.temp"
				done
			fi
		done
	done
done
