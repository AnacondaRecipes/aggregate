import sys
import re
import tempfile
import shutil


# Reads from argv[1] line-by-line, writes to same file. The patch
# header lines are given LF line endings and the rest CRLF line endings.
# Does not currently deal with the prelude (up to the -- in git patches).


def main(argv):
    file = argv[1]
    lines = []
    with open(file, 'rb') as fi:
        try:
            for line in fi:
                print(line)
                line = line.decode('utf-8').strip('\n').strip('\r\n')
                lines.append(line)
        except:
            pass
        is_git_diff = False
        for line in lines:
            if line.startswith('diff --git'):
                is_git_diff = True
        in_real_patch = False if is_git_diff else True
    print(lines)
    with open(file, 'wb') as fo:
        for line in lines:
            if not in_real_patch:
                fo.write((line + '\n').encode('utf-8'))
                if line.startswith('diff --git'):
                    in_real_patch = True
            else:
                if line.startswith('diff ') or line.startswith('diff --git') or line.startswith('--- ') or line.startswith('+++ ') or line.startswith('@@ ') or line.startswith('index '):
                    fo.write((line + '\n').encode('utf-8'))
                else:
                    fo.write((line + '\r\n').encode('utf-8'))


if __name__ == '__main__':
    main(sys.argv)
