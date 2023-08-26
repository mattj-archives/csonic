program mask_gen;

{$L '../../external/raylib-macos/lib/libraylib.a'}

{$ifdef fpc}
  {$IFDEF DARWIN}
    {$linkFramework IOKit}
    {$linkFramework Cocoa}
    {$linkFramework CoreGraphics}
  {$endif}
{$endif}


uses
    {$ifdef UNIX}
    cthreads, classes
    {$endif}
    ;

type 
	PImage = ^Image;
	Image = record
	data: Pointer;
	width: longint;
	height: longint;
	mipmaps: longint;
	format: longint;
	end;

type Color = record
	r: byte;
	g: byte;
	b: byte;
	a: byte;
	end;

function GenImageColor(width, height: longint; color: longint): Image; cdecl; external;
function ExportImage(image: Image; fileName: PChar): boolean; cdecl; external;
procedure ImageDrawPixel(dst: PImage; posX, posY: longint; color: longint); cdecl; external;

var
  heights: array[0..1151, 0..23] of byte;
  f: file;
  i: integer;
  buf: ^byte;
  im: Image;
  tx, ty, px, py: integer;
  map_width_pixels: longint;
  col: longint;
begin
	writeln('mask_gen ../../height.dat');
  // Writeln (paramstr(0),' : Got ',ParamCount,' command-line parameters: ');
  // For i:=1 to ParamCount do
  // 	case ParamStr(i) of:
  //   Writeln (ParamStr (i));
  //   Exit;
  writeln('mask_gen');
  Assign(f, ParamStr(1));
  Reset(f, 1);
  if IOResult <> 0 then begin
  	writeln('couldn''t open ', ParamStr(1));
  	Exit;
  end;
  BlockRead(f, heights, 1152 * 24);
  System.Close(f);


  im := GenImageColor(168 * 24, 54 * 24, $000000ff);
  GetMem(buf, (24 * 24) * (168 * 54));

  map_width_pixels := 168 * 24;
  col := $ff0000ff;
  for ty := 0 to 53 do begin
  	for tx := 0 to 167 do begin
  	  for py := 0 to 23 do begin
  	  	for px := 0 to 23 do begin
  	  		// buf[(ty * 24 + py) * map_width_pixels + (tx * 24 + px)] := 255;
  	  		ImageDrawPixel(@im, tx * 24 + px, ty * 24 + py, $ff0000ff)
  	  	end;
  	  end;
  	end;
  end;

  ExportImage(im, 'test.raw');

  FreeMem(buf);
end.