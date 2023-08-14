unit app;

{$mode TP}

interface



uses
  Engine, Sys, Event, Text, Image, Timer,
  common,
  GFX_SDL, res,
  Classes, SysUtils
  {$ifdef fpc}
  ,SDL2
  {$endif};

procedure Main;

var
  textures: array[0 .. 200] of pimage_t;

implementation

procedure OnKeyDown(sc: ScanCode);
begin

  //if lastKeyDown = kNone then repeatDelay := 0;

  {if lastKeyDown <> sc then repeatDelay := 0;}
  //lastKeyDown := sc;

end;

procedure OnKeyUp(sc: ScanCode);
var
  s: scanCode;
begin
  //if sc = lastKeyDown then
  //begin
  //  lastKeyDown := kNone;

  //  { See if any other keys are down }

  //  for s := kNone to kF12 do
  //  begin
  //    if not (s in engine.keys) then continue;
  //    if not I_IsKeyDown(s) then continue;
  //    lastKeyDown := s;
  //    Exit;
  //  end;
  //end;
end;

procedure LoadGFX;
var
  DirInfo: TSearchRec;
  i: integer;
  f: file;
  numFiles: integer;
  strLen: integer;
  fileName: string;
begin
  Assign(f, 'gfxlist.dat');
  reset(f, 1);
  BlockRead(f, numFiles, sizeof(integer));
  writeln('Num files: ', numFiles);

  for i := 0 to numFiles - 1 do
  begin
    BlockRead(f, strLen, 1);
    Seek(f, FilePos(f) - 1);
    BlockRead(f, filename, strLen + 1);

    writeln(fileName);

    textures[i] := Image_Load('GFX3/' + fileName + '.png');
  end;

  System.Close(f);
end;

procedure LoadLevel(fileName: string);
var
  f: file;
  x, y, tn, tc: integer;
  tile: ^TTile;
begin
  Assign(f, fileName);
  Reset(f, 1);
  while not EOF(f) do
  begin

    BlockRead(f, x, sizeof(integer));
    BlockRead(f, y, sizeof(integer));
    BlockRead(f, tn, sizeof(integer));
    BlockRead(f, tc, sizeof(integer));
    writeln(x, y, tn, tc);
    tile := @map[y * 168 + x];

    case tn of
      -1:
        writeln('player');
      0, 1:
      begin
        writeln('terrain');
        tile^.tile := 1;
        tile^.color := tc;
      end;
      71:
      begin
        BlockRead(f, x, sizeof(integer));
        BlockRead(f, x, sizeof(integer));
        BlockRead(f, y, sizeof(integer));
        BlockRead(f, tn, sizeof(integer));
        BlockRead(f, tc, sizeof(integer));
      end;

    end;
  end;


  System.Close(f);
end;

procedure DrawMap;
var
  tileStartX, tileStartY: integer;
  x, y: integer;
  tile: ^TTile;
begin
  tileStartX := camera.X div 24;
  tileStartY := camera.Y div 24;

  for y := tileStartY to tileStartY + 10 do
  begin
    for x := tileStartX to tileStartX + 14 do
    begin
      tile := @map[y * 168 + x];
      {R_DrawSprite(x * 24 - camera.x, y * 24 - camera.y, textures[tile^.tile]^);            }
      case tile^.tile of
        1:
          R_DrawSprite(x * 24 - camera.x, y * 24 - camera.y, textures[SPRITE_T2]^);
      end;
    end;
  end;
end;

procedure Main;
var
  img, img2: pimage_t;
  x: integer;
begin
  x := 0;

  {$ifdef fpc}
  if SDL_Init(SDL_INIT_VIDEO or SDL_INIT_AUDIO) < 0 then
  begin
    writeln('SDL_Init failed');
    Halt;
  end;
  {$endif}

  InitDriver;
  R_Init;

  LoadGFX;

  img := Image_Load('gfx3/AFSPIKE.png');
  img2 := Image_Load('gfx3/SRS.png');

  Event_SetKeyDownProc(OnKeyDown);
  Event_SetKeyUpProc(OnKeyUp);

  LoadLevel('levels/1_1.l2');

  map[0 * 168 + 0].tile := 1;
  map[1 * 168 + 1].tile := 1;

  while (not shouldQuit) do
  begin

    Sys_PollEvents;
    Event_ProcessEvents;

    R_DrawSprite(x, 0, img^);
    R_DrawSprite(10, 10, textures[4]^);

    DrawMap;

    if I_WasKeyPressed(kEsc) or I_IsKeyDown(k0) then
    begin
      shouldQuit := True;
    end;
    if I_IsKeyDown(kUp) then
    begin
      Inc(camera.y, -4);
      if camera.y < 0 then camera.y := 0;
    end;
    if I_IsKeyDown(kDn) then
    begin
      Inc(camera.y, 4);
    end;

    if I_IsKeyDown(kLf) then
    begin
      Inc(camera.x, -4);
      if camera.x < 0 then camera.x := 0;
    end;



    if I_IsKeyDown(kRt) then
    begin
      Inc(camera.x, 4);
    end;

    R_SwapBuffers;
    Timer_Delay(16);
  end;
end;

end.
