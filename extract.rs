/*
 * extract.rs | Wrastor Extraction Utility
 *
 * Copyright (c) 2017 Alexander Taylor <ajtaylor@fuzyll.com>
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
 * IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

use std::env;
use std::process;
use std::path::Path;
use std::fs::File;
use std::io::Read;
use std::io::Write;
use std::error::Error;


fn main() {
    // ensure proper program usage
    let args: Vec<_> = env::args().collect();
    if args.len() < 2 {
        println!("Usage: {} <executable>", args[0]);
        process::exit(0);
    }

    // read data from disk
    let data = read(&args[1]);

    // look for an embedded IFF file by finding the "FORM" signature within the input file
    let mut idx = 0;
    let mut len = 0;
    for (i, _) in data.iter().enumerate() {
        // find next possible IFF signature: "FORM" + 4-byte, little-endian length counter
        if &data[i..i+4] != &['F' as u8, 'O' as u8, 'R' as u8, 'M' as u8] {
            continue;
        }
        if &data[i..i+6] == &['F' as u8, 'O' as u8, 'R' as u8, 'M' as u8, 'A' as u8, 'T' as u8] {
            continue;
        }

        // check the length to see if it looks valid before selecting this offset
        len = ((data[i+7] as usize) << 24) + ((data[i+6] as usize) << 16) + ((data[i+5] as usize) << 8) + (data[i+4] as usize);
        if len < data.len() && len > 0x100000 {  // FIXME: minimum size of 0x100000 here was chosen arbitrarily
            idx = i;
            break;
        }
    }
    if idx == 0 {
        println!("[!] Couldn't locate an embedded IFF file");
        process::exit(-1);
    }

    // strip the embedded IFF file out of the input file and write it to disk
    println!("[+] Found embedded IFF file at offset {:#X} (size {:#X})", idx, len);
    write(&"data.win", &data[idx..idx+8+len]);
}


fn read(name: &str) -> Vec<u8> {
    // open the input file
    let path = Path::new(name);
    let mut file = match File::open(path) {
        Err(why) => {
            println!("[!] Couldn't open {}: {}", path.display(), why.description());
            process::exit(-1);
        },
        Ok(file) => file
    };

    // read from the input file
    let mut data = Vec::new();
    match file.read_to_end(&mut data) {
        Err(why) => {
            println!("[!] Couldn't read from {}: {}", path.display(), why.description());
            process::exit(-1);
        }
        Ok(_) => println!("[+] Read data from {}", path.display())
    }

    return data;
}


fn write(name: &str, data: &[u8]) {
    // open the output file
    let path = Path::new(name);
    let mut file = match File::create(path) {
        Err(why) => {
            println!("[!] Couldn't open {}: {}", path.display(), why.description());
            process::exit(-1);
        }
        Ok(file) => file
    };

    // write to the output file
    match file.write_all(data) {
        Err(why) => {
            println!("[!] Couldn't write to {}: {}", path.display(), why.description());
            process::exit(-1);
        }
        Ok(_) => println!("[+] Wrote IFF data to {}", path.display())
    }
}
