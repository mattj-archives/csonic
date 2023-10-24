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



implementation

uses enemy, game, util;
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
  i, x, y: longint;
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

        x:= x shl 3;
        Dec(y, 24);
        y:= y shl 3;

        case object_type of
        17: begin
          writeln('spawn Spring1 at ', x, ' ', y);
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
  x, y, tn, tc: longint;
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

    x := (x * 24) shl 3;
    y := (y * 24) shl 3;

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
        e := SpawnEntity(x, y, tn);
        Entity_SetState(e, STATE_SPRING1_IDLE);
      end;
      18: begin
        e := SpawnEntity(x, y, tn);
        Entity_SetState(e, STATE_SPRING2_IDLE);
      end;
      43:
      begin
        e := SpawnEntity(x, y, tn);
        Entity_SetState(e, entityStates.STATE_RING1);
      end;
      44: begin
        e := SpawnEntity(x, y, tn);
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
  e := SpawnEntity((7 * 24) shl 3, (10 * 24) shl 3, 1);
  gPlayer.ent := e;
  Entity_SetState(e, STATE_PLAYER_STAND1);

  for i := 0 to 1 do
  begin
    //e := SpawnEntity(24 * (6 + i), 14 * 24, 38);
    //Entity_SetState(e, STATE_BOX_RING1);
  end;

  mp := PEntityMovingPlatform(SpawnEntity(intToFix32(7 * 24), intToFix32(7 * 24), 13));

  mp^.p[0].x := mp^.x;
  mp^.p[0].y := mp^.y;
  mp^.p[1].x := mp^.x + intToFix32(24 * 3);
  mp^.p[1].y := mp^.y;
  mp^.dest := 1;

  Entity_SetState(mp, STATE_MPLAT);

  Event_SetKeyDownProc(OnKeyDown);
  Event_SetKeyUpProc(OnKeyUp);

  writeln('G_Init: done');



  //map[0 * 168 + 0].tile := 1;
  //map[1 * 168 + 1].tile := 1;
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
