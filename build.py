from os.path import (expanduser)
from os import (environ)
import argparse
from subprocess import Popen, PIPE
import sys

def main():
    parser = argparse.ArgumentParser(description='Build a list of packages identified in a file (one line per recipe folder name)')
    parser.add_argument('--start-at', '-s', default=None)
    parser.add_argument('--package-list-file', '-f', default=None)
    parser.add_argument('--packages', '-p', nargs='*', default=None)
    parser.add_argument('--log-file', '-l', default='/tmp/conda-build.log')
    # Passed directly to conda-build.
    parser.add_argument('cb-args', nargs=argparse.REMAINDER)
    args, unknown = parser.parse_known_args()
    print(args)
    print(unknown)
    order = []
    print(args.packages)
    print(args.start_at)
    seen_start_at = False
    with open(expanduser(args.package_list_file), 'rt') as f:
        for l in f.readlines():
            l = l.replace('\n', '')
            if args.packages and l in args.packages:
                order.append(l)
            elif args.start_at:
#                print(l)
                if l == args.start_at:
                    seen_start_at = True
                if seen_start_at:
                    order.append(l)
            else:
                order.append(l)
    cb_full_args = ['conda-build']
    cb_full_args.extend(order)
    cb_full_args.extend(unknown)
    environ["PYTHONUNBUFFERED"] = "1"
    print("Running:\n{}".format(cb_full_args))
    with open(args.log_file, "w") as log_file:
        proc = Popen(cb_full_args, stdin=None, stdout=PIPE, stderr=PIPE)
        cont = True
        while cont:
            cont = False
            while True:
                line = proc.stdout.readline()
                if line and not line == b"":
                    out = line.decode("utf-8").rstrip()
                    log_file.write(out)
                    print("out: {}".format(out))
                    cont = True
                else:
                    break

            while True:
                line = proc.stderr.readline()
                if line and not line == b"":
                    out = line.decode("utf-8").rstrip()
                    log_file.write(out)
                    print("err: {}".format(out))
                    cont = True
                else:
                    break

            if not cont and proc.poll() is not None:
                break
            rc = proc.returncode

if __name__ == '__main__':
    main()
