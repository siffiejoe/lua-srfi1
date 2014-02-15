-- Linked list implementation following the Scheme's standard list
-- library as specified by SRFI-1.
-- http://srfi.schemers.org/srfi-1/srfi-1.html
-- dotted-lists are not supported, there are no "linear-update"
-- variants, and the whole "association lists" and "set operations
-- on lists" parts are missing (better use tables for that anyways)

local implementation = "array"
--implementation = "table"
--implementation = "closure"
--implementation = "ccons"
local assert = assert
local select = assert( select )
local error = assert( error )
local require = assert( require )
local unpack = assert( unpack or require( "table" ).unpack )
local cons, car, cdr, set_car, set_cdr

if implementation == "array" then

  function cons( hd, tl )
    return { hd, tl }
  end

  function car( lst )
    return lst[ 1 ]
  end

  function cdr( lst )
    return lst[ 2 ]
  end

  function set_car( lst, v )
    lst[ 1 ] = v
  end

  function set_cdr( lst, v )
    lst[ 2 ] = v
  end

elseif implementation == "table" then

  function cons( hd, tl )
    return { head = hd, tail = tl }
  end

  function car( lst )
    return lst.head
  end

  function cdr( lst )
    return lst.tail
  end

  function set_car( lst, v )
    lst.head = v
  end

  function set_cdr( lst, v )
    lst.tail = v
  end

elseif implementation == "closure" then

  function cons( hd, tl )
    return function( w, v )
      if w then
        if w == "set_car" then
          hd = v
        else -- w == "set_cdr"
          tl = v
        end
      else
        return hd, tl
      end
    end
  end

  function car( lst )
    return (lst())
  end

  function cdr( lst )
    local _, v = lst()
    return v
  end

  function set_car( lst, v )
    return lst( "set_car", v )
  end

  function set_cdr( lst, v )
    return lst( "set_cdr", v )
  end

else -- use external module

  local M = require( implementation )
  cons = assert( M.cons )
  car = assert( M.car )
  cdr = assert( M.cdr )
  set_car = assert( M.set_car )
  set_cdr = assert( M.set_cdr )

end


local function list( ... )
  local n, c = select( '#', ... ), nil
  for i = n, 1, -1 do
    c = cons( select( i, ... ), c )
  end
  return c
end


local function xcons( tl, hd )
  return cons( hd, tl )
end


local function make( n, v )
  local lst
  for i = 1, n do
    lst = cons( v, lst )
  end
  return lst
end


local function tabulate( n, f )
  local c
  for i = n, 1, -1 do
    c = cons( f( i ), c )
  end
  return c
end


local function copy( lst )
  local newlist, last
  if lst ~= nil then
    newlist = cons( car( lst ), nil )
    last, lst = newlist, cdr( lst )
    while lst ~= nil do
      local c = cons( car( lst ), nil )
      set_cdr( last, c )
      last, lst = c, cdr( lst )
    end
  end
  return newlist
end


local function circular( ... )
  local n, c = select( '#', ... ), nil
  if n > 0 then
    c = cons( select( n, ... ), nil )
    local last = c
    for i = n-1, 1, -1 do
      c = cons( select( i, ... ), c )
    end
    set_cdr( last, c )
  end
  return c
end


local function iota( n, start, step )
  start, step = start or 0, step or 1
  local c
  for i = n-1, 0, -1 do
    c = cons( start+i*step, c )
  end
  return c
end


local function is_circular( lst )
  local fast, slow = lst, lst
  while fast ~= nil do
    fast = cdr( fast )
    if fast == nil or fast == slow then
      break
    end
    fast, slow = cdr( fast ), cdr( slow )
  end
  return fast ~= nil
end


local function is_null( lst )
  return lst == nil
end


local function equal( a, b )
  return a == b
end

local function is_equal( a, b, eq )
  eq = eq or equal
  while a ~= nil and b ~= nil do
    if not eq( car( a ), car( b ) ) then
      return false
    end
    a, b = cdr( a ), cdr( b )
  end
  return a == b
end


local function caar( lst )
  return car( car( lst ) )
end

local function cadr( lst )
  return car( cdr( lst ) )
end

local function cdar( lst )
  return cdr( car( lst ) )
end

local function cddr( lst )
  return cdr( cdr( lst ) )
end

local function caaar( lst )
  return car( car( car( lst ) ) )
end

local function caadr( lst )
  return car( car( cdr( lst ) ) )
