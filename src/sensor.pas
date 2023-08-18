unit Sensor;

{$mode tp}

interface

uses
  engine, common, terrainmove;

function SensorX(y, startX, endX: integer): integer;
function SensorY(x, startY, endY: integer): integer;

implementation

function SensorX(y, startX, endX: integer): integer;
var
  hitType, delta, h, x, tx, ty, ty0, ty1, idx, traceXValue: integer;
  other: TBoundingBox;
begin
  traceXValue := endX;
  SensorX := endX;

  if startX > endX then delta := -1
  else
    delta := 1;

  ty := y div 24;
  x := startX;
  while true do
  begin
    tx := x div 24;

    other.left := tx * 24;
    other.right := tx * 24 + 24;
    other.top := ty * 24;
    other.bottom := ty * 24 + 24;

    if map[ty * 168 + tx].tile = 4 then
    begin
      idx := (x - other.left);
      if idx < 0 then idx := 0;
      if idx > 23 then idx := 23;

      // TODO: Is this -1 correct?
      h := other.bottom - heights[map[ty * 168 + tx].description][idx] - 1;

      //writeln('sensorX hit at x: ', x, ' h: ', h, ' y is: ', y);
      if h <= y then break;
    end;

    traceXValue := x;
    if x = endX then break;
    Inc(x, delta);
  end;

  SensorX := traceXValue;
end;

function SensorY(x, startY, endY: integer): integer;
var
  hitType, delta, h, tx, ty, ty0, ty1, idx, traceYValue: integer;
  other: TBoundingBox;
begin
  hitType := 0;
  traceYValue := endY;
  SensorY := endY;

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

    h := startY;

    if map[ty * 168 + tx].tile = 1 then
    begin
      //h := other.top;
      //h := other.bottom - 23;
      h := other.bottom - 24;
      if (h < traceYValue) then traceYValue := h;
      hitType := 1;
    end;

    if map[ty * 168 + tx].tile = 4 then
    begin
      idx := (x - other.left);
      if idx < 0 then idx := 0;
      if idx > 23 then idx := 23;

      h := other.bottom - heights[map[ty * 168 + tx].description][idx] - 1;

      if (h < traceYValue) then traceYValue := h;
      hitType := 1;
      //writeln('hit at type type 4 at h ', h);
    end;

    sensorY := traceYValue;
  end;
end;

end.
