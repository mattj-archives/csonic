unit common;

{$mode tp}

interface

uses
  res_enum;

const
  MAX_ENTITIES = 256;

  ENTITY_FLAG_ACTIVE = 1 shl 0;
  ENTITY_FLAG_MISC = 1 shl 1;

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

  PEntityBPot = ^TEntityBPot;
  TEntityBPot = record
    {$include entity.inc}
    vy: integer;
  end;

  PEntityRM = ^TEntityRM;
  TEntityRM = record
    {$include entity.inc}
  end;


  PEntityMosquito = ^TEntityMosquito;
  TEntityMosquito = record
    {$include entity.inc}
    patrolFrames: integer;
  end;

  PTile = ^TTile;
  TTile = record
    entity: PEntity;
    description: integer;      { For now, index into the height table }
    tile: integer;
    color: integer;
  end;

  TSpriteState = record
    sprites: array[0..1] of integer;
  end;

  EntityStateProc = procedure(data: Pointer);
  EntityUpdateProc = procedure(data: Pointer);
  EntityDebugDrawProc = procedure(data: Pointer);
  TEntityInfo = record
    stateProc: EntityStateProc;
    updateProc: EntityUpdateProc;
    debugDrawProc: EntityDebugDrawProc;

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

    { May be filled out so collision response knows the incoming velocity }
    velX: integer;
    velY: integer;
  end;

  TBoundingBox = record
    left, right, top, bottom: integer;
  end;

  TGlobals = record
    map: array[0..9071] of TTile; { 168 * 54 }
    entities: array[1..MAX_ENTITIES] of TEntity;
    entityInfo: array[0..256] of TEntityInfo;
    camera: TVector2;
  end;


var
  G: TGlobals;
  heights: array[0..1151, 0..23] of byte;

implementation

begin
  G.camera.x := 0;
  G.camera.y := 0;
end.