end

local function cadar( lst )
  return car( cdr( car( lst ) ) )
end

local function caddr( lst )
  return car( cdr( cdr( lst ) ) )
end

local function cdaar( lst )
  return cdr( car( car( lst ) ) )
end

local function cdadr( lst )
  return cdr( car( cdr( lst ) ) )
end

local function cddar( lst )
  return cdr( cdr( car( lst ) ) )
end

local function cdddr( lst )
  return cdr( cdr( cdr( lst ) ) )
end

local function caaaar( lst )
  return car( car( car( car( lst ) ) ) )
end

local function caaadr( lst )
  return car( car( car( cdr( lst ) ) ) )
end

local function caadar( lst )
  return car( car( cdr( car( lst ) ) ) )
end

local function caaddr( lst )
  return car( car( cdr( cdr( lst ) ) ) )
end

local function cadaar( lst )
  return car( cdr( car( car( lst ) ) ) )
end

local function cadadr( lst )
  return car( cdr( car( cdr( lst ) ) ) )
end

local function caddar( lst )
  return car( cdr( cdr( car( lst ) ) ) )
end

local function cadddr( lst )
  return car( cdr( cdr( cdr( lst ) ) ) )
end

local function cdaaar( lst )
  return cdr( car( car( car( lst ) ) ) )
end

local function cdaadr( lst )
  return cdr( car( car( cdr( lst ) ) ) )
end

local function cdadar( lst )
  return cdr( car( cdr( car( lst ) ) ) )
end

local function cdaddr( lst )
  return cdr( car( cdr( cdr( lst ) ) ) )
end

local function cddaar( lst )
  return cdr( cdr( car( car( lst ) ) ) )
end

local function cddadr( lst )
  return cdr( cdr( car( cdr( lst ) ) ) )
end

local function cdddar( lst )
  return cdr( cdr( cdr( car( lst ) ) ) )
end

local function cddddr( lst )
  return cdr( cdr( cdr( cdr( lst ) ) ) )
end


local function fifth( lst )
  return car( cdr( cdr( cdr( cdr( lst ) ) ) ) )
end

local function sixth( lst )
  return car( cdr( cdr( cdr( cdr( cdr( lst ) ) ) ) ) )
end

local function seventh( lst )
  return car( cdr( cdr( cdr( cdr( cdr( cdr( lst ) ) ) ) ) ) )
end

local function eighth( lst )
  return car( cdr( cdr( cdr( cdr( cdr( cdr( cdr( lst ) ) ) ) ) ) ) )
end

local function ninth( lst )
  return car( cdr( cdr( cdr( cdr( cddddr( lst ) ) ) ) ) )
end

local function tenth( lst )
  return car( cdr( cdr( cdr( cdr( cdr( cddddr( lst ) ) ) ) ) ) )
end


local function car_cdr( lst )
  return car( lst ), cdr( lst )
end


local function split_at( lst, n )
  if lst == nil or n == 0 then
    return nil, lst
  else
    local front = cons( car( lst ), nil )
    local last, rest, i = front, cdr( lst ), 1
    while rest ~= nil and i < n do
      local newlast = cons( car( rest ), nil )
      set_cdr( last, newlast )
      last, rest, i = newlast, cdr( rest ), i+1
    end
    return front, rest
  end
end


local function take( lst, n )
  return (split_at( lst, n ))
end


local function drop( lst, n )
  while lst ~= nil and n > 0 do
    lst, n = cdr( lst ), n-1
  end
  return lst
end


local function take_right( lst, n )
  local front = drop( lst, n )
  while front ~= nil do
    lst, front = cdr( lst ), cdr( front )
  end
  return lst
end


local function drop_right( lst, n )
  local front, newlist, last = drop( lst, n ), nil, nil
  if front ~= nil then
    newlist = cons( car( lst, nil ) )
    last, front, lst = newlist, cdr( front ), cdr( lst )
    while front ~= nil do
      local c = cons( car( lst ), nil )
      set_cdr( last, c )
      last, front, lst = c, cdr( front ), cdr( lst )
    end
  end
  return newlist
end


local function ref( lst, n )
  if n < 1 then
    error( "invalid index for 'list.ref'" )
  end
  lst = drop( lst, n-1 )
  if lst == nil then
    error( "list too short for 'list.ref'" )
  end
  return car( lst )
end


