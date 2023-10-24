unit Sensor;

{$mode tp}

interface

uses
  engine, common;

procedure SensorX(y, startX, endX: integer; var Result: THitResult);
procedure SensorY(x, startY, endY: LongInt; var Result: THitResult);

function EntityTrace(startX, startY, endX, endY: integer): integer;


var
  entityTraceResultX, entityTraceResultY: integer;
  entityTraceResult: PEntity;
  traceEntitySkip: PEntity;

implementation

uses Entity, util;

procedure SensorX(y, startX, endX: integer; var Result: THitResult);
var
  hitType, delta, h, x, tx, ty, ty0, ty1, idx, traceXValue: integer;
  other: TBoundingBox;
  tile: ^TTile;
begin
  Result.hitType := 0;

  Result.y := y;

  y := fix32ToInt(y);
  startX := fix32ToInt(startX);
  endX := fix32ToInt(endX);
  traceXValue := endX;

  if startX > endX then delta := -1
  else
    delta := 1;

  ty := y div 24;
  x := startX;
  while True do
  begin
    tx := x div 24;

    other.left := tx * 24;
    other.right := tx * 24 + 24;
    other.top := ty * 24;
    other.bottom := ty * 24 + 24;

    tile := @map[ty * 168 + tx];

    if tile^.tile = 4 then
    begin
      idx := x - other.left;
      if idx < 0 then idx := 0;
      if idx > 23 then idx := 23;

      // TODO: Is this -1 correct?
      if tile^.description < 576 then begin
         h := other.bottom - heights[map[ty * 168 + tx].description][idx] - 1;  { TODO: should -1 be in brackets?, check other traces... }
      end;
      //writeln('sensorX hit at x: ', x, ' h: ', h, ' y is: ', y);
      if h <= y then break;
    end;

    traceXValue := x;
    if x = endX then break;
    Inc(x, delta);
  end;

  if traceXValue <> endX then Result.hitType := 1;
  EntityTrace(startX, y, endX, y);

  if entityTraceResult <> nil then
  begin
    if endX > startX then
    begin
      if entityTraceResultX < traceXValue then
      begin
        traceXValue := entityTraceResultX;
        Result.entity := entityTraceResult;
        Result.hitType := 2;
      end;
    end
    else
    begin
      if entityTraceResultX > traceXValue then
      begin
        traceXValue := entityTraceResultX;
        Result.entity := entityTraceResult;

        Result.hitType := 2;
      end;
    end;
  end;

  Result.x := intToFix32(traceXValue);


end;

function SensorYUp(x, startY, endY: integer; var Result: THitResult): integer;
var
  hitType, lower, upper, tx, ty, ty0, ty1, idx, traceYValue: integer;
  other: TBoundingBox;
  tile: ^TTile;
