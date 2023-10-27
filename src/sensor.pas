unit Sensor;

{$mode tp}

interface

uses
  engine, common;

procedure SensorX(y, startX, endX: longint; var Result: THitResult);
procedure SensorY(x, startY, endY: longint; var Result: THitResult);

function EntityTrace(startX, startY, endX, endY: longint): integer;

procedure SensorRay(startX, startY: longint; deltaX, deltaY: longint;
  var Result: THitResult);

var
  entityTraceResultX, entityTraceResultY: longint;
  entityTraceResult: PEntity;
  traceEntitySkip: PEntity;

implementation

uses Entity, util, map;

procedure SensorX(y, startX, endX: longint; var Result: THitResult);
var
  hitType, delta, h, x, tx, ty, ty0, ty1, idx, traceXValue: longint;
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

    tile := Map_TileAt(tx, ty);

    if Assigned(tile) and (tile^.tile = 4) then
    begin
      idx := x - other.left;
      if idx < 0 then idx := 0;
      if idx > 23 then idx := 23;

      // TODO: Is this -1 correct?
      if tile^.description < 576 then
      begin
        //h := other.bottom - heights[tile^.description][idx] - 1; {(incorrect?)}
        // Also, if heights = 0 then continue
        h := other.bottom - heights[tile^.description][idx];
      end;
      //writeln('sensorX hit at x: ', x, ' h: ', h, ' y is: ', y);
      if h <= y then break;
    end;

    traceXValue := x;
    if x = endX then break;
    Inc(x, delta);
  end;

  if traceXValue <> endX then Result.hitType := 1;
  {
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
}
  Result.x := intToFix32(traceXValue);

end;