local function last_pair( lst )
  if lst == nil then
    error( "'list.last_pair' called on empty list" )
  end
  return take_right( lst, 1 )
end


local function last( lst )
  return car( last_pair( lst ) )
end


local function length( lst )
  local len = 0
  while lst ~= nil do
    lst, len = cdr( lst ), len+1
  end
  return len
end


local function length_( lst )
  local len, fast, slow = 0, lst, lst
  while fast ~= nil do
    fast = cdr( fast )
    if fast == nil then
      len = len + 1
      break
    elseif fast == slow then
      return nil
    end
    len, fast, slow = len+2, cdr( fast ), cdr( slow )
  end
  return len
end


local function append( ... )
  local n, nlst, last = select( '#', ... ), nil, nil
  for i = 1, n-1 do
    local lst = select( i, ... )
    while lst ~= nil do
      local c = cons( car( lst ), nil )
      if last then
        set_cdr( last, c )
      else
        nlst = c
      end
      last, lst = c, cdr( lst )
    end
  end
  if n > 0 then
    if last then
      set_cdr( last, (select( n, ... )) )
    else
      nlst = select( n, ... )
    end
  end
  return nlst
end


local function concatenate( llst )
  local nlst, last
  if llst ~= nil then
    local front = cdr( llst )
    while front ~= nil do
      local lst = car( llst )
      while lst ~= nil do
        local c = cons( car( lst ), nil )
        if last then
          set_cdr( last, c )
        else
          nlst = c
        end
        last, lst = c, cdr( lst )
      end
      llst, front = front, cdr( front )
    end
    if last then
      set_cdr( last, car( llst ) )
    else
      nlst = car( llst )
    end
  end
  return nlst
end


local function reverse( lst )
  local newlist
  while lst ~= nil do
    newlist, lst = cons( car( lst ), newlist ), cdr( lst )
  end
  return newlist
end


local function append_reverse( rhd, tl )
  while rhd ~= nil do
    rhd, tl = cdr( rhd ), cons( car( rhd ), tl )
  end
  return tl
end


local function append_map1( f, lst )
  local newlist, last
  while lst ~= nil do
    local res, tl = f( car( lst ) ), cdr( lst )
    if tl == nil then
      if last then
        set_cdr( last, res )
      else
        newlist = res
      end
    else
      while res ~= nil do
        local c = cons( car( res ), nil )
        if last then
          set_cdr( last, c )
        else
          newlist = c
        end
        last, res = c, cdr( res )
      end
    end
    lst = tl
  end
  return newlist
end

local function append_map( f, ... )
  local n = select( '#', ... )
  if n <= 1 then
    return append_map1( f, (...) )
  else
    local cars, cdrs, newlist, last = { ... }, { ... }
    local last_loop = false
    while true do
      for i = 1, n do
        local lst = cdrs[ i ]
        if lst == nil then return newlist end
        local tl = cdr( lst )
        cars[ i ], cdrs[ i ] = car( lst ), tl
        if tl == nil then last_loop = true end
      end
      local res = f( unpack( cars, 1, n ) )
      if last_loop then
        if last then
          set_cdr( last, res )
        else
          newlist = res
        end
      else
        while res ~= nil do
          local c = cons( car( res ), nil )
          if last then
            set_cdr( last, c )
          else
            newlist = c
          end
          last, res = c, cdr( res )
        end
      end
    end
  end
end


local function zip( ... )
  local n = select( '#', ... )
  if n > 0 then
    local lsts, res, last = { ... }
    while true do
      local el
      for i = n, 1, -1 do
        local l = lsts[ i ]
        if l == nil then return res end
        lsts[ i ] = cdr( l )
        el = cons( car( l ), el )
      end
      local c = cons( el, nil )
      if last then
        set_cdr( last, c )
      else
        res = c
      end
      last = c
    end
  end
  return nil
end


local function map1( f, lst )
  local newlist, last
  if lst ~= nil then
    newlist = cons( f( car( lst ) ), nil )
    last, lst = newlist, cdr( lst )
    while lst ~= nil do
      local c = cons( f( car( lst ) ), nil )
      set_cdr( last, c )
      last, lst = c, cdr( lst )
    end
  end
  return newlist
end

local function safe_car( lst )
  if lst == nil then
    error( "'list.unzip1' requires at least one element each" )
  end
  return car( lst )
end

local function unzip1( lst )
  return map1( safe_car, lst )
end


