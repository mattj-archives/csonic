
Unit Game;

Interface

uses image, res_enum;

procedure Game_New;
Procedure G_RunFrame;
Procedure G_Draw;
procedure DrawWorldLine(x0, y0, x1, y1: longint);
procedure DrawWorldRay(x0, y0, dx, dy: longint);
Procedure DrawState(x, y: integer; state: entityStates; direction: integer);

Var 
  isPaused: boolean;

  camx, camy: longint;

  textures: array[0 .. 200] Of pimage_t;
  renderedTiles: pimage_t;
  frameCount: longint;

Implementation

Uses Sys, Event, entity, engine, util
,common
,player
,res,  SysUtils, map

    {$ifdef SDL2}
,GFX_SDL
  {$endif}
;



procedure DrawWorldLine(x0, y0, x1, y1: longint);
begin
  R_DrawLine(
        fix32ToInt(x0 - G.camera.x), fix32ToInt(y0 - G.camera.y),
        fix32ToInt(x1 - G.camera.x), fix32ToInt(y1 - G.camera.y), 255, 255, 255, 255);
end;

procedure DrawWorldRay(x0, y0, dx, dy: longint);
begin
  R_DrawLine(
        fix32ToInt(x0 - G.camera.x), fix32ToInt(y0 - G.camera.y),
        fix32ToInt(x0 + dx - G.camera.x), fix32ToInt(y0 + dy - G.camera.y), 255, 255, 255, 255);
end;

Procedure DrawMap;

Var 
  tileStartX, tileStartY: integer;
  x, y, i, c, tx, ty: integer;
  x0, y0: longint;

  idx: integer;
  tile: ^TTile;
Begin


  tileStartX := camx Div 24;
  tileStartY := camy Div 24;

  For y := tileStartY To tileStartY + 10 Do
    Begin
      For x := tileStartX To tileStartX + 14 Do
        Begin
          tile := @G.map[y * 168 + x];
      {R_DrawSprite(x * 24 - camera.x, y * 24 - camera.y, textures[tile^.tile]^);            }

          x0 := fix32ToInt((intToFix32(x * 24) - G.camera.X));
          y0 := fix32ToInt((intToFix32(y * 24) - G.camera.Y));

          Case tile^.tile Of 
            0:
               Begin
                 //R_DrawSprite(x * 24 - camx, y * 24 - camy, textures[SPRITE_T1]^);

               End;
            1:
               Begin
               End;
            //R_DrawSprite(x * 24 - camx, y * 24 - camy, textures[SPRITE_T2]^);
            4:
               Begin
                 tx := tile^.color Mod 16;
                 ty := tile^.color Div 16;




//R_DrawLine(x * 24 - G.camera.x, y * 24 - G.camera.y, x * 24 - G.camera.x + 24, y * 24 - G.camera.y + 24, 255, 255, 255, 255);
                 //R_DrawSprite(x * 24 - camx, y * 24 - camy, textures[SPRITE_T1]^);

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
                 R_DrawSubImageTransparent(renderedTiles^, x0, y0, tx * 24, ty * 24, 24, 24);
               End;

          End;
        End;
    End;
End;



Procedure DrawState(x, y: integer; state: entityStates; direction: integer);

Var 
  ss: ^TSpriteState;
  img: pimage_t;
Begin
  If direction >= 3 Then Dec(direction, 3);
  //writeln('direction ', direction);
  ss := @sprite_states[Ord(entity_states[Ord(state)].spriteState)];
  img := textures[ss^.sprites[direction]];
  { writeln('draw state ', ord(state), ' at ', x, ' ', y); }
  If Not Assigned(img) Then
    Begin
      // writeln('error...', Ord(state), ' ', direction, ' sprite index ',
      //   ss^.sprites[direction], ' at ', x, ' ', y);
    End;
  If Assigned(img) Then R_DrawSprite(x, y, img^);
End;

Procedure G_Draw;
alias: 'G_Draw';

