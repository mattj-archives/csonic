unit app;

{$mode TP}

interface



uses
  Engine, Sys, Event, Text, Image, Timer,
  common,
  GFX_SDL,
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
  //
  //  { See if any other keys are down }
  //
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
begin
  i := 0;
  if FindFirst('GFX3\*.png', faArchive, DirInfo) = 0 then
  begin
    repeat
      with DirInfo do
      begin
        Writeln (Name:40,Size:15);
        textures[i] := Image_Load('GFX3/' + Name);

        Inc(i);
      end;
    until FindNext(DirInfo) <> 0;
  end;
end;

procedure DrawMap;
var
  tileStartX, tileStartY: integer;
  x, y: integer;
  tile: ^TTile;
begin
  tileStartX := camera.X div 24;
  tileStartY := camera.Y div 24;

  for y := tileStartY to tileStartY + 8 do begin
    for x := tileStartX to tileStartX + 14 do begin
      tile := @map[y * 168 + x];

      R_DrawSprite(x * 24 - camera.x, y * 24 - camera.y, textures[tile^.tile]^);

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

  map[0 * 168 + 0].tile := 2;
  map[1 * 168 + 1].tile := 2;

  while (not shouldQuit) do
  begin

    Sys_PollEvents;
    Event_ProcessEvents;

    R_DrawSprite(x, 0, img^);
    R_DrawSprite(10, 10, textures[4]^);

    DrawMap;

    if I_WasKeyPressed(kEsc) then
    begin
      shouldQuit := true;
    end;

    if I_IsKeyDown(kLf) then begin
      Inc(camera.x, -1);
      if camera.x < 0 then camera.x := 0;
    end;

    if I_IsKeyDown(kRt) then begin
      Inc(camera.x);
    end;

    R_SwapBuffers;
    Timer_Delay(16);
  end;
end;

end.
