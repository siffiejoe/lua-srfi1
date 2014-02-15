#!/usr/bin/env lua

local LARGE = 100000
local maj,min = assert( _VERSION:match( "(%d+)%.(%d+)$" ) )
local V = maj..min
package.path = "./?.lua;"..package.path
package.cpath = "./?."..V..".so;./?."..V..".dll;"..package.cpath
local L = require( "srfi1" )

local assert, done
do
  local N = LARGE

  local fh, n_tests, n_wrap = io.stdout, 0, 70
  function assert( cond )
    n_tests = n_tests + 1
    if cond then
      fh:write( "." )
      if n_tests % n_wrap == 0 then
        fh:write( "\n" )
      end
      fh:flush()
    else
      if n_tests > 1 then
        fh:write( "\n" )
        fh:flush()
      end
      error( "test "..n_tests.." failed!", 2 )
    end
  end

  function done()
    if n_tests % n_wrap ~= 0 then
      fh:write( "\n" )
    end
    fh:write( n_tests, " tests ok\n" )
    fh:flush()
  end

  local gc = collectgarbage
  local function mem()
    gc() gc()
    return gc( "count" )*1024
  end

  -- check memory
  local m_d, m_a
  local lst = nil
  for i = N, 1, -1 do
    lst = L.cons( i, lst )
  end
  m_d = mem()
  lst = nil
  m_a = mem()
  fh:write( "memory per cons cell: ", (m_d-m_a)/N, "\n" )
end


-- helper functions
local function id( i ) return i end
local function even( a ) return a % 2 == 0 end
local function odd( a ) return a % 2 == 1 end
local function lt( a, b ) return a < b end
local function gt( a, b ) return a > b end
local function lt_5( a ) return  a < 5 end
local function gt_4( a ) return  a > 4 end
local function all( p )
  return function( ... )
    for i = 1, select( '#', ... ) do
      if not p( (select( i, ... )) ) then return false end
    end
    return true
  end
end
local all_even = all( even )
local function inc( i ) return i + 1 end
local function dec( i ) return i - 1 end
local function sqr( x ) return x * x end
local function add2( a, b ) return a + b end


-- tests
local large_lst = nil
for i = LARGE, 1, -1 do
  large_lst = L.cons( i, large_lst )
end


do -- cons, car, cdr, set_car, set_cdr
  local c = L.cons( 1, 2 )
  assert( L.car( c ) == 1 )
  assert( L.cdr( c ) == 2 )
  L.set_car( c, 3 )
  L.set_cdr( c, 4 )
  assert( L.car( c ) == 3 )
  assert( L.cdr( c ) == 4 )
end

do -- list
  local l1 = L.list( 1, 2, 3, 4, 5 )
  assert( L.car( l1 ) == 1 )
  assert( L.is_equal( L.cdr( l1 ), L.list( 2, 3, 4, 5 ) ) )
  local l2
  for i = 5, 1, -1 do
    l2 = L.cons( i, l2 )
  end
  assert( L.is_equal( l1, l2 ) )
  local l3 = L.list()
  assert( l3 == nil )
end

do -- xcons
  local c = L.xcons( 1, 2 )
  assert( L.car( c ) == 2 )
  assert( L.cdr( c ) == 1 )
end

do -- make
  local l1 = L.make( 3, true )
  assert( L.is_equal( l1, L.list( true, true, true ) ) )
  local l2 = L.make( 0, true )
  assert( l2 == nil )
  local l3 = L.make( LARGE, true )
  assert( L.length( l3 ) == LARGE )
end

do -- tabulate
  local l1 = L.tabulate( 3, id )
  assert( L.is_equal( l1, L.list( 1, 2, 3 ) ) )
  local l2 = L.tabulate( 0, id )
  assert( l2 == nil )
  local l3 = L.tabulate( LARGE, id )
  assert( L.length( l3 ) == LARGE )
  assert( L.last( l3 ) == LARGE )
end

do -- copy
  local l1 = L.list( 1, 2, 3, 4, 5 )
  local l2 = L.copy( l1 )
  assert( l1 ~= l2 )
  assert( L.car( l1 ) == 1 )
  assert( L.is_equal( L.cdr( l1 ), L.list( 2, 3, 4, 5 ) ) )
  assert( L.length( l1 ) == 5 )
  assert( L.last( l1 ) == 5 )
  local l2 = L.copy( nil )
  assert( l2 == nil )
  local l3 = L.copy( large_lst )
  assert( L.is_equal( l3, large_lst ) )
end

do -- circular
  local l1 = L.circular( 1, 2, 3 )
  assert( L.car( l1 ) == 1 )
  assert( L.ref( l1, 4 ) == 1 )
  assert( L.ref( l1, 6 ) == 3 )
  assert( L.is_circular( l1 ) )
  local l2 = L.circular()
  assert( l2 == nil )
end

do -- iota
  local l1 = L.iota( 6 )
  assert( L.is_equal( l1, L.list( 0, 1, 2, 3, 4, 5 ) ) )
  local l2 = L.iota( 5, 1 )
  assert( L.is_equal( l2, L.list( 1, 2, 3, 4, 5 ) ) )
  local l3 = L.iota( 6, 2, 0.5 )
  assert( L.is_equal( l3, L.list( 2, 2.5, 3, 3.5, 4, 4.5 ) ) )
  local l4 = L.iota( LARGE, 1, 1 )
  assert( L.length( l4 ) == LARGE )
  assert( L.last( l4 ) == LARGE )
end

do -- is_circular
  assert( L.is_circular( L.circular( true, false ) ) )
  assert( not L.is_circular( L.list( true, false ) ) )
  assert( not L.is_circular( nil ) )
  local l1 = L.iota( LARGE, 1, 1 )
  L.set_cdr( L.last_pair( l1 ), l1 )
  assert( L.is_circular( l1 ) )
