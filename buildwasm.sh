#!/bin/bash
# source ~/emsdk/emsdk_env.sh

rm -rf vfs/*

cp datatest.dat vfs/
cp gfxlist.dat vfs/
cp res.dat vfs/
cp height.dat vfs/

mkdir vfs/levels
cp levels/*.l2 vfs/levels

mkdir vfs/GFX3
cp gfx3/* vfs/GFX3

mkdir vfs/dev
cp dev/out_test.l3 vfs/dev
cp dev/out_testmap1.l3 vfs/dev
cp dev/TEST_rendered.png vfs/dev


FPC=~/bin/ppcrosswasm32-embedded
FPC_FLAGS=@fpcwasm.cfg

$FPC $FPC_FLAGS src/app.pas
$FPC $FPC_FLAGS src/common.pas
$FPC $FPC_FLAGS src/entity.pas
$FPC $FPC_FLAGS src/player.pas
$FPC $FPC_FLAGS src/sensor.pas
$FPC $FPC_FLAGS src/terrainmove.pas
$FPC $FPC_FLAGS src/res/res.pas

$FPC $FPC_FLAGS engine/src/buffer.pas
# $FPC $FPC_FLAGS engine/src/datafile.pas
$FPC $FPC_FLAGS engine/src/engine.pas
$FPC $FPC_FLAGS engine/src/event.pas
$FPC $FPC_FLAGS engine/src/fixedint.pas
$FPC $FPC_FLAGS engine/src/gfx.pas
$FPC $FPC_FLAGS engine/src/rect.pas
$FPC $FPC_FLAGS engine/src/vect2d.pas

$FPC $FPC_FLAGS engine/wasm/wasm_embedded_backend.pas

$FPC $FPC_FLAGS engine/src/ext/gfx_ext.pas
$FPC $FPC_FLAGS engine/src/ext/image.pas
$FPC $FPC_FLAGS engine/src/ext/sys.pas
$FPC $FPC_FLAGS engine/src/ext/text.pas
# 	engine/src/datafile.o 

emcc -o game.html \
	engine/wasm/backend.c wasm/main.c \
	src/app.o \
	src/common.o \
	src/entity.o \
	src/player.o \
	src/sensor.o \
	src/terrainmove.o \
	src/res/res.o \
	engine/src/buffer.o \
	engine/src/engine.o \
	engine/src/event.o \
	engine/src/fixedint.o \
	engine/src/gfx.o \
	engine/src/rect.o \
	engine/src/vect2d.o \
	engine/wasm/wasm_embedded_backend.o \
	engine/src/ext/gfx_ext.o \
	engine/src/ext/image.o \
	engine/src/ext/sys.o \
	engine/src/ext/text.o \
	~/fpcwasm/lib/fpc/3.3.1/units/wasm32-embedded/rtl/consoleio.o \
	~/fpcwasm/lib/fpc/3.3.1/units/wasm32-embedded/rtl/system.o \
	-Wall ~/Downloads/raylib-4.5.0_webassembly/lib/libraylib.a -I. -I/Users/mattj/Downloads/raylib-4.5.0_webassembly/include \
	-s USE_GLFW=3 -DPLATFORM_WEB \
	-s WASM=1 \
	-s WASM_OBJECT_FILES=0 \
	-s NO_EXIT_RUNTIME=1 \
	-s ASYNCIFY \
	-s ERROR_ON_UNDEFINED_SYMBOLS=0 \
	--preload-file vfs@/ -lidbfs.js \
	-s EXPORTED_FUNCTIONS='["_main"]'

# 	-g -s SAFE_HEAP=0 \