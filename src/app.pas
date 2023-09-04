unit app;

{$mode TP}
{$H-}
interface


uses
  Engine, Sys, Event, Image,
  common, entity, player,
   res, res_enum, SysUtils
  {$ifdef SDL2}
    ,SDL2 ,sdl2_ttf, GFX_SDL
  {$endif}
  {$ifdef WASM}
    ,GFX_EXT
  {$endif}
  ;

procedure Main;
procedure G_Init;
procedure G_RunFrame;
procedure G_Draw;

var
  textures: array[0 .. 200] of pimage_t;
  renderedTiles: pimage_t;
  isPaused: boolean;
  frameCount: longint;

implementation

uses enemy;
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
  f: file;
  numFiles: integer;
  strLen: integer;
  fileName: string;

begin

  Assign(f, 'height.dat');
  Reset(f, 1);
  writeln('loading heights');
  BlockRead(f, heights, 1152 * 24);

  System.Close(f);

  Assign(f, 'gfxlist.dat');
  Reset(f, 1);
  BlockRead(f, numFiles, sizeof(integer));
    writeln('Num files: ', numFiles);

    for i := 0 to numFiles - 1 do
    begin
      BlockRead(f, strLen, 1);

      Seek(f, FilePos(f) - 1);
      BlockRead(f, filename, strLen + 1);

      // writeln(i + 1, ' ', fileName);

      textures[i + 1] := Image_Load('GFX3/' + fileName + '.png');
    end;

    System.Close(f);

    renderedTiles := Image_Load('dev/TEST_rendered.png');

end;

procedure LoadLevel2(fileName: string);
var f: file;
  width, height, num_objects, tile_type, object_type: byte;
  i, x, y: integer;
  tile_desc, tile_vis: integer;
  tile: ^TTile;
  e: PEntity;
  begin
      writeln('LoadLevel2 ', fileName);
      Assign(f, fileName);
      Reset(f, 1);
      BlockRead(f, width, 1);
      BlockRead(f, height, 1);

      for y := 0 to height - 1 do begin
        for x := 0 to width - 1 do begin
            BlockRead(f, tile_type, 1);
            BlockRead(f, tile_desc, sizeof(integer));
            BlockRead(f, tile_vis, sizeof(integer));

            tile := @map[y * 168 + x];
            tile^.tile := 0;
            if tile_type = 1 then begin
              tile^.tile := 4;
              tile^.description:=tile_desc;
              tile^.color := tile_vis;
              { vis }
            end;
        end;
      end;

      BlockRead(f, num_objects, sizeof(integer));

      for i := 0 to num_objects - 1 do begin
        BlockRead(f, object_type, sizeof(integer));
        BlockRead(f, x, sizeof(integer));
        BlockRead(f, y, sizeof(integer));
        Dec(y, 24);

        case object_type of
        17: begin
          e := SpawnEntity(x, y, object_type);
          Entity_SetState(e, STATE_SPRING1_IDLE);
        end;
        18: begin
          e := SpawnEntity(x, y, object_type);
          Entity_SetState(e, STATE_SPRING2_IDLE);
        end;
              43:
      begin
        e := SpawnEntity(x, y, object_type);
        Entity_SetState(e, entityStates.STATE_RING1);
      end;
      44: begin
        e := SpawnEntity(x, y, object_type);
        Entity_SetState(e, entityStates.STATE_CHILI1);
      end;
          70: {Enemy "Rabid Mushroom" }
      begin
           e := SpawnEntity(x, y, object_type);
         Entity_SetState(e, STATE_RM_IDLE);
      end;
          71: { Enemy "Mosquito" }
          begin
            e := SpawnEntity(x, y, object_type);
            Entity_SetState(e, STATE_MOSQU_IDLE);
          end;
          72: {Enemy "Bouncing potato" }
      begin
           e := SpawnEntity(x, y, object_type);
         Entity_SetState(e, STATE_BPOT_IDLE);
      end;
      end;

      end;


      System.close(f);
  end;

procedure LoadLevel(fileName: string);
var
  f: file;
  x, y, tn, tc: integer;
  p0, p1, p2, p3: integer;
  tile: ^TTile;
  e: PEntity;
