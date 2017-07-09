#!/usr/bin/env ruby

# strip the GameMaker archive out of the executable
open("RivalsofAether.exe", "rb") do |file|
    data = file.read()  # FIXME: reading in the entire file here is not the most elegant solution...
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

    # if we did locate the archive, strip it out of the executable
    size = data[found+4..found+7].unpack("I<")[0]
    puts "[+] Found GameMaker Archive at offset 0x#{found.to_s(16)} (size 0x#{size.to_s(16)})"
    open("data.win", "wb") do |f|
        f.write(data[found..found+size+8-1])
    end
    puts "[+] Wrote data.win to disk"
end