Var 
  //img, img2: pimage_t;
  x, i: integer;
  e: PEntity;
  mp: PEntityMovingPlatform;
  bb: TBoundingBox;

Begin

  { camera.X := intToFix32(4 * 24); }

  camx := fix32ToInt(G.camera.X);
  camy := fix32ToInt(G.camera.Y);

  R_FillColor($aa0000);
  DrawMap;

  //R_FillRect(0, 0, 200, 200, 2);
  For i := 1 To MAX_ENTITIES Do
    Begin
      If (G.entities[i].flags And 1) = 0 Then continue;
      e := @G.entities[i];

      //if e^.x < camera.x - 24 then continue;
      //if e^.x > camera.x + 320 then continue;
      //if e^.y < camera.y - 24 then continue;
      //if e^.y > camera.y + 240 then continue;

      //writeln('draw entity ', i, ' type ', e^.t);
      if Assigned(e^.info^.drawProc) then
         e^.info^.drawProc(e)
      else begin
           DrawState(fix32ToInt(e^.x - G.camera.x), fix32ToInt(e^.y - G.camera.y), e^.state, e^.direction);
      end;
      Entity_Hitbox(e, bb);

      Inc(bb.bottom, intToFix32(-1));
      Inc(bb.right, intToFix32(-1));

      //bb.right := (bb.right - G.camera.x) - 1;

      DrawWorldLine(bb.left, bb.top, bb.right, bb.top);
      DrawWorldLine(bb.left, bb.bottom, bb.right, bb.bottom);
      DrawWorldLine(bb.left, bb.top, bb.left, bb.bottom);
      DrawWorldLine(bb.right, bb.top, bb.right, bb.bottom);

     { R_DrawLine(
                 fix32ToInt(bb.left - G.camera.x), bb.bottom,
                 bb.right, bb.bottom, 255, 255, 255, 255);

      R_DrawLine(
           fix32ToInt(bb.left - G.camera.x),  fix32ToInt(bb.top - G.camera.y),
           fix32ToInt(bb.left - G.camera.x), bb.bottom, 255, 255, 255, 255);

           R_DrawLine(
           bb.right,  fix32ToInt(bb.top - G.camera.y),
           bb.right, bb.bottom, 255, 255, 255, 255);
                                                                }
      if Assigned(G.entityInfo[e^.t].debugDrawProc) then G.entityInfo[e^.t].debugDrawProc(e);
    End;

  R_DrawText(0, 0, 'Player: ');
  R_DrawText(42, 0, IntToStr(gPlayer.ent^.x));
  R_DrawText(42, 9, IntToStr(gPlayer.ent^.y));

  R_DrawText(80, 0, IntToStr(gPlayer.velX));
  R_DrawText(80, 9, IntTOStr(gPlayer.velY));

  If playerInAir Then R_DrawText(0, 18, 'In air');
  If isPaused Then R_DrawText(0, 27, 'Paused');
  If gPlayer.debugMode Then R_DrawText(0, 36, 'Debug mode');

  //R_DrawSprite(0, 0, renderedTiles^);
  R_SwapBuffers;
End;


procedure MovingPlatform_Move(var self: TEntityMovingPlatform; deltaX, deltaY: longint);
begin
  Inc(self.x, deltaX);
  Inc(self.y, deltaY);

    If gPlayer.groundEntity = @self Then
    Begin
      // TODO: Actually push player in this direction, check for getting crushed
      Inc(gPlayer.ent^.x, deltaX);
    End;

end;

Procedure MovingPlatform_Update(Data: Pointer);

Var 
  self: PEntityMovingPlatform absolute Data;
  destPoint: TVector2;
  deltaX: longint;
Begin

  deltaX := 0;

  destPoint := self^.p[self^.dest];

  If destPoint.x > self^.x Then
    Begin

      deltaX := floatToFix32(1);
      MovingPlatform_Move(self^, deltaX, 0);

      If self^.x >= destPoint.x Then
        Begin
          self^.dest := self^.dest xor 1;
        End;

      Exit;
   end;

  if destPoint.x < self^.x Then
    Begin
      deltaX := -floatToFix32(1);
      MovingPlatform_Move(self^, deltaX, 0);
      If self^.x <= destPoint.x Then
        Begin
          self^.dest := self^.dest xor 1;
        End;

      Exit;

    End;
