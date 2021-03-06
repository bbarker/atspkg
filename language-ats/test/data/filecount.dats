#include "share/atspre_staload.hats"
#include "libats/ML/DATS/filebas_dirent.dats"
#include "libats/libc/DATS/dirent.dats"

staload "libats/ML/DATS/string.dats"

fun good_dir(next: string) : bool = case next of | "." => false | ".." => false | _ => true
fnx step_stream(acc: int, s: string) : int =
if test_file_isdir(s) != 0 then
flow_stream(s, acc + 1)
else
acc + 1
and flow_stream(s: string, init: int) : int =
let
var files = streamize_dirname_fname(s)
var ffiles = stream_vt_filter_cloptr(files, lam x => good_dir(x))
in
stream_vt_foldleft_cloptr(ffiles, init, lam (acc, next) => step_stream(acc, s + "/" + next))
end
fun count_files(s: string) : void =
let
var n: int = step_stream(0, g1ofg0(s))
in
println!(tostring_int(n))
end

implement main0 (argc, argv) =
if argc > 1 then
count_files(argv[1])
else
count_files(".")
