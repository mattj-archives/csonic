#!/bin/bash
# source ~/emsdk/emsdk_env.sh

FPC=~/bin/ppcrosswasm32
FPC_FLAGS=@fpcwasm.cfg

$FPC $FPC_FLAGS src/app.pas
$FPC $FPC_FLAGS src/player.pas
$FPC $FPC_FLAGS src/entity.pas

$FPC $FPC_FLAGS engine/src/buffer.pas
# $FPC $FPC_FLAGS engine/src/datafile.pas
$FPC $FPC_FLAGS engine/src/engine.pas
$FPC $FPC_FLAGS engine/src/event.pas
$FPC $FPC_FLAGS engine/src/fixedint.pas
$FPC $FPC_FLAGS engine/src/gfx.pas
$FPC $FPC_FLAGS engine/src/rect.pas
$FPC $FPC_FLAGS engine/src/vect2d.pas

$FPC $FPC_FLAGS engine/src/ext/gfx_ext.pas
$FPC $FPC_FLAGS engine/src/ext/image.pas
$FPC $FPC_FLAGS engine/src/ext/sys.pas
$FPC $FPC_FLAGS engine/src/ext/text.pas
$FPC $FPC_FLAGS engine/src/ext/timer.pas
# 	engine/src/datafile.o 

emcc -o game.html wasm/main.c src/app.o src/player.o src/entity.o \
	engine/src/buffer.o \
	engine/src/engine.o \
	engine/src/event.o \
	engine/src/fixedint.o \
	engine/src/gfx.o \
	engine/src/rect.o \
	engine/src/vect2d.o \
	engine/src/ext/gfx_ext.o \
	engine/src/ext/image.o \
	engine/src/ext/sys.o \
	engine/src/ext/text.o \
	engine/src/ext/timer.o \
	~/fpcwasm/lib/fpc/3.3.1/units/wasm32-wasi/rtl/system.o \
	-Wall ~/Downloads/raylib-4.5.0_webassembly/lib/libraylib.a -I. -I/Users/mattj/Downloads/raylib-4.5.0_webassembly/include \
	-s USE_GLFW=3 -DPLATFORM_WEB -s ASYNCIFY \
	-s WASM=1 \
	-g \
	-s SAFE_HEAP=1 \
	-s NO_EXIT_RUNTIME=1 \
	-s ERROR_ON_UNDEFINED_SYMBOLS=0 \
	--preload-file vfs@/ -lidbfs.js \
	-s EXPORTED_FUNCTIONS='["_main", "_G_Init", "_G_RunFrame"]'