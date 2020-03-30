#!/bin/bash

# INTERNALS
OPENCYPHER_DIR="org/opencypher/v9_0"
OPENCYPHER_PACKAGE=`echo $OPENCYPHER_DIR | sed "s|/|.|g"`
NEO4J_DIR_PREFIX="org/neo4j/cypher/internal"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
OPENCYPHER_LICENSE="$DIR/opencypher-license.txt"

# Go through all relevant folders
for d in ast expressions frontend parser rewriting util cypher-macros; do
	for use in main test; do
		for lang in java scala; do
			sourceDir="$d/src/$use/$lang"
			if [ -d $sourceDir ]; then
                neo4jDir="$NEO4J_DIR_PREFIX"
                neo4jPackage=`echo $neo4jDir | sed "s|/|.|g"`
                if [ -d $sourceDir/$neo4jDir ]; then
                    # Move the files to the right place
                    mkdir -p "$sourceDir/$OPENCYPHER_DIR"
                    rm -r "$sourceDir/$OPENCYPHER_DIR"
                    mv "$sourceDir/$neo4jDir" "$sourceDir/$OPENCYPHER_DIR"

                    # For all .java/.scala files:
                    for sourceFile in `find "$sourceDir/$OPENCYPHER_DIR" -type f -name "*.$lang"`; do
                        # change to open cypher packages
                        cat "$sourceFile" | sed "s/$neo4jPackage/$OPENCYPHER_PACKAGE/g" > "$sourceFile.temp"

                        # add open cypher license
                        cat $OPENCYPHER_LICENSE > "$sourceFile"

                        # copy in rest of code, but omitting any previous license
                        sed -n '/package /,$p' "$sourceFile.temp" >> "$sourceFile"
                        rm "$sourceFile.temp"
                    done
                fi
			fi
		done
	done
done