local function lselect( lst, n, msg )
  if n >= 1 then
    if lst == nil then
      error( msg )
    else
      return cons( car( lst ), nil ), lselect( cdr( lst ), n-1, msg )
    end
  end
end

local function unzip2( lst )
  local res1, res2, last1, last2
  while lst ~= nil do
    local e1, e2 = lselect( car( lst ), 2,
      "'list.unzip2' requires at least two elements each" )
    if last1 then
      set_cdr( last1, e1 )
      set_cdr( last2, e2 )
    else
      res1, res2 = e1, e2
    end
    last1, last2 = e1, e2
    lst = cdr( lst )
  end
  return res1, res2
end

local function unzip3( lst )
  local res1, res2, res3, last1, last2, last3
  while lst ~= nil do
    local e1, e2, e3 = lselect( car( lst ), 3,
      "'list.unzip3' requires at least three elements each" )
    if last1 then
      set_cdr( last1, e1 )
      set_cdr( last2, e2 )
      set_cdr( last3, e3 )
    else
      res1, res2, res3 = e1, e2, e3
    end
    last1, last2, last3 = e1, e2, e3
    lst = cdr( lst )
  end
  return res1, res2, res3
end

local function unzip4( lst )
  local res1, res2, res3, res4, last1, last2, last3, last4
  while lst ~= nil do
    local e1, e2, e3, e4 = lselect( car( lst ), 4,
      "'list.unzip4' requires at least four elements each" )
    if last1 then
      set_cdr( last1, e1 )
      set_cdr( last2, e2 )
      set_cdr( last3, e3 )
      set_cdr( last4, e4 )
    else
      res1, res2, res3, res4 = e1, e2, e3, e4
    end
    last1, last2, last3, last4 = e1, e2, e3, e4
    lst = cdr( lst )
  end
  return res1, res2, res3, res4
end


local function count1( p, lst )
  local n = 0
  while lst ~= nil do
    if p( car( lst ) ) then
      n = n + 1
    end
    lst = cdr( lst )
  end
  return n
end

local function count( p, ... )
  local n = select( '#', ... )
  if n <= 1 then
    return count1( p, (...) )
  else
    local cars, cdrs, c = { ... }, { ... }, 0
    while true do
      for i = 1, n do
        local lst = cdrs[ i ]
        if lst == nil then return c end
        cars[ i ], cdrs[ i ] = car( lst ), cdr( lst )
      end
      if p( unpack( cars, 1, n ) ) then
        c = c + 1
      end
    end
  end
end


local function map( f, ... )
  local n = select( '#', ... )
  if n <= 1 then
    return map1( f, (...) )
  else
    local cars, cdrs, nlst, last = { ... }, { ... }
    while true do
      for i = 1, n do
        local lst = cdrs[ i ]
        if lst == nil then return nlst end
        cars[ i ], cdrs[ i ] = car( lst ), cdr( lst )
      end
      local c = cons( f( unpack( cars, 1, n ) ), nil )
      if last then
        set_cdr( last, c )
      else
        nlst = c
      end
      last = c
    end
  end
end


local function for_each1( f, lst )
  while lst ~= nil do
    f( car( lst ) )
    lst = cdr( lst )
  end
end

local function for_each( f, ... )
  local n = select( '#', ... )
  if n <= 1 then
    return for_each1( f, (...) )
  else
    local cars, cdrs = { ... }, { ... }
    while true do
      for i = 1, n do
        local lst = cdrs[ i ]
        if lst == nil then return end
        cars[ i ], cdrs[ i ] = car( lst ), cdr( lst )
      end
      f( unpack( cars, 1, n ) )
    end
  end
end


local function pair_for_each1( f, lst )
  while lst ~= nil do
    local tl = cdr( lst )
    f( lst )
    lst = tl
  end
end

local function pair_for_each( f, ... )
  local n = select( '#', ... )
  if n <= 1 then
    return pair_for_each1( f, (...) )
  else
    local prs, cdrs = { ... }, { ... }
    while true do
      for i = 1, n do
        local lst = cdrs[ i ]
        if lst == nil then return end
        prs[ i ], cdrs[ i ] = lst, cdr( lst )
      end
      f( unpack( prs, 1, n ) )
    end
  end
end


local function filter_map1( f, lst )
  local newlist, last
  while lst ~= nil do
    local v = f( car( lst ) )
    if v ~= nil then
      local c = cons( v, nil )
      if last ~= nil then
        set_cdr( last, c )
      else
        newlist = c
      end
      last = c
    end
    lst = cdr( lst )
  end
  return newlist
