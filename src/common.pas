unit common;

interface

uses
  res_enum;

const
  MAX_ENTITIES = 256;

  ENTITY_FLAG_ACTIVE = 1 shl 0;
  ENTITY_FLAG_MISC = 1 shl 1;

  FRAC_BITS = 8;

  COLLISION_LEVEL = $0001;
  COLLISION_ENEMY = $0004;

type

  TVector2 = record
    x, y: longint;
  end;

  PEntity = ^TEntity;
  PEntityInfo = ^TEntityInfo;

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

  EntityInitProc = procedure(Data: Pointer);
  EntityStateProc = procedure(Data: Pointer);
  EntityUpdateProc = procedure(Data: Pointer);
  EntityDebugDrawProc = procedure(Data: Pointer);
  EntityDrawProc = procedure(Data: Pointer);

  TEntityInfo = record
    initProc: EntityInitProc;
    stateProc: EntityStateProc;
    updateProc: EntityUpdateProc;
    debugDrawProc: EntityDebugDrawProc;
    drawProc: EntityDrawProc;

  end;

  TEntityState = record
    duration: integer;
    nextState: entityStates;
    spriteState: spriteStates;
    func: integer;
  end;

  THitResult = record
    // Parameters
    collisionMask: shortint;
    ignoreEntity: PEntity;

    // Results
    hitType: integer;
    entity: PEntity;
    x: longint;
    y: longint;

    { May be filled out so collision response knows the incoming velocity }
    velX: longint;
    velY: longint;
  end;

  TBoundingBox = record
    left, right, top, bottom: longint;
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
