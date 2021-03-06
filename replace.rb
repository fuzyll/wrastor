#!/usr/bin/env ruby

##
# replace.rb | Wrastor Replace Utility
#
# Copyright (c) 2017 Alexander Taylor <ajtaylor@fuzyll.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
##

# get the old GameMaker archive's file size
size = File.size?("data.win")

# read in the new GameMaker archive
archive = nil
open("new.win", "rb") do |file|
    archive = file.read()
end

# abort if we're larger than the original
# TODO: there's probably a way to make this work - I just haven't had time to figure out what's going on yet
if archive.length() > size
    abort "[!] Currently only support having less data than the original file size"
end

# pad the new archive out to the old length if we're smaller than the original
# TODO: not sure why this appears to be necessary - need to take some time to look into it
if archive.length() < size
    archive += "\x00"*(size - archive.length())
end

# replace the one in the existing executable with our new one
exe = nil
open("RivalsofAether.exe", "rb") do |file|
    # FIXME: reading in the entire file here is not the most elegant solution...
    data = file.read()
    filesize = data.length()

    # look for the "FORM" magic header
    found = nil
    matches = data.enum_for(:scan, /FORM/).map { Regexp.last_match.begin(0) }
    matches.each() do |i|
        # ignore anything that isn't simply "FORM"
        if not data[i..i+7].include?("FORMAT")
            size = data[i+4..i+7].unpack("I<")[0]
            # ignore anything that has a size we think would be too large or too small
            if i+size < filesize and size > 0x100000
                found = i
            end
        end
    end

    # abort if we couldn't locate the archive in the input file
    if found == nil
        abort "Could not find the GameMaker archive for some reason!"
    end

    # if we did locate the archive, splice the new one in
    size = data[found+4..found+7].unpack("I<")[0]
    puts "[+] Found GameMaker Archive at offset 0x#{found.to_s(16)} (size 0x#{size.to_s(16)})"
    exe = data[0..found-1] + archive + data[found+size+8..-1]
    open("RivalsofAether-patched.exe", "wb") do |f|
        f.write(exe)
    end
    puts "[+] Wrote RivalsofAether-patched.exe to disk"
end

