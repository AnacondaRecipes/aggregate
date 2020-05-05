#!/usr/bin/env python

import glob
import logging
import os
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
from re import match

log = logging.getLogger(__name__)

"""
NAME
       git-format-patch-le - Prepare patches for e-mail submission, retaining
                             line-endings in the patch blocks.

SYNOPSIS
       git format-patch-le [-k] [(-o|--output-directory) <dir> | --stdout]
                          [--no-thread | --thread[=<style>]]
                          [(--attach|--inline)[=<boundary>] | --no-attach]
                          [-s | --signoff]
                          [--signature=<signature> | --no-signature]
                          [--signature-file=<file>]
                          [-n | --numbered | -N | --no-numbered]
                          [--start-number <n>] [--numbered-files]
                          [--in-reply-to=Message-Id] [--suffix=.<sfx>]
                          [--ignore-if-in-upstream]
                          [--rfc] [--subject-prefix=Subject-Prefix]
                          [(--reroll-count|-v) <n>]
                          [--to=<email>] [--cc=<email>]
                          [--[no-]cover-letter] [--quiet]
                          [--no-notes | --notes[=<ref>]]
                          [--interdiff=<previous>]
                          [--range-diff=<previous> [--creation-factor=<percent>]]
                          [--progress]
                          [<common diff options>]
                          [ <since> | <revision range> ]
"""

debug = True

rev_list_complete = None
def get_rev_list(from_sha1=None):
    '''
    This is so slow when from_sha1==None since we get the whole lot! In that case we cache it.
    '''

    res = None
    if not from_sha1:
        global rev_list_complete
        if rev_list_complete:
            return rev_list_complete
        rev_list_complete = subprocess.check_output(['git', 'rev-list', '--all']).decode('utf-8').splitlines()
        res = rev_list_complete
    else:
        res = subprocess.check_output(['git', 'rev-list', '--max-count', '2', from_sha1]).decode('utf-8').splitlines()
    return res


def check_blob_in_rev(rev, blob):
    '''

    :param rev_list:
    :param blob:
    :return: Tuple of filename, omode, type, sha
    '''
    shas = subprocess.check_output(['git', 'ls-tree', '-r', rev]).decode('utf-8').splitlines()
    matching_shas = [sha for sha in shas if blob in sha]
    if matching_shas:
        rest, fname = matching_shas[0].split('\t')
        return tuple((fname, *rest.split(' ')))
    return None, None, None, None


