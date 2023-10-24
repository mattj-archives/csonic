unit Map;



interface

uses common;

function Map_TileAt(tx, ty: integer): PTile;

implementation


function Map_TileAt(tx, ty: integer): PTile;
begin
  Map_TileAt := nil;
  if (ty < 0) or (ty >= 54) or (tx < 0) or (tx >= 168) then Exit;

  Map_TileAt := @G.map[ty * 168 + tx];
end;

end.
