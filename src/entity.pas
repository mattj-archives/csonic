unit entity;

{$mode tp}

interface

uses
  common, Classes, SysUtils;

implementation

function SpawnEntity(x, y, entityType: integer): PEntity;
var i: integer;
  e: PEntity;
begin
  SpawnEntity := nil;
  for i := 1 to MAX_ENTITIES do begin
      e := @entities[i];

      if (e^.flags and 1) = 0 then begin
        e^.x := x * 24;
        e^.y := y * 24;
        e^.flags := 1;
        e^.entityNum:= i;
        e^.state = 0;
        e^.stateFrames:= 60;
        e^.t:= = entityType;
        e^.nextTileEntity:= nil;
        //Entity_AddToTile(

        SpawnEntity := e;
        exit;
      end;
  end;
end;

{
FUNCTION SpawnEntity% (x AS INTEGER, y AS INTEGER, entityType AS INTEGER)
SpawnEntity% = -1

DIM i AS INTEGER

FOR i = 1 TO MAX.ENTITIES

		IF (entities(i).flags AND 1) = 0 THEN
				entities(i).x = x * 24
				entities(i).y = y * 24
				entities(i).entityNum = i
				entities(i).flags = 1
				eStateNum(i) = STATE.NONE
				entities(i).stateFrames = 60
				entities(i).t = entityType
				entities(i).nextTileEntityNum = 0

				Entity.AddToTile i

				SpawnEntity% = i
				EXIT FUNCTION
		END IF
NEXT i
END FUNCTION
}
end.

