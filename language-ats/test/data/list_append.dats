fun
{a:t@ype}
list_append
  {m,n:nat} (
  xs: list (a, m)
, ys: list (a, n)
) : list (a, m+n) =
(
case+ xs of
| list_cons
    (x, xs) => list_cons (x, list_append (xs, ys))
| list_nil ((*void*)) => ys
) // end of [list_append]

fun
{a:t@ype}
list_append2
  {m,n:nat} (
  xs: list (a, m)
, ys: list (a, n)
) : list (a, m+n) = let
//
fun loop{m:nat}
(
  xs: list (a, m)
, ys: list (a, n)
, res: &ptr? >> list (a, m+n)
) : void =
(
case+ xs of
| list_cons
    (x, xs1) => let
    val () = res := list_cons{a}{0}(x, _)
    val+list_cons (_, res1) = res
    val () = loop (xs1, ys, res1) // of [xs1] and [ys]
  in
    fold@(res)
  end
| list_nil ((*void*)) => res := ys
)
//
var res: ptr
val () = loop (xs, ys, res)
//
in
  res
end // end of [list_append2]
