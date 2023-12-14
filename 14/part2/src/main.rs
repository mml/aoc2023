#![allow(uncommon_codepoints)]
use std::io::{self,BufRead};
// see ascii(7)
const ROUND: u8 = 79; // O
const EMPTY: u8 = 46; // .
const CUBE: u8 = 35; // #

#[derive(PartialEq)]
enum Dir { NORTH, SOUTH, WEST, EAST }

struct TiltSpec {
    i_max: usize,
    runs_len: fn(&Analysis, usize)->usize,
    run: fn(&Analysis, usize, usize)->Run,
    drun: fn(usize)->usize,
    get: fn(&Platform,usize,usize)->u8,
    set: fn(&mut Platform,usize,usize,u8),
}

struct Analysis {
    row_runs: Vec<Vec<Run>>,
    col_runs: Vec<Vec<Run>>,
}

type Platform = Vec<Row>;
type Row = Vec<u8>;
type Run = (usize,usize);

fn main() {
    let lines: Platform;
    let mut tilta: Platform = Vec::new();
    let mut tiltb: Platform = Vec::new();
    let mut prevs: Vec<Platform> = Vec::new();
    let max_i = 1_000_000_000;

    match run() {
        Err(err) => {
            eprintln!("Error: {}", err);
            std::process::exit(1);
        }
        Ok(r) => {
            lines = r;
        }
    }

    let analysis: Analysis  = analyze(Dir::NORTH, &lines);
    for i in 0..lines.len() {
        tilta.push(lines[i].clone());
        tiltb.push(lines[i].clone());
    }
    let mut i = 0;
    let mut need_ff = true;
    'tilt: loop {
        println!("f[{}]...", i);
        tilt(Dir::NORTH, &analysis, &tilta, &mut tiltb);
        tilt(Dir::WEST,  &analysis, &tiltb, &mut tilta);
        tilt(Dir::SOUTH, &analysis, &tilta, &mut tiltb);
        tilt(Dir::EAST,  &analysis, &tiltb, &mut tilta);
        if need_ff {
            let mut prev: Platform = Vec::new();
            for j in 0..tilta.len() {
                prev.push(tilta[j].clone());
            }
            for j in 0..i {
                if same(&tilta, &prevs[j]) {
                    let size = i-j;
                    let ff_cycles = (max_i-i)/size;
                    let ff = size*ff_cycles;
                    println!("f[{}] = f[{}]", i, j);
                    println!("Cycle length = {}", size);
                    println!("Fast forward by {} to {}", ff, i+ff);
                    i = i + ff + 1; // +1 because we still need the normal loop increment
                    need_ff = false;
                    continue 'tilt;
                }
            }
            prevs.push(prev);
        }
        if i % 1_000_000 == 0 {
            println!("{}", i / 1_000_000);
        }
        i = i + 1;
        if i == max_i {
            break;
        }
    }

    for (i, line) in tilta.iter().enumerate() {
        println!("{} -> {}",
                 std::str::from_utf8(&lines[i]).unwrap(),
                 std::str::from_utf8(&line).unwrap());
    }

    println!("{}", score(tilta));
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

#[allow(dead_code)]
fn same(p: &Platform, q: &Platform) -> bool {
    for i in 0..p.len() {
        for j in 0..p[i].len() {
            if p[i][j] != q[i][j] {
                return false;
            }
        }
    }
    true
}

fn tilt(d: Dir, a: &Analysis, p: &Platform, rv: &mut Platform) {
    let spec = tilt_spec(&d, &p);
    /*
    let nrow = p.len();
    let ncol = p[0].len();
    */

    for i in 0..(spec.i_max+1) {
        'run: for run_idx in 0..(spec.runs_len)(&a,i) {
            let (first,last) = (spec.run)(&a, i, run_idx);
            //println!("Checking run in col/row {} ({}->{})", i, first, last);
            let mut drop_at = first;
            let mut check = first;
            loop {
                //println!("first {} drop_at {} check {} last {}", first, drop_at, check, last);
                if (spec.get)(p, i, check) == ROUND {
                    //println!("Dropping at ({},{})", drop_at, i);
                    (spec.set)(rv, i, drop_at, ROUND);
                    if drop_at == last {
                        continue 'run;
                    }
                    drop_at = (spec.drun)(drop_at);
                    //println!("first {} drop_at {} check {} last {}", first, drop_at, check, last);
                }
                if check == last {
                    break;
                }
                check = (spec.drun)(check);
            }
            loop {
                //println!("first {} drop_at {} check {} last {}", first, drop_at, check, last);
                (spec.set)(rv, i, drop_at, EMPTY);
                if drop_at == last {
                    break;
                }
                drop_at = (spec.drun)(drop_at);
            }
        }
    }
}


fn analyze(d: Dir, p: &Platform) -> Analysis {
    if d != Dir::NORTH {
        panic!("Not supported");
    }
    let mut row_vecs: Vec<Vec<Run>> = Vec::new();
    let mut col_vecs: Vec<Vec<Run>> = Vec::new();
    let nrow = p.len();
    let ncol = p[0].len();

    for i in 0..ncol {
        //println!("Runs for col {}", i);
        let mut runs: Vec<Run> = Vec::new();
        let mut in_run = false;
        let mut start = i; // to quiet warning
        for j in 0..nrow {
            if !in_run {
                if p[j][i] == ROUND || p[j][i] == EMPTY {
                    in_run = true;
                    start = j;
                }
            } else {
                if p[j][i] == CUBE {
                    in_run = false;
                    //println!("({},{})", start, j-1);
                    runs.push((start,j-1));
                }
            }
        }
        if in_run {
            //println!("({},{})", start, ncol-1);
            runs.push((start,ncol-1));
        }
        col_vecs.push(runs);
    }
    for i in 0..nrow {
        let mut runs: Vec<Run> = Vec::new();
        let mut in_run = false;
        let mut start = i; // to quiet warning
        for j in 0..ncol {
            if !in_run {
                if p[i][j] == ROUND || p[i][j] == EMPTY {
                    in_run = true;
                    start = j;
                }
            } else {
                if p[i][j] == CUBE {
                    in_run = false;
                    runs.push((start,j-1));
                }
            }
        }
        if in_run {
            runs.push((start,ncol-1));
        }
        row_vecs.push(runs);
    }

    Analysis {
        row_runs: row_vecs,
        col_runs: col_vecs,
    }
}