end

do -- is_null
  assert( L.is_null( nil ) )
  assert( not L.is_null( L.list( 1 ) ) )
  assert( not L.is_null( large_lst ) )
end

do -- is_equal
  local l1 = L.list( 1, 2, 3 )
  assert( L.is_equal( l1, l1 ) )
  assert( L.is_equal( l1, L.list( 1, 2, 3 ) ) )
  assert( L.is_equal( nil, nil ) )
  assert( not L.is_equal( l1, L.list( 1, 2, 4 ) ) )
  assert( not L.is_equal( l1, L.list( 1, 2 ) ) )
  assert( not L.is_equal( l1, nil ) )
  local l2 = L.list( L.list( 1, 2 ), L.list( 2, 3 ) )
  local l3 = L.list( L.list( 1, 2 ), L.list( 2, 3 ) )
  local l4 = L.list( L.list( 1, 2 ) )
  assert( L.is_equal( l2, l3, L.is_equal ) )
  assert( not L.is_equal( l3, l4, L.is_equal ) )
  assert( L.is_equal( large_lst, large_lst ) )
end

do -- c[ad][ad]+r
  local l01 = L.cons( 1, 2 )
  local l02 = L.cons( 3, 4 )
  local l03 = L.cons( 5, 6 )
  local l04 = L.cons( 7, 8 )
  local l05 = L.cons( 9, 10 )
  local l06 = L.cons( 11, 12 )
  local l07 = L.cons( 13, 14 )
  local l08 = L.cons( 15, 16 )
  local l09 = L.cons( l01, l02 )
  local l10 = L.cons( l03, l04 )
  local l11 = L.cons( l05, l06 )
  local l12 = L.cons( l07, l08 )
  local l13 = L.cons( l09, l10 )
  local l14 = L.cons( l11, l12 )
  local l15 = L.cons( l13, l14 )
  assert( L.caar( l09 ) == 1 )
  assert( L.cdar( l09 ) == 2 )
  assert( L.cadr( l09 ) == 3 )
  assert( L.cddr( l09 ) == 4 )
  assert( L.caaar( l13 ) == 1 )
  assert( L.cdaar( l13 ) == 2 )
  assert( L.cadar( l13 ) == 3 )
  assert( L.cddar( l13 ) == 4 )
  assert( L.caadr( l13 ) == 5 )
  assert( L.cdadr( l13 ) == 6 )
  assert( L.caddr( l13 ) == 7 )
  assert( L.cdddr( l13 ) == 8 )
  assert( L.caaaar( l15 ) == 1 )
  assert( L.cdaaar( l15 ) == 2 )
  assert( L.cadaar( l15 ) == 3 )
  assert( L.cddaar( l15 ) == 4 )
  assert( L.caadar( l15 ) == 5 )
  assert( L.cdadar( l15 ) == 6 )
  assert( L.caddar( l15 ) == 7 )
  assert( L.cdddar( l15 ) == 8 )
  assert( L.caaadr( l15 ) == 9 )
  assert( L.cdaadr( l15 ) == 10 )
  assert( L.cadadr( l15 ) == 11 )
  assert( L.cddadr( l15 ) == 12 )
  assert( L.caaddr( l15 ) == 13 )
  assert( L.cdaddr( l15 ) == 14 )
  assert( L.cadddr( l15 ) == 15 )
  assert( L.cddddr( l15 ) == 16 )
end

do -- first - tenth
  local l1 = L.tabulate( 11, id )
  assert( L.first( l1 ) == 1 )
  assert( L.second( l1 ) == 2 )
  assert( L.third( l1 ) == 3 )
  assert( L.fourth( l1 ) == 4 )
  assert( L.fifth( l1 ) == 5 )
  assert( L.sixth( l1 ) == 6 )
  assert( L.seventh( l1 ) == 7 )
  assert( L.eighth( l1 ) == 8 )
  assert( L.ninth( l1 ) == 9 )
  assert( L.tenth( l1 ) == 10 )
  assert( not pcall( function()
    return L.first( nil )
  end ) )
  assert( not pcall( function()
    return L.second( nil )
  end ) )
  assert( not pcall( function()
    return L.third( nil )
  end ) )
  assert( not pcall( function()
    return L.fourth( nil )
  end ) )
  assert( not pcall( function()
    return L.fifth( nil )
  end ) )
  assert( not pcall( function()
    return L.sixth( nil )
  end ) )
  assert( not pcall( function()
    return L.seventh( nil )
  end ) )
  assert( not pcall( function()
    return L.eighth( nil )
  end ) )
  assert( not pcall( function()
    return L.ninth( nil )
  end ) )
  assert( not pcall( function()
    return L.tenth( nil )
  end ) )
end

do -- car_cdr
  local c = L.cons( 1, 2 )
  local x, y = L.car_cdr( c )
  assert( x == L.car( c ) )
  assert( y == L.cdr( c ) )
end

do -- splitat
  local l1 = L.list( 1, 2, 3, 4 )
  local l2, l3 = L.splitat( l1, 2 )
  assert( L.is_equal( l2, L.list( 1, 2 ) ) )
  assert( L.is_equal( l3, L.list( 3, 4 ) ) )
  local l4, l5 = L.splitat( l1, 0 )
  assert( L.is_equal( l4, nil ) )
  assert( L.is_equal( l5, l1 ) )
  assert( l5 == l1 )
  local l6, l7 = L.splitat( l1, 5 )
  assert( L.is_equal( l6, l1 ) )
  assert( l7 == nil )
  local l8, l9 = L.splitat( nil, 2 )
  assert( l8 == nil )
  assert( l9 == nil )
  local i = math.floor( LARGE/2 )
  local l10, l11 = L.splitat( large_lst, i )
  assert( L.length( l10 ) == i )
  assert( L.last( l10 ) == i )
  assert( L.length( l11 ) == LARGE-i )