end

local function filter_map( f, ... )
  local n = select( '#', ... )
  if n <= 1 then
    return filter_map1( f, (...) )
  else
    local cars, cdrs, nlst, last = { ... }, { ... }
    while true do
      for i = 1, n do
        local lst = cdrs[ i ]
        if lst == nil then return nlst end
        cars[ i ], cdrs[ i ] = car( lst ), cdr( lst )
      end
      local v = f( unpack( cars, 1, n ) )
      if v ~= nil then
        local c = cons( v, nil )
        if last then
          set_cdr( last, c )
        else
          nlst = c
        end
        last = c
      end
    end
  end
end


local function fold1( op, init, lst )
  while lst ~= nil do
    init, lst = op( init, car( lst ) ), cdr( lst )
  end
  return init
end

local function fold( op, init, ... )
  local n = select( '#', ... )
  if n <= 1 then
    return fold1( op, init, (...) )
  else
    local cars, cdrs = { ... }, { ... }
    while true do
      for i = 1, n do
        local lst = cdrs[ i ]
        if lst == nil then return init end
        cars[ i ], cdrs[ i ] = car( lst ), cdr( lst )
      end
      init = op( init, unpack( cars, 1, n ) )
    end
  end
end


local function reduce( f, rid, lst )
  if lst == nil then
    return rid
  else
    return fold1( f, car( lst ), cdr( lst ) )
  end
end


local function fold_right1( op, init, lst )
  local rev = reverse( lst )
  while rev ~= nil do
    init, rev = op( car( rev ), init ), cdr( rev )
  end
  return init
end

local function fold_right( op, init, ... )
  local n = select( '#', ... )
  if n <= 1 then
    return fold_right1( op, init, (...) )
  else
    local cars, cdrs = { 1, ... }, { ... }
    for i = 1, n do
      cdrs[ i ] = reverse( cdrs[ i ] )
    end
    while true do
      for i = 1, n do
        local lst = cdrs[ i ]
        if lst == nil then return init end
        cars[ i ], cdrs[ i ] = car( lst ), cdr( lst )
      end
      cars[ n+1 ] = init
      init = op( unpack( cars, 1, n+1 ) )
    end
  end
end


local function reduce_right( f, rid, lst )
  if lst == nil then
    return rid
  else
    local tl = cdr( lst )
    if tl == nil then
      return car( lst )
    else
      return f( car( lst ), fold1( f, car( tl ), cdr( tl ) ) )
    end
  end
end


local function pair_fold1( op, init, lst )
  while lst ~= nil do
    local tl = cdr( lst )
    init, lst = op( init, lst ), tl
  end
  return init
end

local function pair_fold( op, init, ... )
  local n = select( '#', ... )
  if n <= 1 then
    return pair_fold1( op, init, (...) )
  else
    local prs, cdrs = { ... }, { ... }
    while true do
      for i = 1, n do
        local lst = cdrs[ i ]
        if lst == nil then return init end
        prs[ i ], cdrs[ i ] = lst, cdr( lst )
      end
      init = op( init, unpack( prs, 1, n ) )
    end
  end
end


local function pair_fold_right1( op, init, lst )
  local rev = reverse( lst )
  while rev ~= nil do
    local tl = cdr( rev )
    init, rev = op( rev, init ), tl
  end
  return init
end

local function pair_fold_right( op, init, ... )
  local n = select( '#', ... )
  if n <= 1 then
    return pair_fold_right1( op, init, (...) )
  else
    local prs, cdrs = { ... }, { ... }
    for i = 1, n do
      cdrs[ i ] = reverse( cdrs[ i ] )
    end
    while true do
      for i = 1, n do
        local lst = cdrs[ i ]
        if lst == nil then return init end
        prs[ i ], cdrs[ i ] = lst, cdr( lst )
      end
      prs[ n+1 ] = init
      init = op( unpack( prs, 1, n+1 ) )
    end
  end
end


local function unfold( p, f, g, seed, tail_gen, ... )
  if p( seed ) then
    local lst
    if tail_gen then lst = tail_gen( seed, ... ) end
    return lst
  else
    local lst = cons( f( seed ), nil )
    local last = lst
    seed = g( seed )
    while not p( seed ) do
      local c = cons( f( seed ), nil )
      set_cdr( last, c )
      last, seed = c, g( seed )
    end
    if tail_gen then
      set_cdr( last, tail_gen( seed, ... ) )
    end
    return lst
  end
