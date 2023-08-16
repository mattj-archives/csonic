unit Player;

{$mode tp}

interface

uses
  res, res_enum, common, engine, entity, timer;

type
  TPlayer = record
    velX, velY: integer;
    groundEntity: PEntity;
    ent: PEntity;
  end;

procedure Player_Update(self: PEntity);

var
  gPlayer: TPlayer;

implementation

type
  SonicModes = (
    None,
    Running,
    Waiting,
    Standing,
    Spinning
    );

var
  playerInAir: boolean;
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
    // writeln('cant jump, vel is ', gPlayer.velY);
    Exit;

  end;
  if playerInAir then
  begin
    // writeln('cant jump, player is in air');
    Exit;
  end;

  gPlayer.velY := -13;
  Player_SetMode(Spinning);
end;

procedure Player_HitEntity(self, e: PEntity; Result: THitResult);
var
  explode: PEntity;
begin
  if Result.hitType <> 2 then Exit;

  if e^.t = 38 then
  begin
    if mode = SonicModes.Spinning then
    begin

      gPlayer.velY := -12;

      explode := SpawnEntity(e^.x, e^.y, 100);
      // writeln('explode at ', e^.x, ' ', e^.y);
      Entity_SetState(explode, entityStates.STATE_EXPLODE1);

      e^.flags := 0;
    end;
  end;
end;

procedure Player_Touch(self: PEntity);
var
  this, other: TBoundingBox;
  i: integer;
  e: PEntity;
begin

  this.left := self^.x;
  this.right := this.left + 24;
  this.top := self^.y;
  this.bottom := this.top + 24;

  for i := 1 to MAX_ENTITIES do
  begin
    e := @entities[i];

    if (e^.flags and 1) = 0 then continue;
    if e = self then continue;

    other.left := e^.x;
    other.right := other.left + 24;
    other.top := e^.y;
    other.bottom := other.top + 24;

    if this.left >= other.right then continue;
    if this.right <= other.left then continue;
    if this.top >= other.bottom then continue;
    if this.bottom <= other.top then continue;

    if e^.t = 17 then
    begin
      // writeln('touch spring');
      gPlayer.velY := -16;
      Entity_SetState(e, STATE_SPRING1_USE);
    end;

    if e^.t = 43 then
    begin
      // writeln('touch ring');
      e^.flags := 0;
    end;
    if e^.t = 44 then
    begin
      e^.flags := 0;
    end;
  end;
end;

procedure Player_Update(self: PEntity);
var
  delta, origin: TVector2;
  playerWasInAir: boolean;
  Result: THitResult;
  resultVector: TVector2;

begin

  if mode = SonicModes.None then
  begin
    mode := SonicModes.Standing;
    self^.state := entityStates.STATE_PLAYER_STAND1;
    self^.stateFrames := 10;
    modeTime := Timer_GetTicks;
  end;

  delta.x := 0;
  delta.y := 0;
  playerWasInAir := playerInAir;

  if I_IsKeyDown(kLf) then
  begin
    Inc(gPlayer.velX, -2);
    if gPlayer.velX < -8 then gPlayer.velX := -8;
  end;

  if I_IsKeyDown(kRt) then
  begin
    Inc(gPlayer.velX, 2);
    if gPlayer.velX > 8 then gPlayer.velX := 8;
  end;

  if I_IsKeyDown(kSpace) then
  begin
    Player_Jump(self);
  end;

  { Decelerate X }

  if gPlayer.velX < 0 then Inc(gPlayer.velX);
  if gPlayer.velX > 0 then Dec(gPlayer.velX);

  if gPlayer.velY <> 0 then playerInAir := True;

  { TODO: Check below player to see if still in air, or trace down, or whatever }
  { Do gravity move. If moving down and hit something, then no longer in air }

  delta.y := gPlayer.velY;

  // check what's below us, if we're not moving up

  if playerInAir then
  begin
    Inc(gPlayer.velY);
    if gPlayer.velY > 12 then gPlayer.velY := 12;

    Entity_MoveBy(self, 0, gPlayer.velY, Result);

    gPlayer.groundEntity:=nil;

    if Result.hitType = 0 then
    begin

    end
    else
    begin
      if gPlayer.velY > 0 then
      begin
        playerInAir := False;
        //writeln('hit while in air, no longer in air');
      end;

      // Hit something
      gPlayer.velY := 0;

      if Result.hitType = 2 then
      begin
        Player_HitEntity(self, Result.entity, Result);
      end;

      // If the player has been bounced back upwards again, then stay in the air
      if gPlayer.velY < 0 then
      begin
        playerInAir := True;
      end;
    end;
  end
  else
  begin
    { Player not in air }

    //if gPlayer.velY >= 0 then
    //begin
    Entity_GetMoveBy(self, 0, 1, resultVector, Result);

    if Result.hitType = 0 then
    begin
      gPlayer.groundEntity := nil;
      if not playerInAir then
      begin
        playerInAir := True;
        // writeln('player is now in air, ', gPlayer.velY);
      end;
    end
    else
    begin
      if Result.hitType = 1 then
      begin
        gPlayer.groundEntity := nil;
      end;

      if Result.hitType = 2 then
      begin
        gPlayer.groundEntity := Result.entity;
      end;
      if playerInAir then
      begin
        playerInAir := False;
        // writeln('player is no longer in air');
      end;
    end;
    //end;
  end;

  if gPlayer.velX <> 0 then
  begin

    if playerInAir then
    begin
      Entity_MoveBy(self, gPlayer.velX, 0, Result);
    end
    else
    begin
      origin.x := self^.x + 12;
      origin.y := self^.y + 24;
      Entity_GetMoveBy2(self, origin, gPlayer.velX, 0, resultVector, result);

      Inc(self^.x, resultVector.x);
      Inc(self^.y, resultVector.y);

    end;
    if gPlayer.velX > 0 then self^.direction := 4;
    if gPlayer.velX < 0 then self^.direction := 3;
  end;

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

  Player_Touch(self);

end;

begin

  playerInAir := True;
  mode := SonicModes.None;
  gPlayer.groundEntity := nil;

end.
