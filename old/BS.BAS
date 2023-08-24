TYPE FooType
  x AS INTEGER
  y AS INTEGER
END TYPE

DECLARE SUB test1 (temp AS ANY)

DIM SHARED arr(3) AS FooType

CLS

arr(1).x = 100

test1 arr(1)

PRINT "Final arr(1).x", arr(1).x

SUB test1 (temp AS FooType)
 temp.x = temp.x + 1

 PRINT "temp.x", temp.x
 PRINT "arr(1).x", arr(1).x
END SUB