function SensorYUp(x, startY, endY: longint; var Result: THitResult): integer;
var
  hitType, lower, upper, tx, ty, ty0, ty1, idx, traceYValue: longint;
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

    tile := Map_TileAt(tx, ty);

    if Assigned(tile) and (tile^.tile = 4) then
    begin
      idx := fix32ToInt(x - other.left);
      if idx < 0 then idx := 0;
      if idx > 23 then idx := 23;

      if heights[tile^.description][idx] = 0 then continue;

      { TODO: if heights = 0, this column won't clip }

      if tile^.description < 576 then
      begin
        continue;
        //lower := other.bottom;
        //upper := lower - heights[map[ty * 168 + tx].description][idx] - 1;
      end
      else
      begin

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

  Result.x := x;
  Result.y := traceYValue;

end;

{$inline on}

procedure SensorY(x, startY, endY: longint; var Result: THitResult);
var
  originalX, originalStartY, originalEndY: longint;
  h, tx, ty, ty0, ty1, idx, traceYValue: longint;
  other: TBoundingBox;
  tile: ^TTile;
  iter: integer;
begin

  Result.hitType := 0;
  Result.x := x;

  if startY > endY then
  begin
    SensorYUp(x, startY, endY, Result);
    exit;
  end;

  originalX := x;
  originalStartY := startY;
  originalEndY := endY;

  x := fix32ToInt(x);

  //writeln('test ', -fix32ToInt(1024));
  startY := fix32ToInt(startY);
  endY := fix32ToInt(endY);
  traceYValue := endY;

  tx := x div 24;
  ty0 := startY div 24;
  ty1 := endY div 24;

  iter := 0;

  for ty := ty0 to ty1 do
  begin
    inc(iter);
    if iter > 10 then begin
       writeln('error: too many iterations');
       Break;
    end;
    other.left := tx * 24;
    other.right := tx * 24 + 24;
    other.top := ty * 24;
    other.bottom := ty * 24 + 24;

    h := startY;

    tile := Map_TileAt(tx, ty);
        //writeln('SensorY checking tile at ', tx, ' ', ty);


    if Assigned(tile) then
    begin
      if tile^.tile = 1 then
      begin
        //h := other.top;
        //h := other.bottom - 23;
        h := other.bottom - 24;
        if (h < traceYValue) then traceYValue := h;
      end;

      if tile^.tile = 4 then
      begin

        { Downward traces don't bother with ceilings }
        if (tile^.description >= 576) then
          continue;

        idx := x - other.left;
        if idx < 0 then idx := 0;
        if idx > 23 then idx := 23;

        h := other.bottom - heights[tile^.description][idx] - 1;

        if (h < traceYValue) then traceYValue := h;
        //writeln('hit at type type 4 at h ', h);
      end;
    end;
  end;

  if traceYValue <> endY then Result.hitType := 1;

  EntityTrace(originalX, originalStartY, originalX, originalEndY);

  if entityTraceResult <> nil then
  begin

  end;


  Result.y := intToFix32(traceYValue);

end;

procedure SensorRay(startX, startY: longint; deltaX, deltaY: longint;
  var Result: THitResult);
var
  originalStartX, originalStartY, originalEndX, originalEndY: longint;
begin
  FillChar(Result, sizeof(THitResult), 0);

  if (deltaX <> 0) and (deltaY <> 0) then
  begin
    writeln('invalid arguments to SensorRay');
  end;

  Result.x := startX;
  Result.y := startY;
  originalStartX := startX;
  originalStartY := startY;
  originalEndX := startX + deltaX;
  originalEndY := startY + deltaY;

  if (deltaX <> 0) then
  begin
    SensorX(startY, startX, originalEndX, Result);
  end
  else if (deltaY <> 0) then
  begin
    if (deltaY < 0) then
    begin
      SensorYUp(startX, startY, originalEndY, Result);
    end
    else
    begin
      SensorY(startX, startY, originalEndY, Result);
    end;
  end;

  EntityTrace(originalStartX, originalStartY, originalEndX, originalEndY);

  if entityTraceResult <> nil then
  begin
    if (deltaX <> 0) then
    begin
      if deltaX > 0 then
      begin
        { Moving right }
        if entityTraceResultX < Result.x then
        begin
          Result.x := entityTraceResultX;
          Result.entity := entityTraceResult;

          Result.hitType := 2;
        end;
      end
      else
      begin
        { Moving left }
        if entityTraceResultX > Result.x then
        begin
          Result.x := entityTraceResultX;
          Result.entity := entityTraceResult;

          Result.hitType := 2;
        end;
      end;
    end;

    if (deltaY <> 0) then
    begin
      if deltaY > 0 then
      begin
        { Moving down }
        if entityTraceResultY < Result.y then
        begin
          Result.y := entityTraceResultY;
          Result.entity := entityTraceResult;

          Result.hitType := 2;
        end;

      end
      else
      begin
        if entityTraceResultY > Result.y then
        begin
          Result.y := entityTraceResultY;
          Result.entity := entityTraceResult;

          Result.hitType := 2;
        end;
      end;
    end;
  end;
end;

{ Trace a line against entity hitboxes. Set traceEntitySkip to skip a specific entity }

function EntityTrace(startX, startY, endX, endY: longint): integer;
var
  deltaX, deltaY, i: longint;
  e: PEntity;
  other: TBoundingBox;
begin
  entityTraceResult := nil;

  deltaX := endX - startX;
  deltaY := endY - startY;

  for i := 1 to MAX_ENTITIES do
  begin
    e := @G.entities[i];
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
            endX := other.right; // + intToFix32(1);
            entityTraceResult := e;
          end;

        end
        else
        begin
          { Trace +X (right) }

          if (other.left <= endX) and (other.left > startX) then
          begin
            endX := other.left - intToFix32(1);
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
            endY := other.bottom + intToFix32(1);
            entityTraceResult := e;
          end;
        end
        else
        begin
          { Trace +Y (down) }
          if (other.top <= endY) and (other.top > startY) then
          begin
            endY := other.top - intToFix32(1);
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
