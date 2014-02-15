#            SRFI1 -- Scheme's SRFI-1 List Library for Lua           #

##                           Introduction                           ##

The primary data structure of functional languages is often a linked
list consisting of cells. For the Lisp-dialect Scheme there is a
standard list library ([SRFI-1][1]) that aims to provide a common
library for list processing for all Scheme dialects. This Lua module
is a reimplementation of [SRFI-1][1] for Lua. It also served as an
experiment for different `cons`-cell implementations.

  [1]:  http://srfi.schemers.org/srfi-1/srfi-1.html

##                          Getting Started                         ##

Go to the [SRFI-1 website][1] to get an overview of all available
functions. This Lua module follows the standardized interface as much
as possible with the following exceptions:

*   Dotted lists are not supported. There are no functions to check
    for dotted lists, and there is no guarantee that any function will
    work with a dotted list even if [SRFI-1][1] says otherwise. The
    reason is that support for dotted lists would require a way to
    identify `cons`-cells, which in turn would cost additional memory.
*   The whole "association lists" and "set operations on lists"
    part of [SRFI-1][1] is missing. You are better off using Lua
    tables for that.
*   Currently there are no "linear update" variants (the functions
    which have an exclamation mark in their name). Maybe those
    functions will be added later ...
*   Some functions are named slightly differently, e.g. characters
    which are invalid in Lua identifiers are replaced by an
    underscore, or superfluous prefixes are removed from the function
    names.
*   The following functions are missing:
    *   `cons*`
    *   `pair?`, `not-pair?`, `proper-list?`, `dotted-list?` 
    *   `take!`, `drop-right!`, `split-at!`
    *   `append!`, `concatenate!`, `reverse!`, `append-reverse!`,
        `unzip5`
    *   `append-map!`, `map!`
    *   `filter!`, `partition!`, `remove!`
    *   `memq`, `memv`, `span!`, `break!`
    *   `delete!`, `delete-duplicates!`
    *   `assoc`, `assq`, `assv`, `alist-cons`, `alist-copy`,
        `alist-delete`, `alist-delete!`
    *   `lset<=`, `lset=`, `lset-adjoin`, `lset-union`, `lset-union!`,
        `lset-intersection`, `lset-intersection!`, `lset-difference`,
        `lset-difference!`, `lset-xor`, `lset-xor!`,
        `lset-diff+intersection`, `lset-diff+intersection!`
*   The following functions are renamed:
    *   `set-car!` => `set_car`
    *   `set-cdr!` => `set_cdr`
    *   `make-list` => `make`
    *   `list-tabulate` => `tabulate`
    *   `list-copy` => `copy`
    *   `circular-list` => `circular`
    *   `null?` => `is_null`
    *   `circular-list?` => `is_circular`
    *   `list=` => `is_equal`
    *   `list-ref` => `ref`
    *   `car+cdr` => `car_cdr`
    *   `take-right` => `take_right`
    *   `drop-right` => `drop_right`
    *   `split-at` => `split_at`
    *   `last-pair` => `last_pair`
    *   `length+` => `length_`
    *   `append-reverse` => `append_reverse`
    *   `for-each` => `for_each`
    *   `pair-fold` => `pair_fold`
    *   `fold-right` => `fold_right`
    *   `unfold-right` => `unfold_right`
    *   `pair-fold-right` => `pair_fold_right`
    *   `reduce-right` => `reduce_right`
    *   `append-map` => `append_map`
    *   `pair-for-each` => `pair_for_each`
    *   `map-in-order` => `map_in_order`
    *   `find-tail` => `find_tail`
    *   `list-index` => `index`
    *   `take-while` => `take_while`
    *   `drop-while` => `drop_while`
    *   `break` => `lbreak`
    *   `delete-duplicates` => `delete_duplicates`
*   The following functions have different behavior:
    *   `list=`: `is_equal` takes an optional third parameter used as
        a comparator function for the list elements.
    *   `unfold`: passes any extra arguments to the `tail-gen`
        function.
    *   `filter`: passes extra arguments to the predicate.
    *   `partition`: passes extra arguments to the predicate.
    *   `remove`: passes extra arguments to the predicate.
    *   `find`: passes extra arguments to the predicate.
    *   `find-tail`: passes extra arguments to the predicate.
    *   `take-while`: passes extra arguments to the predicate.
    *   `drop-while`: passes extra arguments to the predicate.
    *   `span`: passes extra arguments to the predicate.
    *   `break`: passes extra arguments to the predicate.
    *   `delete-duplicates`: only removes adjacent duplicates (FIXME).
    *   `traverse`: new function, creates for-loop iterator.


##                              Contact                             ##

Philipp Janda, siffiejoe(a)gmx.net

Comments and feedback are always welcome.


##                              License                             ##

`srfi1` (the Lua module) is *copyrighted free software* distributed
under the MIT license (the same license as Lua 5.1). The full license
text follows:

    srfi1 (c) 2014 Philipp Janda

    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHOR OR COPYRIGHT HOLDER BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

