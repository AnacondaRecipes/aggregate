from os.path import (expanduser)
from os import (environ)
import argparse
import platform
import re
from subprocess import Popen, PIPE
import sys

sel_pat = re.compile(r'(.+?)\s*(#.*)?\[([^\[\]]+)\](?(2)[^\(\)]*)$')

# We evaluate the selector and return True (keep this line) or False (drop this line)
# If we encounter a NameError (unknown variable in selector), then we replace it by False and
#     re-run the evaluation
def eval_selector(selector_string, namespace, variants_in_place):
    try:
        # TODO: is there a way to do this without eval?  Eval allows arbitrary
        #    code execution.
        return eval(selector_string, namespace, {})
    except NameError as e:
        missing_var = parseNameNotFound(e)
        if variants_in_place:
            log = utils.get_logger(__name__)
            log.debug("Treating unknown selector \'" + missing_var +
                      "\' as if it was False.")
        next_string = selector_string.replace(missing_var, "False")
        return eval_selector(next_string, namespace, variants_in_place)


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
        for index, line in enumerate(f.readlines()):
            line = line.replace('\n', '')
            # Taken from conda-build's metadata.py
            if line.lstrip().startswith('#'):
                # Don't bother with comment only lines
                continue
            m = sel_pat.match(line)
            if m:
                cond = m.group(3)
                namespace = {'ppc': True if platform.processor() == 'ppc64le' else False}
                try:
                    if eval_selector(cond, namespace, True):
                        line = m.group(1)
                    else:
                        continue
                except Exception as e:
                    sys.exit('''\
Error: Invalid selector in %s line %d:
offending line:
%s
exception:
%s
''' % (args.package_list_file, index + 1, line, str(e)))

            if args.packages and line in args.packages:
                order.append(line)
            elif args.start_at:
#                print(line)
                if line == args.start_at:
                    seen_start_at = True
                if seen_start_at:
                    order.append(line)
            else:
                order.append(line)
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
