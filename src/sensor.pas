unit Sensor;

interface

uses
  engine, common;

procedure SensorX(y, startX, endX: longint; var Result: THitResult);
procedure SensorY(x, startY, endY: longint; var Result: THitResult);

function InitTraceInfo(collisionMask: shortint; ignoreEntity: PEntity): THitResult;
function EntityTrace(startX, startY, endX, endY: longint;
  var traceInfo: THitResult): integer;

procedure SensorRay(startX, startY: longint; deltaX, deltaY: longint;
  var Result: THitResult);

procedure SimpleBoxMove(self: PEntity; delta: TVector2; var traceInfo: THitResult);

var
  entityTraceResultX, entityTraceResultY: longint;
  entityTraceResult: PEntity;
  traceEntitySkip: PEntity;

implementation

uses Entity, util, map, SysUtils;

function InitTraceInfo(collisionMask: shortint; ignoreEntity: PEntity): THitResult;
var
  traceInfo: THitResult;
begin
  traceInfo.collisionMask := collisionMask;
  traceInfo.ignoreEntity := ignoreEntity;
  Result := traceInfo;
end;

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

function SensorYUp(x, startY, endY: longint; var traceInfo: THitResult): integer;
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

  if traceYValue <> endY then traceInfo.hitType := 1;

  traceInfo.x := x;
  traceInfo.y := traceYValue;

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
    Inc(iter);
    if iter > 10 then
    begin
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

  EntityTrace(originalX, originalStartY, originalX, originalEndY, Result);

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
  Result.entity := nil;
  Result.hitType := 0;

  //FillChar(Result, sizeof(THitResult), 0);

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

  EntityTrace(originalStartX, originalStartY, originalEndX, originalEndY, Result);

  if entityTraceResult <> nil then
  begin
    // writeln('entityTrace hit something');
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
        writeln('entityTrace hit something moving down');
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

function EntityTrace(startX, startY, endX, endY: longint;
  var traceInfo: THitResult): integer;
var
  deltaX, deltaY, i: longint;
  e: PEntity;
  other: TBoundingBox;
begin
  Result := 0;
  entityTraceResult := nil;

  deltaX := endX - startX;
  deltaY := endY - startY;

  //writeln(Format('EntityTrace %d %d -> %d %d  (%d, %d)', [startX, startY, endX, endY, endX - startX, endY - startY]));

  for i := 1 to MAX_ENTITIES do
  begin
    e := @G.entities[i];
    if (e^.flags and 1) = 0 then continue;

    if e = traceInfo.ignoreEntity then continue;

    if (e^.collision and traceInfo.collisionMask) = 0 then continue;
    // TODO: Remove
    if e = traceEntitySkip then continue;

    if e^.t = 43 then continue;
    if e^.t = 44 then continue;
    if e^.t = 100 then continue;

    other := Entity_Hitbox(e);

    //if e^.t = 17 then begin
    //  writeln('checking against type 17', ' ', deltaX, ' ', deltaY);
    //end;

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

function ShortestNonZeroAxis(v: TVector2): integer;
begin
  Result := 0;

  if v.x = 0 then
  begin
    Result := 1;
    Exit;
  end;

  if v.y = 0 then
  begin
    Exit;
  end;

  if (abs(v.x) < abs(v.y)) then
  begin
    Result := 0;
    Exit;
  end;

  Result := 1;

{
  if (abs(v.y) < abs(v.x)) and (v.y <> 0) and (v.x <> 0) then
  begin
    Result := 1;
    Exit;
  end;
}
end;

function GetTileReject(bb, other: TBoundingBox; delta: TVector2; tile: PTile): TVector2;
var
  idx0, idx1, idx: integer;
  h: longint;
  adj: integer;
  collide: boolean;
