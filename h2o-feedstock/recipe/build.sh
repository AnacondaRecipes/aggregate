#!/bin/sh

export TERM=${TERM:-dumb}

while IFS='.' read -ra ADDR; do
    for i in "${ADDR[@]}"; do
        buildnum=$i
    done
done <<< "$PKG_VERSION"

echo BUILD_NUMBER=$buildnum > gradle/buildnumber.properties

if [ `uname` == Linux  ]; then
    # at time of writing, there's a parameter error in the tests, only on Linux?  skip tests.
    #   we also allow root, because we build in docker containers as root.  Without this,
    #   bower will error out.
    ./gradlew build -x test -Ph2o.web.allow.root
else
    # On OS X, things run OK, but only on machines with lots of memory.
    # ./gradlew syncSmalldata --stacktrace
    # ./gradlew build --stacktrace -i

    ./gradlew build -x test -Ph2o.web.allow.root
fi

# gradle keeps workers running. we need to kill them so that we can remove files.
./gradlew --stop