end

do -- take
  local l1 = L.list( 1, 2, 3, 4 )
  assert( L.is_equal( L.take( l1, 1 ), L.list( 1 ) ) )
  assert( L.take( l1, 0 ) == nil )
  assert( L.take( nil, 2 ) == nil )
  assert( L.is_equal( L.take( l1, 4 ), l1 ) )
  assert( L.is_equal( L.take( l1, 6 ), l1 ) )
  assert( L.take( l1, 4 ) ~= l1 )
  local l2 = L.take( large_lst, 3 )
  assert( L.is_equal( l2, L.list( 1, 2, 3 ) ) )
end

do -- drop
  local l1 = L.list( 1, 2, 3, 4 )
  assert( L.is_equal( L.drop( l1, 3 ), L.list( 4 ) ) )
  assert( L.is_equal( L.drop( l1, 0 ), l1 ) )
  assert( L.drop( l1, 0 ) == l1 )
  assert( L.drop( nil, 2 ) == nil )
  assert( L.drop( l1, 4 ) == nil )
  assert( L.drop( l1, 6 ) == nil )
  local l2 = L.drop( large_lst, LARGE-3 )
  assert( L.length( l2 ) == 3 )
  assert( L.is_equal( l2, L.iota( 3, LARGE-2 ) ) )
end

do -- take_right
  local l1 = L.list( 1, 2, 3, 4 )
  assert( L.is_equal( L.take_right( l1, 2 ), L.list( 3, 4 ) ) )
  assert( L.take_right( l1, 0 ) == nil )
  assert( L.take_right( nil, 2 ) == nil )
  assert( L.take_right( l1, 4 ) == l1 )
  assert( L.take_right( l1, 6 ) == l1 )
  local l2 = L.take_right( large_lst, 2 )
  assert( L.length( l2 ) == 2 )
  assert( L.is_equal( l2, L.iota( 2, LARGE-1 ) ) )
end

do -- drop_right
  local l1 = L.list( 1, 2, 3, 4 )
  assert( L.is_equal( L.drop_right( l1, 2 ), L.list( 1, 2 ) ) )
  assert( L.is_equal( L.drop_right( l1, 0 ), l1 ) )
  assert( L.drop_right( l1, 0 ) ~= l1 )
  assert( L.drop_right( nil, 2 ) == nil )
  assert( L.drop_right( l1, 4 ) == nil )
  assert( L.drop_right( l1, 6 ) == nil )
  local l2 = L.drop_right( large_lst, LARGE-3 )
  assert( L.is_equal( l2, L.list( 1, 2, 3 ) ) )
end

do -- ref
  local l1 = L.list( 1, 2, 3, 4 )
  assert( L.ref( l1, 1 ) == 1 )
  assert( L.ref( l1, 4 ) == 4 )
  assert( not pcall( function()
    return L.ref( l1, 0 )
  end ) )
  assert( not pcall( function()
    return L.ref( l1, 6 )
  end ) )
  assert( not pcall( function()
    return L.ref( nil, 1 )
  end ) )
  assert( L.ref( large_lst, LARGE-1 ) == LARGE-1 )
end

do -- last_pair
  local l1 = L.list( 1, 2, 3, 4 )
  assert( L.is_equal( L.last_pair( l1 ), L.list( 4 ) ) )
  assert( not pcall( function()
    return L.last_pair( nil )
  end ) )
  assert( L.is_equal( L.last_pair( large_lst ), L.list( LARGE ) ) )
end

do -- last
  local l1 = L.list( 1, 2, 3, 4 )
  assert( L.last( l1 ) == 4 )
  assert( not pcall( function()
    return L.last( nil )
  end ) )
  assert( L.last( large_lst ) == LARGE )
end

do -- length
  local l1 = L.list( 1, 2, 3, 4 )
  assert( L.length( l1 ) == 4 )
  assert( L.length( nil ) == 0 )
  assert( L.length( large_lst ) == LARGE )
end

do -- length_
  local l1 = L.list( 1, 2, 3, 4 )
  local l2 = L.circular( true, false )
  local l3 = L.list( 1, 2, 3 )
  assert( L.length_( l1 ) == 4 )
  assert( L.length_( nil ) == 0 )
  assert( L.length_( l2 ) == nil )
  assert( L.length_( l3 ) == 3 )
  assert( L.length_( large_lst ) == LARGE )
end

do -- append
  local l1 = L.list( 1, 2 )
  local l2 = L.list( 3, 4 )
  local l3 = L.list( 5, 6 )
  local l4 = L.list( 1, 2, 3, 4 )
  local l5 = L.list( 1, 2, 3, 4, 5, 6 )
  assert( L.is_equal( L.append( l1, l2 ), l4 ) )
  assert( L.is_equal( L.append( l1, nil ), l1 ) )
  assert( L.append( l1, nil ) ~= l1 )
  assert( L.append( nil, l1 ) == l1 )
  assert( L.drop( L.append( l1, l2 ), L.length( l1 ) ) == l2 )
  assert( L.append() == nil )
  assert( L.is_equal( L.append( l1, l2, l3 ), l5 ) )
  local l6 = L.append( large_lst, l5 )
  assert( L.last( l6 ) == 6 )
  assert( L.last( L.append( nil, large_lst ) ) == LARGE )
end

