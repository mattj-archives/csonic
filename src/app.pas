unit app;

{$mode TP}
{$H-}
interface


uses
  Engine, Sys, Event, Text, Image, Timer,
  common, entity, player,
   res, res_enum,
  Classes, SysUtils
  {$ifdef SDL2}
    ,SDL2
  , sdl2_ttf
    ,GFX_SDL
  {$endif}
  {$ifdef WASM}
    ,GFX_EXT
  {$endif}
  ;

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
  i: integer;
  f: TFile;
  numFiles: integer;
  strLen: integer;
  fileName: string;

begin
  if File_Open('gfxlist.dat', f) then begin
    File_BlockRead(f, numFiles, sizeof(integer));
    ConsoleLog('Num files: ' + IntToStr(numFiles));

    for i := 0 to numFiles - 1 do
    begin
      File_BlockRead(f, strLen, 1);

      File_Seek(f, File_Pos(f) - 1);
      File_BlockRead(f, filename, strLen + 1);

      //writeln(i + 1, ' ', fileName);

      textures[i + 1] := Image_Load('GFX3/' + fileName + '.png');
    end;

    File_Close(f);
  end else begin
    ConsoleLog('couldnt open gfxlist.dat');
   end;
end;


procedure LoadLevel(fileName: string);
var
  f: TFile;
  x, y, tn, tc: integer;
  p0, p1, p2, p3: integer;
  tile: ^TTile;
  e: PEntity;
begin
  File_Open(fileName, f);

  while not File_EOF(f) do
  begin
    File_BlockRead(f, x, sizeof(integer));
    File_BlockRead(f, y, sizeof(integer));
    File_BlockRead(f, tn, sizeof(integer));
    File_BlockRead(f, tc, sizeof(integer));

    if (x < 0) or (x >= 168) or (y < 0) or (y >= 54) then continue;

    //writeln(x, y, tn, tc);
    tile := @map[y * 168 + x];

    case tn of
      // -1:
      //   writeln('player ', x, ' ', y);
      0, 1:
      begin
        //writeln('terrain');
        tile^.tile := 1;
        tile^.color := tc;
      end;
      13: { Moving Platform }
      begin
        File_BlockRead(f, p0, sizeof(integer));
        File_BlockRead(f, p1, sizeof(integer));
        File_BlockRead(f, p2, sizeof(integer));
        File_BlockRead(f, p3, sizeof(integer));
      end;
      17: begin
        e := SpawnEntity(x * 24, y * 24, tn);
        Entity_SetState(e, STATE_SPRING1_IDLE);
      end;
      18: begin
        e := SpawnEntity(x * 24, y * 24, tn);
        Entity_SetState(e, STATE_SPRING2_IDLE);
      end;
      43:
      begin
        e := SpawnEntity(x * 24, y * 24, tn);
        Entity_SetState(e, entityStates.STATE_RING1);
      end;
      44: begin
        e := SpawnEntity(x * 24, y * 24, tn);
        Entity_SetState(e, entityStates.STATE_CHILI1);
      end;
      71: { Enemy "mosquito" }
      begin
        File_BlockRead(f, x, sizeof(integer));
        File_BlockRead(f, x, sizeof(integer));
        File_BlockRead(f, y, sizeof(integer));
        File_BlockRead(f, tn, sizeof(integer));
        File_BlockRead(f, tc, sizeof(integer));
      end;
    end;
  end;

    ConsoleLog('close...');
  File_Close(f);
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
        0:
          R_DrawSprite(x * 24 - camera.x, y * 24 - camera.y, textures[SPRITE_T1]^);

        1:
          R_DrawSprite(x * 24 - camera.x, y * 24 - camera.y, textures[SPRITE_T2]^);
        4:
          R_DrawSprite(x * 24 - camera.x, y * 24 - camera.y, textures[SPRITE_T2SLOPE]^);

      end;
    end;
  end;
end;

procedure DrawState(x, y: integer; state: entityStates; direction: integer);
var
  ss: ^TSpriteState;
  img: pimage_t;
begin
  if direction >= 3 then Dec(direction, 3);
  //writeln('direction ', direction);
  ss := @sprite_states[Ord(entity_states[Ord(state)].spriteState)];
  img := textures[ss^.sprites[direction]];
  { writeln('draw state ', ord(state), ' at ', x, ' ', y); }
  if not Assigned(img) then
  begin
    // writeln('error...', Ord(state), ' ', direction, ' sprite index ',
    //   ss^.sprites[direction], ' at ', x, ' ', y);
  end;
  if Assigned(img) then R_DrawSprite(x, y, img^);
end;

procedure MovingPlatform_Update(Data: Pointer);
var
  self: PEntityMovingPlatform absolute Data;
  destPoint: TVector2;
  deltaX: integer;