begin

  writeln('LoadLevel ', fileName);

  Assign(f, fileName);
  Reset(f, 1);

  while not EOF(f) do
  begin
    BlockRead(f, x, sizeof(integer));
    BlockRead(f, y, sizeof(integer));
    BlockRead(f, tn, sizeof(integer));
    BlockRead(f, tc, sizeof(integer));

    //writeln('Map entity spawn: ', x, ' ', y, ' ', ' type: ', tn);
    if (x < 0) or (x >= 168) or (y < 0) or (y >= 54) then continue;

    //writeln(x, y, tn, tc);
    tile := @map[y * 168 + x];

    case tn of
      // -1:
      //   writeln('player ', x, ' ', y);
      0, 1:
      begin
        //writeln('terrain');
        tile^.tile := 4;
        tile^.description:=0;
        tile^.color := tc;
      end;
      13: { Moving Platform }
      begin
        BlockRead(f, p0, sizeof(integer));
        BlockRead(f, p1, sizeof(integer));
        BlockRead(f, p2, sizeof(integer));
        BlockRead(f, p3, sizeof(integer));
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
      70: {Enemy "Rabid Mushroom" }
      begin
           e := SpawnEntity(x * 24, y * 24, tn);
         Entity_SetState(e, STATE_RM_IDLE);
      end;
      71: { Enemy "mosquito" }
      begin
        //"temp, x1, y1, x2, y2"
        BlockRead(f, x, sizeof(integer));
        BlockRead(f, x, sizeof(integer));
        BlockRead(f, y, sizeof(integer));
        BlockRead(f, tc, sizeof(integer));
        BlockRead(f, tc, sizeof(integer));

        e := SpawnEntity(x * 24, y * 24, tn);
        Entity_SetState(e, STATE_MOSQU_IDLE);
      end;
    end;
  end;
  System.Close(f);
end;

procedure DrawMap;
var
  tileStartX, tileStartY: integer;
  x, y, i, c, tx, ty: integer;
  idx: integer;
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
        4: begin
          tx := tile^.color mod 16;
          ty := tile^.color div 16;

          //R_DrawLine(x * 24 - camera.x, y * 24 - camera.y, x * 24 - camera.x + 24, y * 24 - camera.y + 24, 255, 255, 255, 255);
          R_DrawSprite(x * 24 - camera.x, y * 24 - camera.y, textures[SPRITE_T1]^);
{
          c := $aa;
          if ((x + y) mod 2) = 0 then c := $7f;

          for i := 0 to 23 do begin
            R_DrawLine(
            x * 24 + i - camera.x,
            y * 24 + 24 - camera.y,
            x * 24 + i - camera.x,
            (y * 24 + 24 - heights[tile^.description][i]) - camera.y, 0, c, 0, 255);
          end;
}
          R_DrawSubImageTransparent(renderedTiles^, x * 24 - camera.x, y * 24 - camera.y, tx * 24, ty * 24, 24, 24);
        end;

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
  writeln('G_Init');

  Entity__Init;

  LoadGFX;

  FillChar(entities, sizeof(TEntity) * MAX_ENTITIES, 0);
  
  //LoadLevel('levels/1_1.l2');
  //LoadLevel2('dev/out_test.l3');
    LoadLevel2('dev/out_testmap1.l3');
{
  map[14 * 168 + 5].tile := 4;
  map[14 * 168 + 5].description := 2;
  map[14 * 168 + 6].tile := 4;
  map[14 * 168 + 6].description := 3;

  map[11 * 168 + 3].tile := 4;
  map[11 * 168 + 3].description := 0;

  map[14 * 168 + 7].tile := 4;
  map[14 * 168 + 7].description := 27;
  map[14 * 168 + 8].tile := 4;
  map[14 * 168 + 8].description := 28;
  map[14 * 168 + 9].tile := 4;
  map[14 * 168 + 9].description := 29;
  map[14 * 168 + 10].tile := 4;
  map[14 * 168 + 10].description := 30;
  map[14 * 168 + 11].tile := 4;
  map[14 * 168 + 11].description := 31;

  map[15 * 168 + 11].tile := 4;
  map[15 * 168 + 11].description := 0;

  map[15 * 168 + 12].tile := 4;
  map[15 * 168 + 12].description := 33;
  map[15 * 168 + 13].tile := 4;
  map[15 * 168 + 13].description := 34;
  map[15 * 168 + 14].tile := 4;
  map[15 * 168 + 14].description := 35;
  map[15 * 168 + 15].tile := 4;
  map[15 * 168 + 15].description := 36;

}
  //map[14 * 168 + 6].tile := 1;


  //map[13 * 168 + 6].tile := 1;
  //e := SpawnEntity(3 * 24, 4 * 24, -1);
  e := SpawnEntity(7 * 24, 10 * 24, 1);
  gPlayer.ent := e;
  Entity_SetState(e, STATE_PLAYER_STAND1);

  for i := 0 to 1 do
  begin
    //e := SpawnEntity(24 * (6 + i), 14 * 24, 38);
    //Entity_SetState(e, STATE_BOX_RING1);
  end;
{
  mp := PEntityMovingPlatform(SpawnEntity(7 * 24, 12 * 24, 13));

  mp^.p[0].x := mp^.x;
  mp^.p[0].y := mp^.y;
  mp^.p[1].x := mp^.x + 24 * 3;
  mp^.p[1].y := mp^.y;
  mp^.dest := 1;

  Entity_SetState(mp, STATE_MPLAT);
}
  Event_SetKeyDownProc(OnKeyDown);
  Event_SetKeyUpProc(OnKeyUp);

  writeln('G_Init: done');



  //map[0 * 168 + 0].tile := 1;
  //map[1 * 168 + 1].tile := 1;
