#!/usr/bin/env python
# -*- coding: utf-8 -*-
#=======================================================================
#
# fltbwt.py
# ---------
# Burrows-Wheeler Transform encoder and decoder that consumes
# in the order of 2*n memory where n is the size of the block.
# Supports several different input and output formats.
#
# 
# Copyright (c) 2011- Secworks Sweden AB
# Author: Joachim Strombergson
#
# Redistribution and use in source and binary forms, with or
# without modification, are permitted provided that the following
# conditions are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in
#    the documentation and/or other materials provided with the
#    distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#=======================================================================

#-------------------------------------------------------------------
# Python module imports.
#-------------------------------------------------------------------
import sys
import argparse
import random


#-------------------------------------------------------------------
# def printblock(listarray)
#
# Helper function. Prints a block of strings given as an array.
#-------------------------------------------------------------------
def printblock(listarray):
    for string in listarray:
        print string


#-------------------------------------------------------------------
# get_rotstring(my_string, index)
#
# Get the rotational string for the given index.
# Note: Index must be 
#-------------------------------------------------------------------
def get_rotstring(my_string, index):
    i = index % len(my_string)
    return my_string[i:] + my_string[0:i]


#-------------------------------------------------------------------
# qsort_rotstring(my_string, my_ptrs)
#
# Given a string of size n and a list of n pointers returns a list
# of pointers pointing to rotated versions of the string in
# ascending order.
#-------------------------------------------------------------------
def qsort_rotstring(my_string, my_ptrs, debug = False):
    if debug:
        print "Length of pointers: %d" % len(my_ptrs)

    if len(my_ptrs) <= 1:
        return my_ptrs

    elif len(my_ptrs) == 2:
        l_str = get_rotstring(my_string, my_ptrs[0])
        r_str = get_rotstring(my_string, my_ptrs[1])
        if l_str < r_str:
            return my_ptrs
        else:
            return [my_ptrs[1], my_ptrs[0]]
            
    else:
        # Get pivot pointer and associated string.
        pivot_ptr = my_ptrs[int(len(my_ptrs) / 2)]
        pivot_str = get_rotstring(my_string, pivot_ptr)
        if debug:
            print "Pivot pointer selected: %d" % pivot_ptr

        lt_ptr = []
        gt_ptr = []

        for i in range(int(len(my_ptrs) / 2)):
            i_str = get_rotstring(my_string, my_ptrs[i])
            if debug:
                print (i, my_ptrs[i], i_str)

            if i_str < pivot_str:
                lt_ptr.append(my_ptrs[i])
            else:
                gt_ptr.append(my_ptrs[i])

        for i in range((len(my_ptrs) / 2) + 1 , len(my_ptrs)):
            i_str = get_rotstring(my_string, my_ptrs[i])
            if debug:
                print (i, my_ptrs[i], i_str)

            if i_str < pivot_str:
                lt_ptr.append(my_ptrs[i])
            else:
                gt_ptr.append(my_ptrs[i])

        if debug:
            print lt_ptr
            print gt_ptr

        sorted_lt_ptr = qsort_rotstring(my_string, lt_ptr, debug)
        sorted_gt_ptr = qsort_rotstring(my_string, gt_ptr, debug)

    return sorted_lt_ptr + [pivot_ptr] + sorted_gt_ptr


#-------------------------------------------------------------------
# def bw_encode(my_string)
#
# Returns a tuple with the Burrows-Wheeler encoded version of
# the given string and the index of the original string in the
# block array.
#-------------------------------------------------------------------
def bw_encode(my_string, block_size = 65536, debug = False):
    # Get list of rows sorted alpphabetically.
    str_ptrs = [x for x in range(len(my_string))]
    sort_list = qsort_rotstring(my_string, str_ptrs, debug=False)
    if debug:
        for i in range(len(sort_list)):
            print (i, get_rotstring(my_string, sort_list[i]))

    # Create suffix coloumn string.
    suffix_string = ""
    for i in range(len(sort_list)):
        ch_ptr = (sort_list[i] + len(my_string) - 1) % len(my_string)
        suffix_string += my_string[ch_ptr]
    if debug:
        print suffix_string

    # Find which row contains the original row.
    string_index = 0
    while sort_list[string_index] != 0:
        string_index += 1
    if debug:
        print string_index
    
    return (string_index, suffix_string)


