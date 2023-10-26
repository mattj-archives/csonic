unit enemy;

{$mode tp}

interface

uses common;

procedure EntityType_RM_Init(var info: TEntityInfo);
procedure EntityType_Mosquito_Init(var info: TEntityInfo);
procedure EntityType_BPot_Init(var info: TEntityInfo);

implementation

uses res, res_enum, sensor, app, player, entity, sys, game, util, engine;

procedure Entity_BPot_State(Data: Pointer);
var
  self: PEntityBPot absolute Data;
begin
  case self^.state of
    STATE_BPOT_IDLE:
    begin
      self^.vy := -12;
    end;
  end;
end;

procedure Entity_BPot_Update(Data: Pointer);
var
  self: PEntityBPot absolute Data;
  Result: THitResult;
  initialY: integer;
  //distanceRemaining: integer;
begin

  initialY := self^.y;

  Inc(self^.vy, intToFix32(1));

  //  distanceRemaining := Abs(self^.vy);
  //  repeat

  //  until distanceRemaining <= 0;

  if (self^.vy > 0) then
  begin
    SensorY(self^.x + intToFix32(12), self^.y + intToFix32(23), self^.y +
      intToFix32(23) + self^.vy, Result);

    self^.y := Result.y - intToFix32(23);
    if Result.hitType <> 0 then
    begin
      self^.vy := intToFix32(-12);
      if isPaused then
      begin
        writeln('bpot hit ground, set vy = -12');
      end;
    end;
  end
  else
  begin
    Inc(self^.y, self^.vy);
  end;

  if isPaused then
  begin

    writeln('moved ', initialY, ' -> ', self^.y, ' delta: ', self^.y -
      initialY, ' velocity was ', self^.vy);
  end;
  //writeln(self^.y, ' ', self^.vy);
end;

procedure RM_Wait(var self: TEntityRM);
begin
  //Entity_SetState(@self, STATE_RM_WALK);
end;


procedure RM_DebugDraw(Data: Pointer);
var
  self: PEntityRM absolute Data;
begin
     DrawWorldRay(self^.x + intToFix32(23), self^.y + intToFix32(15), intToFix32(1), 0);

     DrawWorldRay(self^.x + intToFix32(0), self^.y + intToFix32(11), 0, intToFix32(18));
     DrawWorldRay(self^.x + intToFix32(23), self^.y + intToFix32(11), 0, intToFix32(18));
end;

procedure RM_Walk(var self: TEntityRM);
var
  Result, Result2: THitResult;
  originalX, originalY: longint;
begin
  originalX := self.x;
  originalY := self.y;
  traceEntitySkip := @self;

  if (gPlayer.ent^.x > self.x) then
  begin
    SensorRay(self.x + intToFix32(23), self.y + intToFix32(15), intToFix32(1), 0, Result);
    self.direction := 4;
    writeln('RM +X hitType ', Result.hitType);
    //if Result.hitType <> 0 then Exit;
    self.x := Result.x - intToFix32(23);
  end;

  if (gPlayer.ent^.x < self.x) then
  begin
    SensorRay(self.x, self.y + intToFix32(15), intToFix32(-1), 0, Result);
    self.direction := 3;
    //if Result.hitType <> 0 then Exit;
    self.x := Result.x;
  end;

  // Allow them to stick to the ground if they only move max 2 pixels up or down

  SensorRay(self.x + intToFix32(0),  self.y + intToFix32(11), 0, intToFix32(18), Result);
  SensorRay(self.x + intToFix32(23), self.y + intToFix32(11), 0, intToFix32(18), Result2);
  if Result2.y < Result.y then Result := Result2;

  {if Result.hitType = 1 then
  begin}
    self.y := Result.y - intToFix32(23);
    //writeln('RM ground trace found ', Result.y);
  //end;

  // TODO: If their Y position changed by more than 2, don't allow the move

  if Abs(self.y - originalY) > intToFix32(2) then
  begin
    self.x := originalX;
    self.y := originalY;
    // writeln('can''t move, Y change is ', self.y, ' -> ', newY, ' abs: ', abs(self.y - newY));
    Exit;
  end;
end;


procedure Entity_RM_State(Data: Pointer);
var
  self: PEntityRM absolute Data;
  playerIsFacing: boolean;
begin
  playerIsFacing := False;
  if not assigned(gPlayer.ent) then Exit;

  if (gPlayer.ent^.x > self^.x) and (gPlayer.ent^.direction = 3) then
    playerIsFacing := True;
  if (gPlayer.ent^.x < self^.x) and (gPlayer.ent^.direction = 4) then
    playerIsFacing := True;

  case self^.state of
    STATE_RM_WAIT: begin
      if not playerIsFacing then
      begin
        Entity_SetState(self, STATE_RM_WALK);
      end;
    end;

    STATE_RM_WALK: begin
      if playerIsFacing then
      begin
        Entity_SetState(self, STATE_RM_WAIT);
      end;
    end;
  end;
end;

procedure Entity_RM_Update(Data: Pointer);
var
  self: PEntityRM absolute Data;
begin
  case self^.state of
    STATE_RM_WAIT: RM_Wait(self^);
    STATE_RM_WALK: RM_Walk(self^);
  end;
end;

procedure Mosquito_Patrol(var self: TEntityMosquito);
begin
  Dec(self.patrolFrames);
  if self.patrolFrames = 0 then
  begin
    if self.direction = 3 then self.direction := 4
    else
      self.direction := 3;
    self.patrolFrames := 60;
  end;
  case self.direction of
    3: Dec(self.x, 8);
    4: Inc(self.x, 8);
  end;

  if Assigned(gPlayer.ent) then
  begin
    if (gPlayer.ent^.y > self.y) and (abs(gPlayer.ent^.x - self.x) < 20) then
    begin
      Entity_SetState(@self, STATE_MOSQU_ATTACK1);
    end;
  end;
end;

procedure Mosquito_Attack(var self: TEntityMosquito);
var
  Result: THitResult;
begin
  SensorY(self.x + intToFix32(12), self.y + intToFix32(23), self.y +
    intToFix32(23 + 4), Result);
  self.y := Result.y - intToFix32(23);
  if Result.hitType = 1 then Entity_SetState(@self, STATE_MOSQU_ATTACK4);
end;

procedure Mosquito_Update(Data: Pointer);
var
  self: PEntity absolute Data;
begin
  case self^.state of
    STATE_MOSQU_PATROL: Mosquito_Patrol(PEntityMosquito(self)^);
    STATE_MOSQU_ATTACK3: Mosquito_Attack(PEntityMosquito(self)^);
  end;
end;

procedure Mosquito_State(Data: Pointer);
var
  self: PEntityMosquito absolute Data;
begin
  //writeln('Mosquito state ', self^.state);
  case self^.state of
    STATE_MOSQU_IDLE: self^.patrolFrames := 60;
  end;
end;

procedure EntityType_RM_Init(var info: TEntityInfo);
begin
  info.stateProc := Entity_RM_State;
  info.updateProc := Entity_RM_Update;
  info.debugDrawProc := RM_DebugDraw;
end;

procedure EntityType_Mosquito_Init(var info: TEntityInfo);
begin
  info.stateProc := Mosquito_State;
  info.updateProc := Mosquito_Update;
end;

procedure EntityType_BPot_Init(var info: TEntityInfo);
begin
  info.stateProc := Entity_BPot_State;
  info.updateProc := Entity_BPot_Update;
end;

end.
