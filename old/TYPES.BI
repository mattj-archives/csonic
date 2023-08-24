' Cool Sonic
' Types

TYPE TEntity
 x AS INTEGER
 y AS INTEGER

 entityNum AS INTEGER
 direction AS INTEGER

 flags AS INTEGER       ' 1 = in use
 t AS INTEGER           ' Type
 idx AS INTEGER         ' Index into other array

 stateFrames AS INTEGER

 nextTileEntityNum AS INTEGER
END TYPE

TYPE TBoundingBox
 left AS INTEGER
 right AS INTEGER
 bottom AS INTEGER
 top AS INTEGER
END TYPE

TYPE TVector2
 x AS INTEGER
 y AS INTEGER
END TYPE

TYPE TCollisionList
    entryType AS INTEGER
    num AS INTEGER
END TYPE

TYPE TTile
 firstEntityNum AS INTEGER
 tile AS INTEGER    ' ??? stuff
 color AS INTEGER   ' Terrain color
END TYPE

TYPE badguy
    x AS INTEGER
    y AS INTEGER
    x1 AS INTEGER
    x2 AS INTEGER
    y1 AS INTEGER
    y2 AS INTEGER
    t AS LONG
    f1 AS INTEGER
    f2 AS INTEGER
    f3 AS INTEGER
    State AS INTEGER
    last AS INTEGER
    num AS INTEGER
    step AS INTEGER
    END TYPE
    TYPE mess
    mes AS STRING * 40
    x AS INTEGER
    y AS INTEGER
    stopx AS INTEGER
    t AS LONG
    col AS INTEGER
END TYPE

TYPE THUD
 redraw AS INTEGER
END TYPE


TYPE THitResult
 hitType AS INTEGER
 entityNum AS INTEGER
 x AS INTEGER
 y AS INTEGER
END TYPE

