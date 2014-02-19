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
*   Some functions are named slightly differently, e.g. characters
    which are invalid in Lua identifiers are replaced by an
    underscore, or superfluous prefixes/suffixes are missing from the
    function names.
*   The following functions are missing:
    *   `cons*`
    *   `pair?`, `not-pair?`, `proper-list?`, `dotted-list?` 
    *   `memq`, `memv`
    *   `assoc`, `assq`, `assv`, `alist-cons`, `alist-copy`,
        `alist-delete`, `alist-delete!`
    *   `lset<=`, `lset=`, `lset-adjoin`, `lset-union`, `lset-union!`,
        `lset-intersection`, `lset-intersection!`, `lset-difference`,
        `lset-difference!`, `lset-xor`, `lset-xor!`,
        `lset-diff+intersection`, `lset-diff+intersection!`
*   The following functions have been renamed:
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
    *   `list-index` => `index`
    *   `break` => `lbreak`
    *   `break!` => `lbreak_`
    *   In general, replace every non-alphanumeric character in the
        Scheme function name with an underscore (`_`) to get the Lua
        function name.
*   The following functions have different behavior:
    *   `copy`: does not work for dotted lists.
    *   `is_equal`: takes an optional third parameter used as
        a comparator function for the list elements.
    *   `take`, `take_`, `drop`, `take_right`, `drop_right`,
        `drop_right_`, `split_at`, `split_at_`, `last`, and
        `last_pair` don't work for dotted lists.
    *   `unfold`: passes extra arguments to the `tail-gen` function.
    *   `filter`, `filter_`: pass extra arguments to the predicate.
    *   `partition`, `partition_`: pass extra arguments to the
        predicate.
    *   `remove`, `remove_`: pass extra arguments to the predicate.
    *   `find`: passes extra arguments to the predicate.
    *   `find_tail`: passes extra arguments to the predicate.
    *   `take_while`, `take_while_`: pass extra arguments to the
        predicate.
    *   `drop_while`: passes extra arguments to the predicate.
    *   `span`, `span_`: pass extra arguments to the predicate.
    *   `lbreak`, `lbreak_`: pass extra arguments to the predicate.
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

