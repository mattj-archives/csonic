unit Player;

interface

uses
  res, res_enum, common, engine, entity, Sensor;

type
  TPlayer = record
    velX, velY: longint;
    groundEntity: PEntity;
    ent: PEntity;
    debugMode: boolean;
    invincFramesCount: integer;
    invincFramesTime: integer;
    numRings: integer;
  end;

procedure Player_Update(self: PEntity);
procedure Player_Damage;
procedure EntityType_Player_Init(var info: TEntityInfo);

var
  gPlayer: TPlayer;

var
  playerInAir: boolean;

implementation

uses sys, util, game, SysUtils, powerup;

type
  SonicModes = (
    None,
    Running,
    Waiting,
    Standing,
    Spinning
    );

var
  mode: SonicModes;
  modeTime: longint;

procedure Player_SetMode(_mode: SonicModes);
begin
  modeTime := Timer_GetTicks;

  if mode = _mode then Exit;

  mode := _mode;

  case mode of
    SonicModes.Running:
      Entity_SetState(gPlayer.ent, entityStates.STATE_PLAYER_RUN1);
    SonicModes.Waiting:
      Entity_SetState(gPlayer.ent, entityStates.STATE_PLAYER_WAIT1);
    SonicModes.Standing:
      Entity_SetState(gPlayer.ent, entityStates.STATE_PLAYER_STAND1);
    SonicModes.Spinning:
      Entity_SetState(gPlayer.ent, entityStates.STATE_PLAYER_SPIN1);
  end;
end;

procedure Player_Jump(self: PEntity);
begin
  if gPlayer.velY <> 0 then
  begin
    writeln('cant jump, vel is ', gPlayer.velY);
    Exit;
  end;

  if playerInAir then
  begin
    writeln('cant jump, player is in air');
    Exit;
  end;

  gPlayer.velY := -intToFix32(13);
  playerInAir := True;
  Player_SetMode(Spinning);
end;

procedure Player_HitEntity(self, e: PEntity; traceInfo: THitResult);
var
  explode: PEntity;
  bbOther: TBoundingBox;
begin
  if traceInfo.hitType <> 2 then Exit;

  bbOther := Entity_Hitbox(e);

  //Log('Player_HitEntity type: %d idx:%d', [e^.t, e^.idx]);

  if Assigned(e^.info^.collideFunc) then
  begin
    e^.info^.collideFunc(e, self);
    Exit;
  end;

  if e^.t = 17 then
  begin
    gPlayer.velY := intToFix32(-16);
    self^.y := bbOther.top - intToFix32(24 + 6);
    Entity_SetState(e, STATE_SPRING1_USE);
  end;

  if e^.t = 18 then
  begin
    // writeln('touch spring');
    gPlayer.velY := intToFix32(-20);
    self^.y := bbOther.top - intToFix32(24 + 6);
    Entity_SetState(e, STATE_SPRING2_USE);
  end;

  if e^.t = 44 then
  begin
    e^.flags := 0;
  end;

  if e^.t = Ord(ENTITY_TYPE_BOX_RING) then
  begin
    if mode = SonicModes.Spinning then
    begin

      //if gPlayer.velY > 0 then gPlayer.velY := intToFix32(-12);
      gPlayer.velY := fix32Mul(gPlayer.velY, floatToFix32(-1.1));

      explode := SpawnEntity(e^.x, e^.y, 100);
      // writeln('explode at ', e^.x, ' ', e^.y);
      Entity_SetState(explode, entityStates.STATE_EXPLODE1);

      e^.flags := 0;
    end;
  end;

  if (e^.t = 70) or (e^.t = 71) or (e^.t = 72) then
  begin
    if mode = SonicModes.Spinning then
    begin
      //if traceInfo.velY > 0 then gPlayer.velY := intToFix32(-12);
      gPlayer.velY := fix32Mul(gPlayer.velY, floatToFix32(-1.1));

      explode := SpawnEntity(e^.x, e^.y, 100);
      // writeln('explode at ', e^.x, ' ', e^.y);
      Entity_SetState(explode, entityStates.STATE_EXPLODE1);

      e^.flags := 0;
    end
    else
    begin
      Player_Damage;
    end;
  end;