begin

  // No clipping?
  //Result.x := x;
  //Result.y := endY;
  //Exit;

  traceYValue := endY;
  SensorYUp := endY;

  //writeln('SensorYUp x: ', x, ' y: ', startY, ' -> ', endY);

  tx := fix32ToInt(x) div 24;
  ty0 := fix32ToInt(startY) div 24;
  ty1 := fix32ToInt(endY) div 24;

  for ty := ty0 downto ty1 do
  begin
    other.left := intToFix32(tx * 24);
    other.right := intToFix32(tx * 24 + 24);
    other.top := intToFix32(ty * 24);
    other.bottom := intToFix32(ty * 24 + 24);

    //h := startY;

    //if map[ty * 168 + tx].tile = 1 then
    //begin
    //  //h := other.top;
    //  //h := other.bottom - 23;
    //  h := other.bottom;
    //  if (h > traceYValue) then traceYValue := h;
    //  hitType := 1;
    //end;
    tile := @map[ty * 168 + tx];
    if tile^.tile = 4 then
    begin
      idx := fix32ToInt(x - other.left);
      if idx < 0 then idx := 0;
      if idx > 23 then idx := 23;

      if heights[tile^.description][idx] = 0 then continue;

      { TODO: if heights = 0, this column won't clip }

      if tile^.description < 576 then begin
        continue;
         //lower := other.bottom;
         //upper := lower - heights[map[ty * 168 + tx].description][idx] - 1;
      end else begin

          upper := other.top;
          lower := other.top + intToFix32(heights[tile^.description][idx]);
      end;

      if (lower > traceYValue) and (startY > upper) then
      begin
        traceYValue := lower;
        hitType := 1;
      end;
    end;
  end;

  if (traceYValue < endY) then
  begin
    traceYValue := endY;
  end;

  if traceYValue <> endY then Result.hitType := 1;

  EntityTrace(x, startY, x, endY);

  if entityTraceResult <> nil then
  begin
    if entityTraceResultY > traceYValue then
    begin
      traceYValue := entityTraceResultY;
      Result.entity := entityTraceResult;

      Result.hitType := 2;
    end;
  end;

  Result.x := x;
  Result.y := traceYValue;

end;

{$inline on}

procedure SensorY(x, startY, endY: LongInt; var Result: THitResult);
var
  h, tx, ty, ty0, ty1, idx, traceYValue: integer;
  other: TBoundingBox;
  tile: ^TTile;
begin
  Result.hitType := 0;
  Result.x := x;

  if startY > endY then
  begin
    SensorYUp(x, startY, endY, Result);
    exit;
  end;



  x := fix32ToInt(x);
  startY := fix32ToInt(startY);
  endY := fix32ToInt(endY);
    traceYValue := endY;

  tx := x div 24;
  ty0 := startY div 24;
  ty1 := endY div 24;

  for ty := ty0 to ty1 do
  begin
    other.left := tx * 24;
    other.right := tx * 24 + 24;
    other.top := ty * 24;
    other.bottom := ty * 24 + 24;

    h := startY;

    tile := @map[ty * 168 + tx];
    if tile^.tile = 1 then
    begin
      //h := other.top;
      //h := other.bottom - 23;
      h := other.bottom - 24;
      if (h < traceYValue) then traceYValue := h;
    end;

    if map[ty * 168 + tx].tile = 4 then
    begin

         { Downward traces don't bother with ceilings }
      if (tile^.description >= 576) then
         continue;

      idx := x - other.left;
      if idx < 0 then idx := 0;
      if idx > 23 then idx := 23;

      h := other.bottom - heights[map[ty * 168 + tx].description][idx] - 1;

      if (h < traceYValue) then traceYValue := h;
      //writeln('hit at type type 4 at h ', h);
    end;
  end;

  if traceYValue <> endY then Result.hitType := 1;

  EntityTrace(x, startY, x, endY);

  if entityTraceResult <> nil then
  begin
    if entityTraceResultY < traceYValue then
    begin
      traceYValue := entityTraceResultY;
      Result.entity := entityTraceResult;

      Result.hitType := 2;
    end;
  end;


  Result.y := intToFix32(traceYValue);

end;

{ Trace a line against entity hitboxes. Set traceEntitySkip to skip a specific entity }

function EntityTrace(startX, startY, endX, endY: integer): integer;
var
  deltaX, deltaY, i: integer;
  e: PEntity;
  other: TBoundingBox;
begin
  entityTraceResult := nil;

  deltaX := endX - startX;
  deltaY := endY - startY;

  for i := 1 to MAX_ENTITIES do
  begin
    e := @entities[i];
    if (e^.flags and 1) = 0 then continue;
    if e = traceEntitySkip then continue;

    if e^.t = 43 then continue;
    if e^.t = 44 then continue;
    if e^.t = 100 then continue;

    Entity_Hitbox(e, other);

    //GetBoxAdjustment(this, other, delta, adjVector);

    if deltaX <> 0 then
    begin

      { Horizontal checks }

      if (startY >= other.top) and (startY <= other.bottom) then
      begin
        if deltaX < 0 then
        begin
          { Trace -X (left) }

          if (other.right >= endX) and (other.left < startX) then
          begin
            endX := other.right + 1;
            entityTraceResult := e;
          end;

        end
        else
        begin
          { Trace +X (right) }

          if (other.left <= endX) and (other.left > startX) then
          begin
            endX := other.left - 1;
            entityTraceResult := e;
            //writeln('EntityTrace +Y hit at ', endY);
          end;
        end;

      end;
    end
    else
    begin

      { Vertical checks }

      if (startX >= other.left) and (startX < other.right) then
      begin
        if deltaY < 0 then
        begin
          { Trace -Y (up) }
          if (other.bottom >= endY) and (other.top < startY) then
          begin
            endY := other.bottom + 1;
            entityTraceResult := e;
          end;
        end
        else
        begin
          { Trace +Y (down) }
          if (other.top <= endY) and (other.top > startY) then
          begin
            endY := other.top - 1;
            entityTraceResult := e;
            //writeln('EntityTrace +Y hit at ', endY);
          end;
        end;
      end;
    end;

    //if abs(adjVector.x) > abs(adj.x) then
    //begin
    //  adj.x := adjVector.x;
    //  Result.hitType := 2;
    //  Result.entity := e;
    //end;
    //if abs(adjVector.y) > abs(adj.y) then
    //begin
    //  adj.y := adjVector.y;
    //  Result.hitType := 2;
    //  Result.entity := e;
    //end;

  end;
  entityTraceResultX := endX;
  entityTraceResultY := endY;
end;

end.
