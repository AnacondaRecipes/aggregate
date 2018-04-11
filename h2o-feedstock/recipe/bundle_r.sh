
# This file hasn't been tested yet.  It might work, but needs someone with more R experience to make sure.

mkdir -p ${SRC_DIR}/Rlibrary
export R_LIBS_USER=${SRC_DIR}/Rlibrary

# ./gradlew syncRPackages --stacktrace

# Monkeypatch R's Makeconfig for the sake of making kernlab work
R_EXTRA_CPPFLAGS=$(grep -Poh "(?<=R_XTRA_CPPFLAGS = )[\ \$\(\)_\-A-Za-z0-9]+" "$PREFIX/lib/R/etc/Makeconf")
sed -i "s/$R_EXTRA_CPPFLAGS/$R_EXTRA_CPPFLAGS -DDO_NOT_USE_CXX_HEADERS/" "$PREFIX/lib/R/etc/Makeconf"

cd h2o-r
H2O_BUILD_R=true ../gradlew -PdoR -Ph2o.web.allow.root build


# gradle keeps workers running. we need to kill them so that we can remove files.
../gradlew --stop