fn tilt_spec(d: &Dir, p: &Platform) -> TiltSpec {
    let nrow = p.len();
    let ncol = p[0].len();

    match d {
        Dir::NORTH => {
            TiltSpec {
                i_max: ncol-1,
                runs_len: get_col_runs_len,
                run: get_col_run,
                drun: inc,
                set: set_col_row,
                get: get_col_row,
            }
        }
        Dir::SOUTH => {
            TiltSpec {
                i_max: ncol-1,
                runs_len: get_col_runs_len,
                run: flip_get_col_run,
                drun: dec,
                set: set_col_row,
                get: get_col_row,
            }
        }
        Dir::WEST => {
            TiltSpec {
                i_max: nrow-1,
                runs_len: get_row_runs_len,
                run: get_row_run,
                drun: inc,
                set: set_row_col,
                get: get_row_col,
            }
        }
        Dir::EAST => {
            TiltSpec {
                i_max: nrow-1,
                runs_len: get_row_runs_len,
                run: flip_get_row_run,
                drun: dec,
                set: set_row_col,
                get: get_row_col,
            }
        }
        /*
        Dir::SOUTH => {
            TiltSpec {
                i0: nrow-2,
                i_last: 0,
                di: dec,
                j_stop: ncol,
                k0: id,
                k_stop: nrow-1,
                dk: inc,
                set: set_row_col,
                get: get_row_col,
            }
        }
        // For EAST and WEST, i/k are columns and j is rows
        Dir::EAST => {
            TiltSpec {
                i0: ncol-2,
                i_last: 0,
                di: dec,
                j_stop: nrow,
                k0: id,
                k_stop: ncol-1,
                dk: inc,
                set: set_col_row,
                get: get_col_row,
            }
        }
        Dir::WEST => {
            TiltSpec {
                i0: 1,
                i_last: ncol-1,
                di: inc,
                j_stop: nrow,
                k0: id,
                k_stop: 0,
                dk: dec,
                set: set_col_row,
                get: get_col_row,
            }
        }
        */
    }
}

fn get_col_runs_len(a: &Analysis, col: usize) -> usize { a.col_runs[col].len() }
fn flip_get_col_run(a: &Analysis, col: usize, n: usize) -> Run {
    let (a,b) = a.col_runs[col][n];
    (b,a)
}
fn get_col_run(a: &Analysis, col: usize, n: usize) -> Run { a.col_runs[col][n] }
fn get_row_runs_len(a: &Analysis, row: usize) -> usize { a.row_runs[row].len() }
fn get_row_run(a: &Analysis, row: usize, n: usize) -> Run { a.row_runs[row][n] }
fn flip_get_row_run(a: &Analysis, row: usize, n: usize) -> Run {
    let (a,b) = a.row_runs[row][n];
    (b,a)
}

fn get_row_col(p: &Platform, i: usize, j: usize) -> u8 {
    //println!("p[{}][{}]", i, j);
    p[i][j]
}
fn get_col_row(p: &Platform, i: usize, j: usize) -> u8 {
    //println!("p[{}][{}]", j, i);
    p[j][i]
}
fn set_row_col(p: &mut Platform, i: usize, j: usize, v: u8) {
    //println!("p[{}][{}] = {}", i, j, v);
    p[i][j] = v
}
fn set_col_row(p: &mut Platform, i: usize, j: usize, v: u8) {
    //println!("p[{}][{}] = {}", j, i, v);
    p[j][i] = v
}
// fn id(n: usize) -> usize { n }
fn inc(n: usize) -> usize { n + 1 }
fn dec(n: usize) -> usize { n - 1 }

/*
fn tilt(d: Dir, input: &Platform) -> Platform {
    let mut rv: Platform = Vec::new();
    let spec = tilt_spec(&d, &input);

    for row in input.iter() {
        rv.push(row.clone())
    }

    let mut i = spec.i0;
    loop {
        let mut j = 0;
        while j != spec.j_stop {
            let mut k = (spec.k0)(i);
            while k != spec.k_stop {
                let kʹ = (spec.dk)(k);
                if (spec.get)(&mut rv,k,j) == ROUND && (spec.get)(&mut rv,kʹ,j) == EMPTY {
                    (spec.set)(&mut rv,kʹ,j,ROUND);
                    (spec.set)(&mut rv,k,j,EMPTY);
                } else {
                    break;
                }
                k = kʹ;
            }
            j = j + 1;
        }
        if i == spec.i_last {
            break;
        }
        i = (spec.di)(i);
    }

    rv
}
*/

/*
fn spin_n(p: &Platform, n: usize) -> Platform {
    let mut rv: Platform = p.to_vec();

    for _i in 0..n {
        rv = tilt(Dir::NORTH, &rv);
        rv = tilt(Dir::WEST, &rv);
        rv = tilt(Dir::SOUTH, &rv);
        rv = tilt(Dir::EAST, &rv);
    }

    rv
}
*/

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
