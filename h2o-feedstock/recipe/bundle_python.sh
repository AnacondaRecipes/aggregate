cd h2o-py
# patch current version into
H2O_BUILD_PY=true ../gradlew -PdoPython -Ph2o.web.allow.root build

# gradle keeps workers running. we need to kill them so that we can remove files.
../gradlew --stop