do -- concatenate
  local l1 = L.list( 1, 2 )
  local l2 = L.list( 3, 4 )
  local l3 = L.list( 5, 6 )
  local l4 = L.list( 1, 2, 3, 4, 5, 6 )
  assert( L.is_equal( L.concatenate( L.list( l1, l2, l3 ) ), l4 ) )
  assert( L.is_equal( L.concatenate( L.list( l1, nil ) ), l1 ) )
  assert( L.concatenate( L.list( l1 ) ) == l1 )
  assert( L.concatenate( L.list( l1, nil ) ) ~= l1 )
  assert( L.concatenate( L.list( nil, l1 ) ) == l1 )
  local l5 = L.drop( L.concatenate( L.list( l1, l2 ) ), L.length( l1 ) )
  assert( l5 == l2 )
  assert( L.concatenate( nil ) == nil )
  local l6 = L.concatenate( L.list( large_lst, l4 ) )
  assert( L.last( l6 ) == 6 )
  assert( L.last( L.concatenate( L.list( nil, large_lst ) ) ) == LARGE )
end

do -- reverse
  local l1 = L.reverse( L.list( 1, 2, 3, 4 ) )
  assert( L.is_equal( l1, L.list( 4, 3, 2, 1 ) ) )
  assert( L.reverse( nil ) == nil )
  local l2 = L.reverse( large_lst )
  assert( L.car( l2 ) == LARGE )
  assert( L.last( l2 ) == 1 )
end

do -- append_reverse
  local l1 = L.list( 1, 2 )
  local l2 = L.list( 3, 4 )
  local l3 = L.list( 2, 1, 3, 4 )
  assert( L.is_equal( L.append_reverse( l1, l2 ), l3 ) )
  assert( L.is_equal( L.append_reverse( l1, nil ), L.reverse( l1 ) ) )
  assert( L.is_equal( L.append_reverse( nil, l1 ), l1 ) )
  assert( L.append_reverse( nil, l1 ) == l1 )
  assert( L.drop( L.append_reverse( l1, l2 ), L.length( l1 ) ) == l2 )
  local l4 = L.append_reverse( large_lst, l3 )
  assert( L.last( l4 ) == 4 )
  assert( L.last( L.append_reverse( nil, large_lst ) ) == LARGE )
end

do -- append_map
  local l1 = L.list( 1, 2, 3, 4 )
  local l2 = L.list( 2, 4, 6, 8, 10 )
  local l3 = L.list( 1, -1, 2, -2, 3, -3, 4, -4 )
  local l4 = L.list( 1, 2, 2, 4, 3, 6, 4, 8 )
  local l5 = L.list( 1 )
  local l6 = L.list( 1, -1 )
  local l7 = L.list( 1, 2 )
  local function posneg( v ) return L.list( v, -v ) end
  local function lid( v ) return L.list( v ) end
  local function pairs2( v, w ) return L.list( v, w ) end
  assert( L.is_equal( L.append_map( posneg, l1 ), l3 ) )
  assert( L.append_map( posneg, nil ) == nil )
  assert( L.is_equal( L.append_map( posneg, l5 ), l6 ) )
  assert( L.is_equal( L.append_map( pairs2, l1, l2 ), l4 ) )
  assert( L.is_equal( L.append_map( pairs2, l5, l2 ), l7 ) )
  assert( L.is_equal( L.append_map( lid, large_lst ), large_lst ) )
end

do -- zip
  local l1 = L.list( 1, 2, 3 )
  local l2 = L.list( 2, 3, 4, 5 )
  local l3 = L.list( L.list( 1 ), L.list( 2 ), L.list( 3 ) )
  local l4 = L.list( L.list( 1, 2 ), L.list( 2, 3 ), L.list( 3, 4 ) )
  assert( L.is_equal( L.zip( l1 ), l3, L.is_equal ) )
  assert( L.is_equal( L.zip( l1, l2 ), l4, L.is_equal ) )
  assert( L.zip() == nil )
  assert( L.zip( nil ) == nil )
  assert( L.zip( l1, nil ) == nil )
  local l5
  for i = LARGE, 1, -1 do
    l5 = L.cons( L.list( i ), l5 )
  end
  assert( L.is_equal( L.zip( large_lst ), l5, L.is_equal ) )
end

do -- unzip1
  local l1 = L.list( 1, true, "a", 1 )
  local l2 = L.list( 2, false, "b", 2 )
  local l3 = L.list( 3, true, "c", 3 )
  local l4 = L.list( 4, false, "d", 4 )
  local l6 = L.list( l1, l2, l3, l4 )
  local l7 = L.list( l1, l2, l3, nil )
  assert( L.is_equal( L.unzip1( l6 ), L.list( 1, 2, 3, 4 ) ) )
  assert( L.unzip1( nil ) == nil )
  assert( not pcall( function()
    return L.unzip1( l7 )
  end ) )
end

do -- unzip2
  local l1 = L.list( 1, true, "a", 1 )
  local l2 = L.list( 2, false, "b", 2 )
  local l3 = L.list( 3, true, "c", 3 )
  local l4 = L.list( 4, false, "d", 4 )
  local l5 = L.list( 4 )
  local l6 = L.list( l1, l2, l3, l4 )
  local l7 = L.list( l1, l2, l3, l5 )
  local l8, l9 = L.unzip2( l6 )
  assert( L.is_equal( l8, L.list( 1, 2, 3, 4 ) ) )
  assert( L.is_equal( l9, L.list( true, false, true, false ) ) )
  local l10, l11 = L.unzip2( nil )
  assert( l10 == nil and l11 == nil )
  assert( select( '#', L.unzip2( nil ) ) == 2 )
  assert( not pcall( function()
    return L.unzip2( l7 )
  end ) )
end

