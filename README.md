# Wrastor #

The files contained in this repository constitute the beginnings of a Rivals of Aether modding tool. If you are
interested in using these scripts, please be warned: **THERE BE DRAGONS**. I wrote the first prototype of this code
in a single sitting on July 4, 2017 (because if it weren't a federal holiday, I'd probably be at work). I chose the
name Wrastor because, clearly, he is the most patriotic rival (which fit the release date well). I have plans to
support and continue work on this code, but haven't gotten around to many of them yet - see the TODO section below.

## Usage ##

This tool is *currently* written in [Ruby](https://www.ruby-lang.org/en/downloads/). It's been tested on:

* Windows 10 (thanks, Menace13!)
* Bash on Ubuntu on Windows 10
* MacOS 10.12.5
* Ubuntu 16.04

There are 5 steps I intend for a user to take when using the scripts located here:

1. Run `./extract.rb` to extract the `data.win` file (the GameMaker archive) out of `RivalsofAether.exe`
2. Run `./unpack.rb` to unpack the contents of `data.win` to the `out` directory
3. Edit any of the texture/audio files you find in the `out/TXTR` or `out/AUDO` folders however you'd like
    * **NOTE:** You MUST keep the same filename and filetype! I don't (yet) support other shenanigans.
4. Run `./pack.rb` to package up the contents of the `out` directory into `new.win`
5. Run `./replace.rb` to replace the `data.win` in your executable with `new.win`

The only pre-requisite should be having your copy of `RivalsofAether.exe` in the same folder as these scripts. I think.

## TODO ##

This is a short list of stuff I need to do to make this thing more better:

1. Test swapping textures out (which should be theoretically possible now, though still un-tested)
2. Re-write the tool in a language other than Ruby
    * Ruby is a *fantastic* language, but this isn't one of its best use-cases. Maintaining this code is going to
      be kinda crappy and most users aren't going to want to install the entire Ruby toolchain just to get it working.
3. Extract all the other data within the GameMaker archive so that people can edit that, too
4. Make everything more user-friendly
5. Document everything better
6. ???
7. PROFIT!

## Proof ##

To ensure I understood the file format well, I used the first version of these tools to re-build different versions
of Rivals of Aether. Below are proofs-of-work showing that I can use my tools to make a byte-for-byte match of the
executable with the tools in this repository.

Proof of work with Rivals of Aether 1.0.3:

```
fuzyll@dagobah:~/Projects/wrastor$ ./carve.rb
[+] Found GameMaker Archive at offset 0x15867b0 (size 0x675f49b)
[+] Wrote data.win to disk

fuzyll@dagobah:~/Projects/wrastor$ ./extract.rb
[+] Found GEN8 chunk at offset 0x8 (size 0x1a4)
[+] Found OPTN chunk at offset 0x1b4 (size 0x50)
[+] Found LANG chunk at offset 0x20c (size 0xc)
[+] Found EXTN chunk at offset 0x220 (size 0x174)
[+] Found SOND chunk at offset 0x39c (size 0x47e4)
[+] Found AGRP chunk at offset 0x4b88 (size 0x4)
[+] Found SPRT chunk at offset 0x4b94 (size 0x12b47e0)
[+] Found BGND chunk at offset 0x12b937c (size 0xb74)
[+] Found PATH chunk at offset 0x12b9ef8 (size 0x4)
[+] Found SCPT chunk at offset 0x12b9f04 (size 0x3670)
[+] Found GLOB chunk at offset 0x12bd57c (size 0x4)
[+] Found SHDR chunk at offset 0x12bd588 (size 0x308)
[+] Found FONT chunk at offset 0x12bd898 (size 0x4998)
[+] Found TMLN chunk at offset 0x12c2238 (size 0x4)
[+] Found OBJT chunk at offset 0x12c2244 (size 0x1cb74)
[+] Found ROOM chunk at offset 0x12dedc0 (size 0x7419c)
[+] Found DAFL chunk at offset 0x1352f64 (size 0x0)
[+] Found TPAG chunk at offset 0x1352f6c (size 0x4938c)
[+] Found CODE chunk at offset 0x139c300 (size 0x0)
[+] Found VARI chunk at offset 0x139c308 (size 0x0)
[+] Found FUNC chunk at offset 0x139c310 (size 0x0)
[+] Found STRG chunk at offset 0x139c318 (size 0x3a160)
[+] Found TXTR chunk at offset 0x13d6480 (size 0x1305a38)
[+] Found AUDO chunk at offset 0x26dbec0 (size 0x40835db)
[+] Ripped 56 textures out of the TXTR chunk
[+] Ripped 394 audio files out of the AUDO chunk

fuzyll@dagobah:~/Projects/wrastor$ ./package.rb
[+] Added a GEN8 chunk into the new archive
[+] Added a OPTN chunk into the new archive
[+] Added a LANG chunk into the new archive
[+] Added a EXTN chunk into the new archive
[+] Added a SOND chunk into the new archive
[+] Added a AGRP chunk into the new archive
[+] Added a SPRT chunk into the new archive
[+] Added a BGND chunk into the new archive
[+] Added a PATH chunk into the new archive
[+] Added a SCPT chunk into the new archive
[+] Added a GLOB chunk into the new archive
[+] Added a SHDR chunk into the new archive
[+] Added a FONT chunk into the new archive
[+] Added a TMLN chunk into the new archive
[+] Added a OBJT chunk into the new archive
[+] Added a ROOM chunk into the new archive
[+] Added a DAFL chunk into the new archive
[+] Added a TPAG chunk into the new archive
[+] Added a CODE chunk into the new archive
[+] Added a VARI chunk into the new archive
[+] Added a FUNC chunk into the new archive
[+] Added a STRG chunk into the new archive
[+] Found 56 textures to create the TXTR chunk with...
[+] Added a TXTR chunk into the new archive
[+] Found 394 textures to create the AUDO chunk with...
[+] Added a AUDO chunk into the new archive

fuzyll@dagobah:~/Projects/wrastor$ md5sum *.win
a2f4ff539962b9ea236d9b13a078f7a6  data.win
a2f4ff539962b9ea236d9b13a078f7a6  new.win

fuzyll@dagobah:~/Projects/wrastor$ ./replace.rb
[+] Found GameMaker Archive at offset 0x15867b0 (size 0x675f49b)
[+] Wrote RivalsofAether-patched.exe to disk

fuzyll@dagobah:~/Projects/wrastor$ md5sum *.exe
79e882cf90767eef7537aa683fb51a70  RivalsofAether.exe
79e882cf90767eef7537aa683fb51a70  RivalsofAether-patched.exe
```

Proof of work with Rivals of Aether 1.0.5:

```
fuzyll@dagobah:~/Projects/wrastor$ ./carve.rb
[+] Found GameMaker Archive at offset 0x159800c (size 0x67fb0af)
[+] Wrote data.win to disk

fuzyll@dagobah:~/Projects/wrastor$ ./extract.rb
[+] Found GEN8 chunk at offset 0x8 (size 0x1a4)
[+] Found OPTN chunk at offset 0x1b4 (size 0x50)
[+] Found LANG chunk at offset 0x20c (size 0xc)
[+] Found EXTN chunk at offset 0x220 (size 0x174)
[+] Found SOND chunk at offset 0x39c (size 0x485c)
[+] Found AGRP chunk at offset 0x4c00 (size 0x4)
[+] Found SPRT chunk at offset 0x4c0c (size 0x12c5c08)
[+] Found BGND chunk at offset 0x12ca81c (size 0xb74)
[+] Found PATH chunk at offset 0x12cb398 (size 0x4)
[+] Found SCPT chunk at offset 0x12cb3a4 (size 0x36b8)
[+] Found GLOB chunk at offset 0x12cea64 (size 0x4)
[+] Found SHDR chunk at offset 0x12cea70 (size 0x308)
[+] Found FONT chunk at offset 0x12ced80 (size 0x4998)
[+] Found TMLN chunk at offset 0x12d3720 (size 0x4)
[+] Found OBJT chunk at offset 0x12d372c (size 0x1cb74)
[+] Found ROOM chunk at offset 0x12f02a8 (size 0x7419c)
[+] Found DAFL chunk at offset 0x136444c (size 0x0)
[+] Found TPAG chunk at offset 0x1364454 (size 0x4bbdc)
[+] Found CODE chunk at offset 0x13b0038 (size 0x0)
[+] Found VARI chunk at offset 0x13b0040 (size 0x0)
[+] Found FUNC chunk at offset 0x13b0048 (size 0x0)
[+] Found STRG chunk at offset 0x13b0050 (size 0x3a528)
[+] Found TXTR chunk at offset 0x13ea580 (size 0x1339d38)
[+] Found AUDO chunk at offset 0x27242c0 (size 0x40d6def)
[+] Ripped 56 textures out of the TXTR chunk
[+] Ripped 397 audio files out of the AUDO chunk

fuzyll@dagobah:~/Projects/wrastor$ ./package.rb
[+] Added a GEN8 chunk into the new archive
[+] Added a OPTN chunk into the new archive
[+] Added a LANG chunk into the new archive
[+] Added a EXTN chunk into the new archive
[+] Added a SOND chunk into the new archive
[+] Added a AGRP chunk into the new archive
[+] Added a SPRT chunk into the new archive
[+] Added a BGND chunk into the new archive
[+] Added a PATH chunk into the new archive
[+] Added a SCPT chunk into the new archive
[+] Added a GLOB chunk into the new archive
[+] Added a SHDR chunk into the new archive
[+] Added a FONT chunk into the new archive
[+] Added a TMLN chunk into the new archive
[+] Added a OBJT chunk into the new archive
[+] Added a ROOM chunk into the new archive
[+] Added a DAFL chunk into the new archive
[+] Added a TPAG chunk into the new archive
[+] Added a CODE chunk into the new archive
[+] Added a VARI chunk into the new archive
[+] Added a FUNC chunk into the new archive
[+] Added a STRG chunk into the new archive
[+] Found 56 textures to create the TXTR chunk with...
[+] Added a TXTR chunk into the new archive
[+] Found 397 textures to create the AUDO chunk with...
[+] Added a AUDO chunk into the new archive

fuzyll@dagobah:~/Projects/wrastor$ md5sum *.win
c34363ac7987e434f4a2d13060c9a2a4  data.win
c34363ac7987e434f4a2d13060c9a2a4  new.win

fuzyll@dagobah:~/Projects/wrastor$ ./replace.rb
[+] Found GameMaker Archive at offset 0x159800c (size 0x67fb0af)
[+] Wrote RivalsofAether-patched.exe to disk

fuzyll@dagobah:~/Projects/wrastor$ md5sum *.exe
bb045dc0e31f928ae786b6e16b7a21ee  RivalsofAether.exe
bb045dc0e31f928ae786b6e16b7a21ee  RivalsofAether-patched.exe
```
