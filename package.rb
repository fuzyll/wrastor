#!/usr/bin/env ruby

# read the raw chunks from the output directory and build the new archive
archive = ""
open("out/order.txt", "r") do |meta|
    order = meta.read().split(",")
    order.each() do |name|
        size = archive.length() + 8  # add 8 here to account for the archive header we have yet to prepend
        if name == "TXTR"
            offsets = ""
            meta = ""
            data = ""

            # find all numbered textures in the current directory
            Dir.chdir("out/TXTR")
            filenames = Dir.glob("[0-9]*.png").sort_by { |s| s.gsub(".png","").to_i }
            num = filenames.length()
            puts "[+] Found #{num} textures to create the TXTR chunk with..."

            filenames.each_with_index() do |filename, i|
                # read in input file
                img = nil
                open(filename, "rb") do |file|
                    img = file.read()
                end

                # add information to the TXTR header
                offsets += [size + 12 + 4*num + 8*i].pack("I<")       # add 12 + 4*num for header, 8*i for position
                location = size + 12 + 4*num + 8*num + data.length()  # calculate the next available position
                padding = 0x80 - location % 0x80                      # pad that position out to a 128-byte boundary
                img = "\x00"*padding + img unless padding == 0x80     # add padding to the front of our image data
                meta += "\x00\x00\x00\x00#{[location + padding].pack("I<")}"

                # save the texture data
                data += img
            end

            chunk_size = 4 + offsets.length() + meta.length() + data.length()
            chunk_padding = 8 - ((archive.length() + 8 + chunk_size) % 8)
            archive += "#{name}#{[chunk_size + chunk_padding].pack("I<")}#{[num].pack("I<")}#{offsets}#{meta}#{data}"
            archive += "\x00"*chunk_padding

            Dir.chdir("../..")
            puts "[+] Added a TXTR chunk into the new archive"
        elsif name == "AUDO"
            offsets = ""
            data = ""

            # find all numbered audio files in the current directory
            Dir.chdir("out/AUDO")
            filenames = Dir.glob("[0-9]*.{wav,ogg}").sort_by { |s| s.gsub(".*","").to_i }
            num = filenames.length()
            puts "[+] Found #{num} textures to create the AUDO chunk with..."

            filenames.each_with_index() do |filename, i|
                # read in input file
                wav = nil
                open(filename, "rb") do |file|
                    wav = file.read()
                end

                # add information to the AUDO header
                location = size + 12 + 4*num + data.length()
                padding = 4 - location % 4
                padding = 0 if padding == 4  # handle edge-case of already being aligned properly
                offsets += [location + padding].pack("I<")

                # save the audio data
                data += "\x00"*padding + "#{[wav.length()].pack("I<")}" + wav
            end

            chunk_size = 4 + offsets.length() + data.length()
            archive += "#{name}#{[chunk_size].pack("I<")}#{[num].pack("I<")}#{offsets}#{data}"

            Dir.chdir("../..")
            puts "[+] Added a AUDO chunk into the new archive"
        else
            open("out/#{name}.bin", "rb") do |file|
                data = file.read()
                archive += "#{name}#{[data.length()].pack("I<")}#{data}"
            end
            puts "[+] Added a #{name} chunk into the new archive"
        end
    end
end
archive = "FORM" + [archive.length()].pack("I<") + archive

# write the archive to disk
open("new.win", "wb") do |file|
    file.write(archive)
end
