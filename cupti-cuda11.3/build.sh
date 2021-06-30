set -ex

RUNFILE="cuda_11.3.1_465.19.01_linux.run"
EMBEDDED_RUNFILE="cuda_11.3.1_465.19.01_linux.run"
TMPDIR="${SRC_DIR}/unpacked"
RUNDIR="${SRC_DIR}/rundir"

# unpack the embedded runfiles
chmod +x ${RUNFILE}
mkdir -p ${RUNDIR}
./$RUNFILE --extract=$RUNDIR --nox11 --silent

# unpack the runfile
mkdir -p ${TMPDIR}
$RUNDIR/$EMBEDDED_RUNFILE -prefix=$TMPDIR -noprompt --nox11

# copy library to prefix
mkdir -p $PREFIX/lib
cp unpacked/extras/CUPTI/lib64/* $PREFIX/lib/

# create symlinks
cd $PREFIX/lib