end;

procedure Player_Touch(self: PEntity);
var
  this, other: TBoundingBox;
  i: integer;
  e, explode: PEntity;
  adjustBox: boolean;
  adjVector, playerVel: TVector2;
  traceInfo: THitResult;

begin

  traceInfo := InitTraceInfo(COLLISION_LEVEL or COLLISION_ENEMY, self);
  traceInfo.velX := gPlayer.velX;
  traceInfo.velY := gPlayer.velY;
  traceInfo.hitType := 2;

  this.left := self^.x;
  this.right := this.left + intToFix32(24);
  this.top := self^.y;
  this.bottom := this.top + intToFix32(24);

  { TODO... velX, velY should be a vector... }

  playerVel.x := gPlayer.velX;
  playerVel.y := gPlayer.velY;

  for i := 1 to MAX_ENTITIES do
  begin
    e := @G.entities[i];

    if (e^.flags and 1) = 0 then continue;
    if e = self then continue;

    adjustBox := False;

    other := Entity_Hitbox(e);

    if this.left >= other.right then continue;
    if this.right <= other.left then continue;
    if this.top >= other.bottom then continue;
    if this.bottom <= other.top then continue;

    Player_HitEntity(self, e, traceInfo);
{
    if e^.t = 72 then
    begin
      if mode = SonicModes.Spinning then
      begin
        if gPlayer.velY > 0 then gPlayer.velY := -12;

        explode := SpawnEntity(e^.x, e^.y, 100);
        // writeln('explode at ', e^.x, ' ', e^.y);
        Entity_SetState(explode, entityStates.STATE_EXPLODE1);

        e^.flags := 0;
        adjustBox := True;
      end;
    end;
}
    if adjustBox then
    begin
      GetBoxAdjustment(this, other, playerVel, adjVector);
      Inc(self^.x, adjVector.x);
      Inc(self^.y, adjVector.y);
    end;
  end;
end;

procedure DebugMove(self: PEntity);
var
  delta: TVector2;
  Result: THitResult;
begin
  if I_IsKeyDown(kUp) then
  begin
    Inc(gPlayer.velY, intToFix32(-2));
    if gPlayer.velY < intToFix32(-8) then gPlayer.velY := intToFix32(-8);
  end;

  if I_IsKeyDown(kDn) then
  begin
    Inc(gPlayer.velY, intToFix32(2));
    if gPlayer.velY > intToFix32(8) then gPlayer.velY := intToFix32(8);
  end;

  if I_IsKeyDown(kLf) then
  begin
    Inc(gPlayer.velX, intToFix32(-2));
    if gPlayer.velX < intToFix32(-8) then gPlayer.velX := intToFix32(-8);
  end;

  if I_IsKeyDown(kRt) then
  begin
    Inc(gPlayer.velX, intToFix32(2));
    if gPlayer.velX > intToFix32(8) then gPlayer.velX := intToFix32(8);
  end;

  if gPlayer.velX < 0 then Inc(gPlayer.velX, intToFix32(1));
  if gPlayer.velX > 0 then Dec(gPlayer.velX, intToFix32(1));

  if gPlayer.velY < 0 then Inc(gPlayer.velY, intToFix32(1));
  if gPlayer.velY > 0 then Dec(gPlayer.velY, intToFix32(1));

  delta.x := gPlayer.velX;
  delta.y := gPlayer.velY;
  SimpleBoxMove(self, delta, Result);
end;

var
  initialSensor: THitresult;



procedure AirMove(self: PEntity);
var
  finalSensor, sensorYResult, sensorYResult2: THitResult;
const
  GRAVITY = 1 shl FRAC_BITS;
  MAX_Y_VEL = 12 shl FRAC_BITS;