begin
  Result.x := 0;
  Result.y := 0;
{
  writeln(Format('GetTileReject (%d %d -> %d %d) vs tile (%d %d -> %d %d), delta %d %d',
    [bb.left, bb.top, bb.right, bb.bottom, other.left, other.top,
    other.right, other.bottom, delta.x, delta.y]));
}
  idx0 := bb.left - other.left;
  if idx0 < 0 then idx0 := 0;

  idx1 := (bb.right - 1) - other.left;
  if idx1 > 23 then idx1 := 23;

  //writeln('idx: ', idx0, ' to ', idx1);

  if (delta.x > 0) then
  begin
    if tile^.tile = 1 then
    begin
      if (bb.right > other.left) then Result.x := other.left - bb.right;
      Exit;
    end;

    if tile^.tile = 4 then
    begin
      // If the height at this X position enters the box, then set the adjustment and exit

      for idx := idx0 to idx1 do
      begin

        if tile^.description < 576 then
          collide := bb.bottom > (other.bottom - heights[tile^.description][idx])
        else
          collide := bb.top < (other.top + heights[tile^.description][idx]);

        if collide then
        begin
          Result.x := (other.left + idx) - bb.right;
          Exit;
        end;
      end;
    end;
  end;

  if (delta.x < 0) then
  begin
    if tile^.tile = 1 then
    begin
      if (bb.left < other.right) then Result.x := other.right - bb.left;
      Exit;
    end;

    if tile^.tile = 4 then
    begin
      // If the height at this X position enters the box, then set the adjustment and exit

      for idx := idx1 downto idx0 do
      begin
        if tile^.description < 576 then
          collide := bb.bottom > (other.bottom - heights[tile^.description][idx])
        else
          collide := bb.top < (other.top + heights[tile^.description][idx]);

        if collide then
        begin
          Result.x := (other.left + idx) - bb.left + 1;
          Exit;
        end;
      end;
    end;
  end;

  if (delta.y > 0) then
  begin
    if tile^.tile = 1 then
    begin
      if (bb.bottom > other.top) then Result.y := other.top - bb.bottom;
    end;

    if tile^.tile = 4 then
    begin

      // For now, don't bother with downward motions into ceilings
      if tile^.description >= 576 then Exit;

      for idx := idx0 to idx1 do
      begin

        if heights[tile^.description][idx] = 0 then continue;

        h := other.bottom - heights[tile^.description][idx];

        if bb.bottom >= h then
        begin
          adj := h - bb.bottom;
          if adj < Result.y then Result.y := adj;
        end;
      end;
    end;
  end;


  if (delta.y < 0) then
  begin
    if tile^.tile = 1 then
    begin
      if (bb.top < other.bottom) then Result.y := other.bottom - bb.top;
    end;

    if tile^.tile = 4 then
    begin

      // For now, don't bother with upward motions into floors
      if tile^.description < 576 then Exit;

      for idx := idx0 to idx1 do
      begin

        if heights[tile^.description][idx] = 0 then continue;

        h := other.top + heights[tile^.description][idx];

        if bb.top <= h then
        begin
          adj := h - bb.top;
          if adj > Result.y then Result.y := adj;
        end;
      end;

    end;
  end;
end;

procedure SimpleBoxMove1D(self: PEntity; delta: TVector2; var Result: THitResult);
var
  bb, bb0, other: TBoundingBox;
  tx0, tx1, ty0, ty1, tx, ty: integer;
  maxAdjX, maxAdjY: integer;
  tile: PTile;
  adj, adj1: TVector2;
  didAdjust: boolean;

  axis: integer;
begin

  adj.x := 0;
  adj.y := 0;
  bb := Entity_Hitbox(self);
  bb0 := bb;

  Inc(bb.left, delta.x);
  Inc(bb.right, delta.x);
  Inc(bb.top, delta.y);
  Inc(bb.bottom, delta.y);

  { Move to pixel space }
  bb.left := fix32ToInt(bb.left);
  bb.right := fix32ToInt(bb.right);
  bb.top := fix32ToInt(bb.top);
  bb.bottom := fix32ToInt(bb.bottom);

  tx0 := bb.left div 24;
  tx1 := bb.right div 24;
  ty0 := bb.top div 24;
  ty1 := bb.bottom div 24;

  for ty := ty0 to ty1 do
  begin
    for tx := tx0 to tx1 do
    begin
      tile := Map_TileAt(tx, ty);
      if not Assigned(tile) then continue;

      other.left := tx * 24;
      other.right := tx * 24 + 24;
      other.top := ty * 24;
      other.bottom := ty * 24 + 24;

      if bb.bottom <= other.top then continue;
      if bb.right <= other.left then continue;

      if tile^.tile <> 0 then
      begin
        adj1 := GetTileReject(bb, other, delta, tile);

        if delta.x <> 0 then
        begin
          if (abs(adj1.x) > abs(adj.x)) then adj.x := adj1.x;
        end
        else
        begin
          if (abs(adj1.y) > abs(adj.y)) then adj.y := adj1.y;
        end;
      end;
    end;
  end;

  // TODO: Check vs entities

  if (adj.x <> 0) or (adj.y <> 0) then
  begin
    //writeln(Format('Final adjust for delta: %d %d = %d %d, delta', [delta.x, delta.y, adj.x, adj.y]));

    if delta.x <> 0 then Result.x := adj.x;
    if delta.y <> 0 then Result.y := adj.y;

    Inc(delta.X, intToFix32(adj.x));
    Inc(delta.Y, intToFix32(adj.y));
  end;

  Inc(self^.x, delta.x);
  Inc(self^.y, delta.y);