End;

Procedure G_RunFrame;
alias: 'G_RunFrame';

Var i: integer;
  e: PEntity;
  doRunFrame: boolean;
Begin

  doRunFrame := true;

  Sys_PollEvents;
  Event_ProcessEvents;

  If I_WasKeyPressed(kEsc) Or I_IsKeyDown(k0) Then
    Begin
      shouldQuit := True;
    End;

  if I_WasKeyPressed(kR) then begin
     Game_New;
     Exit;
  end;
  If I_WasKeyPressed(kP) Then
    Begin
      isPaused := Not isPaused;
    End;

  If I_WasKeyPressed(kD) Then
    Begin
      gPlayer.debugMode := Not gPlayer.debugMode;
      gPlayer.velX := 0;
      gPlayer.velY := 0;
    End;

  If isPaused Then
    Begin
      doRunFrame := false;
      If I_WasKeyPressed(kA) Then doRunFrame := true;
      //doRunFrame := true;
    End;

  If doRunFrame Then
    Begin
      Inc(frameCount);
      If isPaused Then writeln('Frame ', frameCount, ' ===================');
      //if isPaused then writeln('...');
//      writeln('Frame ', frameCount, ' ===================');

      Player_Update(gPlayer.ent);

      For i := 1 To MAX_ENTITIES Do
        Begin
          If (G.entities[i].flags And 1) = 0 Then continue;
          e := @G.entities[i];

          Dec(e^.stateFrames);

          If e^.stateFrames <= 0 Then
            Begin
              Entity_SetState(e, entity_states[Ord(e^.state)].nextState);

              If entity_states[Ord(e^.state)].func = 999 Then
                Begin
                  e^.flags := 0;
                End;
            End;

          If e^.t = 13 Then
            Begin
              MovingPlatform_Update(e);
            End;

          If Assigned(G.entityInfo[e^.t].updateProc) Then G.entityInfo[e^.t].updateProc(e);

          //if e^.t = 70 then
          //begin
          //  Entity_RM_Update(e);
          //end;
          //
          //if e^.t = 72 then
          //begin
          //  Entity_BPot_Update(e);
          //end;
        End;

      G.camera.x := gPlayer.ent^.x - intToFix32(6 * 24);
      G.camera.y := gPlayer.ent^.y - intToFix32(4 * 24);
      If G.camera.x < 0 Then G.camera.x := 0;
      If G.camera.y < 0 Then G.camera.y := 0;

    End;

  engine.prevKeys := engine.keys;
End;

procedure Game_New;
var e: PEntity;
  i: integer;
begin

  FillChar(G.entities, sizeof(TEntity) * MAX_ENTITIES, 0);

  //LoadLevel('levels/1_1.l2');
  //LoadLevel2('dev/out_test.l3');
    Map_Load('dev/out_testmap1.l3');
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
  e := SpawnEntity(intToFix32(7 * 24), intToFix32(10 * 24), 1);
  gPlayer.ent := e;
  Entity_SetState(e, STATE_PLAYER_STAND1);

  for i := 0 to 1 do
  begin
    //e := SpawnEntity(24 * (6 + i), 14 * 24, 38);
    //Entity_SetState(e, STATE_BOX_RING1);
  end;
    {
  mp := PEntityMovingPlatform(SpawnEntity(intToFix32(7 * 24), intToFix32(7 * 24), 13));

  mp^.p[0].x := mp^.x;
  mp^.p[0].y := mp^.y;
  mp^.p[1].x := mp^.x + intToFix32(24 * 3);
  mp^.p[1].y := mp^.y;
  mp^.dest := 1;

  Entity_SetState(mp, STATE_MPLAT);
     }
end;

End.