begin
  Inc(gPlayer.velY, GRAVITY);

  if gPlayer.velY > MAX_Y_VEL then gPlayer.velY := MAX_Y_VEL;
  //if gPlayer.velY > 1 then gPlayer.velY := 1;
  finalSensor := initialSensor;
  sensorYResult := initialSensor;
  sensorYResult2 := initialSensor;

  if gPlayer.velY > 0 then
  begin
    //SensorRay(self^.x, self^.y + intToFix32(24), 0, gPlayer.velY, finalSensor); { should this be 23? }
    //SensorRay(self^.x + intToFix32(23), self^.y + intToFix32(24), 0, gPlayer.velY, sensorYResult2); { should this be 23? }

    SensorRay(self^.x, self^.y + intToFix32(16), 0, intToFix32(6) +
      gPlayer.velY, sensorYResult); { should this be 23? }
    SensorRay(self^.x + intToFix32(23), self^.y + intToFix32(16), 0,
      intToFix32(6) + gPlayer.velY, sensorYResult2); { should this be 23? }

    finalSensor := sensorYResult;

    if sensorYResult2.y < finalSensor.y then
      finalSensor := sensorYResult2;
  end
  else
  begin
    SensorRay(self^.x, self^.y, 0, gPlayer.velY, finalSensor);
    SensorRay(self^.x + intToFix32(23), self^.y, 0, gPlayer.velY, sensorYResult2);

    if sensorYResult2.y > finalSensor.y then
      finalSensor := sensorYResult2;
  end;

  //Log('AirMove sensor hitTypes: %d %d, chose %d', [sensorYResult.hitType, sensorYResult2.hitType, finalSensor.hitType]);

  if gPlayer.velY > 0 then
    self^.y := finalSensor.y - intToFix32(23)   // was 23
  else
    self^.y := finalSensor.y;

  gPlayer.groundEntity := nil;

  //writeln('falling hitType ', finalSensor.hitType);
  if (finalSensor.hitType = 2) and (gPlayer.velY > 0) then
  begin
    gPlayer.groundEntity := finalSensor.entity;
  end;

  if finalSensor.hitType <> 0 then
  begin
    //if gPlayer.velY > 0 then
    //begin
    //  playerInAir := False;
    //  //writeln('hit while in air, no longer in air');
    //end;

    // Could "velY" be filled in during the call to SensorRay?
    finalSensor.velY := gPlayer.velY;

    // Hit something
    //gPlayer.velY := 0;

    if gPlayer.velY < 0 then gPlayer.velY := 0;

    if finalSensor.hitType = 2 then
    begin
      Player_HitEntity(self, finalSensor.entity, finalSensor);
      { TODO: Player may have been bounced! }
      //writeln('player velY after hit ', gPlayer.velY);
    end;

    // If the player has been bounced back upwards again, then stay in the air

  end;
end;

procedure GroundCheck(self: PEntity);
var
  initialSensor, sensorYResult, sensorYResult2: THitResult;
begin

  initialSensor := InitTraceInfo(COLLISION_LEVEL, self);
  initialSensor.velX := gPlayer.velX;
  initialSensor.velY := gPlayer.velY;

  if gPlayer.invincFramesTime = 0 then initialSensor.collisionMask :=
      initialSensor.collisionMask or COLLISION_ENEMY;

  // Updates whether or not player is on the ground
  playerInAir := True;

  if gPlayer.velY < 0 then Exit;

  sensorYResult := initialSensor;
  sensorYResult2 := initialSensor;

  SensorRay(self^.x, self^.y + intToFix32(23), 0, intToFix32(2), sensorYResult);
  { should this be 23? }
  SensorRay(self^.x + intToFix32(23), self^.y + intToFix32(23), 0,
    intToFix32(2), sensorYResult2);  { should this be 23? }

  { TODO: Touch entities hit by gravity }

  //writeln('Ground check: ', sensorYResult, ' ', sensorYResult2, ' adj ', adj, adj2);

  if (sensorYResult.y <> self^.y + intToFix32(23)) and
    (sensorYResult2.y <> self^.y + intToFix32(23)) then     // was 23
  begin
    gPlayer.groundEntity := nil;
    //writeln('player in air');
    Exit;
  end
  else
  begin
    //writeln('GroundCheck: Player on ground');
    gPlayer.velY := 0;

    if sensorYResult.hitType = 2 then
    begin
      Player_HitEntity(self, sensorYResult.entity, sensorYResult);
    end
    else
    begin

      if sensorYResult2.hitType = 2 then
      begin
        Player_HitEntity(self, sensorYResult2.entity, sensorYResult2);
      end;
    end;
    // may need to set groundentity here
  end;

  // If the player has been bounced back upwards again, then stay in the air
  if gPlayer.velY < 0 then Exit;

  playerInAir := False;

