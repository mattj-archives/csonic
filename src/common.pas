unit common;

{$mode tp}

interface

uses
  Classes, SysUtils;

const
  MAX_ENTITIES = 128;

type
  PEntity = ^TEntity;

  TEntity = record
    x: integer;
    y: integer;

    entityNum: integer;
    direction: integer;
    flags: integer;
    t: integer;
    idx: integer;
    stateFrames: integer;

    nextTileEntity: PEntity;
  end;

  TVector2 = record
    x, y: integer;
  end;

  TTile = record
    entity: PEntity;
    tile: integer;
  end;

  TSpriteState = record
    sprites: array[0..1] of integer;
  end;

  TEntityState = record
    duration: integer;
    nextState: integer;
    spriteState: integer;
    func: integer;
  end;

var
  map: array[0..9071] of TTile; { 168 * 54 }
  entities: array[1..MAX_ENTITIES] of TEntity;
  camera: TVector2;

implementation

begin
  camera.x := 0;
  camera.y := 0;

end.
