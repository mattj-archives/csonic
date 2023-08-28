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

# $FPC $FPC_FLAGS -B src/app.pas
$FPC $FPC_FLAGS -B wasm/raylib_app.pas
$FPC $FPC_FLAGS engine/wasm/wasm_embedded_backend.pas

# 	engine/src/datafile.o 

	# src/app.o \
	# src/common.o \
	# src/entity.o \
	# src/player.o \
	# src/sensor.o \
	# src/terrainmove.o \
	# src/res/res.o \ wasm/main.c
echo "EMCC..."
emcc -o game.html \
	engine/wasm/backend.c \
	wasm/raylib_app.o \
	src/*.o \
	src/res/*.o \
	engine/src/*.o \
	engine/src/ext/*.o \
	engine/external/raylib/*.o \
	engine/wasm/wasm_embedded_backend.o \
	~/fpcwasm/lib/fpc/3.3.1/units/wasm32-embedded/rtl/consoleio.o \
	~/fpcwasm/lib/fpc/3.3.1/units/wasm32-embedded/rtl/math.o \
	~/fpcwasm/lib/fpc/3.3.1/units/wasm32-embedded/rtl/system.o \
	~/fpcwasm/lib/fpc/3.3.1/units/wasm32-embedded/rtl/strings.o \
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