end;

procedure UpdateMode;
begin

  case mode of
    SonicModes.Running:
    begin
      if gPlayer.velX = 0 then
      begin
        // If we're not in the air and not running, set to standing

        if not playerInAir then Player_SetMode(SonicModes.Standing);
      end;
    end;
    SonicModes.Standing:
    begin
      if gPlayer.velX <> 0 then
      begin
        Player_SetMode(SonicModes.Running);
      end
      else
      begin
        if Timer_GetTicks - modeTime > 1000 then
        begin
          Player_SetMode(SonicModes.Waiting);
        end;
      end;
    end;
    SonicModes.Waiting:
    begin
      if gPlayer.velX <> 0 then
      begin
        Player_SetMode(SonicModes.Running);
      end;
    end;
    SonicModes.Spinning:
    begin
      if not playerInAir then
      begin
        if gPlayer.velX <> 0 then
        begin
          Player_SetMode(Running);
        end
        else
        begin
          Player_SetMode(Standing);
        end;
      end;
    end;
  end;

end;

procedure Player_Update(self: PEntity);
var
  playerWasInAir: boolean;
  finalSensor, sensorXResult, sensorYResult, sensorYResult2: THitResult;

const
  MAX_X_VEL = 9 shl FRAC_BITS;
  X_ACCEL = 2 shl FRAC_BITS;

begin

  traceEntitySkip := self;

  if gPlayer.debugMode then
  begin
    DebugMove(self);
    Exit;
  end;

  if mode = SonicModes.None then
  begin
    mode := SonicModes.Standing;
    Entity_SetState(self, STATE_PLAYER_STAND1);
    modeTime := Timer_GetTicks;
  end;

  playerWasInAir := playerInAir;

  if I_IsKeyDown(kLf) then
  begin
    Inc(gPlayer.velX, -X_ACCEL);
    if gPlayer.velX < -MAX_X_VEL then gPlayer.velX := -MAX_X_VEL;
  end;

  if I_IsKeyDown(kRt) then
  begin
    Inc(gPlayer.velX, X_ACCEL);
    if gPlayer.velX > MAX_X_VEL then gPlayer.velX := MAX_X_VEL;
  end;

  if gPlayer.invincFramesTime > 0 then Dec(gPlayer.invincFramesTime);

  GroundCheck(self);

  if I_IsKeyDown(kSpace) then
  begin
    Player_Jump(self);
  end;

  { Decelerate X }

  if gPlayer.velX < 0 then Inc(gPlayer.velX, intToFix32(1));
  if gPlayer.velX > 0 then Dec(gPlayer.velX, intToFix32(1));

  initialSensor := InitTraceInfo(COLLISION_LEVEL, self);
  initialSensor.velX := gPlayer.velX;
  initialSensor.velY := gPlayer.velY;

  if gPlayer.invincFramesTime = 0 then initialSensor.collisionMask :=
      initialSensor.collisionMask or COLLISION_ENEMY;

  if playerInAir then
  begin
    AirMove(self);
    GroundCheck(self);
  end;

  if gPlayer.velX <> 0 then
  begin

    sensorXResult := initialSensor;

    if gPlayer.velX > 0 then
    begin
      SensorRay(self^.x + intToFix32(23), self^.y + intToFix32(11),
        gPlayer.velX, 0, sensorXResult);
      if sensorXResult.hitType <> 0 then
      begin
        gPlayer.velX := 0;
      end;
      self^.x := sensorXResult.x - intToFix32(23);
    end
    else
    begin
      SensorRay(self^.x, self^.y + intToFix32(11), gPlayer.velX, 0, sensorXResult);
      //SensorX(self^.y + intToFix32(11), self^.x, self^.x + gPlayer.velX, sensorXResult);
      self^.x := sensorXResult.x;
      if sensorXResult.hitType <> 0 then
      begin
        gPlayer.velX := 0;
      end;
    end;

    if sensorXResult.hitType = 2 then
    begin
      Player_HitEntity(self, sensorXResult.entity, sensorXResult);
    end;

    if not playerInAir then
    begin

      { Keep player stuck to the ground, if possible... }
      //endY := self^.y + intToFix32(28);

      SensorRay(self^.x, self^.y + intToFix32(11),
        0, intToFix32(17), sensorYResult);
      SensorRay(self^.x + intToFix32(23), self^.y + intToFix32(11),
        0, intToFix32(17), sensorYResult2);
      //SensorY(self^.x, self^.y + intToFix32(11), endY, sensorYResult);
      //adj := (sensorYResult.y - endY);


      //SensorY(self^.x + intToFix32(23), self^.y + intToFix32(11), endY, sensorYResult2);
      //adj2 := (sensorYResult2.y - endY);

      // writeln('Terrain move sensorY results: ', sensorYResult, ' ', sensorYResult2, ' adj: ', adj, ' ', adj2);

      //if (sensorYResult.y <> endY) or (sensorYResult2.y <> endY) then
      //begin
      if (sensorYResult.hitType <> 0) or (sensorYResult2.hitType <> 0) then
      begin

        if sensorYResult2.y < sensorYResult.y then sensorYResult := sensorYResult2;
        self^.y := sensorYResult.y - intToFix32(23);

        if sensorYResult.hitType = 2 then
        begin
          Player_HitEntity(self, sensorYResult.entity, sensorYResult);
        end;
      end;
      //end;
    end;

    if gPlayer.velX > 0 then self^.direction := 4;
    if gPlayer.velX < 0 then self^.direction := 3;
  end;

  UpdateMode;

  Player_Touch(self);

