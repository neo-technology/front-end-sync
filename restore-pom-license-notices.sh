#!/bin/bash

for path in .gitignore .travis.yml NOTICE.txt **/NOTICE.txt LICENSES.txt **/LICENSES.txt LICENSE.txt **/LICENSE.txt pom.xml */pom.xml build ; do
    git checkout -q $OPENCYPHER_COMMIT -- $path 2>/dev/null
done
exit 0 # in case the last "git checkout" failed, override its status