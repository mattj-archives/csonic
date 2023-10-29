program mask_gen;

{$mode objfpc}{$H+}

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
    cthreads, classes,
              {$endif}
  iostream,
  SysUtils,
  CustApp;

type
  TByteArray = array[0..64000] of byte;
  PByteArray = ^TByteArray;

  TMyApplication = class(TCustomApplication)
  protected
    procedure DoRun; override;
    function IsMaskedPixel(tx, ty, x, y, tile_num: integer): boolean;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;

  var
    map_width: integer;
    map_height: integer;
    map_width_pixels: longint;
    heights: array[0..1151, 0..23] of byte;
    tiles: array of smallint;
    buf: ^byte;
    canvas_buf: ^longint;
  end;


  { TMyApplication }
  function TMyApplication.IsMaskedPixel(tx, ty, x, y, tile_num: integer): boolean;
  var
    tile_top, tile_left, tile_bottom: integer;
    tile_heights: array of byte;
  begin
    Result := False;
    if tile_num = 0 then Exit;

    tile_top := ty * 24;
    tile_bottom := tile_top + 24;
    tile_left := tx * 24;
    //writeln(tile_num - 1, ' ', x mod 24);
    //tile_heights := @heights[tile_num - 1, 0];

    //if tile_heights[x mod 24] = 0 then Exit;
    if heights[tile_num - 1, x mod 24] = 0 then Exit;

    if tile_num < 576 then
    begin
      //Result := True;
      Result := (tile_bottom - heights[tile_num - 1, x mod 24]) <=
        (tile_top + (y mod 24));
    end
    else
    begin
      //Result := True;
      Result := tile_top + heights[tile_num - 1, x mod 24] > tile_top + (y mod 24);

    end;

  end;

  procedure TMyApplication.DoRun;
  var
    ErrorMsg: string;
    idx: integer;
    longOpt: boolean;
    height_file_name, tiles_file_name, canvas_file_name: string;
    fileStream: TFileStream;
    buf_size_bytes, canvas_buf_size_bytes: integer;
    tx, ty, px, py: integer;
    tile_num: integer;
    offs: integer;

  begin
    // quick check parameters
    {ErrorMsg := CheckOptions('h s hf', 'help size height-file');

    if ErrorMsg <> '' then
    begin
      ShowException(Exception.Create(ErrorMsg));
      Terminate;
      Exit;
    end;
     }
    // parse parameters
    if HasOption('h', 'help') then
    begin
      WriteHelp;
      Terminate;
      Exit;
    end;

    { add your program here }

    idx := FindOptionIndex('size', longopt);
    if idx = -1 then
    begin
      ShowException(Exception.Create('Specify size'));
      Terminate;
      Exit;
    end;

    map_width := StrToInt(GetOptionAtIndex(idx, False));
    map_height := StrToInt(GetOptionAtIndex(idx + 1, False));

    idx := FindOptionIndex('height-file', longopt);
    if idx = -1 then
    begin
      ShowException(Exception.Create('Required: height file'));
      Terminate;
      Exit;
    end;

    height_file_name := GetOptionAtIndex(idx, False);

    idx := FindOptionIndex('tiles-file', longopt);
    if idx = -1 then
    begin
      writeln('Missing tiles file');
      Terminate;
      Exit;
    end;

    tiles_file_name := GetOptionAtIndex(idx, False);

    idx := FindOptionIndex('canvas-file', longopt);
    if idx = -1 then
    begin
      writeln('Missing canvas file option');
      Terminate;
      Exit;
    end;

    canvas_file_name := GetOptionAtIndex(idx, False);

    fileStream := TFileStream.Create(height_file_name, fmOpenRead);
    fileStream.Read(heights, sizeof(heights));
    fileStream.Free;

    SetLength(tiles, map_width * map_height);
    FillChar(tiles[0], map_width * map_height * 2, 0);

    fileStream := TFileStream.Create(tiles_file_name, fmOpenRead);
    fileStream.ReadBuffer(tiles[0], sizeof(smallint) * map_width * map_height);
    fileStream.Free;

    buf_size_bytes := (24 * 24) * (map_width * map_height); // div 8;
    canvas_buf_size_bytes := (24 * 24) * (map_width * map_height) * 4;

    writeln(Format('Map size in tiles: %dx%d', [map_width, map_height]));
    writeln('Loading height file ', height_file_name);
    writeln('Mask size in bytes: ', buf_size_bytes);
    writeln('Canvas size in bytes: ', canvas_buf_size_bytes);

    buf := GetMem(buf_size_bytes);
    canvas_buf := GetMem(canvas_buf_size_bytes);
    //GetMem(buf, buf_size_bytes);
    FillChar(buf^, buf_size_bytes, 0);
    FillChar(canvas_buf^, canvas_buf_size_bytes, 0);

    map_width_pixels := map_width * 24;

    writeln('Generate mask...');
    for ty := 0 to map_height - 1 do
    begin
      for tx := 0 to map_width - 1 do
      begin

        tile_num := Self.tiles[ty * map_width + tx];

        //if tile_num = 0 then continue;
        //writeln(tx, ' ', ty);

        //writeln('will work with ', tile_num);

        for py := 0 to 23 do
        begin
          for px := 0 to 23 do
          begin

            offs := (ty * 24 + py) * map_width_pixels + (tx * 24 + px);

            if IsMaskedPixel(tx, ty, (tx * 24) + px, (ty * 24) + py, tile_num) then
              //buf[offs div 8] := buf[offs div 8] or (1 shl (7 - (offs and $7)));
              buf[offs] := 1;


            //if (tx + ty) mod 2 = 0 then buf^[offs] := 255;
            //ImageDrawPixel(@im, tx * 24 + px, ty * 24 + py, $ff0000ff)
          end;
        end;
      end;
    end;

    writeln('BG Fill...');

    for py := 0 to map_height * 24 - 1 do
    begin
      for px := 0 to map_width * 24 - 1 do
      begin
        offs := py * map_width_pixels + px;
        if buf[offs] <> 0 then begin
          canvas_buf[offs] := $ff00aa00;
        end;
      end;
    end;

    fileStream := TFileStream.Create('test.raw', fmCreate or fmOpenWrite);
    fileStream.Write(buf^, buf_size_bytes);
    fileStream.Free;

    fileStream := TFileStream.Create(canvas_file_name, fmCreate or fmOpenWrite);
    fileStream.Write(canvas_buf^, canvas_buf_size_bytes);
    fileStream.Free;


    FreeMem(buf);
    FreeMem(canvas_buf);
    //FreeMem(tiles);
    writeln('Done');

    // stop program loop
    Terminate;
  end;

  constructor TMyApplication.Create(TheOwner: TComponent);
  begin
    inherited Create(TheOwner);
    StopOnException := True;
  end;

  destructor TMyApplication.Destroy;
  begin
    inherited Destroy;
  end;

  procedure TMyApplication.WriteHelp;
  begin
    { add your help code here }
    writeln('Usage: ', ExeName, ' -h');
  end;

var
  Application: TMyApplication;

type
  PImage = ^Image;

  Image = record
    Data: Pointer;
    Width: longint;
    Height: longint;
    mipmaps: longint;
    format: longint;
  end;

type
  Color = record
    r: byte;
    g: byte;
    b: byte;
    a: byte;
  end;

  function GenImageColor(Width, Height: longint; color: longint): Image; cdecl; external;
  function ExportImage(image: Image; fileName: PChar): boolean; cdecl; external;
  procedure ImageDrawPixel(dst: PImage; posX, posY: longint; color: longint);
  cdecl; external;

begin

  Application := TMyApplication.Create(nil);
  Application.Title := 'My Application';
  Application.Run;
  Application.Free;

  Exit;
end.
