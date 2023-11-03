unit Map;



interface

uses common;

procedure Map_Load(fileName: string);
function Map_TileAt(tx, ty: integer): PTile;

implementation

uses res, res_enum, buffer, entity, util;

procedure Map_Load(fileName: string);
var
  f: file;
  Width, Height, num_objects, tile_type, object_type: byte;
  i, x, y: longint;
  tile_desc, tile_vis: integer;
  tile: ^TTile;
  e: PEntity;
  moving_platform: PEntityMovingPlatform;
  _reader: TBufferReader;
  reader: PBufferReader;

begin
  writeln('Map_Load ', fileName);
  Assign(f, fileName);
  Reset(f, 1);

  _reader := Buf_CreateReaderForFile(f);
  reader := @_reader;

  Width := Buf_ReadByte(reader);
  Height := Buf_ReadByte(reader);

  for y := 0 to Height - 1 do
  begin
    for x := 0 to Width - 1 do
    begin
      tile_type := Buf_ReadByte(reader);
      tile_desc := Buf_ReadInt(reader);
      tile_vis := Buf_ReadInt(reader);

      tile := @G.map[y * 168 + x];
      tile^.tile := 0;
      if tile_type = 1 then
      begin
        tile^.tile := 4;
        tile^.description := tile_desc;
        tile^.color := tile_vis;
        { vis }
      end;
    end;
  end;

  num_objects := Buf_ReadInt(reader);

  //BlockRead(f, num_objects, sizeof(integer));

  for i := 0 to num_objects - 1 do
  begin
    object_type := Buf_ReadInt(reader);

    x := intToFix32(Buf_ReadInt(reader));
    y := intToFix32(Buf_ReadInt(reader) - 24);

    //Dec(y, 24);
    //y := intToFix32(y);

    case object_type of
      13: begin
        moving_platform := PEntityMovingPlatform(SpawnEntity(x, y, object_type));
        Entity_SetState(moving_platform, STATE_MPLAT);

        moving_platform^.p[0].x := x;
        moving_platform^.p[0].y := y;
        moving_platform^.dest := 1;
        moving_platform^.p[1].x := intToFix32(Buf_ReadInt(reader));
        moving_platform^.p[1].y := intToFix32(Buf_ReadInt(reader));
      end;
      17: begin
        writeln('spawn Spring1 at ', x, ' ', y);
        e := SpawnEntity(x, y, object_type);
        Entity_SetState(e, STATE_SPRING1_IDLE);
      end;
      18: begin
        e := SpawnEntity(x, y, object_type);
        Entity_SetState(e, STATE_SPRING2_IDLE);
      end;
      ord(ENTITY_TYPE_BOX_RING):
      begin
        e := SpawnEntity(x, y, object_type);
        Entity_SetState(e, entityStates.STATE_BOX_RING1);
      end;
      43:
      begin
        e := SpawnEntity(x, y, object_type);
        Entity_SetState(e, entityStates.STATE_RING1);
      end;
      44: begin
        e := SpawnEntity(x, y, object_type);
        Entity_SetState(e, entityStates.STATE_CHILI1);
      end;
      70: {Enemy "Rabid Mushroom" }
      begin
        e := SpawnEntity(x, y, object_type);
        Entity_SetState(e, STATE_RM_IDLE);
      end;
      71: { Enemy "Mosquito" }
      begin
        e := SpawnEntity(x, y, object_type);
        Entity_SetState(e, STATE_MOSQU_IDLE);
      end;
      72: {Enemy "Bouncing potato" }
      begin
        e := SpawnEntity(x, y, object_type);
        Entity_SetState(e, STATE_BPOT_IDLE);
      end;
    end;

  end;


  System.Close(f);
end;


function Map_TileAt(tx, ty: integer): PTile;
begin
  Map_TileAt := nil;
  if (ty < 0) or (ty >= 54) or (tx < 0) or (tx >= 168) then Exit;

  Map_TileAt := @G.map[ty * 168 + tx];
end;

end.