do -- unzip3
  local l1 = L.list( 1, true, "a", 1 )
  local l2 = L.list( 2, false, "b", 2 )
  local l3 = L.list( 3, true, "c", 3 )
  local l4 = L.list( 4, false, "d", 4 )
  local l5 = L.list( 4, true )
  local l6 = L.list( l1, l2, l3, l4 )
  local l7 = L.list( l1, l2, l3, l5 )
  local l8, l9, l10 = L.unzip3( l6 )
  assert( L.is_equal( l8, L.list( 1, 2, 3, 4 ) ) )
  assert( L.is_equal( l9, L.list( true, false, true, false ) ) )
  assert( L.is_equal( l10, L.list( "a", "b", "c", "d" ) ) )
  local l11, l12, l13 = L.unzip3( nil )
  assert( l11 == nil and l12 == nil and l13 == nil )
  assert( select( '#', L.unzip3( nil ) ) == 3 )
  assert( not pcall( function()
    return L.unzip3( l7 )
  end ) )
end

do -- unzip4
  local l1 = L.list( 1, true, "a", 1 )
  local l2 = L.list( 2, false, "b", 2 )
  local l3 = L.list( 3, true, "c", 3 )
  local l4 = L.list( 4, false, "d", 4 )
  local l5 = L.list( 4, true, "e" )
  local l6 = L.list( l1, l2, l3, l4 )
  local l7 = L.list( l1, l2, l3, l5 )
  local l8, l9, l10, l11 = L.unzip4( l6 )
  assert( L.is_equal( l8, L.list( 1, 2, 3, 4 ) ) )
  assert( L.is_equal( l9, L.list( true, false, true, false ) ) )
  assert( L.is_equal( l10, L.list( "a", "b", "c", "d" ) ) )
  assert( L.is_equal( l11, L.list( 1, 2, 3, 4 ) ) )
  local l12, l13, l14, l15 = L.unzip4( nil )
  assert( l12 == nil and l13 == nil and l14 == nil and l15 == nil )
  assert( select( '#', L.unzip4( nil ) ) == 4 )
  assert( not pcall( function()
    return L.unzip4( l7 )
  end ) )
end

do -- count
  local l1 = L.list( 1, 2, 3, 4, 5, 6, 7 )
  local l2 = L.list( 1, 1, 2, 2, 3, 3, 4, 4 )
  assert( L.count( even, l1 ) == 3 )
  assert( L.count( even, nil ) == 0 )
  assert( L.count( all_even, l1, l2 ) == 1 )
  assert( L.count( all_even, nil, l2 ) == 0 )
  assert( L.count( all_even, l1, nil ) == 0 )
  assert( L.count( even, large_lst ) >= (LARGE-1)/2 )
end

do -- map
  local function double( x ) return 2 * x end
  local l1 = L.list( 1, 2, 3, 4 )
  local l2 = L.list( 1, 2, 3, 4, 5 )
  local l3 = L.list( 2, 4, 6, 8 )
  assert( L.is_equal( L.map( double, l1 ), l3 ) )
  assert( L.map( double, nil ) == nil )
  assert( L.is_equal( L.map( add2, l1, l2 ), l3 ) )
  assert( L.map( double, nil, l2 ) == nil )
  local l4 = L.map( id, large_lst )
  assert( L.is_equal( large_lst, l4 ) )
  assert( l4 ~= large_lst )
end

do -- for_each
  local i = 0
  local function check1( v )
    i = i + 1
    assert( v == i )
  end
  local j = 0
  local function check2( v, w )
    j = j + 1
    assert( v == j and w == 2*j )
  end
  local l1 = L.list( 1, 2, 3, 4 )
  local l2 = L.list( 2, 4, 6, 8, 10 )
  L.for_each( check1, l1 )
  assert( i == 4 )
  i = 0
  L.for_each( check1, nil )
  assert( i == 0 )
  L.for_each( check2, l1, l2 )
  assert( j == 4 )
end

do -- pair_for_each
  local i = 0
  local function check1( v )
    i = i + 1
    L.set_cdr( v, nil )
    assert( L.car( v ) == i )
  end
  local j = 0
  local function check2( v, w )
    j = j + 1
    L.set_cdr( v, nil )
    L.set_cdr( w, nil )
    assert( L.car( v ) == j and L.car( w ) == 2*j  )
  end
  local l1 = L.list( 1, 2, 3, 4 )
  local l2 = L.copy( l1 )
  local l3 = L.list( 2, 4, 6, 8, 10 )
  L.pair_for_each( check1, l1 )
  assert( i == 4 )
  i = 0
  L.pair_for_each( check1, nil )
  assert( i == 0 )
  L.pair_for_each( check2, l2, l3 )
  assert( j == 4 )
end

do -- map_in_order
  local i = 0
  local function checked_id1( v )
    i = i + 1
    assert( v == i )
    return v
  end
  local j = 0
  local function checked_id2( v, w )
    j = j + 1
    assert( v == j and w == 2*j )
    return v+w
  end
  local l1 = L.list( 1, 2, 3, 4 )
  local l2 = L.list( 2, 4, 6, 8, 10 )
  local l3 = L.list( 3, 6, 9, 12 )
  local l4 = L.map_in_order( checked_id1, l1 )
  assert( L.is_equal( l4, l1 ) )
  assert( l4 ~= l1 )
  assert( i == 4 )
  i = 0
  assert( L.map_in_order( checked_id1, nil ) == nil )
  assert( i == 0 )
  assert( L.is_equal( L.map_in_order( checked_id2, l1, l2 ), l3 ) )
  assert( j == 4 )
  local l5 = L.map_in_order( id, large_lst )
  assert( L.is_equal( large_lst, l5 ) )
  assert( l5 ~= large_lst )
end

do -- filter_map
  local function double_even( x )
    if even( x ) then return 2 * x end
  end
  local function add_odd( x, y )
    if odd( x ) then return x+y end
  end
  local l1 = L.list( 1, 2, 3, 4 )
  local l2 = L.list( 1, 2, 3, 4, 5 )
  local l3 = L.list( 4, 8 )
  local l4 = L.list( 2, 6 )
  assert( L.is_equal( L.filter_map( double_even, l1 ), l3 ) )
  assert( L.filter_map( double_even, nil ) == nil )
  assert( L.filter_map( double_even, L.list( 1 ) ) == nil )
  assert( L.is_equal( L.filter_map( add_odd, l1, l2 ), l4 ) )
  assert( L.filter_map( double_even, nil, l2 ) == nil )
  local l5 = L.filter_map( id, large_lst )
  assert( L.is_equal( large_lst, l5 ) )
  assert( l5 ~= large_lst )
