unit Powerup;

interface

uses common;

procedure EntityType_Ring_Init(var info: TEntityInfo);

implementation

uses sensor, util;

procedure Ring_Init(Data: Pointer);
var
  self: PEntityRing absolute Data;
begin

     self^.isBouncing:=true;
     self^.vel.x:=-256 + Random(512);
     self^.vel.y:=- 4 * Random(512);

end;

procedure Ring_Update(Data: Pointer);
var
  self: PEntityRing absolute Data;
  result: THitResult;
begin
  //writeln('ring update');
  Inc(self^.vel.y, intToFix32(1));
  SimpleBoxMove(PEntity(self), self^.vel, result);
  if result.y <> 0 then begin
    self^.vel.y := fix32Mul(self^.vel.y, -floatToFix32(0.7));
  end;
end;

procedure EntityType_Ring_Init(var info: TEntityInfo);
begin
  with info do
  begin
    initProc := @Ring_Init;
    updateProc := @Ring_Update;
  end;
end;

end.
