unit TerrainMove;

{$mode tp}

interface

uses
  common;

procedure DoTerrainMove(origin: TVector2; deltaX, deltaY: integer;
  var resultVector: TVector2; var Result: THitResult);


implementation

uses Math, entity;

var
  traceYResult: THitResult;
  traceYValue: integer;
  traceXValue: integer;
  sensorStartY: integer;



procedure TraceY(x, startY, endY: integer);
var
  tx, ty, ty0, ty1, h, idx, delta: integer;
  other: TBoundingBox;
begin
  traceYResult.hitType := 0;
  if startY > endY then delta := -1
  else
    delta := 1;

  tx := x div 24;
  ty0 := startY div 24;
  ty1 := endY div 24;

  for ty := ty0 to ty1 do
  begin
    other.left := tx * 24;
    other.right := tx * 24 + 24;
    other.top := ty * 24;
    other.bottom := ty * 24 + 24;

    h := traceYValue;

    if map[ty * 168 + tx].tile = 1 then
    begin
      //h := other.top;
      //h := other.bottom - 23;
      h := other.bottom - 24;
      traceYResult.hitType := 1;
    end;

    if map[ty * 168 + tx].tile = 4 then
    begin
      idx := (x - other.left);
      if idx < 0 then idx := 0;
      if idx > 23 then idx := 23;

      h := other.bottom - heights[map[ty * 168 + tx].description][idx];
      traceYResult.hitType := 1;
      writeln('h ', h);
    end;

    if (h < traceYValue) and (h > sensorStartY) then
    begin
      traceYValue := h - 1;
    end;
  end;
end;

procedure TraceX(y, startX, endX: integer);
var
  x, tx, ty, otherLeft, otherBottom, idx, delta, h: integer;
  tile: ^TTile;
begin

  if startX > endX then delta := -1
  else
    delta := 1;

  traceXValue := startX;

  x := startX;

  ty := y div 24;

  while True do
  begin
    tx := x div 24;
    tile := @map[ty * 168 + tx];
    otherLeft := tx * 24;
    otherBottom := ty * 24 + 24;
    idx := (x - otherLeft);
    if idx < 0 then idx := 0;
    if idx > 23 then idx := 23;

    h := y + 24;

    if tile^.tile = 1 then h := otherBottom - 24;
    if tile^.tile = 4 then h := otherBottom - heights[map[ty * 168 + tx].description][idx];

    if h <= y then
    begin

      exit;
    end;
    traceXValue := x;
    if x = endX then break;
    Inc(x, delta);
  end;
end;

(*
procedure DoTerrainMove(origin: TVector2; deltaX, deltaY: integer;
  var resultVector: TVector2; var Result: THitResult);

var
  this, other: TBoundingBox;
  tx, ty, tx0, tx1, ty0, ty1, h, idx: integer;
  tile: ^TTile;
  delta, adj, adjVector: TVector2;
begin
  delta.x := deltaX;
  delta.y := deltaY;
  adj.x := 0;
  adj.y := 0;

  resultVector.x := delta.x;
  resultVector.y := delta.y;

  this.left := origin.x + deltaX - 12;
  this.right := this.left + 24;
  this.bottom := origin.y + deltaY;
  this.top := origin.y - 24;

  tx0 := this.left div 24;
  tx1 := this.right div 24;
  ty0 := this.top div 24;
  ty1 := this.bottom div 24;


  for ty := ty0 to ty1 do
  begin
    for tx := tx0 to tx1 do
    begin
      tile := @map[ty * 168 + tx];

      other.left := tx * 24;
      other.right := tx * 24 + 24;
      other.top := ty * 24;
      other.bottom := ty * 24 + 24;

      if this.left > other.right then continue;
      if this.top > other.bottom then continue;
      if this.right < other.left then continue;
      if this.bottom < other.top then continue;

      if tile^.tile = 1 then
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

      if tile^.tile = 4 then
      begin
        idx := (this.right - other.left);
        if idx < 0 then idx := 0;
        if idx > 23 then idx := 23;

        h := other.bottom - heights[0][idx];
        if h < other.top then h := other.top;

        adjVector.y := h - this.bottom;
        writeln('slope adj y: ', adjVector.y);
        { TODO: If this requires making a large vertical height adjustment, then adjust the x only ... }
        if (abs(adjVector.y) > abs(adj.y)) then
        begin
          adj.y := adjVector.y;
          Result.hitType := 1;
        end;
      end;
    end;
  end;

  resultVector.x := delta.x + adj.x;
  resultVector.y := delta.y + adj.y;

end;
*)

const
  SONIC_RADIUS_R = 11;
  SONIC_RADIUS_L = SONIC_RADIUS_R + 1;

procedure DoTerrainMove(origin: TVector2; deltaX, deltaY: integer;
  var resultVector: TVector2; var Result: THitResult);

var
  v0: TVector2;
  this, other: TBoundingBox;
  h, x, y: integer;
  leftResult, rightResult: integer;

begin

  if deltaX > 0 then
  begin
    TraceX(origin.y - 11, origin.x + SONIC_RADIUS_R, origin.x + SONIC_RADIUS_R + deltaX);
    writeln('traceXValue: ', traceXValue);
    resultVector.x := traceXValue - (origin.x + SONIC_RADIUS_R);

    Inc(origin.x, resultVector.x);
  end;

  if deltaX < 0 then
  begin
    TraceX(origin.y - 11, origin.x - SONIC_RADIUS_L, origin.x - SONIC_RADIUS_L + deltaX);
    writeln('traceXValue: ', traceXValue);
    resultVector.x := traceXValue - (origin.x - SONIC_RADIUS_L);

    Inc(origin.x, resultVector.x);
  end;

  // The "origin" should be the center point under the feet, ideally
  v0.y := origin.y + deltaY - 11;
  sensorStartY := v0.y;

  traceYValue := v0.y + 16;

  leftResult := 0;
  rightResult := 0;

  //writeln('tile x, y ', x, ' ', ty0);
  writeln('TraceY ', v0.y, ' -> ', v0.y + 16);
  //v0.x := origin.x + deltaX + 12;
  v0.x := origin.x + SONIC_RADIUS_R;


  TraceY(v0.x, v0.y, v0.y + 16);
  leftResult := traceYResult.hitType;

  //v0.x := origin.x + deltaX - 12;
  begin
    v0.x := origin.x - SONIC_RADIUS_L;
    TraceY(v0.x, v0.y, v0.y + 16);
    rightResult := traceYResult.hitType;
  end;

  if (leftResult = 0) and (rightResult = 0) then
  begin
    writeln('Y sensors did''t find anything');
    resultVector.y := deltaY;
  end
  else
  begin
    resultVector.y := traceYValue - origin.Y;
  end;

  writeln('result ', resultVector.x, ' ', resultVector.y);
end;

end.
