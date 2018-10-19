import sys
import random
import struct
import argparse
import string

parser = argparse.ArgumentParser()
parser.add_argument('input', nargs='?', type=argparse.FileType('r'), 
        default=sys.stdin,
        help='input file. defaults to stdin')
parser.add_argument('-o', '--output', type=argparse.FileType('w'), 
        default=sys.stdout, action='store',
        help='output filename. defaults to stdout')
parser.add_argument('-n', action='store', type=int, default=1000000,
        help='''average good bits per error. 
                defaults to 1000000 (10e-6 bit error rate)''')
parser.add_argument('-t', '--truncate', action='store', 
        type=int, default=None,
        help='truncate file after T bytes')
parser.add_argument('-g', '--garbage', action='store', type=int, default=0,
        help='add G bytes of garbage at the end of the file')
parser.add_argument('-a', '--ascii', action='store_true',
        help='assume ASCII input and enforce ASCII output')
args = parser.parse_args()

CHUNK = 4096
cstart = 0
cend = 0
nextn = random.randint(0,args.n)
data = args.input.read(CHUNK)
while len(data) > 0:
    cend = cstart + len(data)
    while cend > nextn/8:
        k = nextn - cstart * 8
        if args.ascii:
            b = random.choice(string.printable)
        else:
            b = chr(ord(data[k//8]) ^ (1 << (k % 8)))
        data = ''.join([data[:k//8], b, data[k//8+1:]])
        nextn += random.randint(0,2*args.n)
    cstart = cend
    if args.truncate is not None and cend > args.truncate:
        args.output.write(data[:args.truncate - cstart])
        break
    args.output.write(data)
    data = args.input.read(CHUNK)

random.seed()
garbage = args.garbage
while garbage > 0:
    if args.ascii:
        b = random.choice(string.printable)
    else:
        b = chr(random.randint(0, 255))
    args.output.write(b)
    garbage -= 1

args.output.close()
