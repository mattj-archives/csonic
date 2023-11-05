unit Powerup;

interface

uses common;

procedure EntityType_Ring_Init(var info: TEntityInfo);
procedure Ring_SetBouncing(Data: Pointer);

implementation

uses sensor, util, game, entity, res_enum, player;

procedure Ring_Init(Data: Pointer);
var
  self: PEntityRing absolute Data;
begin
  self^.isBouncing := False;
  Entity_SetState(self, entityStates.STATE_RING1);
end;

procedure Ring_SetBouncing(Data: Pointer);
var
  self: PEntityRing absolute Data;
begin
  with self^ do
  begin
    isBouncing := True;

    time := 30 * 3 + 30 * random(3);

    vel.x := 4 * (-256 + Random(512));
    vel.y := 2 * (-4 * Random(512));
  end;
end;

procedure Ring_Update(Data: Pointer);
var
  self: PEntityRing absolute Data;
  traceInfo: THitResult;
begin
  traceInfo := InitTraceInfo(COLLISION_LEVEL, PEntity(self));

  //writeln('ring update');
  with self^ do
  begin
    if isBouncing then
    begin
      Inc(elapsedBounceTime);
      Dec(time);

      if time <= 0 then
      begin
        flags := 0;
        exit;
      end;

      Inc(vel.y, intToFix32(1));
      SimpleBoxMove(PEntity(self), vel, traceInfo);
      if traceInfo.y <> 0 then
      begin
        vel.y := fix32Mul(vel.y, -floatToFix32(0.7));
      end;
    end;
  end;
end;

procedure Ring_Draw(Data: Pointer);
var
  self: PEntityRing absolute Data;
begin

  with self^ do
  begin
    if isBouncing and (time < 2 * 30) and (time mod 4 < 2) then Exit;
  end;
  Entity_Draw(self);
end;

procedure Ring_Collide(Data: Pointer; other: PEntity);
var
  self: PEntityRing absolute Data;
begin
  if other^.t = Ord(ENTITY_TYPE_PLAYER) then
  begin
    if self^.isBouncing then
    begin
      // Can't pick up ring for first second of bouncing
      if self^.elapsedBounceTime < 30 then Exit;
    end;

    self^.flags := 0;
    Inc(gPlayer.numRings);
  end;
end;

procedure EntityType_Ring_Init(var info: TEntityInfo);
begin
  with info do
  begin
    initProc := @Ring_Init;
    updateProc := @Ring_Update;
    drawProc := @Ring_Draw;
    collideFunc := @Ring_Collide;
  end;
end;

end.