end;

procedure G_RunFrame; alias: 'G_RunFrame';
  var i: integer;
  e: PEntity;
  doRunFrame: boolean;
begin

    doRunFrame := true;

    Sys_PollEvents;
    Event_ProcessEvents;

    if I_WasKeyPressed(kEsc) or I_IsKeyDown(k0) then
    begin
      shouldQuit := True;
    end;

    if I_WasKeyPressed(kP) then begin
      isPaused := not isPaused;
    end;

    if I_WasKeyPressed(kD) then begin
      gPlayer.debugMode := not gPlayer.debugMode;
      gPlayer.velX:=0;
      gPlayer.velY:= 0;
    end;

    if isPaused then begin
      doRunFrame := false;
       if I_WasKeyPressed(kA) then doRunFrame := true;
    end;

    if doRunFrame then begin
      Inc(frameCount);
      if isPaused then writeln('Frame ', frameCount, ' ===================');

      Player_Update(gPlayer.ent);

      for i := 1 to MAX_ENTITIES do
      begin
        if (entities[i].flags and 1) = 0 then continue;
        e := @entities[i];

        Dec(e^.stateFrames);

        if e^.stateFrames <= 0 then
        begin
          Entity_SetState(e, entity_states[Ord(e^.state)].nextState);

          if entity_states[Ord(e^.state)].func = 999 then
          begin
            e^.flags := 0;
          end;
        end;

        if e^.t = 13 then
        begin
          MovingPlatform_Update(e);
        end;

        if Assigned(entityInfo[e^.t].updateProc) then entityInfo[e^.t].updateProc(e);

        //if e^.t = 70 then
        //begin
        //  Entity_RM_Update(e);
        //end;
        //
        //if e^.t = 72 then
        //begin
        //  Entity_BPot_Update(e);
        //end;
      end;

      camera.x := gPlayer.ent^.x - 6 * 24;
      camera.y := gPlayer.ent^.y - 4 * 24;
      if camera.x < 0 then camera.x := 0;
      if camera.y < 0 then camera.y := 0;

    end;
    
    engine.prevKeys := engine.keys;
end;

procedure G_Draw; alias:'G_Draw';
  var
  img, img2: pimage_t;
  x, i: integer;
  e: PEntity;
  mp: PEntityMovingPlatform;

begin
    DrawMap;

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

    R_DrawText(0, 0, 'Player: ');
    R_DrawText(42, 0, IntToStr(gPlayer.ent^.x));
    R_DrawText(42, 9, IntToStr(gPlayer.ent^.y));

    R_DrawText(80, 0, IntToStr(gPlayer.velX));
    R_DrawText(80, 9, IntTOStr(gPlayer.velY));

    if playerInAir then R_DrawText(0, 18, 'In air');
    if isPaused then R_DrawText(0, 27, 'Paused');
    if gPlayer.debugMode then R_DrawText(0, 36, 'Debug mode');

    //R_DrawSprite(0, 0, renderedTiles^);
    R_SwapBuffers;
end;

procedure Main;
var
  img, img2: pimage_t;
  x, i: integer;
  e: PEntity;
  mp: PEntityMovingPlatform;

begin
  x := 0;
  isPaused := false;
  frameCount := 0;

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

    G_Draw;

    Timer_Delay(16 * 2);
  end;
end;



end.
