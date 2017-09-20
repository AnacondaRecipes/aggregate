import sys
import re

# Reads from stdin line by line, writes to stdout line by line. The patch
# header lines are given LF line endings and the rest CRLF line endings.
# Does not currently deal with the prelude (up to the -- in git patches).

# replacing each line ending in '^M$' with CRLF and each line ending in
# '$' with LF.

def main():
    lines = []
    for line in iter(sys.stdin.readline, ''):
        line = line.strip('\n').strip('\r\n')
        lines.append(line)
    is_git_diff = False
    for line in lines:
        if line.startswith('diff --git'):
            is_git_diff = True
    in_real_patch = False if is_git_diff else True
    for line in lines:
        if not in_real_patch:
            sys.stdout.write(line + '\n')
            if line.startswith('diff --git'):
                in_real_patch = True
        else:
            if line.startswith('diff ') or line.startswith('diff --git') or line.startswith('--- ') or line.startswith('+++ ') or line.startswith('@@ ') or line.startswith('index '):
                sys.stdout.write(line + '\n')
            else:
                sys.stdout.write(line + '\r\n')

if __name__ == '__main__':
    main()