def main(argv):
    
    global debug

    # Some things we must set to sensible defaults and also check for
    # in the command-line arguments to `git format-patch`.
    output_dir = os.getcwd()
    suffix = '.patch'
    src_prefix = 'a/'
    dst_prefix = 'b/'

    input_args = sys.argv[1:]

    # Some constants you should never change.
    git_diff = 'diff --git '
    git_index = 'index '

    def get_last_option_with_possible_value(args, option_prefixes, default=None):
        '''

        :param args:
        :param option_prefixes:
        :param default:
        :return: tuple of (found_option, found_option_value, Value (or default))
        '''
        result = [(a, i) for i, a in enumerate(args) if a.startswith(option_prefixes)]
        if result:
            value, index = result[-1]
            try:
                if '=' in value:
                    return True, True, value.rsplit('=', 1)[1]
                else:
                    return True, True, args[index+1]
            except:
                pass
            return True, False, default
        return False, False, default

    _, _, output_dir = get_last_option_with_possible_value(input_args,
                                                     ('-o', '--output-directory'), default=output_dir)
    _, _, suffix = get_last_option_with_possible_value(input_args,
                                                 ('--suffix'), default=suffix)
    _, _, src_prefix = get_last_option_with_possible_value(input_args,
                                                     ('--src-prefix'), default=src_prefix)
    _, _, dst_prefix = get_last_option_with_possible_value(input_args,
                                                     ('--src-prefix'), default=dst_prefix)
    no_prefix, _, _ = get_last_option_with_possible_value(input_args,
                                                     ('--no-prefix'), default=False)
    if no_prefix:
        src_prefix = ''
        dst_prefix = ''

    repo_root = os.getcwd()
    try:
        repo_root = subprocess.check_output(['git', 'rev-parse', '--show-toplevel']).decode('utf-8').splitlines()[0]
        if sys.platform == 'win32' and not os.path.exists(repo_root):
            # Untested!
            repo_root = subprocess.check_output(['cygpath', '-w', repo_root]).decode('utf-8').splitlines()[0]
        if not os.path.exists(repo_root):
            log.error("repo_root {} does not exist?".format(repo_root))
            sys.exit(1)
    except:
        log.error("git rev-parse --show-toplevel failed. Is this a git repository?")
        sys.exit(1)

    '''
       --src-prefix=<prefix>
           Show the given source prefix instead of "a/".

       --dst-prefix=<prefix>
           Show the given destination prefix instead of "b/".

       --no-prefix
           Do not show any source or destination prefix.
    '''

    def get_files(output_dir, suffix):
        res = {}
        for filename in sorted(glob.iglob('{output_dir}/*{suffix}'.format(output_dir=output_dir,
                                                                          suffix=suffix), recursive=True)):
            res[filename] = {'stat': os.stat(filename)}
        return res
    files_old = get_files(output_dir, suffix)
    git_args = ['git', 'format-patch'] + sys.argv[1:]
    try:
        git_result = subprocess.check_call(git_args)
    except Exception as e:
        log.error("subprocess.check_call({}) failed".format(git_args))
        raise e
    files_new = get_files(output_dir, suffix)
    all_modified = []
    for file in files_new:
        if file in files_old:
            if files_new[file]['stat'] != files_old[file]['stat']:
                if debug:
                    print('{} was modified'.format(file))
                all_modified.append(file)
        else:
            if debug:
                print('{} was created'.format(file))
            all_modified.append(file)

    for file in all_modified:
        lines = []
        print("Fixing CRLF/LF in file: {}".format(file))
        with open(file, 'rb') as fi:
            try:
                for line in fi:
                    line = line.decode('utf-8')
                    lines.append(line)
            except Exception as e:
                pass
            is_git_diff = False
            for line in lines:
                if line.startswith(git_diff):
                    is_git_diff = True
            in_real_patch_state = False if is_git_diff else True
        if debug:
            print("git format-patch made the following {}".format(file))
            print('\n'.join([l.replace('\r\n', '\\r\\n').replace('\n', '\\n') for l in lines]))
        with open(file+'.tmp', 'wb') as fo:

            # Try to get the from_sha1 from the first line of the patch. This speeds up other
            # queries to git.
            line = lines[0]
            import re
            from_sha1 = None
            try:
                matcha = re.match(r'^From ([0-9a-f]{40,40}) .*', line, re.MULTILINE)
                from_sha1 = matcha.group(1)
            except:
                pass
            rev_list = get_rev_list(from_sha1)
            fo.write(line.encode('utf-8'))
            in_real_patch_state = None
            for line in lines[1:]:
                line = line.replace('\n', '')
                if line.startswith(git_diff):
                    fo.write((line + '\n').encode('utf-8'))
                    if line.startswith(git_diff):
                        in_real_patch_state = 'first'
                        line2 = line[len(git_diff):]
                        if line2.count(' ') == 1:
                            patched_files = shlex.split(line2, posix=True)
                        else:
                            # Horrible. Find the space closest to the centre and split there.
                            midspacen = (line2.count(' ')+1)//2
                            midspacei = -1
                            for i in range(0, midspacen):
                                midspacei = line2.find(' ', midspacei + 1)
                            patched_files = [line2[0:midspacei], line2[midspacei+1:]]
                        patched_src_file = patched_files[0]
                        patched_dst_file = patched_files[1]
                        assert patched_src_file.startswith(src_prefix)
                        assert patched_dst_file.startswith(dst_prefix)
                        patched_src_file = patched_src_file[len(src_prefix):]
                        patched_dst_file = patched_dst_file[len(dst_prefix):]
                        assert patched_src_file == patched_dst_file, \
                            "Expected source {} to match dest {}, maybe git mv was involved?".format(patched_src_file, patched_dst_file)
                else:
                    if line.startswith(git_index):
                        in_real_patch_state = 'index'
                        shas_and_omode = line[len(git_index):].split()
                        shas = shas_and_omode[0].split('..')
                        if debug:
                            print(patched_src_file, shas)
                        src_file_rl, src_omode, src_type, src_sha1 = check_blob_in_rev(rev_list[1], shas[0])
                        dst_file_rl, dst_omode, dst_type, dst_sha1 = check_blob_in_rev(rev_list[0], shas[1])
                        if shas[0] != '0000000000':
                            assert src_file_rl == patched_src_file
                        if shas[1] != '0000000000':
                            assert dst_file_rl == patched_dst_file

                        # Without `--filters` newlines will be incorrect here, the values in .gitattributes
                        # are basically ignored.
                        if src_file_rl:
                            lines_src = subprocess.check_output(['git', 'cat-file', '--filters', '{}:{}'.format(rev_list[1], src_file_rl)]).decode('utf-8').split('\n')
                        else:
                            lines_src = []
                        if dst_file_rl:
                            lines_dst = subprocess.check_output(['git', 'cat-file', '--filters', '{}:{}'.format(rev_list[0], dst_file_rl)]).decode('utf-8').split('\n')
                        else:
                            lines_dst = []
                        crlf_lines_src = set([index for index, content in enumerate(lines_src) if content.endswith('\r')])
                        crlf_lines_dst = set([index for index, content in enumerate(lines_dst) if content.endswith('\r')])
                    elif line.startswith('@@ '):
                        in_real_patch_state = 'blocks'
                        markers = line[3:].split(' ')[:2]
                        if lines_src and markers[0] != '-1':
                            block_src_start = int(markers[0].split(',')[0])
                            block_src_len = int(markers[0].split(',')[1])
                        else:
                            block_src_start = -1
                            block_src_len = 0  # Represents a file that does not exist.
                        if lines_dst and markers[1] != '+1':
                            block_dst_start = int(markers[1].split(',')[0])
                            block_dst_len = int(markers[1].split(',')[1])
                        else:
                            block_dst_start = -1
                            block_dst_len = -1  # Represents an entire file that does exist.
                    if (line.startswith('diff ') or
                        line.startswith('diff --git') or
                        line.startswith('--- ') or 
                        line.startswith('+++ ') or
                        line.startswith('@@ ') or
                        line.startswith('index ') or
                        line.startswith('new file mode ') or
                        line.startswith('delete mode ')):
                        fo.write((line + '\n').encode('utf-8'))
                    else:
                        # This is wrong, it allows a file to be entirely CRLF or LF only, but for now that'll do as I've
                        # spend too long on this. We need to be keeping track of what line we are at in src and dst and
                        # look up what the ending should be for each.. It's fairly simple but well, for another day.
                        if in_real_patch_state == 'blocks':
                            if len(crlf_lines_src) or len(crlf_lines_dst):
                                fo.write((line + '\r\n').encode('utf-8'))
                            else:
                                fo.write((line + '\n').encode('utf-8'))
                        else:
                            fo.write((line + '\n').encode('utf-8'))
        os.unlink(file)
        shutil.move(file+'.tmp', file)


if __name__ == '__main__':
    main(sys.argv)
