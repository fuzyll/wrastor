#!/usr/bin/env ruby

##
# unpack.rb | Wrastor Unpack Utility
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

chunk = {}  # the data for each chunk
order = ""  # the order in which the chunks were packed

# parse the archive into separate chunks
open("data.win", "rb") do |file|
    data = file.read()  # FIXME: reading entire file into memory is not the best way to accomplish this...

    # check to see if the input file at least has the correct magic header
    if data[0..3] != "FORM"
        abort "[!] Input file is not a valid GameMaker Archive"
    end

    # split the archive apart into separate chunks
    i = 8  # skip the 8 bytes in the header
    while i < data.length
        # parse the type and length of the chunk
        name = data[i..i+3]                     # first 4 bytes are the chunk type
        size = data[i+4..i+7].unpack("I<")[0]   # next 4 bytes are the size of the chunk (little-endian)
        puts "[+] Found #{name} chunk at offset 0x#{i.to_s(16)} (size 0x#{size.to_s(16)})"
        i += 8

        # add an entry for the chunk in our hash
        chunk[name] = [i, data[i..i+size-1]]    # each chunk entry here is [absolute file location, data chunk]
        i += size

        # record the order in which the chunk was packed for later
        order += "#{name},"
    end
end

# create output directory and save the order in which the chunks were packed
Dir.mkdir("out") unless File.exists?("out")
open("out/order.txt", "w") do |file|
    file.write(order[0..-2])
end

# save each chunk's data to the output directory
chunk.each do |name,entry|
    location = entry[0]
    data = entry[1]

    if name == "TXTR"
        # we want to rip the texture files out of the TXTR chunk individually
        Dir.mkdir("out/TXTR") unless File.exists?("out/TXTR")

        # parse TXTR header information
        num = data[0..3].unpack("I<")[0]                    # first 4 bytes are # of textures
        offsets = []                                        # 4 bytes per texture point to the file metadata
        data[4..4+4*num-1].scan(/.{4}/m).each() do |o|
            offsets << (o.unpack("I<")[0] - location - 4 - 4*num) / 8  # <-- this is why absolute offsets suck
        end
        meta = []                                           # 8 bytes per texture contain the texture metadata entry
        data[4+4*num..4+4*num+8*num-1].scan(/.{8}/m).each() do |e|
            type, start = e.unpack("II<")                   # first 4 bytes are type, next 4 bytes are start offset
            start -= location
            meta << {:type => type, :start => start}
        end

        # strip out each texture and write it to separate file
        num.times do |i|
            # calculate the start and end of the texture file from the metadata in the header
            start = meta[offsets[i]][:start]
            finish = data[start..-1].index(/IEND/) + 8      # PNG files always end with an 4-byte "IEND" chunk
                                                            # we add 8 here instead of 4 because, for some reason,
                                                            # the input always has 0x826042AE after "IEND"

            # write the texture to disk
            # FIXME: we assume that all textures are type 0, which is wrong for games like Hyper Light Drifter
            open("out/TXTR/#{i}.png", "wb") do |file|
                file.write(data[start..start+finish-1])
            end
        end

        puts "[+] Ripped #{num} textures out of the TXTR chunk"
    elsif name == "AUDO"
        # we also need to rip the audio files out of the AUDO chunk individually if we're changing textures
        Dir.mkdir("out/AUDO") unless File.exists?("out/AUDO")

        # parse AUDO header information
        num = data[0..3].unpack("I<")[0]                    # first 4 bytes are # of audio files
        offsets = []                                        # 4 bytes per audio file point to the file and its size
        data[4..4+4*num-1].scan(/.{4}/m).each() do |o|
            offsets << o.unpack("I<")[0] - location
        end

        # strip out each audio file and write it to separate file
        num.times do |i|
            start = offsets[i]
            size = data[start..start+3].unpack("I<")[0]

            # write the audio file out to disk
            if data[start+4] == "R"
                open("out/AUDO/#{i}.wav", "wb") do |file|
                    file.write(data[start+4..start+4+size-1])
                end
            else
                open("out/AUDO/#{i}.ogg", "wb") do |file|
                    file.write(data[start+4..start+4+size-1])
                end
            end
        end

        puts "[+] Ripped #{num} audio files out of the AUDO chunk"
    else
        # all other chunks just get written out as a binary blob
        open("out/#{name}.bin", "wb") do |file|
            file.write(data)
        end
    end
end