end

do -- fold
  local function horners( a, b, c ) return 10 * a + b + (c or 0) end
  local l1 = L.list( 1, 2, 3, 4 )
  local l2 = L.circular( 1 )
  assert( L.fold( horners, 0, l1 ) == 1234 )
  assert( L.fold( horners, 0, nil ) == 0 )
  assert( L.fold( horners, 0, l1, l2 ) == 2345 )
  assert( L.fold( inc, 0, large_lst ) == LARGE )
end

do -- fold_right
  local function rhorners2( a, b ) return a + 10 * b end
  local function rhorners3( a, b, c ) return a + b + 10 * c end
  local function rinc( _, b ) return b + 1 end
  local l1 = L.list( 1, 2, 3, 4 )
  local l2 = L.list( 1, 1, 1, 1 )
  assert( L.fold_right( rhorners2, 0, l1 ) == 4321 )
  assert( L.fold_right( rhorners2, 0, nil ) == 0 )
  assert( L.fold_right( rhorners3, 0, l1, l2 ) == 5432 )
  assert( L.fold_right( rinc, 0, large_lst ) == LARGE )
end

do -- reduce
  local l1 = L.list( 3, 0, 8, 2, 9, 1 )
  assert( L.reduce( math.max, 0, l1 ) == 9 )
  assert( L.reduce( math.max, 0, nil ) == 0 )
  assert( L.reduce( math.max, 0, L.list( 1 ) ) == 1 )
  assert( L.reduce( add2, 0, l1 ) == 23 )
  assert( L.reduce( add2, 17, l1 ) == 23 )
  assert( L.reduce( add2, 17, nil ) == 17 )
end

do -- reduce_right
  local l1 = L.list( 1, 2 )
  local l2 = L.list( l1, L.list( 3, 4 ) )
  local l3 = L.list( 1, 2, 3, 4 )
  assert( L.is_equal( L.reduce_right( L.append, nil, l2 ), l3 ) )
  assert( L.reduce_right( L.append, nil, nil ) == nil )
  assert( L.reduce_right( L.append, nil, L.list( l1 ) ) == l1 )
  assert( L.is_equal( L.reduce_right( L.append, l1, l2 ), l3 ) )
  assert( L.reduce_right( L.append, l1, nil ) == l1 )
end

do -- pair_fold
  local function horners( a, b, c )
    L.set_cdr( b, nil )
    if c then L.set_cdr( c, nil ) end
    return 10 * a + L.car( b ) + (c and L.car( c ) or 0)
  end
  local l1 = L.list( 1, 2, 3, 4 )
  local l2 = L.copy( l1 )
  local l3 = L.list( 1, 1, 1, 1, 1, 1, 1, 1 )
  assert( L.pair_fold( horners, 0, l1 ) == 1234 )
  assert( L.pair_fold( horners, 0, nil ) == 0 )
  assert( L.pair_fold( horners, 0, l2, l3 ) == 2345 )
  assert( L.pair_fold( inc, 0, large_lst ) == LARGE )
end

do -- pair_fold_right
  local function rhorners2( a, b )
    L.set_cdr( a, nil )
    return L.car( a ) + 10 * b
  end
  local function rhorners3( a, b, c )
    L.set_cdr( a, nil )
    L.set_cdr( b, nil )
    return L.car( a ) + L.car( b ) + 10 * c
  end
  local function rinc( _, b ) return b + 1 end
  local l1 = L.list( 1, 2, 3, 4 )
  local l2 = L.copy( l1 )
  local l3 = L.list( 1, 1, 1, 1 )
  assert( L.pair_fold_right( rhorners2, 0, l1 ) == 4321 )
  assert( L.pair_fold_right( rhorners2, 0, nil ) == 0 )
  assert( L.pair_fold_right( rhorners3, 0, l2, l3 ) == 5432 )
  assert( L.pair_fold_right( rinc, 0, large_lst ) == LARGE )
end

do -- unfold
  local function gen_tail() return L.list( 5 ) end
  local l1 = L.list( 1, 2, 3, 4 )
  local l2 = L.unfold( gt_4, sqr, inc, 1 )
  assert( L.is_equal( l2, L.list( 1, 4, 9, 16 ) ) )
  assert( L.unfold( gt_4, sqr, inc, 5 ) == nil )
  local l3 = L.unfold( L.is_null, L.car, L.cdr, l1, gen_tail )
  assert( L.is_equal( l3, L.list( 1, 2, 3, 4, 5 ) ) )
end

do -- unfold_right
  local function eq_0( a ) return a == 0 end
  local l1 = L.list( 1, 2, 3, 4 )
  local l2 = L.unfold_right( eq_0, sqr, dec, 5 )
  assert( L.is_equal( l2, L.list( 1, 4, 9, 16, 25 ) ) )
  assert( L.unfold_right( eq_0, sqr, dec, 0 ) == nil )
  local l3 = L.unfold_right( L.is_null, L.car, L.cdr, l1, L.list( 0 ) )
  assert( L.is_equal( l3, L.list( 4, 3, 2, 1, 0 ) ) )
end