#-------------------------------------------------------------------
# bw_decode(my_bw)
#
# Given a tuple with the BW-encoded version of a string and
# index of the original string in the block array returns
# the decoded string.
#
# Note: Assumes that the string contains bytes.
#-------------------------------------------------------------------
def bw_decode(my_bw, debug = False):
    (string_index, suffix_string) = my_bw
    
    # Create suffix rank and char pointer tables.
    suffix_rank = [0] * len(suffix_string)
    char_rank = [0] * 256
    char_ptr = [0] * 256
    for i in range(len(suffix_string)):
        ch = ord(suffix_string[i])
        suffix_rank[i] = char_rank[ch]
        char_rank[ch] += 1

    for i in range(1, len(char_ptr)):
        char_ptr[i] += char_ptr[(i - 1)] + char_rank[(i - 1)]

    decoded_string = ""
    row = string_index
    for i in range(len(suffix_string)):
        ch = suffix_string[row]
        decoded_string = ch + decoded_string
        ch_rank = suffix_rank[row]
        row = char_ptr[ord(ch)] + ch_rank
        
    return decoded_string


#-------------------------------------------------------------------
# test_transform()
#
# Tests the implementation by encoding a randomly generated
# string, decode the string and check that the original
# string was recreated.
#-------------------------------------------------------------------
def test_transform(block_size = 16384, debug=False):
    if debug:
        print "Generating a string of %d bytes." % block_size
        print
        
    original_string =""
    for n in xrange(block_size):
        original_string += chr(random.randrange(0,256))

    (enc_index, enc_string) = bw_encode(original_string, block_size)

    if debug:
        print "Original string at index %d." % enc_index
        print

    recreated_string = bw_decode((enc_index, enc_string))

    if recreated_string == original_string:
        print "Test successful. String recreated."
    else:
        print "Test NOT successful. String mismatch!"



#-------------------------------------------------------------------
#-------------------------------------------------------------------
def encode_data():
    pass


#-------------------------------------------------------------------
#-------------------------------------------------------------------
def decode_data():


#-------------------------------------------------------------------
#-------------------------------------------------------------------
def save_data():
    pass


#-------------------------------------------------------------------
# load_data()
#
# Load data into an internal structure. The data is loaded either
# from std in or from a file based on the given name. The function
# supports raw, json and a compact 'c64' format.
#
# Note that json and c64 format implies that the data has
# previously been transformed.
#-------------------------------------------------------------------
def load_data(format='raw', name=None):
    return {}
    
    
#-------------------------------------------------------------------
# main()
#
# Parse arguments.
#-------------------------------------------------------------------
def main():
    VERSION = "FLTBWT 0.5 Alpha. Use with caution."
    
    parser = argparse.ArgumentParser(
        description='fltbwt provides Burrows-Wheeler transform \
        for strings of bytes.')

    parser.add_argument("-a", "--action", action="store",
                        dest="action", default=None,
                        help="Action to be performed. Supported \
                        commands are \'e\', \'enc\' or \'encode\' for \
                        encoding and \'d\', \'dec\' or \'decode\' for decode \
                        operations.")

    parser.add_argument("-b", action="store", type=int, dest="block_size",
                        default=65536, help="The Burrows-Wheeler block \
                        size in bytes. Default is 65536 bytes.")

    parser.add_argument("-i", action="store", dest="input_filename",
                        default=None, help="The input file name. \
                        If no file is given data will be read from std in.")

    parser.add_argument("-if", action="store", dest="input_format",
                        default='raw', help="The input data format. \
                        Supported formats are \'raw\', \'c64\' and \'json\' .\
                        Default format is \'raw\'. Note that \'c64\' format \
                        implies a length of less than 65536 bytes and a block \
                        size of 65536 bytes.}.")

    parser.add_argument("-o", action="store", dest="output_filename",
                        default=None, help="The output file name. \
                        If no file is given data will be written to std out.")

    parser.add_argument("-of", action="store", dest="output_format",
                        default='raw', help="The output data format. \
                        Supported formats are \'raw\', \'c64\' and \'json\' .\
                        Default format is \'raw\'. Note that \'c64\' format \
                        implies a length of less than 65536 bytes and a block \
                        size of 65536 bytes.")

    parser.add_argument("-t", "--test_mode", action="store_true",
                        dest="test", help="Test mode. Performs encode and \
                        decode of a randomly generated string.")

    parser.add_argument("-v", "--verbose", action="store_true",
                        dest="verbose", help="Verbose output during processing.")

    parser.add_argument("-V", "--version", action="store_true",
                        dest="version", help="Print version number and quit.")

    args = parser.parse_args()

    # Check commands and flags and perform required actions.
    # First some sanity checks and simple commands.
    if args.version:
        print VERSION
        return

    if args.test:
        test_transform(args.block_size, args.verbose)
        return

    # Main processing. Load, perform action and store.
    


#-------------------------------------------------------------------
# __name__
# Python thingy which allows the file to be run standalone as
# well as parsed from within a Python interpreter.
#-------------------------------------------------------------------
if __name__=="__main__": 
    # Run the main function.
    sys.exit(main())

#=======================================================================
# EOF fltbwt.py
#=======================================================================
