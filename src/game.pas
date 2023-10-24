
Unit Game;

{$mode tp}

Interface

uses image;

Procedure G_RunFrame;
Procedure G_Draw;

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
,res, res_enum, SysUtils

    {$ifdef SDL2}
,GFX_SDL
  {$endif}
;





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
          tile := @map[y * 168 + x];
      {R_DrawSprite(x * 24 - camera.x, y * 24 - camera.y, textures[tile^.tile]^);            }

          x0 := (x * 24 * 8 - camera.X) shr 3;
          y0 := (y * 24 * 8 - camera.Y) shr 3;

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


//R_DrawLine(x * 24 - camera.x, y * 24 - camera.y, x * 24 - camera.x + 24, y * 24 - camera.y + 24, 255, 255, 255, 255);
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

Begin

  { camera.X := intToFix32(4 * 24); }

  camx := camera.X shr 3;
  camy := camera.Y shr 3;

  R_FillColor($aa0000);
  DrawMap;

  //R_FillRect(0, 0, 200, 200, 2);
  For i := 1 To MAX_ENTITIES Do
    Begin
      If (entities[i].flags And 1) = 0 Then continue;
      e := @entities[i];

      //if e^.x < camera.x - 24 then continue;
      //if e^.x > camera.x + 320 then continue;
      //if e^.y < camera.y - 24 then continue;
      //if e^.y > camera.y + 240 then continue;

      //writeln('draw entity ', i, ' type ', e^.t);
      DrawState((e^.x - camera.x) shr 3, (e^.y - camera.y) shr 3, e^.state, e^.direction);
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


Procedure MovingPlatform_Update(Data: Pointer);

Var 
  self: PEntityMovingPlatform absolute Data;
  destPoint: TVector2;
  deltaX: integer;
Begin

  deltaX := 0;

  destPoint := self^.p[self^.dest];

  If destPoint.x > self^.x Then
    Begin
      deltaX := 3;
      Inc(self^.x, deltaX);
      If self^.x >= destPoint.x Then
        Begin
          self^.dest := self^.dest xor 1;
        End;
    End;

  If destPoint.x < self^.x Then
    Begin
      deltaX := -3;
      Inc(self^.x, deltaX);

      If self^.x <= destPoint.x Then
        Begin
          self^.dest := self^.dest xor 1;
        End;
    End;

  If gPlayer.groundEntity = PEntity(self) Then
    Begin
      // TODO: Actually push player in this direction, check for getting crushed
      Inc(gPlayer.ent^.x, deltaX);
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
    End;

  If doRunFrame Then
    Begin
      Inc(frameCount);
      If isPaused Then writeln('Frame ', frameCount, ' ===================');

      Player_Update(gPlayer.ent);

      For i := 1 To MAX_ENTITIES Do
        Begin
          If (entities[i].flags And 1) = 0 Then continue;
          e := @entities[i];

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

          If Assigned(entityInfo[e^.t].updateProc) Then entityInfo[e^.t].updateProc(e);

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

      camera.x := gPlayer.ent^.x - (6 * 24) shl 3;
      camera.y := gPlayer.ent^.y - (4 * 24) shl 3;
      If camera.x < 0 Then camera.x := 0;
      If camera.y < 0 Then camera.y := 0;

    End;

  engine.prevKeys := engine.keys;
End;

End.