end


local function unfold_right( p, f, g, seed, tail )
  while not p( seed ) do
    tail, seed = cons( f( seed ), tail ), g( seed )
  end
  return tail
end


local function filter( p, lst, ... )
  local newlist, last
  while lst ~= nil and not p( car( lst ), ... ) do
    lst = cdr( lst )
  end
  if lst ~= nil then
    newlist, lst = cons( car( lst ), nil ), cdr( lst )
    last = newlist
    while lst ~= nil do
      local hd = car( lst )
      if p( hd, ... ) then
        local c = cons( hd, nil )
        set_cdr( last, c )
        last = c
      end
      lst = cdr( lst )
    end
  end
  return newlist
end


local function partition( p, lst, ... )
  local yes, no, lastyes, lastno
  while lst ~= nil do
    local hd = car( lst )
    local c = cons( hd, nil )
    if p( hd, ... ) then
      if yes == nil then
        yes = c
      else
        set_cdr( lastyes, c )
      end
      lastyes = c
    else
      if no == nil then
        no = c
      else
        set_cdr( lastno, c )
      end
      lastno = c
    end
    lst = cdr( lst )
  end
  return yes, no
end


local function remove( p, lst, ... )
  local newlist, last
  while lst ~= nil and p( car( lst ), ... ) do
    lst = cdr( lst )
  end
  if lst ~= nil then
    newlist, lst = cons( car( lst ), nil ), cdr( lst )
    last = newlist
    while lst ~= nil do
      local hd = car( lst )
      if not p( hd, ... ) then
        local c = cons( hd, nil )
        set_cdr( last, c )
        last = c
      end
      lst = cdr( lst )
    end
  end
  return newlist
end


local function find_tail( p, lst, ... )
  while lst ~= nil do
    if p( car( lst ), ... ) then
      return lst
    end
    lst = cdr( lst )
  end
  return nil
end


local function member( x, lst, eq )
  eq = eq or equal
  return find_tail( eq, lst, x )
end


local function find( p, lst, ... )
  lst = find_tail( p, lst, ... )
  return lst and car( lst )
end


local function any1( p, lst )
  while lst ~= nil do
    local r = p( car( lst ) )
    if r then return r end
    lst = cdr( lst )
  end
  return false
end

local function any( p, ... )
  local n = select( '#', ... )
  if n <= 1 then
    return any1( p, (...) )
  else
    local cars, cdrs = { ... }, { ... }
    while true do
      for i = 1, n do
        local lst = cdrs[ i ]
        if lst == nil then return false end
        cars[ i ], cdrs[ i ] = car( lst ), cdr( lst )
      end
      local r = p( unpack( cars, 1, n ) )
      if r then return r end
    end
  end
end


local function every1( p, lst )
  while lst ~= nil do
    local r = p( car( lst ) )
    if not r then return r end
    lst = cdr( lst )
  end
  return true
end

local function every( p, ... )
  local n = select( '#', ... )
  if n <= 1 then
    return every1( p, (...) )
  else
    local cars, cdrs = { ... }, { ... }
    while true do
      for i = 1, n do
        local lst = cdrs[ i ]
        if lst == nil then return true end
        cars[ i ], cdrs[ i ] = car( lst ), cdr( lst )
      end
      local r = p( unpack( cars, 1, n ) )
      if not r then return r end
    end
  end
end


local function index1( p, lst )
  local i = 0
  while lst ~= nil do
    i = i + 1
    if p( car( lst ) ) then
      return i
    end
    lst = cdr( lst )
  end
  return nil
end

local function index( p, ... )
  local n = select( '#', ... )
  if n <= 1 then
    return index1( p, (...) )
  else
    local cars, cdrs, c = { ... }, { ... }, 1
    while true do
      for i = 1, n do
        local lst = cdrs[ i ]
        if lst == nil then return nil end
        cars[ i ], cdrs[ i ] = car( lst ), cdr( lst )
      end
      if p( unpack( cars, 1, n ) ) then
        return c
      end
      c = c + 1
    end
  end
end


local function span( p, lst, ... )
  local newlist, last
  while lst ~= nil do
    local hd = car( lst )
    if not p( hd, ... ) then break end
    local c = cons( hd, nil )
    if last then
      set_cdr( last, c )
    else
      newlist = c
    end
    last, lst = c, cdr( lst )
  end
  return newlist, lst