begin

  deltaX := 0;

  destPoint := self^.p[self^.dest];

  if destPoint.x > self^.x then
  begin
    deltaX := 1;
    Inc(self^.x);
    if self^.x >= destPoint.x then
    begin
      self^.dest := self^.dest xor 1;
    end;
  end;

  if destPoint.x < self^.x then
  begin
    Dec(self^.x);
    deltaX := -1;
    if self^.x <= destPoint.x then
    begin
      self^.dest := self^.dest xor 1;
    end;
  end;

  if gPlayer.groundEntity = PEntity(self) then
  begin
    // TODO: Actually push player in this direction, check for getting crushed
    Inc(gPlayer.ent^.x, deltaX);
  end;
end;

procedure G_Init; alias: 'G_Init';
var
  img, img2: pimage_t;
  x, i: integer;
  e: PEntity;
  mp: PEntityMovingPlatform;
begin
  ConsoleLog('G_Init');

  LoadGFX;

  FillChar(entities, sizeof(TEntity) * MAX_ENTITIES, 0);

  img := Image_Load('gfx3/AFSPIKE.png');
  img2 := Image_Load('gfx3/SRS.png');

  map[14 * 168 + 5].tile := 4;
  map[14 * 168 + 6].tile := 1;
  map[13 * 168 + 6].tile := 1;
  e := SpawnEntity(3 * 24, 4 * 24, -1);
  gPlayer.ent := e;
  Entity_SetState(e, STATE_PLAYER_STAND1);

  for i := 0 to 1 do
  begin
    //e := SpawnEntity(24 * (6 + i), 14 * 24, 38);
    //Entity_SetState(e, STATE_BOX_RING1);
  end;

  mp := PEntityMovingPlatform(SpawnEntity(7 * 24, 12 * 24, 13));

  mp^.p[0].x := mp^.x;
  mp^.p[0].y := mp^.y;
  mp^.p[1].x := mp^.x + 24 * 3;
  mp^.p[1].y := mp^.y;
  mp^.dest := 1;

  Entity_SetState(mp, STATE_MPLAT);

  Event_SetKeyDownProc(OnKeyDown);
  Event_SetKeyUpProc(OnKeyUp);

  LoadLevel('levels/1_1.l2');

  map[0 * 168 + 0].tile := 1;
  map[1 * 168 + 1].tile := 1;
end;

procedure G_RunFrame; alias: 'G_RunFrame';
  var i: integer;
  e: PEntity;
begin

    Sys_PollEvents;
    Event_ProcessEvents;

    if I_WasKeyPressed(kEsc) or I_IsKeyDown(k0) then
    begin
      shouldQuit := True;
    end;

    Player_Update(gPlayer.ent);

    for i := 1 to MAX_ENTITIES do
    begin
      if (entities[i].flags and 1) = 0 then continue;
      e := @entities[i];

      Dec(e^.stateFrames);

      if e^.stateFrames <= 0 then
      begin
        e^.state := entity_states[Ord(e^.state)].nextState;
        e^.stateFrames := entity_states[Ord(e^.state)].duration;

        if entity_states[Ord(e^.state)].func = 999 then
        begin
          e^.flags := 0;
        end;
      end;

      if e^.t = 13 then
      begin
        MovingPlatform_Update(e);
      end;
    end;

    camera.x := gPlayer.ent^.x - 6 * 24;
    camera.y := gPlayer.ent^.y - 4 * 24;
    if camera.x < 0 then camera.x := 0;
    if camera.y < 0 then camera.y := 0;
end;

procedure Main;
var
  img, img2: pimage_t;
  x, i: integer;
  e: PEntity;
  mp: PEntityMovingPlatform;
begin
  x := 0;

  {$ifdef SDL2}
  if SDL_Init(SDL_INIT_VIDEO or SDL_INIT_AUDIO) < 0 then
  begin
    // writeln('SDL_Init failed');
    Halt;
  end;
  if TTF_Init < 0 then begin
    writeln('error ' , SDL_GetError);
  end;
  {$endif}

  InitDriver;
  R_Init;

  G_Init;

  while (not shouldQuit) do
  begin
    G_RunFrame;

    DrawMap;

    R_DrawText(0, 0, 'Player: ');
    R_DrawText(42, 0, IntToStr(gPlayer.ent^.x));
    R_DrawText(42, 9, IntToStr(gPlayer.ent^.y));
    for i := 1 to MAX_ENTITIES do
    begin
      if (entities[i].flags and 1) = 0 then continue;
      e := @entities[i];

      if e^.x < camera.x - 24 then continue;
      if e^.x > camera.x + 320 then continue;
      if e^.y < camera.y - 24 then continue;
      if e^.y > camera.y + 240 then continue;

      //writeln('draw entity ', i, ' type ', e^.t);
      DrawState(e^.x - camera.x, e^.y - camera.y, e^.state, e^.direction);
    end;
    R_SwapBuffers;
    Timer_Delay(16 * 2);
  end;
end;



end.
