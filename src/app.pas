unit app;

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

uses enemy, game, util, buffer, map;
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
  numFiles: smallint;
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
  BlockRead(f, numFiles, sizeof(smallint));
    writeln('Num files: ', numFiles);

    for i := 0 to numFiles - 1 do
    begin
      BlockRead(f, strLen, 1);

      Seek(f, FilePos(f) - 1);
      BlockRead(f, filename, strLen + 1);

      writeln(i + 1, ' ', fileName);

      textures[i + 1] := Image_Load('GFX3/' + fileName + '.png');
    end;

    System.Close(f);

    renderedTiles := Image_Load('dev/TEST_rendered.png');

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

    x := intToFix32(x * 24);
    y := intToFix32(y * 24);

    //writeln('Map entity spawn: ', x, ' ', y, ' ', ' type: ', tn);
    if (x < 0) or (x >= 168) or (y < 0) or (y >= 54) then continue;

    //writeln(x, y, tn, tc);
    tile := @G.map[y * 168 + x];

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

  Event_SetKeyDownProc(@OnKeyDown);
  Event_SetKeyUpProc(@OnKeyUp);

  Game_New;
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