do -- filter
  local l1 = L.list( 1, 2, 3, 4, 5, 6, 7, 8 )
  local l2 = L.list( 2, 4, 6, 8 )
  local l3 = L.list( 1, 2, 3, 4 )
  assert( L.is_equal( L.filter( even, l1 ), l2 ) )
  assert( L.filter( even, nil ) == nil )
  assert( L.is_equal( L.filter( lt, l1, 5 ), l3 ) )
  assert( L.filter( lt, l1, 1 ) == nil )
  local l4 = L.filter( lt, large_lst, LARGE+1 )
  assert( L.is_equal( l4, large_lst ) )
  assert( l4 ~= large_lst )
end

do -- partition
  local l1 = L.list( 1, 2, 3, 4, 5, 6, 7, 8 )
  local l2 = L.list( 2, 4, 6, 8 )
  local l3 = L.list( 1, 3, 5, 7 )
  local l4 = L.list( 1, 2, 3, 4 )
  local l5 = L.list( 5, 6, 7, 8 )
  local l6, l7 = L.partition( even, l1 )
  assert( L.is_equal( l6, l2 ) )
  assert( L.is_equal( l7, l3 ) )
  local l8, l9 = L.partition( even, nil )
  assert( l8 == nil )
  assert( l9 == nil )
  local l10, l11 = L.partition( lt, l1, 5 )
  assert( L.is_equal( l10, l4 ) )
  assert( L.is_equal( l11, l5 ) )
  local l12, l13 = L.partition( lt, large_lst, LARGE+1 )
  assert( L.is_equal( l12, large_lst ) )
  assert( l12 ~= large_lst )
  assert( l13 == nil )
end

do -- remove
  local l1 = L.list( 1, 2, 3, 4, 5, 6, 7, 8 )
  local l2 = L.list( 2, 4, 6, 8 )
  local l3 = L.list( 5, 6, 7, 8 )
  assert( L.is_equal( L.remove( odd, l1 ), l2 ) )
  assert( L.remove( odd, nil ) == nil )
  assert( L.is_equal( L.remove( lt, l1, 5 ), l3 ) )
  assert( L.remove( lt, l1, 9 ) == nil )
  local l4 = L.remove( lt, large_lst, 1 )
  assert( L.is_equal( l4, large_lst ) )
  assert( l4 ~= large_lst )
end

do -- find_tail
  local l1 = L.list( 1, 2, 3, 4, 5 )
  assert( L.is_equal( L.find_tail( even, l1 ), L.cdr( l1 ) ) )
  assert( L.find_tail( even, l1 ) == L.cdr( l1 ) )
  assert( L.find_tail( even, nil ) == nil )
  assert( L.find_tail( gt, l1, 1 ) == L.cdr( l1 ) )
  assert( L.find_tail( gt, l1, 5 ) == nil )
  assert( L.find_tail( gt, large_lst, 1 ) == L.cdr( large_lst ) )
end

do -- member
  local l1 = L.list( 1, 2, 3, 4 )
  assert( L.is_equal( L.member( 2, l1 ), L.cdr( l1 ) ) )
  assert( L.member( 2, l1 ) == L.cdr( l1 ) )
  assert( L.member( 0, l1 ) == nil )
  assert( L.member( 1, nil ) == nil )
  local l2 = L.list( L.list( 1 ), L.list( 2 ) )
  local l3 = L.member( L.list( 2 ), l2, L.is_equal )
  assert( L.is_equal( l3, L.cdr( l2 ) ) )
  assert( l3 == L.cdr( l2 ) )
  assert( L.member( L.list( 3 ), l2, L.is_equal ) == nil )
  assert( L.member( LARGE, large_lst ) == L.last_pair( large_lst ) )
end

do -- find
  local l1 = L.list( 1, 2, 3, 4 )
  assert( L.find( even, l1 ) == 2 )
  assert( L.find( even, nil ) == nil )
  assert( L.find( gt, l1, 2 ) == 3 )
  assert( L.find( gt, l1, 4 ) == nil )
  assert( L.find( gt, large_lst, LARGE-1 ) == LARGE )
end

do -- any
  local function gt_large( a ) return gt( a, LARGE ) end
  local l1 = L.list( 1, 2, 3, 4, 5, 6, 7, 8 )
  local l2 = L.list( 1, 3, 5, 7, 9 )
  local l3 = L.list( 2, 4, 6, 8, 10 )
  local l4 = L.list( 1, 3, 5, 7, 9, 10 )
  assert( L.any( even, l1 ) == true )
  assert( L.any( even, l2 ) == false )
  assert( L.any( even, nil ) == false )
  assert( L.any( all_even, l1, l2 ) == false )
  assert( L.any( all_even, l1, l3 ) == true )
  assert( L.any( all_even, l3, l4 ) == false )
  assert( L.any( gt_large, large_lst ) == false )
end

do -- every
  local function lt_large( a ) return lt( a, LARGE ) end
  local l1 = L.list( 2, 4, 6, 8, 10, 11 )
  local l2 = L.make( 5, 2 )
  assert( L.every( even, l1 ) == false )
  assert( L.every( even, l2 ) == true )
  assert( L.every( even, nil ) == true )
  assert( L.every( all_even, l1, l1 ) == false )
  assert( L.every( all_even, l2, l2 ) == true )
  assert( L.every( all_even, l1, l2 ) == true )
  assert( L.every( lt_large, large_lst ) == false )
end

do -- index
  local l1 = L.list( 1, 2, 3, 4, 5, 6, 7, 8 )
  local l2 = L.list( 1, 1, 2, 2, 3, 3, 4, 4 )
  assert( L.index( even, l2 ) == 3 )
  assert( L.index( even, nil ) == nil )
  assert( L.index( gt_4, l1 ) == 5 )
  assert( L.index( gt_4, l2 ) == nil )
  assert( L.index( all_even, l1, l2 ) == 4 )
  assert( L.index( even, large_lst ) == 2 )
end

