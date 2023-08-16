unit entity;

{$mode tp}

interface

uses
  common, res, res_enum;

function SpawnEntity(x, y, entityType: integer): PEntity;
procedure Entity_GetMoveBy(self: PEntity; deltaX, deltaY: integer;
  var resultVector: TVector2; var Result: THitResult);
procedure Entity_MoveBy(self: PEntity; deltaX, deltaY: integer; var Result: THitResult);
procedure Entity_SetState(Data: Pointer; state: entityStates);
procedure Entity_GetMoveBy2(self: PEntity; origin: TVector2;
  deltaX, deltaY: integer; var resultVector: TVector2; var Result: THitResult);
procedure GetBoxAdjustment(this, other: TBoundingBox; delta: TVector2;
  var adjVector: TVector2);

implementation

uses TerrainMove;

function SpawnEntity(x, y, entityType: integer): PEntity;
var
  i: integer;
  e: PEntity;
begin
  SpawnEntity := nil;
  for i := 1 to MAX_ENTITIES do
  begin
    e := @entities[i];

    if (e^.flags and 1) = 0 then
    begin
      FillChar(e^, sizeof(TEntity), 0);
      e^.x := x;
      e^.y := y;
      e^.flags := 1;
      e^.entityNum := i;
      e^.state := STATE_NONE;
      e^.stateFrames := 60;
      e^.t := entityType;
      e^.nextTileEntity := nil;
      e^.direction := 3;
      //Entity_AddToTile(
      // writeln(' spawn entity ', i, ' type ', entityType);
      SpawnEntity := e;
      exit;
    end;
  end;
end;

procedure GetBoxAdjustment(this, other: TBoundingBox; delta: TVector2;
  var adjVector: TVector2);
begin
  adjVector.x := 0;
  adjVector.y := 0;

  if this.left > other.right then exit;
  if this.top > other.bottom then exit;
  if this.right < other.left then exit;
  if this.bottom < other.top then exit;

  if delta.x <> 0 then
  begin
    if this.bottom - 1 < other.top then Exit;
    if delta.x > 0 then
    begin
      { delta.x > 0 }
      if (this.right > other.left) and (this.left < other.left) then
      begin
        adjVector.x := other.left - this.right;
      end;
    end
    else
    begin
      { delta.x < 0 }
      if (this.left < other.right) and (this.right > other.right) then
      begin
        adjVector.x := other.right - this.left;
      end;
    end;
  end;

  if delta.y <> 0 then
  begin
    if this.right - 2 < other.left then Exit;

    if delta.y < 0 then
    begin
      { delta.y < 0 }
      if (this.top < other.bottom) and (this.bottom > other.bottom) then
      begin
        adjVector.y := other.bottom - this.top;
      end;
    end
    else
    begin
      { delta.y > 0 }

      if (this.bottom >= other.top) and (this.top < other.top) then
      begin
        adjVector.y := other.top - this.bottom;
      end;
    end;
  end;

end;

procedure Entity_GetMoveBy2(self: PEntity; origin: TVector2;
  deltaX, deltaY: integer; var resultVector: TVector2; var Result: THitResult);

begin
  DoTerrainMove(origin, deltaX, deltaY, resultVector, Result);
end;

procedure Entity_GetMoveBy(self: PEntity; deltaX, deltaY: integer;
  var resultVector: TVector2; var Result: THitResult);
var
  delta, adj, adjVector: TVector2;
  this, other: TBoundingBox;
  tx0, tx1, ty0, ty1, x, y, i, j, h: integer;
  e: PEntity;
begin
  resultVector.x := 0;
  resultVector.y := 0;
  Result.hitType := 0;
  adj.x := 0;
  adj.y := 0;

  this.left := self^.x + deltaX;
  this.right := this.left + 24;
  this.top := self^.y + deltaY;
  this.bottom := this.top + 24;

  tx0 := this.left div 24;
  ty0 := this.top div 24;
  tx1 := tx0 + 1;
  ty1 := ty0 + 1;

  delta.x := deltaX;
  delta.y := deltaY;

  for y := ty0 to ty1 do
  begin
    for x := tx0 to tx1 do
    begin
      other.left := x * 24;
      other.right := x * 24 + 24;
      other.top := y * 24;
      other.bottom := y * 24 + 24;

      if map[y * 168 + x].tile = 1 then
      begin
        GetBoxAdjustment(this, other, delta, adjVector);
        if abs(adjVector.x) > abs(adj.x) then
        begin
          adj.x := adjVector.x;
          Result.hitType := 1;
        end;
        if abs(adjVector.y) > abs(adj.y) then
        begin
          adj.y := adjVector.y;
          Result.hitType := 1;
        end;
      end;

      if map[y * 168 + x].tile = 4 then
      begin
        for i := 0 to 23 do
        begin
          h := other.bottom - i;
          //writeln('h: ', h);
          if (this.bottom > h) and (this.right >= other.left + i) then
          begin
            adjVector.y := h - this.bottom;
            if abs(adjVector.y) > abs(adj.y) then
            begin
              adj.y := adjVector.y;
              Result.hitType := 1;
            end;
          end;
        end;
      end;
    end;
  end;

  { Brute force entity check }

  for i := 1 to MAX_ENTITIES do
  begin
    e := @entities[i];
    if (e^.flags and 1) = 0 then continue;
    if e = self then continue;

    if e^.t = 43 then continue;
    if e^.t = 44 then continue;
    if e^.t = 100 then continue;

    other.left := e^.x;
    other.right := e^.x + 24;
    other.top := e^.y;
    other.bottom := e^.y + 24;

    GetBoxAdjustment(this, other, delta, adjVector);

    if abs(adjVector.x) > abs(adj.x) then
    begin
      adj.x := adjVector.x;
      Result.hitType := 2;
      Result.entity := e;
    end;
    if abs(adjVector.y) > abs(adj.y) then
    begin
      adj.y := adjVector.y;
      Result.hitType := 2;
      Result.entity := e;
    end;

  end;


  resultVector.x := deltaX + adj.x;
  resultVector.y := deltaY + adj.y;
end;

procedure Entity_MoveBy(self: PEntity; deltaX, deltaY: integer; var Result: THitResult);
var
  resultVector: TVector2;
begin
  Entity_GetMoveBy(self, deltaX, deltaY, resultVector, Result);

  Inc(self^.x, resultVector.x);
  Inc(self^.y, resultVector.y);
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

procedure Entity_SetState(Data: Pointer; state: entityStates);
var
  self: PEntity absolute Data;
begin
  self^.state := state;
  self^.stateFrames := entity_states[Ord(state)].duration;
end;

end.
