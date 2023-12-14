use std::io::{self,BufRead};
// see ascii(7)
const ROUND: u8 = 79; // O
const EMPTY: u8 = 46; // .
// const CUBE: u8 = 35; // #

type Platform = Vec<Row>;
type Row = Vec<u8>;

fn main() {
    let lines: Platform;
    let tilted: Platform;

    match run() {
        Err(err) => {
            eprintln!("Error: {}", err);
            std::process::exit(1);
        }
        Ok(r) => {
            lines = r;
        }
    }

    match tilt(&lines) {
        Err(err) => {
            eprintln!("Error: {}", err);
            std::process::exit(1);
        }
        Ok(r) => {
            tilted = r;
        }
    }

    for (i, line) in tilted.iter().enumerate() {
        println!("{} -> {}",
                 std::str::from_utf8(&lines[i]).unwrap(),
                 std::str::from_utf8(&line).unwrap());
    }

    println!("{}", score(tilted));
}

fn run() -> io::Result<Platform> {
    let mut lines: Platform = Vec::new();
    let stdin = io::stdin();
    let handle = stdin.lock();

    for line_result in handle.lines() {
        match line_result {
            Ok(line) => {
                lines.push(line.into_bytes());
            }
            Err(err) => {
                eprintln!("Error reading line: {}", err);
                break;
            }
        }
    }

    Ok(lines)
}

fn tilt(input: &Platform) -> Result<Platform,&'static str> {
    let mut rv: Platform = Vec::new();
    let nrow = input.len();

    for row in input.iter() {
        rv.push(row.clone())
    }

    for i in 1..nrow {
        for j in 0..rv[i].len() {
            for k in (1..i+1).rev() {
                if rv[k][j] == ROUND && rv[k-1][j] == EMPTY {
                    rv[k-1][j] = ROUND;
                    rv[k][j] = EMPTY;
                } else {
                    break;
                }
            }
        }
    }

    Ok(rv)
}

fn score(p: Platform) -> usize {
    let mut mult = p.len();
    let mut tot = 0;

    for i in 0..p.len() {
        for j in 0..p[i].len() {
            if p[i][j] == ROUND {
                tot += mult;
            }
        }
        mult -= 1;
    }

    tot
}
