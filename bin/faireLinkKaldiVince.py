#!/usr/bin/env python
from __future__ import print_function
import fileinput, re, sys, os
# Compatiblity with python3 print() style

kaldi_lattice_rep = sys.argv[1]
sphinx_latp2_rep = sys.argv[2]

if not os.path.isdir(sphinx_latp2_rep):
    os.makedirs(sphinx_latp2_rep)

# Number of frames we want to check for roundind problems
max_diff = 5

for line in sys.stdin:
    # Parse input line (.pseudo format)
    parts = line.rstrip().split(' ')
    show = parts[0]
    start = int(float(parts[2])*100)
    end = int(float(parts[3])*100)
    loc_match = re.match(r'^.*_(.)-S(\d+)', parts[4])
    gender = loc_match.group(1)
    number = int(loc_match.group(2))

    if(start < 0):
        start = 0

    # We will check 5 frame before and after each time
    for start_shift in range(start - max_diff, start + max_diff):
        for end_shift in range(end - max_diff, end + max_diff):

            kaldi_file = "{}/{}#{}{:07d}#{:07d}:{:07d}#{}.lat.gz".format(kaldi_lattice_rep, show, gender, number, start_shift, end_shift, gender)
            kaldi_file_escaped = kaldi_file.replace('#', '\\#')

            kaldi_file_antho = "{}/S{}{:07d}#{}#{:07d}:{:07d}#{}.lat.gz".format(kaldi_lattice_rep, gender, number, show, start_shift, end_shift, gender)
            kaldi_file_antho_escaped = kaldi_file_antho.replace('#', '\\#')

            if(os.path.isfile(kaldi_file)):
                sphinx_file = "{}/{}-{}-{}-{}.lat.gz".format(sphinx_latp2_rep, show, parts[2], parts[3], parts[4])
                print("ln -s {} {}".format(kaldi_file_escaped, sphinx_file))

            if(os.path.isfile(kaldi_file_antho)):
                sphinx_file = "{}/{}-{}-{}-{}.lat.gz".format(sphinx_latp2_rep, show, parts[2], parts[3], parts[4])
                print("ln -s {} {}".format(kaldi_file_antho_escaped, sphinx_file))
