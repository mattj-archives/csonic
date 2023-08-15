unit common;

{$mode tp}

interface

uses
  Classes, SysUtils, res_enum;

const
  MAX_ENTITIES = 128;

type

  TVector2 = record
    x, y: integer;
  end;

  PEntity = ^TEntity;

  TEntity = record
    {$include entity.inc}
    padding: array[0..15] of integer; { 32 bytes of padding }
  end;

  PEntityMovingPlatform = ^TEntityMovingPlatform;
  TEntityMovingPlatform = record
    {$include entity.inc}
    p: array[0..1] of TVector2;
    dest: integer;
  end;


  TTile = record
    entity: PEntity;
    tile: integer;
    color: integer;
  end;

  TSpriteState = record
    sprites: array[0..1] of integer;
  end;

  TEntityState = record
    duration: integer;
    nextState: entityStates;
    spriteState: spriteStates;
    func: integer;
  end;

  THitResult = record
    hitType: integer;
    entity: PEntity;
    x: integer;
    y: integer;
  end;

  TBoundingBox = record
    left, right, top, bottom: integer;
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