end;

procedure DebugDraw(Data: Pointer);
var
  self: PEntity absolute Data;
begin

  if gPlayer.velX > 0 then DrawWorldRay(self^.x + intToFix32(23),
      self^.y + intToFix32(11), gPlayer.velX, 0);
  if gPlayer.velX < 0 then DrawWorldRay(self^.x, self^.y + intToFix32(11),
      gPlayer.velX, 0);

  if playerInAir then
  begin
    if gPlayer.velY > 0 then
    begin
      DrawWorldRay(self^.x, self^.y + intToFix32(16), 0,
        intToFix32(6) + gPlayer.velY); { should this be 23? }
      DrawWorldRay(self^.x + intToFix32(23), self^.y + intToFix32(16),
        0, intToFix32(6) + gPlayer.velY); { should this be 23? }

    end;
  end;
  //DrawWorldRay(self^.x + intToFix32(0), self^.y + intToFix32(11), 0, intToFix32(18));
  //DrawWorldRay(self^.x + intToFix32(23), self^.y + intToFix32(11), 0, intToFix32(18));
end;

procedure Player_Damage;
var
  i: integer;
  e: PEntityRing;
begin
  with gPlayer.ent^ do
  begin
    if gPlayer.invincFramesTime = 0 then
    begin
      gPlayer.invincFramesTime := 30 * 4;
      for i := 0 to 10 do
      begin
        e := PEntityRing(SpawnEntity(x, y, ord(ENTITY_TYPE_RING)));
        Ring_SetBouncing(e);
      end;
    end;

  end;

end;


procedure Draw(Data: Pointer);
var
  self: PEntity absolute Data;
begin
  if gPlayer.invincFramesTime > 0 then
  begin
    Inc(gPlayer.invincFramesCount);
    if (gPlayer.invincFramesCount mod 2 = 0) then Exit;
  end;

  Entity_Draw(self);
end;

procedure EntityType_Player_Init(var info: TEntityInfo);
begin
  with info do
  begin

    debugDrawProc := @DebugDraw;
    drawProc := @Draw;
  end;
  //info.updateProc := Entity_BPot_Update;
end;

begin

  playerInAir := True;
  mode := SonicModes.None;
  gPlayer.groundEntity := nil;
  gPlayer.debugMode := False;
end.
