"""Use Resolve's bundled LuaJIT to check syntax and run a small Fuse API double."""
import ctypes
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
LIB = Path('/Applications/DaVinci Resolve/DaVinci Resolve.app/Contents/Libraries/Fusion/libluajit-5.1.2.dylib')
if not LIB.exists():
    raise SystemExit('Resolve LuaJIT library is unavailable on this machine')
lua = ctypes.CDLL(str(LIB))
lua.luaL_newstate.restype = ctypes.c_void_p
lua.luaL_openlibs.argtypes = [ctypes.c_void_p]
lua.luaL_loadfile.argtypes = [ctypes.c_void_p, ctypes.c_char_p]
lua.luaL_loadfile.restype = ctypes.c_int
lua.lua_pcall.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int]
lua.lua_pcall.restype = ctypes.c_int
lua.lua_tolstring.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.POINTER(ctypes.c_size_t)]
lua.lua_tolstring.restype = ctypes.c_char_p
lua.lua_pushstring.argtypes = [ctypes.c_void_p, ctypes.c_char_p]
lua.lua_settop.argtypes = [ctypes.c_void_p, ctypes.c_int]
lua.lua_close.argtypes = [ctypes.c_void_p]
state = lua.luaL_newstate()
lua.luaL_openlibs(state)
try:
    for rel in ('fuses/NodeWaveDeform.fuse', 'scripts/NodeWaveController.lua'):
        code = lua.luaL_loadfile(state, str(ROOT / rel).encode())
        if code:
            raise RuntimeError(lua.lua_tolstring(state, -1, None).decode())
        print(rel + ': syntax OK')
        lua.lua_settop(state, 0)
    for test, target, platform in (
        ('tests/fuse_mock.lua', 'fuses/NodeWaveDeform.fuse', None),
        ('tests/controller_mock.lua', 'scripts/NodeWaveController.lua', 'macOS'),
        ('tests/controller_mock.lua', 'scripts/NodeWaveController.lua', 'Windows'),
    ):
        code = lua.luaL_loadfile(state, str(ROOT / test).encode())
        if code:
            raise RuntimeError(lua.lua_tolstring(state, -1, None).decode())
        lua.lua_pushstring(state, str(ROOT / target).encode())
        if platform:
            lua.lua_pushstring(state, platform.encode())
        code = lua.lua_pcall(state, 2 if platform else 1, 0, 0)
        if code:
            raise RuntimeError(lua.lua_tolstring(state, -1, None).decode())
        lua.lua_settop(state, 0)
finally:
    lua.lua_close(state)
