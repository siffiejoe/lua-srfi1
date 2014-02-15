#include <stddef.h>
#include "lua.h"
#include "lauxlib.h"


/* compatibility with Lua 5.1 */
#if LUA_VERSION_NUM < 502

#define luaL_newlib( L, reg ) \
  newlib( L, (reg), sizeof( (reg) )/sizeof( *(reg) )-1 )

static void newlib( lua_State* L, luaL_Reg const* reg, size_t n ) {
  lua_createtable( L, 0, (int)n );
  luaL_register( L, NULL, reg );
}

#endif


static int pair( lua_State* L ) {
  int i = luaL_checkint( L, 1 );
  luaL_argcheck( L, i >= 1 && i <= 2, 1, "index out of bounds" );
  if( lua_gettop( L ) < 2 ) {
    lua_pushvalue( L, lua_upvalueindex( i ) );
    return 1;
  } else {
    lua_settop( L, 2 );
    lua_replace( L, lua_upvalueindex( i ) );
    return 0;
  }
}


static int cons( lua_State* L ) {
  lua_settop( L, 2 );
  lua_pushcclosure( L, pair, 2 );
  return 1;
}

static int car( lua_State* L ) {
  luaL_checktype( L, 1, LUA_TFUNCTION );
  lua_settop( L, 1 );
  lua_pushinteger( L, 1 );
  lua_call( L, 1, 1 );
  return 1;
}

static int cdr( lua_State* L ) {
  luaL_checktype( L, 1, LUA_TFUNCTION );
  lua_settop( L, 1 );
  lua_pushinteger( L, 2 );
  lua_call( L, 1, 1 );
  return 1;
}

static int set_car( lua_State* L ) {
  luaL_checktype( L, 1, LUA_TFUNCTION );
  lua_settop( L, 2 );
  lua_pushinteger( L, 1 );
  lua_insert( L, 2 );
  lua_call( L, 2, 0 );
  return 0;
}

static int set_cdr( lua_State* L ) {
  luaL_checktype( L, 1, LUA_TFUNCTION );
  lua_settop( L, 2 );
  lua_pushinteger( L, 2 );
  lua_insert( L, 2 );
  lua_call( L, 2, 0 );
  return 0;
}


static luaL_Reg const mod[] = {
  { "cons", cons },
  { "car", car },
  { "cdr", cdr },
  { "set_car", set_car },
  { "set_cdr", set_cdr },
  { NULL, NULL },
};

#ifndef EXTERN
#  define EXTERN extern
#endif

EXTERN int luaopen_ccons( lua_State* L ) {
  luaL_newlib( L, mod );
  return 1;
}

