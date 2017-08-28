import os
import shutil
import subprocess
import sys


MAGIC = {
    b'\xca\xfe\xba\xbe': 'MachO-universal',
    b'\xce\xfa\xed\xfe': 'MachO-i386',
    b'\xcf\xfa\xed\xfe': 'MachO-x86_64',
    b'\xfe\xed\xfa\xce': 'MachO-ppc',
    b'\xfe\xed\xfa\xcf': 'MachO-ppc64',
}


def get_arch(path):
    with open(path, 'rb') as fi:
        head = fi.read(4)
    try:
        return MAGIC[head][6:]
    except KeyError:
        return None


def cp_arch(src_path, dst_path, arch='x86_64', ignore_wrong_arch=False):
    src_arch = get_arch(src_path)
    if src_arch == arch:
        shutil.copy2(src_path, dst_path)
    elif src_arch == 'universal':
        subprocess.check_call(['lipo', '-thin', arch,
                               '-output', dst_path, src_path])
    else:
        msg = "MachO type %r: %s" % (src_arch, src_path)
        if ignore_wrong_arch:
            sys.stdout.write('WARNING: ignoring %s\n' % msg)
            shutil.copy2(src_path, dst_path)
        else:
            sys.exit('ERROR: %s' % msg)


def main_cp_arch():
    from optparse import OptionParser

    p = OptionParser(usage="usage: %prog [options] SRC [SRC ...] DST_DIR",
                     description="""\
Copy MachO binaries from SRC to DST_DIR, and use lipo to "thin" binaries (if
necessary), such that all binaries in DST_DIR are thin binaries of ARCH.""")

    p.add_option("--arch",
                 action="store",
                 default="x86_64",
                 help="target architecture, defaults to %default")

    p.add_option("--ignore-wrong-arch",
                 action="store_true",
                 help="ignore non-universal binaries of wrong ARCH")

    opts, args = p.parse_args()

    if len(args) < 2:
        p.error('two or more arguments expected, try -h')

    src_paths, dst_dir = args[:-1], args[-1]
    if not os.path.isdir(dst_dir):
        p.error('no such directory: %s' % dst_dir)

    for src_path in src_paths:
        cp_arch(src_path, os.path.join(dst_dir, os.path.basename(src_path)),
                arch=opts.arch, ignore_wrong_arch=opts.ignore_wrong_arch)


if __name__ == '__main__':
    main_cp_arch()