end;

procedure SimpleBoxMove(self: PEntity; delta: TVector2; var traceInfo: THitResult);
var
  bb, bb0, other: TBoundingBox;
  tx0, tx1, ty0, ty1, tx, ty: integer;
  maxAdjX, maxAdjY: integer;
  tile: PTile;
  adj, adj1: TVector2;
  didAdjust: boolean;

  axis: integer;

begin

  traceInfo.x := 0;
  traceInfo.y := 0;

  if (delta.x = 0) and (delta.y = 0) then Exit;

  //writeln(Format('SimpleBoxMove, delta: %d %d', [delta.x, delta.y]));

  if (delta.x <> 0) then SimpleBoxMove1D(self, Vector2Make(delta.x, 0), traceInfo);
  if (delta.y <> 0) then SimpleBoxMove1D(self, Vector2Make(0, delta.y), traceInfo);
  Exit;

  adj.x := 0;
  adj.y := 0;
  bb := Entity_Hitbox(self);
  bb0 := bb;

  Inc(bb.left, delta.x);
  Inc(bb.right, delta.x);
  Inc(bb.top, delta.y);
  Inc(bb.bottom, delta.y);

  { Move to pixel space }
  bb.left := fix32ToInt(bb.left);
  bb.right := fix32ToInt(bb.right);
  bb.top := fix32ToInt(bb.top);
  bb.bottom := fix32ToInt(bb.bottom);

  tx0 := bb.left div 24;
  tx1 := bb.right div 24;
  ty0 := bb.top div 24;
  ty1 := bb.bottom div 24;

  for ty := ty0 to ty1 do
  begin
    for tx := tx0 to tx1 do
    begin
      tile := Map_TileAt(tx, ty);
      if not Assigned(tile) then continue;

      other.left := tx * 24;
      other.right := tx * 24 + 24;
      other.top := ty * 24;
      other.bottom := ty * 24 + 24;

      if bb.bottom <= other.top then continue;
      if bb.right <= other.left then continue;

      if tile^.tile <> 0 then
      begin

        adj1 := GetTileReject(bb, other, delta, tile);


        axis := ShortestNonZeroAxis(adj1);
        writeln(Format(' Result: %d %d, shortest axis: %d, type: %d',
          [adj1.x, adj1.y, axis, tile^.tile]));
        // Get the smallest non-zero magnitude

        // Find the smallest possible adjustment to move out

        if axis = 0 then
        begin
          writeln('X magnitude is smallest');
          if (abs(adj1.x) > abs(adj.x)) then adj.x := adj1.x;
        end;

        if axis = 1 then
        begin
          writeln('Y magnitude is smallest');
          if (abs(adj1.y) > abs(adj.y)) then adj.y := adj1.y;
        end;



{
        if (adj1.x <> 0) or (adj1.y <> 0) then
        begin
          didAdjust := True;
        end;
        if abs(adj1.x) < abs(adj.x) then adj.x := adj1.x;
        if abs(adj1.y) < abs(adj.y) then adj.y := adj1.y;}
      end;

    end;
  end;

  if (adj.x <> 0) or (adj.y <> 0) then
  begin

    axis := ShortestNonZeroAxis(adj);
    writeln('Final adjust ', adj.x, ' ', adj.y, ' shortest axis: ', axis);
{
    if axis = 0 then
    begin
      Inc(delta.X, intToFix32(adj.x));
    end
    else
    begin
      Inc(delta.Y, intToFix32(adj.y));
    end;
}

    Inc(delta.X, intToFix32(adj.x));
    Inc(delta.Y, intToFix32(adj.y));



    Inc(self^.x, delta.x);
    Inc(self^.y, delta.y);
  end
  else
  begin
    writeln('no adjust');
    Inc(self^.x, delta.x);
    Inc(self^.y, delta.y);

  end;

end;

end.