end


local function lbreak( p, lst, ... )
  local newlist, last
  while lst ~= nil do
    local hd = car( lst )
    if p( hd, ... ) then break end
    local c = cons( hd, nil )
    if last then
      set_cdr( last, c )
    else
      newlist = c
    end
    last, lst = c, cdr( lst )
  end
  return newlist, lst
end


local function take_while( p, lst, ... )
  return (span( p, lst, ... ))
end


local function drop_while( p, lst, ... )
  while lst ~= nil and p( car( lst ), ... ) do
    lst = cdr( lst )
  end
  return lst
end


local function delete( x, lst, eq )
  eq = eq or equal
  return remove( eq, lst, x )
end


local function delete_duplicates( lst, eq )
  local newlist, last, lastc
  if lst ~= nil then
    local c = car( lst )
    eq, newlist = eq or equal, cons( c, nil )
    last, lastc, lst = newlist, c, cdr( lst )
    while lst ~= nil do
      c = car( lst )
      if not eq( lastc, c ) then
        local cell = cons( c, nil )
        set_cdr( last, cell )
        last, lastc = cell, c
      end
      lst = cdr( lst )
    end
  end
  return newlist
end


local function traverse( lst )
  return function()
    if lst ~= nil then
      local hd = car( lst )
      lst = cdr( lst )
      return hd, lst
    end
  end
end


return {
  -- primitives
  cons = cons,
  car = car,
  cdr = cdr,
  set_car = set_car,
  set_cdr = set_cdr,
  -- constructors
  list = list,
  xcons = xcons,
  make = make,
  tabulate = tabulate,
  copy = copy,
  circular = circular,
  iota = iota,
  -- predicates
  is_circular = is_circular,
  is_null = is_null,
  is_equal = is_equal,
  -- selectors
  caar = caar,
  cadr = cadr,
  cdar = cdar,
  cddr = cddr,
  caaar = caaar,
  caadr = caadr,
  cadar = cadar,
  caddr = caddr,
  cdaar = cdaar,
  cdadr = cdadr,
  cddar = cddar,
  cdddr = cdddr,
  caaaar = caaaar,
  caaadr = caaadr,
  caadar = caadar,
  caaddr = caaddr,
  cadaar = cadaar,
  cadadr = cadadr,
  caddar = caddar,
  cadddr = cadddr,
  cdaaar = cdaaar,
  cdaadr = cdaadr,
  cdadar = cdadar,
  cdaddr = cdaddr,
  cddaar = cddaar,
  cddadr = cddadr,
  cdddar = cdddar,
  cddddr = cddddr,
  first = car,
  second = cadr,
  third = caddr,
  fourth = cadddr,
  fifth = fifth,
  sixth = sixth,
  seventh = seventh,
  eighth = eighth,
  ninth = ninth,
  tenth = tenth,
  car_cdr = car_cdr,
  split_at = split_at,
  take = take,
  drop = drop,
  take_right = take_right,
  drop_right = drop_right,
  ref = ref,
  last_pair = last_pair,
  last = last,
  -- miscellaneous
  length = length,
  length_ = length_,
  append = append,
  concatenate = concatenate,
  reverse = reverse,
  append_reverse = append_reverse,
  append_map = append_map,
  zip = zip,
  unzip1 = unzip1,
  unzip2 = unzip2,
  unzip3 = unzip3,
  unzip4 = unzip4,
  count = count,
  -- fold, unfold & map
  map = map,
  for_each = for_each,
  pair_for_each = pair_for_each,
  map_in_order = map,
  filter_map = filter_map,
  fold = fold,
  fold_right = fold_right,
  reduce = reduce,
  reduce_right = reduce_right,
  pair_fold = pair_fold,
  pair_fold_right = pair_fold_right,
  unfold = unfold,
  unfold_right = unfold_right,
  -- filtering & partitioning
  filter = filter,
  partition = partition,
  remove = remove,
  -- searching
  find_tail = find_tail,
  member = member,
  find = find,
  any = any,
  every = every,
  index = index,
  span = span,
  lbreak = lbreak, -- break is a reserved identifier in Lua!
  take_while = take_while,
  drop_while = drop_while,
  -- deleting
  delete = delete,
  delete_duplicates = delete_duplicates,
  -- iterating
  traverse = traverse,
}