do -- span
  local l1 = L.list( 1, 2, 3, 4, 5, 6, 7, 8 )
  local l2 = L.list( 1, 2, 3, 4 )
  local l3 = L.list( 5, 6, 7, 8 )
  local l4, l5 = L.span( lt_5, l1 )
  assert( L.is_equal( l4, l2 ) )
  assert( L.is_equal( l5, l3 ) )
  assert( l5 == L.member( 5, l1 ) )
  local l6, l7 = L.span( lt, l1, 5 )
  assert( L.is_equal( l6, l2 ) )
  assert( L.is_equal( l7, l3 ) )
  assert( l7 == L.member( 5, l1 ) )
  local l8, l9 = L.span( lt_5, nil )
  assert( l8 == nil )
  assert( l9 == nil )
  local l10, l11 = L.span( lt, l1, 1 )
  assert( l10 == nil )
  assert( l11 == l1 )
  local l12, l13 = L.span( lt, l1, 9 )
  assert( L.is_equal( l12, l1 ) )
  assert( l13 == nil )
  local l14, l15 = L.span( lt_5, large_lst )
  assert( L.is_equal( l14, l2 ) )
  assert( l15 == L.member( 5, large_lst ) )
end

do -- lbreak
  local l1 = L.list( 8, 7, 6, 5, 4, 3, 2, 1 )
  local l2 = L.list( 8, 7, 6, 5 )
  local l3 = L.list( 4, 3, 2, 1 )
  local l4, l5 = L.lbreak( lt_5, l1 )
  assert( L.is_equal( l4, l2 ) )
  assert( L.is_equal( l5, l3 ) )
  assert( l5 == L.member( 4, l1 ) )
  local l6, l7 = L.lbreak( lt, l1, 5 )

  assert( L.is_equal( l6, l2 ) )
  assert( L.is_equal( l7, l3 ) )
  assert( l7 == L.member( 4, l1 ) )
  local l8, l9 = L.lbreak( lt_5, nil )
  assert( l8 == nil )
  assert( l9 == nil )
  local l10, l11 = L.lbreak( gt, l1, 1 )
  assert( l10 == nil )
  assert( l11 == l1 )
  local l12, l13 = L.lbreak( gt, l1, 9 )
  assert( L.is_equal( l12, l1 ) )
  assert( l13 == nil )
  local l14, l15 = L.lbreak( gt, large_lst, 4 )
  assert( L.is_equal( l14, L.list( 1, 2, 3, 4 ) ) )
  assert( l15 == L.member( 5, large_lst ) )
end

do -- take_while
  local l1 = L.list( 1, 2, 3, 4, 5, 6, 7, 8 )
  local l2 = L.list( 1, 2, 3, 4 )
  assert( L.is_equal( L.take_while( lt_5, l1 ), l2 ) )
  assert( L.is_equal( L.take_while( lt, l1, 5 ), l2 ) )
  assert( L.take_while( lt_5, nil ) == nil )
  assert( L.take_while( lt, l1, 1 ) == nil )
  assert( L.is_equal( L.take_while( lt_5, large_lst ), l2 ) )
end

do -- drop_while
  local l1 = L.list( 1, 2, 3, 4, 5, 6, 7, 8 )
  local l2 = L.list( 5, 6, 7, 8 )
  assert( L.is_equal( L.drop_while( lt_5, l1 ), l2 ) )
  assert( L.drop_while( lt_5, l1 ) == L.member( 5, l1 ) )
  assert( L.drop_while( lt_5, nil ) == nil )
  assert( L.is_equal( L.drop_while( lt, l1, 5 ), l2 ) )
  assert( L.drop_while( lt, l1, 1 ) == l1 )
  assert( L.drop_while( lt, l1, 9 ) == nil )
  assert( L.drop_while( lt, large_lst, 2 ) == L.cdr( large_lst ) )
end

do -- delete
  local l1 = L.list( 1, 2, 3, 4 )
  local l2 = L.list( 1, 1, 1, 1 )
  assert( L.is_equal( L.delete( 1, l1 ), L.list( 2, 3, 4 ) ) )
  assert( L.is_equal( L.delete( 4, l1 ), L.list( 1, 2, 3 ) ) )
  assert( L.is_equal( L.delete( 5, l1 ), l1 ) )
  assert( L.delete( 1, l2 ) == nil )
  assert( L.delete( 1, nil ) == nil )
  assert( L.last( L.delete( LARGE, large_lst ) ) == LARGE-1 )
end

do -- delete_duplicates
  local l1 = L.list( 1, 2, 3, 4 )
  local l2 = L.list( 1, 1, 1, 1, 1, 1, 1 )
  local l3 = L.list( 1, 2, 3, 4, 4, 4, 4 )
  local l4 = L.list( 1, 1, 2, 2, 3, 3, 4, 4 )
  assert( L.is_equal( L.delete_duplicates( l2 ), L.list( 1 ) ) )
  assert( L.is_equal( L.delete_duplicates( l1 ), l1 ) )
  assert( L.is_equal( L.delete_duplicates( l3 ), l1 ) )
  assert( L.is_equal( L.delete_duplicates( l4 ), l1 ) )
  assert( L.delete_duplicates( nil ) == nil )
  local l5 = L.cons( 1, large_lst )
  assert( L.is_equal( L.delete_duplicates( l5 ), large_lst ) )
end

do -- traverse
  local i = 0
  for hd, tl in L.traverse( nil ) do
    i = i + 1
  end
  assert( i == 0 )
  local l1 = L.list( 1, 2, 3, 4 )
  for hd, tl in L.traverse( l1 ) do
    i = i + 1
    assert( hd == i )
    assert( i ~= 4 or tl == nil )
    assert( i == 4 or tl ~= nil )
  end
  local last_hd, last_tl
  for hd, tl in L.traverse( large_lst ) do
    last_hd, last_tl = hd, tl
  end
  assert( last_hd == LARGE and last_tl == nil )
end

done()

