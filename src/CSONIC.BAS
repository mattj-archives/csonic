DECLARE SUB Player.SetMode (self AS ANY, mode%)
DECLARE SUB StateFunc (self AS ANY)
DECLARE SUB Player.Update (self AS ANY)
DECLARE SUB Entity.AddToTile (e AS ANY, tile AS ANY)
DECLARE SUB Entity.RemoveFromTile (e AS ANY, tile AS ANY)
DECLARE SUB Entity.SetState (e AS ANY, stateNum AS INTEGER)
DECLARE SUB Player.Touch (self AS ANY)
DECLARE SUB Player.Left (self AS ANY, n%)
DECLARE SUB UpdateEntity (self AS ANY)
DECLARE SUB Player.Rt (self AS ANY, n%)
DECLARE SUB Player.Up (self AS ANY, n%)
DECLARE SUB Player.Down (self AS ANY, n%)
DECLARE FUNCTION SpawnEntity% (x AS INTEGER, y AS INTEGER, entityType AS INTEGER)
DECLARE SUB DrawState (x AS INTEGER, y AS INTEGER, stateNum AS INTEGER, BYVAL direction AS INTEGER)
DECLARE SUB Console ()
DECLARE SUB PUT2 (BYVAL x%, BYVAL y%, BYVAL dataSeg%, BYVAL dataOffs%)
DECLARE SUB PUT3 (x AS INTEGER, y AS INTEGER, index AS INTEGER)
'$STATIC
'$INCLUDE: 'src/res/CONST.BI'
TYPE TEntity
 x AS INTEGER
 y AS INTEGER

 entityNum AS INTEGER
 direction AS INTEGER

 flags AS INTEGER       ' 1 = in use
 t AS INTEGER           ' Type
 idx AS INTEGER         ' Index into other array

 stateNum AS INTEGER
 stateFrames AS INTEGER

 nextTileEntityNum AS INTEGER
END TYPE

DECLARE SUB Startup ()
DEFINT A-Z
DECLARE SUB message (n, ty, stx, c, ms$)
DECLARE SUB PassLevel ()
DECLARE SUB DoDie ()
DECLARE SUB DoForces ()
DECLARE SUB tsr (n%)
DECLARE SUB ReadyMask ()
DECLARE SUB enemy.mgr ()
DECLARE SUB loadtoact ()
DECLARE SUB DrawLoadScene (n)
DECLARE SUB LevelIntro ()
DECLARE SUB ChangeGFX (p%())
DECLARE SUB LaserMan ()
DECLARE SUB GambleHolder (n)
DECLARE FUNCTION PChk! (n)
DECLARE SUB PlatDo (n)
DECLARE SUB DnS ()
DECLARE FUNCTION OS (tx, ty)
DECLARE SUB Tman ()
DECLARE SUB HitSpring (t, tx, ty)
DECLARE SUB sfx (n)
DECLARE SUB HitSonic (n)
DECLARE SUB Expman (n, ttx, tty)
DECLARE FUNCTION ChkAhead (tx, ty)
DECLARE SUB gotitem (t)
DECLARE SUB DrawGfx (n)
DECLARE SUB AnmMan ()
DECLARE SUB SonicMan ()
DECLARE SUB Lt (n)
DECLARE SUB Player.Jump (self AS TEntity)
DECLARE SUB UMan ()
DECLARE SUB Up (n)
DECLARE SUB Rt (n)
DECLARE SUB dn (self AS TEntity, n)
DECLARE SUB Die (n)
DECLARE SUB MainLoop ()
DECLARE SUB DrawSonic (ttx, tty)
DECLARE SUB SetScr ()
DECLARE SUB ReDrawObj (tx, ty, ttx, tty, n)
DECLARE SUB DrawAllScr ()
DECLARE SUB LoadLevel (t$)
DECLARE SUB LGFX ()

'Cool Sonic Ver 1.0


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
STATE AS INTEGER
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

TYPE TTile
 firstEntityNum AS INTEGER
 tile AS INTEGER    ' ??? stuff
 color AS INTEGER   ' Terrain color
END TYPE

COMMON SHARED a(), p()
COMMON SHARED bcnt()
COMMON SHARED bpot() AS badguy, mosqu() AS badguy, rm() AS badguy
COMMON SHARED stage, SonicDir
COMMON SHARED act, strx, stry
COMMON SHARED HUD AS THUD
COMMON SHARED Res AS TRes
COMMON SHARED entities() AS TEntity
COMMON SHARED Map() AS TTile

DIM entities(0 TO 128) AS TEntity
DIM a(168, 54)
DIM Map(168, 54) AS TTile

RANDOMIZE TIMER
DIM SHARED ssx, ssy, stax, stay
DIM SHARED sx, sy
stage = 1: act = 1
'**************************
DIM SHARED BOXRNG%(209), BOXSHI%(209), BOXSPI%(209), BOXBUB%(209), BOXFIR%(209)

DIM SHARED BOXST%(209), SPRINGR1%(209), SPRINGR2%(209), SPRINGL1%(209), SPRINGL2%(209)
DIM SHARED SPIKEUP%(209), SPIKEDN%(209), SPIKELT%(209), SPIKERT%(209), SDIE%(209)
DIM SHARED FSPIKE%(209), AFSPIKE%(209), MPL%(209), MPR%(209), MPLAT%(209), BPLAT%(209)
DIM SHARED LFLIP1%(209), RFLIP1%(209), LFLIP2%(209), RFLIP2%(209), GAMBLE%(209)
DIM SHARED LAVA1%(209), LAVA2%(209), LAVA3%(209), ELL%(209), ELR%(209), EL1%(209), EL2%(209), EL3%(209)
DIM SHARED CFP%(209), WFP%(209), LUP%(209), LDN%(209), LLT%(209), LRT%(209), LHOR%(209), LVER%(209)
DIM SHARED PASSER1%(209), PASSER2%(209), PASSER3%(209), PASSER4%(209)

DIM SHARED GraphicsBuf(0 TO 27064) AS INTEGER

'**************************

DIM SHARED playerIdx AS INTEGER

DIM SHARED SonicMode, SonicFrame, PlayerInAir%: SonicMode = 3: SonicFrame = 1
PlayerInAir = 1
DIM SHARED UpForce, StartForce, sti!, jt!: UpForce = 0
DIM SHARED rings, rf!, rc: rings = 0: rc = 4: rf! = INT(TIMER)
DIM SHARED rfr, cfr, rft, cft!: rfr = 1: cfr = 1: rft = 0: cft! = INT(TIMER)
DIM SHARED boxs!, bb, CDP: boxs! = INT(TIMER): bb = 1: CDP = 0
DIM SHARED ex(15), ey(15), ef(15), et(15)
DIM SHARED sc, so, s3, sht!, sht2!, sfxf: sfxf = 1'shield color,onflag,timer
DIM SHARED nos1, nos2, s1s(20), s2s(20), s1t!(20), s2t!(20), spx1(20), spy1(20), spx2(20), spy2(20)
DIM SHARED tempa, Breath, brt!: Breath = 99
DIM SHARED fs, fsx(20), fsy(20), fss(20), afs, afsx(20), afsy(20), afss(20)
DIM SHARED fp, fps(40), fpx(40), fpy(40)
DIM SHARED nof1, nof2, flf(20), frf(20), flt!(20), frt!(20), frx(20), fry(20), flx(20), fly(20)
DIM SHARED tttt$(6), Lives, score, LavaState, LavaTimer: Lives = 3: LavaState = 1
DIM SHARED ElState, Eltimer, GameTime AS LONG: ElState = 1
DIM SHARED fc, fcs(40), fcx(40), fcy(40), stat0
DIM SHARED fw, fws(40), fwx(40), fwy(40), fds: fds = 0
DIM SHARED TmanT!: TmanT! = TIMER
DIM SHARED force$, gothit!, ght!, ghs, forcet!, forcep      '0=No hurt 1=on 2=off
DIM SHARED DieTimer!, youaredead
DIM SHARED passerstate, passertime!, passertime2!, passerframe, passerspin, passerdest'STATE
DIM SHARED passx, passy                                                             '0=none 1=spin
DIM SHARED msg(10) AS mess

stage = 1: act = 1                                            '2=done
DIM SHARED tlsx, tlf, ltf:                                    'FRAME
DIM bcnt(18)                                                  'SAME 12131213
TYPE MP
x1 AS INTEGER
x2 AS INTEGER
y1 AS INTEGER
y2 AS INTEGER
t AS LONG
d AS INTEGER
x AS INTEGER
y AS INTEGER
s AS INTEGER
Mved AS INTEGER
END TYPE
TYPE lsr
x AS INTEGER
y AS INTEGER
ltype AS INTEGER
lx AS INTEGER
ly AS INTEGER
ldir AS INTEGER
Lt AS LONG
et AS LONG
END TYPE
DIM SHARED m(40) AS MP, cm, ocm
DIM SHARED laser(30) AS lsr, lsrs
'Bad guy DIMs
DIM bpot(30) AS badguy, mosqu(30) AS badguy, rm(30) AS badguy
DIM SHARED screenmode: screenmode = 13
'**********************
SonicDir = 4

Startup

PRINT "Loading graphics..."
LGFX

PRINT "Loading level..."
LoadLevel "levels\1_1.l2"

PRINT : PRINT : PRINT "Free memory:"; FRE(-1)

SCREEN screenmode

LevelIntro
SetScr

FOR z = 1 TO 10: msg(z).x = -80: NEXT
MainLoop

SUB AnmMan ()
rft = rft + 1
'IF TIMER - rft! >= .1 THEN
IF rft >= 8 THEN
 rfr = rfr + 1: IF rfr = 7 THEN rfr = 1
 rft = 0
 DrawGfx 43
END IF
IF TIMER - cft! >= .1 THEN
 cfr = cfr + 1: IF cfr = 7 THEN cfr = 1
 cft! = TIMER
 DrawGfx 44
END IF
IF bb = 1 AND TIMER - boxs! >= .9 THEN
 IF bb = 1 THEN bb = 2 ELSE bb = 1
 boxs! = TIMER
 FOR z = 38 TO 42: DrawGfx z: NEXT
GOTO r1
END IF
IF bb = 2 AND TIMER - boxs! >= .3 THEN
 IF bb = 1 THEN bb = 2 ELSE bb = 1
 boxs! = TIMER
 FOR z = 38 TO 42: DrawGfx z: NEXT
END IF
r1:
FOR z = 1 TO nos1
IF s1s(z) = 1 AND TIMER - s1t!(z) >= .5 THEN s1s(z) = 0: DrawGfx 17
NEXT
FOR z = 1 TO nos2
IF s2s(z) = 1 AND TIMER - s2t!(z) >= .5 THEN s2s(z) = 0: DrawGfx 18
NEXT

r2:
FOR z = 1 TO nof1
IF flf(z) = 1 AND TIMER - flt!(z) >= .5 THEN flf(z) = 0: DrawGfx 21
NEXT
FOR z = 1 TO nof2
IF frf(z) = 1 AND TIMER - frt!(z) >= .5 THEN frf(z) = 0: DrawGfx 22
NEXT
IF TIMER - TmanT! > .1 THEN Tman: TmanT! = TIMER
LavaTimer = LavaTimer + 1
IF LavaTimer >= 12 THEN
LavaState = LavaState + 1: IF LavaState = 4 THEN LavaState = 1
LavaTimer = 0
DrawGfx 28
END IF
Eltimer = Eltimer + 1
IF Eltimer >= 8 THEN
ElState = ElState + 1: IF ElState = 4 THEN ElState = 1
Eltimer = 0
DrawGfx 31
END IF
FOR z = 1 TO 15
 IF ef(z) <> 0 THEN
 et(z) = et(z) + 1
 IF et(z) >= 8 THEN ef(z) = ef(z) + 1: et(z) = 0
 IF OS(ex(z), ey(z)) = 1 THEN ReDrawObj ex(z), ey(z), ex(z) - strx, ey(z) - stry, 0
 IF ef(z) = 5 THEN
 ef(z) = 0: a(ex(z), ey(z)) = 0
 IF OS(ex(z), ey(z)) = 1 THEN ReDrawObj ex(z), ey(z), ex(z) - strx, ey(z) - stry, 0
 END IF
 END IF
NEXT
LaserMan
IF passerstate = 1 THEN
 IF TIMER - passertime2! < 4 THEN
  IF TIMER - passertime! > .1 THEN
   IF passerspin = 1 THEN               'on spin
	passerframe = passerframe + 1
	IF passerframe = 3 THEN passerframe = 0
	passerspin = 0
	passertime! = TIMER
   ELSE
	passerspin = 1
	passertime! = TIMER
   END IF
  IF OS(passx, passy) = 1 THEN ReDrawObj passx, passy, passx - strx, passy - stry, 0
  END IF
 ELSE
 passerstate = 2: IF rings >= 50 THEN passerframe = 2 ELSE passerframe = 1
 END IF
ELSE
IF passerstate = 2 THEN
 IF OS(passx, passy) = 1 THEN ReDrawObj passx, passy, passx - strx, passy - stry, 0: passerstate = 3
 PassLevel
END IF
END IF
END SUB

FUNCTION ChkAhead (tx, ty)
ChkAhead = 0
IF tx < 0 OR ty < 0 THEN ChkAhead = 1: EXIT FUNCTION

IF Map(tx, ty).firstEntityNum <> 0 THEN

 SELECT CASE entities(Map(tx, ty).firstEntityNum).t
 CASE 72: 'BPOT
	ChkAhead = 1
	EXIT FUNCTION
 END SELECT

END IF

SELECT CASE a(tx, ty)
CASE 1: ChkAhead = 1: EXIT FUNCTION
CASE 2, 3: ChkAhead = 0: EXIT FUNCTION
CASE 4, 5
IF ty > y THEN UpForce = 2: Player.Up entities(playerIdx), 1
IF ty < y THEN UpForce = 0
ChkAhead = 1: HitSonic 0: EXIT FUNCTION
CASE 6, 7
ChkAhead = 0: HitSonic 0: EXIT FUNCTION
CASE 9, 10: ChkAhead = 1: EXIT FUNCTION
CASE 11, 12: ChkAhead = 1: EXIT FUNCTION
CASE 13: ChkAhead = 1: EXIT FUNCTION
CASE 8: IF x = tx AND ty < y THEN HitSonic 0: ChkAhead = 1: EXIT FUNCTION
ChkAhead = 1: EXIT FUNCTION
CASE 17, 18
IF ty > y AND SonicMode = 4 THEN SonicMode = 1: UpForce = 0: EXIT FUNCTION
ChkAhead = 1: HitSpring a(tx, ty), tx, ty: EXIT FUNCTION
CASE 21, 22: ChkAhead = 1: EXIT FUNCTION
CASE 25
IF ty > y THEN UpForce = 2
ChkAhead = 1
EXIT FUNCTION
CASE 26, 27: ChkAhead = 0: EXIT FUNCTION
CASE 28: HitSonic 28: ChkAhead = 1: EXIT FUNCTION
CASE 29, 30: ChkAhead = 1: EXIT FUNCTION
CASE 31: ChkAhead = 0: HitSonic 31: EXIT FUNCTION
CASE 32, 33: ChkAhead = 1: EXIT FUNCTION
CASE 38 TO 42
IF a(tx, ty) > 37 AND a(tx, ty) < 43 THEN IF SonicMode <> 4 THEN ChkAhead = 1: EXIT FUNCTION
gotitem a(tx, ty)
a(tx, ty) = 0
Expman 1, tx, ty
ChkAhead = 0: EXIT FUNCTION

CASE 43, 44
gotitem a(tx, ty)
a(tx, ty) = 0
ChkAhead = 0: EXIT FUNCTION

CASE 70
FOR z = 1 TO bcnt(2)
IF rm(z).x = tx AND rm(z).y = ty THEN
 IF SonicMode = 4 THEN
  Expman 1, tx, ty: UpForce = 3: score = score + 100
  rm(z).STATE = 0
  sfx 12
 ELSE
 HitSonic 1
 END IF
END IF
NEXT

CASE 71
ChkAhead = 1
'FOR z = 1 TO bcnt(1)
'IF mosqu(z).x = tx AND mosqu(z).y = ty THEN
' IF SonicMode = 4 THEN
'  Expman 1, tx, ty: UpForce = 3: score = score + 100
'  mosqu(z).STATE = 0
'  sfx 12
' ELSE
' HitSonic 1
' END IF
'END IF
'NEXT

CASE 72
'ChkAhead = 1

'FOR z = 1 TO bcnt(3)
'IF bpot(z).x = tx AND bpot(z).y = ty THEN
' IF SonicMode = 4 THEN
'  Expman 1, tx, ty: UpForce = 3: score = score + 100
'  bpot(z).STATE = 0
'  sfx 12
' ELSE
' HitSonic 1
' END IF
'END IF
'NEXT

CASE 100: ChkAhead = 0: EXIT FUNCTION
CASE 103: ChkAhead = 0
IF passerstate = 0 THEN
 passerstate = 1: passertime! = TIMER: passertime2! = TIMER
END IF

EXIT FUNCTION
END SELECT
END FUNCTION

SUB Console ()
COLOR 7
CLS
LOCATE 2, 1
PRINT "Console"
PRINT "GotItem <n>"
INPUT a$

IF LCASE$(a$) = "gotitem" THEN GOSUB cmd.gotitem
EXIT SUB


cmd.gotitem:
PRINT "38 - ring box"
PRINT "39 - shield box 1"
PRINT "40 - spike box"
PRINT "41 - shield box 2 (bubble)"
PRINT "42 - shield box 3 (flame)"
PRINT "43 - ring"
		INPUT "GotItem >", n%
		gotitem n%
RETURN

END SUB

SUB Die (n)
'EXIT SUB
IF n = 1 THEN
DieTimer! = TIMER
force$ = "X"
youaredead = 1
EXIT SUB
END IF
IF n = 2 THEN
DO UNTIL strx = 0 OR stry = 0
strx = strx - 1
stry = stry - 1
IF strx < 0 THEN strx = 0
IF stry < 0 THEN stry = 0
DrawAllScr
LOOP

IF strx > 0 THEN
 DO UNTIL strx = 0
 strx = strx - 1
 IF strx < 0 THEN strx = 0
 DrawAllScr
 LOOP
END IF

IF stry > 0 THEN
 DO UNTIL stry = 0
 stry = stry - 1
 IF stry < 0 THEN stry = 0
 DrawAllScr
 LOOP
END IF
a(x, y) = tempa
sy = ssy: sx = ssx: x = stax: y = stay
tempa = 0
a(x, y) = -1
youaredead = 0
WHILE INKEY$ <> "": WEND
END IF
END SUB

SUB DnS ()
IF so = 2 AND UpForce = 0 AND ChkAhead(x, y + 1) = 1 THEN
 'IF s3 = 0 THEN
 FOR z = .9 TO .1 STEP -.1
 CIRCLE (sx * 24 + 10, sy * 24 + 12 + 10), 12, sc, , , z
 'FOR p = 1 TO 800: NEXT
 t! = TIMER: WHILE TIMER - t! < .01: WEND
 CIRCLE (sx * 24 + 10, sy * 24 + 12 + 10), 12, 0, , , z
 NEXT
s3 = 1
UpForce = 6
'END IF
END IF

END SUB

SUB DoDie ()
dieta:
dx = INT(RND * 6) + strx + 4
dy = INT(RND * 3) + stry + 4
  IF a(dx, dy) <> 0 OR a(dx, dy) = 100 THEN EXIT SUB
  Expman 1, dx, dy
 
' ELSE
' GOTO dieta
' END IF
'ELSE
'GOTO dieta
'END IF
END SUB

SUB DoForces ()
forcet! = TIMER
forcep = forcep + 1
IF forcep > LEN(force$) AND force$ <> "X" THEN force$ = "": EXIT SUB
'IF MID$(force$, forcep, 1) = "U" THEN Player.Up entities(playerIdx), 1
'IF MID$(force$, forcep, 1) = "L" THEN Player.Left entities(playerIdx), 1
'IF MID$(force$, forcep, 1) = "R" THEN Player.Rt entities(playerIdx), 1

END SUB

SUB DrawAllScr ()
trx = 0: try = 0
'CLS
IF screenmode = 13 THEN smy = 6: smx = 12
IF screenmode = 12 THEN smy = 12: smx = 24
FOR z = stry TO stry + smy      '6     12
FOR z2 = strx TO strx + smx     '12    24

IF Map(z2, z).firstEntityNum <> 0 THEN
	entityNum% = Map(z2, z).firstEntityNum
	CALL DrawState(trx, try, entities(entityNum%).stateNum, entities(entityNum%).direction)
ELSE
	SELECT CASE a(z2, z)
	CASE 0: ReDrawObj z2, z, trx, try, 0
	CASE 1: ReDrawObj z2, z, trx, try, 0
	CASE 2: ReDrawObj z2, z, trx, try, 0
	END SELECT
END IF

'IF a(z2, z) = 17 OR a(z2, z) = 18 THEN GOSUB springd
'IF a(z2, z) = 21 OR a(z2, z) = 22 THEN GOSUB flipd
'IF a(z2, z) = 71 OR a(z2, z) = 70 THEN GOSUB botdo
'OnScreen(trx, try) = a(z2, z)
'IF OldOnScreen(trx, try) <> OnScreen(trx, try) THEN ReDrawObj z2, z, trx, try, 0
'IF a(z2, z) = -1 OR a(z2, z) = -2 THEN ReDrawObj z2, z, trx, try, 0
nc2:
trx = trx + 1
NEXT
trx = 0
try = try + 1
NEXT

'IF screenmode = 13 THEN FOR z = 0 TO 6: FOR z2 = 0 TO 12: OldOnScreen(z2, z) = OnScreen(z2, z): NEXT: NEXT
'IF screenmode = 12 THEN FOR z = 0 TO 12: FOR z2 = 0 TO 24: OldOnScreen(z2, z) = OnScreen(z2, z): NEXT: NEXT

EXIT SUB

springd:
 FOR z3 = 1 TO nos1
 IF spx1(z3) = z2 AND spy1(z3) = z THEN ReDrawObj z2, z, trx, try, z3
 NEXT
 FOR z3 = 1 TO nos2
 IF spx2(z3) = z2 AND spy2(z3) = z THEN ReDrawObj z2, z, trx, try, z3
 NEXT
RETURN
flipd:
 FOR z3 = 1 TO nof1
 IF flx(z3) = z2 AND fly(z3) = z THEN ReDrawObj z2, z, trx, try, z3
 NEXT
 FOR z3 = 1 TO nof2
 IF frx(z3) = z2 AND fry(z3) = z THEN ReDrawObj z2, z, trx, try, z3
 NEXT
 GOTO nc2
RETURN
botdo:
SELECT CASE a(z2, z)
CASE 70
 FOR z3 = 1 TO bcnt(2)
 IF rm(z3).x = z2 AND rm(z3).y = z THEN ReDrawObj z2, z, trx, try, z3
 NEXT
CASE 71
 FOR z3 = 1 TO mosqu(1).last
 IF mosqu(z3).x = z2 AND mosqu(z3).y = z THEN ReDrawObj z2, z, trx, try, z3
 NEXT
END SELECT
RETURN
END SUB

SUB DrawGfx (n)
EXIT SUB
trx = 0: try = 0
IF screenmode = 13 THEN smy = 6: smx = 12
IF screenmode = 12 THEN smy = 12: smx = 24
FOR z = stry TO stry + smy      '6     12
FOR z2 = strx TO strx + smx     '12    24
IF n = 17 OR n = 18 THEN
IF a(z2, z) = 17 OR a(z2, z) = 18 THEN
 FOR z3 = 1 TO nos1
 IF spx1(z3) = z2 AND spy1(z3) = z THEN ReDrawObj z2, z, trx, try, z3
 NEXT
 FOR z3 = 1 TO nos2
 IF spx2(z3) = z2 AND spy2(z3) = z THEN ReDrawObj z2, z, trx, try, z3
 NEXT
 GOTO nc3
END IF
END IF
IF a(z2, z) = n THEN ReDrawObj z2, z, trx, try, 0

nc3:

trx = trx + 1
NEXT
trx = 0
try = try + 1
NEXT

END SUB

SUB DrawSonic (ttx, tty)
IF ghs = 2 THEN
' IF tempa <> 0 THEN
'  a(tx, ty) = tempa
'  redrawobj x, y, ttx, tty, 0
' ELSE
  'PUT (ttx * 24, tty * 24 + 12), back%, PSET
' END IF
 EXIT SUB
END IF

SELECT CASE SonicMode

CASE 1, 4: IF SonicFrame = 1 THEN SonicFrame = 2 ELSE SonicFrame = 1
END SELECT

SELECT CASE SonicMode

CASE 1

 SELECT CASE SonicDir

 CASE 3
 SELECT CASE SonicFrame
 CASE 1
 CALL PUT3(ttx, tty, FRAME.SL1)
 CASE 2
 CALL PUT3(ttx, tty, FRAME.SL2)
 END SELECT

 CASE 4
 SELECT CASE SonicFrame
 CASE 1
' PUT (ttx * 24, tty * 24 + 12), SR1%, PSET
 'CALL PUT2(ttx * 24, tty * 24 + 12, FRAME.SR1)
 CASE 2
 'CALL PUT2(ttx * 24, tty * 24 + 12, FRAME.SR2)
 END SELECT
 END SELECT
CASE 2                      'Waiting

 SELECT CASE SonicFrame
 CASE 1
 'DrawState ttx, tty, STATE.PLAYER.WAIT1, entities(playerIdx).direction
 'CALL PUT3(ttx, tty, FRAME.SWAIT1)
 CASE 2
 'DrawState ttx, tty, STATE.PLAYER.WAIT2

' CALL PUT3(ttx, tty, FRAME.SWAIT2)
 END SELECT

CASE 3                     'Standing

 SELECT CASE SonicDir
 CASE 3
 'CALL PUT2(ttx * 24, tty * 24 + 12, frame.sls)
 CASE 4
 'PUT (ttx * 24, tty * 24 + 12), SRS%, PSET
 'CALL PUT2(ttx * 24, tty * 24 + 12, FRAME.SRS)

 END SELECT

CASE 4                     'Jumping
 SELECT CASE SonicFrame
 CASE 1
 'CALL PUT2(ttx * 24, tty * 24 + 12, FRAME.SPIN1%)
 CASE 2
 'CALL PUT2(ttx * 24, tty * 24 + 12, FRAME.SPIN2%)
 END SELECT
END SELECT
END SUB

SUB DrawState (x AS INTEGER, y AS INTEGER, stateNum AS INTEGER, BYVAL direction AS INTEGER)
ss% = Res.States(stateNum).spriteState
direction = direction - 3
IF direction < 0 THEN direction = 0
spriteNum% = Res.SpriteStates(ss%).Sprites(direction)
'LOCATE 10, 10: COLOR 7: PRINT stateNum; spriteNum%; Res.Sprites(spriteNum%).offs
CALL PUT3(x, y, Res.Sprites(spriteNum%).offs)
END SUB

SUB Entity.AddToTile (e AS TEntity, tile AS TTile)
 IF tile.firstEntityNum <> 0 THEN
	e.nextTileEntityNum = tile.firstEntityNum
 END IF

 tile.firstEntityNum = e.entityNum
END SUB

SUB Entity.RemoveFromTile (e AS TEntity, tile AS TTile)

	IF tile.firstEntityNum = e.entityNum THEN
		  tile.firstEntityNum = 0
	END IF

	' e.nextTileEntity...
END SUB

SUB Entity.SetState (e AS TEntity, stateNum AS INTEGER)
	e.stateNum = stateNum
	e.stateFrames = Res.States(stateNum).duration
END SUB

SUB Expman (n, ttx, tty)
SELECT CASE n
CASE 1
FOR z = 1 TO 15
IF ef(z) = 0 THEN GOTO makeexp
NEXT
a(ttx, tty) = 0
EXIT SUB
makeexp:
a(ttx, tty) = 100
ex(z) = ttx: ey(z) = tty
ef(z) = 1
et(z) = 0
CASE 2
DrawGfx 100
END SELECT

END SUB

SUB GambleHolder (n)
'ring
'spike
'jackpot
'sonic
'tails
'bar
tttt$(1) = "o": tttt$(2) = "*": tttt$(3) = "-": tttt$(4) = "SONIC"
tttt$(5) = "TAILS": tttt$(6) = "BAR"

SELECT CASE n
CASE 26
LINE (0, 0)-(320, 11), 0, BF
FOR z = 1 TO 10
tttt1 = INT(RND * 3) + 1: tttt2 = INT(RND * 3) + 1: tttt3 = INT(RND * 3) + 1:
COLOR 6: LOCATE 1, 19: PRINT tttt$(tttt1): LOCATE 1, 20: PRINT tttt$(tttt2): LOCATE 1, 21: PRINT tttt$(tttt3)
SOUND 500, .5: t! = TIMER: WHILE TIMER - t! < .1: WEND
NEXT
SOUND 800, 5
COLOR 14: LOCATE 1, 19: PRINT tttt$(tttt1): LOCATE 1, 20: PRINT tttt$(tttt2): LOCATE 1, 21: PRINT tttt$(tttt3)
LINE (0, 0)-(320, 11), 0, BF
IF tttt1 = 1 AND tttt2 = 1 AND tttt3 = 1 THEN FOR z = 1 TO 125: gotitem 43: NEXT
IF tttt1 = 2 AND tttt2 = 2 AND tttt3 = 2 THEN HitSonic 0
IF tttt1 = 3 AND tttt2 = 3 AND tttt3 = 3 THEN FOR z = 1 TO 25: gotitem 43: NEXT

CASE 27
FOR z = 1 TO 6
score = score + 1000
sfx 11
SetScr
t = TIMER: WHILE TIMER - t < .4: WEND
NEXT
END SELECT

END SUB

SUB gotitem (t)
SELECT CASE t
CASE 38: UpForce = 3: rings = rings + 10: rc = 14: sfx 4: HUD.redraw = 1
CASE 39: UpForce = 3: so = 1: sc = 1: sht! = TIMER: sfx 5: sht2! = TIMER
CASE 40: UpForce = 3: HitSonic 0: sfx 8
CASE 41: UpForce = 3: so = 2: sc = 2: sht! = TIMER: sht2! = TIMER: sfx 7
CASE 42: UpForce = 3: so = 3: sc = 4: sht! = TIMER: sht2! = TIMER: sfx 6

CASE 43
rings = rings + 1: rc = 14: sfx 2
HUD.redraw = 1

CASE 44
sfx 3
IF CDP + 2 > 50 THEN CDP = 48
CDP = CDP + 2
HUD.redraw = 1
END SELECT

END SUB

SUB HitSonic (n)
'EXIT SUB
IF gothit! <> 0 THEN EXIT SUB
IF n = 28 THEN GOTO LHIT
IF n = 31 THEN GOTO EHit
MHIT:
IF so <> 0 THEN so = 0: EXIT SUB
IF rings = 0 THEN Die 1: EXIT SUB
rings = 0
sfx 13:
forcep = 0
SELECT CASE SonicDir
CASE 3  'Facing Left
force$ = "RUURR"
CASE 4
force$ = "LUULL"
END SELECT
gothit! = TIMER: ght! = 0: ghs = 1
HUD.redraw = 1
EXIT SUB

LHIT:
IF so = 3 THEN EXIT SUB
GOTO MHIT

EHit:
IF so = 1 THEN EXIT SUB
GOTO MHIT
END SUB

SUB HitSpring (t, tx, ty)
SELECT CASE t
CASE 17
FOR z = 1 TO nos1
IF spx1(z) = tx AND spy1(z) = ty THEN GOTO hs17
NEXT
EXIT SUB
hs17:
'IF tx > x THEN Player.Rt entities(playerIdx), 2
'IF tx < x THEN Player.Left entities(playerIdx), 2
'IF ty > y THEN Player.Down entities(playerIdx), 2
Player.Up entities(playerIdx), 2
UpForce = 10
s1s(z) = 1: s1t!(z) = TIMER: DrawGfx 17
CASE 18
t18:
FOR z = 1 TO nos2
IF spx2(z) = tx AND spy2(z) = ty THEN GOTO hs18
NEXT
EXIT SUB
hs18:
'IF tx > x THEN Player.Rt entities(playerIdx), 2
'IF tx < x THEN Player.Left entities(playerIdx), 2
'IF ty > y THEN Player.Down entities(playerIdx), 2
Player.Up entities(playerIdx), 2
UpForce = 6
s2s(z) = 1: s2t!(z) = TIMER: DrawGfx 18

CASE 21
t21:
FOR z = 1 TO nof1
IF flx(z) = tx AND fly(z) = ty THEN GOTO hs21
NEXT
EXIT SUB
hs21:
UpForce = 10
SonicMode = 4: SonicFrame = 1
flf(z) = 1: flt!(z) = TIMER: DrawGfx 21
CASE 22
t22:
FOR z = 1 TO nof2
IF frx(z) = tx AND fry(z) = ty THEN GOTO hs22
NEXT
EXIT SUB
hs22:
UpForce = 10
SonicMode = 4: SonicFrame = 1
frf(z) = 1: frt!(z) = TIMER: DrawGfx 21

END SELECT
END SUB

SUB LaserMan ()
FOR z = 1 TO lsrs
 IF laser(z).ldir = 0 AND TIMER - laser(z).et >= 1 THEN GOSUB firelaser
 IF TIMER - laser(z).Lt >= .2 THEN GOSUB movelaser
NEXT
DrawGfx 61
DrawGfx 62

EXIT SUB
firelaser:
 SELECT CASE laser(z).ltype
 CASE 1
 laser(z).ldir = 1: laser(z).lx = laser(z).x: laser(z).ly = laser(z).y - 1
 laser(z).Lt = TIMER: a(laser(z).lx, laser(z).ly) = 62
 CASE 2
 laser(z).ldir = 2: laser(z).lx = laser(z).x: laser(z).ly = laser(z).y + 1
 laser(z).Lt = TIMER: a(laser(z).lx, laser(z).ly) = 62
 CASE 3
 laser(z).ldir = 3: laser(z).lx = laser(z).x - 1: laser(z).ly = laser(z).y
 laser(z).Lt = INT(TIMER): a(laser(z).lx, laser(z).ly) = 61
 CASE 4
 laser(z).ldir = 4: laser(z).lx = laser(z).x + 1: laser(z).ly = laser(z).y
 laser(z).Lt = INT(TIMER): a(laser(z).lx, laser(z).ly) = 61

 END SELECT
temp1 = laser(z).lx: temp2 = laser(z).ly
IF OS(temp1, temp2) = 1 THEN ReDrawObj temp1, temp2, temp1 - strx, temp2 - stry, 0
RETURN

movelaser:
 temp1 = laser(z).lx: temp2 = laser(z).ly
 SELECT CASE laser(z).ldir
 CASE 1
 IF a(laser(z).lx, laser(z).ly - 1) = 1 THEN Expman 1, temp1, temp2: laser(z).ldir = 0: laser(z).et = INT(TIMER): RETURN
 laser(z).ly = laser(z).ly - 1: laser(z).Lt = INT(TIMER)
 a(laser(z).lx, laser(z).ly + 1) = 0
 a(laser(z).lx, laser(z).ly) = 62
 temp1 = laser(z).lx: temp2 = laser(z).ly
 ReDrawObj temp1, temp2 + 1, temp1 - strx, temp2 - stry + 1, 0
 CASE 2
 IF a(laser(z).lx, laser(z).ly + 1) = 1 THEN Expman 1, temp1, temp2: laser(z).ldir = 0: laser(z).et = INT(TIMER): RETURN
 laser(z).ly = laser(z).ly + 1: laser(z).Lt = INT(TIMER)
 a(laser(z).lx, laser(z).ly - 1) = 0
 a(laser(z).lx, laser(z).ly) = 62
 temp1 = laser(z).lx: temp2 = laser(z).ly
 ReDrawObj temp1, temp2 - 1, temp1 - strx, temp2 - stry - 1, 0
 CASE 3
 IF a(laser(z).lx - 1, laser(z).ly) = 1 THEN Expman 1, temp1, temp2: laser(z).ldir = 0: laser(z).et = INT(TIMER): RETURN
 laser(z).lx = laser(z).lx - 1: laser(z).Lt = INT(TIMER)
 a(laser(z).lx + 1, laser(z).ly) = 0
 a(laser(z).lx, laser(z).ly) = 61
 temp1 = laser(z).lx: temp2 = laser(z).ly
 ReDrawObj temp1 + 1, temp2, temp1 - strx + 1, temp2 - stry, 0
 CASE 4
 IF a(laser(z).lx + 1, laser(z).ly) = 1 THEN Expman 1, temp1, temp2: laser(z).ldir = 0: laser(z).et = INT(TIMER): RETURN
 laser(z).lx = laser(z).lx + 1: laser(z).Lt = INT(TIMER)
 a(laser(z).lx - 1, laser(z).ly) = 0
 a(laser(z).lx, laser(z).ly) = 61
 temp1 = laser(z).lx: temp2 = laser(z).ly
 ReDrawObj temp1 - 1, temp2, temp1 - strx - 1, temp2 - stry, 0
 END SELECT
'temp1 = laser(z).lx: temp2 = laser(z).ly

RETURN





END SUB

SUB LevelIntro ()
EXIT SUB
CLS
s1$ = " Rabid Mushroom zone"
s2$ = "1"
s3$ = "Act "
t1 = 0 - LEN(s1$)
BF = 0
t2 = 40
t3 = 25
WHILE BF <> 1
IF t1 + 1 > 9 THEN GOTO npli2
t1 = t1 + 1     'beginning of string x
COLOR 2
FOR z = 1 TO LEN(s1$)        'letter pointer
 IF t1 + z - 1 < 1 THEN GOTO npli1
 LOCATE 10, t1 + z: PRINT MID$(s1$, z, 1)
npli1:
NEXT

npli2:
IF t2 = 14 THEN GOTO npli4
t2 = t2 - 1
COLOR 3
FOR z = 1 TO 4
 IF t2 + z - 1 > 40 THEN GOTO npli3
 LOCATE 11, t2 + z - 1: PRINT MID$(s3$, z, 1)
npli3:
NEXT

npli4:
IF t2 <= 25 THEN
IF t3 = 11 THEN BF = 1: GOTO npli5
t3 = t3 - 1
LOCATE t3, 18: COLOR 14: PRINT s2$;
LOCATE t3 + 1, 18: COLOR 14: PRINT " ";
END IF

npli5:
t! = TIMER: WHILE TIMER - t! < .05: WEND
WEND
t! = TIMER: WHILE TIMER - t! < .3: WEND
COLOR 15: LOCATE 20, 12: PRINT "Cool Sonéc 1"
t! = TIMER: WHILE TIMER - t! < 1: WEND
END SUB

SUB LGFX ()

DEF SEG = VARSEG(GraphicsBuf(0))
BLOAD "datatest.dat", VARPTR(GraphicsBuf(0))

DEF SEG = VARSEG(Res)
BLOAD "res.dat", VARPTR(Res)

DEF SEG
END SUB

SUB LoadLevel (t$)
playerIdx = SpawnEntity(0, 0, -1)
Entity.SetState entities(playerIdx), STATE.PLAYER.WAIT1

passerstate = 0: passerframe = 0
'stat0 = 9295
'IF act = 1 THEN loadtoact
tlsx = 25
x = 0: y = 0

r% = 1
OPEN t$ FOR BINARY AS #1
DO UNTIL EOF(1)
GET #1, , tx: r% = r% + 2
GET #1, , ty: r% = r% + 2
GET #1, , tn: r% = r% + 2
GET #1, , tc: r% = r% + 2

SELECT CASE tn
CASE -1
a(tx, ty) = -1
sx = tx: sy = ty: entities(playerIdx).x = tx: entities(playerIdx).y = ty
ssx = tx: ssy = ty: stax = tx: stay = ty
CASE 0
CASE 1
a(tx, ty) = 1
'p(tx, ty) = tc
Map(tx, ty).tile = 1
Map(tx, ty).color = tc

CASE 10: fp = fp + 1: fpx(fp) = tx: fpy(fp) = ty: a(tx, ty) = tn
CASE 17: nos1 = nos1 + 1: spx1(nos1) = tx: spy1(nos1) = ty: a(tx, ty) = tn
CASE 18: nos2 = nos2 + 1: spx2(nos2) = tx: spy2(nos2) = ty: a(tx, ty) = tn

CASE 2 TO 7, 11, 12, 25 TO 31, 38 TO 42, 44: a(tx, ty) = tn
CASE 8: fs = fs + 1: fsx(fs) = tx: fsy(fs) = ty: a(tx, ty) = tn
CASE 9: afs = afs + 1: afsx(afs) = tx: afsy(afs) = ty: a(tx, ty) = tn
CASE 32: fc = fc + 1: fcx(fc) = tx: fcy(fc) = ty: a(tx, ty) = tn
CASE 33: fw = fw + 1: fwx(fw) = tx: fwy(fw) = ty: a(tx, ty) = tn
CASE 34: a(tx, ty) = 34: lsrs = lsrs + 1: laser(lsrs).x = tx: laser(lsrs).y = ty: laser(lsrs).ltype = 1
CASE 35: a(tx, ty) = 35: lsrs = lsrs + 1: laser(lsrs).x = tx: laser(lsrs).y = ty: laser(lsrs).ltype = 2
CASE 36: a(tx, ty) = 36: lsrs = lsrs + 1: laser(lsrs).x = tx: laser(lsrs).y = ty: laser(lsrs).ltype = 3
CASE 37: a(tx, ty) = 37: lsrs = lsrs + 1: laser(lsrs).x = tx: laser(lsrs).y = ty: laser(lsrs).ltype = 4

CASE 43:
	a = SpawnEntity(tx, ty, 43)
	IF a <> -1 THEN Entity.SetState entities(a), STATE.RING1

CASE 13
a(tx, ty) = tn
INPUT #1, tcm
INPUT #1, m(tcm).x1, m(tcm).y1, m(tcm).x2, m(tcm).y2
IF tcm > cm THEN cm = tcm
CASE 21: nof1 = nof1 + 1: flx(nof1) = tx: fly(nof1) = ty: a(tx, ty) = tn
CASE 22: nof2 = nof2 + 1: frx(nof2) = tx: fry(nof2) = ty: a(tx, ty) = tn

'********************
CASE 70
bcnt(2) = bcnt(2) + 1: rm(bcnt(2)).x = tx: rm(bcnt(2)).y = ty
rm(bcnt(2)).STATE = 2
rm(bcnt(2)).f1 = 0
rm(bcnt(2)).t = INT(TIMER)
a(tx, ty) = tn

CASE 71              'Mosquitoes
bcnt(1) = bcnt(1) + 1
mosqu(1).last = mosqu(1).last + 1

GET #1, , temp

GET #1, , mosqu(bcnt(1)).x1
GET #1, , mosqu(bcnt(1)).y1
GET #1, , mosqu(bcnt(1)).x2
GET #1, , mosqu(bcnt(1)).y2

	a = SpawnEntity(tx, ty, 72)
	IF a <> -1 THEN
		Entity.SetState entities(a), STATE.MOSQU.IDLE
		entities(a).idx = bcnt(1)
	END IF

IF tx > mosqu(bcnt(1)).x2 THEN
	mosqu(bcnt(1)).f1 = 1
ELSE
	mosqu(bcnt(1)).f1 = 2
END IF

mosqu(bcnt(1)).x = mosqu(bcnt(1)).x1
mosqu(bcnt(1)).y = mosqu(bcnt(1)).y1
mosqu(bcnt(1)).STATE = 1
mosqu(bcnt(1)).step = 2


CASE 72  ' BPOT
	a = SpawnEntity(tx, ty, 72)
	IF a <> -1 THEN Entity.SetState entities(a), STATE.BPOT_IDLE

bcnt(3) = bcnt(3) + 1
bpot(bcnt(3)).x = tx
bpot(bcnt(3)).y = ty
bpot(bcnt(3)).STATE = 1
bpot(bcnt(3)).f1 = 1: bpot(bcnt(3)).f2 = 0
bpot(bcnt(3)).t = INT(TIMER)

CASE 103
	passx = tx: passy = ty: a(tx, ty) = tn
END SELECT

'COLOR 7: LOCATE 1, 1: PRINT "Loading..."
'LINE (74, 95)-(127, 105), 10, B
'LINE (74 + ty, 96)-(74 + ty, 104), 2
'DrawLoadScene ty * 5
LOOP
CLOSE

strx = 0: stry = 0
LavaTimer! = TIMER
PlatDo 1
GameTime = INT(TIMER)
END SUB

SUB MainLoop ()
m:

a$ = INKEY$

FOR i = 0 TO 1: WAIT &H3DA, 8: WAIT &H3DA, 8, 8: NEXT

'IF a$ = CHR$(0) + "M" THEN Rt 1
'IF INP(96) = 77 AND force$ = "" THEN Player.Rt entities(playerIdx), 1
'IF INP(96) = 75 AND force$ = "" THEN Player.Left entities(playerIdx), 1

IF a$ = "\" THEN HitSonic 0
'IF a$ = CHR$(0) + "K" THEN Lt 1
IF a$ = CHR$(0) + "P" THEN DnS
'IF a$ = " " THEN Jump
IF INP(96) = 57 THEN Player.Jump entities(playerIdx)
IF a$ = "0" THEN
		SCREEN 0: WIDTH 80: SYSTEM
END IF

IF UCASE$(a$) = "C" THEN Console
IF a$ = CHR$(13) THEN GOSUB systat
'IF Upforce <> 0 AND TIMER - jt! >= .1 THEN UMan

'IF Upforce = 0 THEN IF ChkAhead(x, y + 1) = 0 AND TIMER - jt! >= .1 THEN dn 1

' Gravity
'IF Upforce = 0 THEN IF ChkAhead(x, y + 1) = 0 THEN Player.Down entities(playerIdx), 1

'IF Upforce <> 0 THEN IF a(x, y + 1) = 25 THEN Upforce = 2
'IF a(x, y + 1) = 11 THEN Player.Left entities(playerIdx), 1
'IF a(x, y + 1) = 12 THEN Player.Rt entities(playerIdx), 1
'IF y + 1 = 55 THEN Die 1

' Landing
'IF UpForce = 0 THEN IF ChkAhead(x, y + 1) = 1 AND SonicMode = 4 THEN SonicMode = 1: s3 = 0: DrawGfx -1

IF tempa = 2 OR tempa = 3 THEN
 IF so <> 2 THEN IF TIMER - brt! >= 1 THEN brt! = TIMER: Breath = Breath - 1
END IF

Player.Update entities(playerIdx)

FOR i = 0 TO 64
	 IF (entities(i).flags AND 1) = 1 THEN
		UpdateEntity entities(i)
	 END IF
NEXT

IF tempa = 26 OR tempa = 27 THEN GambleHolder tempa
Expman 2, 0, 0
AnmMan
SonicMan
PlatDo 2
enemy.mgr
IF force$ <> "" AND TIMER - forcet! > .1 THEN DoForces
IF youaredead THEN IF TIMER - DieTimer! < 8 THEN DoDie
IF youaredead AND TIMER - DieTimer! > 8 THEN Die 2: DieTimer! = 0: force$ = ""

DrawAllScr
IF HUD.redraw THEN
		HUD.redraw = 0
		SetScr
END IF
GOTO m


'***************************************
systat:
LINE (100, 100)-(268, 154), 0, BF: LINE (99, 99)-(269, 155), 15, B
FOR z = 0 TO 54: FOR z2 = 0 TO 168
SELECT CASE a(z2, z)
CASE -1, -2: cc = 14
CASE 0: cc = 0
CASE 1, 10: cc = 3
CASE 2: cc = 1
CASE 3: cc = 12
CASE 4 TO 7: cc = 4
CASE 13: cc = 8
CASE 17, 18: cc = 6
CASE 38, 39, 42, 43, 44: cc = 10
CASE 40: cc = 4
CASE 100: cc = 4
END SELECT
PSET (100 + z2, 100 + z), cc
 cc = 0
 NEXT: NEXT
WHILE INKEY$ <> "": WEND
ff = 0
WHILE INKEY$ = ""
IF ff = 0 THEN ff = 1 ELSE ff = 0
IF ff = 0 THEN PSET (100 + x, 100 + y), 0
IF ff = 1 THEN PSET (100 + x, 100 + y), 14
t! = TIMER: WHILE TIMER - t! <= .5: WEND
WEND
RETURN
'*****************************************
END SUB

SUB message (n, ty, stx, c, ms$)
SELECT CASE n
CASE 1
FOR z = 1 TO 10
IF msg(z).x = -80 THEN GOTO makemsg
NEXT
EXIT SUB
makemsg:
msg(z).y = ty: msg(z).x = 40: msg(z).stopx = stx: msg(z).col = c: msg(z).mes = ms$: msg(z).t = TIMER

CASE 2
FOR z = 1 TO 10
IF msg(z).x <> -80 THEN
 IF TIMER - msg(z).t > .1 THEN
 IF msg(z).x <= 41 AND msg(z).x > 1 THEN
  IF msg(z).x <> msg(z).stopx THEN msg(z).x = msg(z).x - 1
  LOCATE msg(z).y, 40 - (40 - msg(z).x): COLOR msg(z).col: PRINT LEFT$(msg(z).mes, 40 - msg(z).x)
  msg(z).t = TIMER
 ELSE
  IF msg(z).x - 1 < -LEN(msg(z).mes) THEN msg(z).x = -80: GOTO nm
  msg(z).x = msg(z).x - 1
  LOCATE msg(z).y, 1: COLOR 41: PRINT RIGHT$(msg(z).mes, LEN(msg(z).mes) + msg(z).x)
  msg(z).t = TIMER
 END IF
'IF msg(z).x + LEN(msg(z).mes) < 41 THEN LOCATE msg(z).y, msg(z).x + LEN(msg(z).mes)
END IF
END IF
nm:
NEXT

END SELECT

END SUB

FUNCTION OS (tx, ty)
IF tx >= strx AND tx <= strx + 12 THEN
 IF ty >= stry AND ty < stry + 7 THEN
  OS = 1: EXIT FUNCTION
 END IF
END IF



END FUNCTION

SUB PassLevel ()
FOR z = 0 TO 5
 FOR y = 12 TO 212 STEP 5
 LINE (0, y + z)-(320, y + z), 0
 NEXT
t! = TIMER: WHILE TIMER - t! < .1: WEND
NEXT
message 1, 10, 10, 14, "Ring BONUS "
SLEEP
FOR z = 1 TO 35
t! = TIMER: WHILE TIMER - t! < .01: WEND
message 2, 0, 0, 0, ""
NEXT
SLEEP
END SUB

SUB PlatDo (n)
SELECT CASE n
CASE 1        '**************Set up platforms
FOR z = 1 TO cm
 IF m(z).x2 < m(z).x1 THEN m(z).d = 3
 IF m(z).x2 > m(z).x1 THEN m(z).d = 4
 IF m(z).y2 < m(z).y1 THEN m(z).d = 1
 IF m(z).y2 > m(z).y1 THEN m(z).d = 2
 m(z).t = TIMER - .5
 m(z).x = m(z).x1: m(z).y = m(z).y1
 m(z).s = 2
NEXT
EXIT SUB
CASE 2
FOR z = 1 TO cm
 SELECT CASE m(z).d
 CASE 1
 IF m(z).s = 2 THEN IF m(z).y = m(z).y2 THEN m(z).s = 1: m(z).t = TIMER + 1: m(z).d = 2: GOTO NePlat
 IF m(z).s = 1 THEN IF m(z).y = m(z).y1 THEN m(z).s = 2: m(z).t = TIMER + 1: m(z).d = 2: GOTO NePlat
mp1:
IF TIMER - m(z).t < .5 THEN m(z).Mved = 0
IF TIMER - m(z).t >= .5 THEN
 IF a(m(z).x, m(z).y - 1) = -1 THEN Player.Up entities(playerIdx), 1
 m(z).y = m(z).y - 1
 a(m(z).x, m(z).y + 1) = 0: a(m(z).x, m(z).y) = 13
 m(z).t = TIMER
 m(z).Mved = 1
END IF

 CASE 2
 IF m(z).s = 2 THEN IF m(z).y = m(z).y2 THEN m(z).s = 1: m(z).t = TIMER + 1: m(z).d = 1: GOTO NePlat
 IF m(z).s = 1 THEN IF m(z).y = m(z).y1 THEN m(z).s = 2: m(z).t = TIMER + 1: m(z).d = 1: GOTO NePlat
mp2:
IF TIMER - m(z).t < .5 THEN m(z).Mved = 0
IF TIMER - m(z).t >= .5 THEN
 IF a(m(z).x, m(z).y - 1) = -1 THEN Player.Up entities(playerIdx), 1
 m(z).y = m(z).y + 1
 a(m(z).x, m(z).y - 1) = 0: a(m(z).x, m(z).y) = 13
 m(z).t = TIMER
 m(z).Mved = 1
END IF
 '****************
 CASE 3
 IF m(z).s = 2 THEN IF m(z).x = m(z).x2 THEN m(z).s = 1: m(z).t = TIMER + 1: m(z).d = 4: GOTO NePlat
 IF m(z).s = 1 THEN IF m(z).x = m(z).x1 THEN m(z).s = 2: m(z).t = TIMER + 1: m(z).d = 4: GOTO NePlat
mp3:
IF TIMER - m(z).t < .5 THEN m(z).Mved = 0
IF TIMER - m(z).t >= .5 THEN
 'IF a(m(z).x, m(z).y - 1) = -1 THEN Player.Left entities(playerIdx), 1
 m(z).x = m(z).x - 1
 a(m(z).x + 1, m(z).y) = 0: a(m(z).x, m(z).y) = 13
 m(z).t = TIMER
 m(z).Mved = 1
END IF

 CASE 4
 IF m(z).s = 2 THEN IF m(z).x = m(z).x2 THEN m(z).s = 1: m(z).t = TIMER + 1: m(z).d = 3: GOTO NePlat
 IF m(z).s = 1 THEN IF m(z).x = m(z).x1 THEN m(z).s = 2: m(z).t = TIMER + 1: m(z).d = 3: GOTO NePlat
mp4:
IF TIMER - m(z).t < .5 THEN m(z).Mved = 0
IF TIMER - m(z).t >= .5 THEN
 'IF a(m(z).x, m(z).y - 1) = -1 THEN Player.Rt entities(playerIdx), 1
 m(z).x = m(z).x + 1
 a(m(z).x - 1, m(z).y) = 0: a(m(z).x, m(z).y) = 13
 m(z).t = TIMER
 m(z).Mved = 1
END IF
END SELECT
NePlat:

NEXT
END SELECT
FOR z = 1 TO cm
IF m(z).Mved = 1 THEN
ttt1 = m(z).x: ttt2 = m(z).y
IF OS(ttt1, ttt2) = 1 THEN ReDrawObj ttt1, ttt2, ttt1 - strx, ttt2 - stry, 0
IF OS(ttt1 - 1, ttt2) = 1 THEN ReDrawObj ttt1 - 1, ttt2, (ttt1 - 1) - strx, ttt2 - stry, 0
IF OS(ttt1 + 1, ttt2) = 1 THEN ReDrawObj ttt1 + 1, ttt2, (ttt1 + 1) - strx, ttt2 - stry, 0
IF OS(ttt1, ttt2 - 1) = 1 THEN ReDrawObj ttt1, ttt2 - 1, ttt1 - strx, (ttt2 - 1) - stry, 0
IF OS(ttt1, ttt2 + 1) = 1 THEN ReDrawObj ttt1, ttt2 + 1, ttt1 - strx, (ttt2 + 1) - stry, 0
m(z).Mved = 0
END IF
NEXT
END SUB

SUB Player.Down (self AS TEntity, n)

IF self.y + 1 = 55 THEN
 Die 1
 EXIT SUB
END IF

IF n <> 2 THEN IF ChkAhead(self.x, self.y + 1) = 1 THEN s3 = 0: EXIT SUB

' Checks if going underwater
IF tempa = 0 THEN IF a(self.x, self.y + 1) = 2 OR a(self.x, self.y + 1) = 3 THEN sfx 9

Entity.RemoveFromTile self, Map(self.x, self.y)
self.y = self.y + 1
Entity.AddToTile self, Map(self.x, self.y)

IF stry = 0 AND sy < 4 THEN sy = sy + 1: GOTO dnr
IF stry = 48 THEN sy = sy + 1: GOTO dnr
stry = stry + 1

dnr:
jt! = TIMER
sti! = TIMER

END SUB

SUB Player.Jump (self AS TEntity)
IF a(self.x, self.y + 1) = 21 OR a(self.x, self.y + 1) = 22 THEN HitSpring a(self.x, self.y + 1), self.x, self.y + 1: sfx 10: EXIT SUB

IF UpForce = 0 AND ChkAhead(self.x, self.y + 1) = 1 THEN
	sfx 1
	UpForce = 4

	Player.SetMode self, 4
	StartForce = 3
	jt! = TIMER
END IF

END SUB

SUB Player.SetMode (self AS TEntity, mode%)

sti! = TIMER

IF SonicMode = mode% THEN EXIT SUB

SonicMode = mode%
SELECT CASE SonicMode
CASE 1: 'Running
	Entity.SetState self, STATE.PLAYER.RUN1
CASE 2: 'Waiting
	Entity.SetState self, STATE.PLAYER.WAIT1
CASE 3: ' Standing
	Entity.SetState self, STATE.PLAYER.STAND1
CASE 4: ' Spinning
	Entity.SetState self, STATE.PLAYER.SPIN1
END SELECT
END SUB

SUB Player.Touch (self AS TEntity)

FOR i = 0 TO 64
  IF (entities(i).flags AND 1) = 1 THEN
   IF entities(i).x = self.x AND entities(i).y = self.y THEN
	 IF entities(i).t = 43 THEN
		gotitem 43
		Entity.RemoveFromTile entities(i), Map(self.x, self.y)
		entities(i).flags = 0
	 END IF

	 'CALL DrawState(trx, try, entities(i).stateNum, entities(i).direction)
   END IF
  END IF
NEXT i

END SUB

SUB Player.Up (self AS TEntity, n)
IF self.y - 1 = -1 THEN EXIT SUB
IF n <> 2 THEN IF ChkAhead(self.x, self.y - 1) = 1 THEN EXIT SUB
IF tempa = 2 OR tempa = 3 THEN IF a(self.x, self.y - 1) = 0 THEN sfx 9

Entity.RemoveFromTile self, Map(self.x, self.y)
self.y = self.y - 1
Entity.AddToTile self, Map(self.x, self.y)

IF stry = 0 THEN sy = sy - 1: GOTO dnr3
IF stry = 46 THEN
 IF sy <= 4 THEN stry = stry - 1: GOTO dnr3
 IF sy > 4 THEN sy = sy - 1: GOTO dnr3
END IF
stry = stry - 1

dnr3:
'IF tempa = 100 THEN tempa = 0
'a(x, y + 1) = tempa
'tempa = a(x, y)
'a(x, y) = -1

jt! = TIMER
sti! = TIMER

Player.Touch self
END SUB

SUB Player.Update (self AS TEntity)
deltaX% = 0
deltaY% = 0
PlayerWasInAir% = PlayerInAir

IF INP(96) = 77 THEN deltaX% = deltaX% + 1
IF INP(96) = 75 THEN deltaX% = deltaX% - 1

IF UpForce > 0 THEN PlayerInAir = 1

IF ChkAhead(self.x, self.y + 1) = 0 THEN
	PlayerInAir = 1
END IF

IF PlayerInAir THEN
	IF UpForce > 0 THEN
		UpForce = UpForce - 1
		deltaY% = -1
	ELSE deltaY% = 1
	END IF

	IF ChkAhead(self.x, self.y + deltaY%) = 0 THEN
		Entity.RemoveFromTile self, Map(self.x, self.y)
		self.y = self.y + deltaY%
		Entity.AddToTile self, Map(self.x, self.y)
	ELSE
		IF deltaY% > 0 THEN
			 PlayerInAir = 0
		END IF
	END IF
ELSE
END IF

IF deltaX% <> 0 THEN
	IF ChkAhead(self.x + deltaX%, self.y) = 0 THEN
		Entity.RemoveFromTile self, Map(self.x, self.y)
		self.x = self.x + deltaX%
		Entity.AddToTile self, Map(self.x, self.y)
	END IF

	IF deltaX% > 0 THEN self.direction = 4
	IF deltaX% < 0 THEN self.direction = 3
END IF

strx = self.x - 6
IF strx < 0 THEN strx = 0
stry = self.y - 4
IF stry < 0 THEN stry = 0

' SonicMode
' 1 = Running
' 2 = Waiting
' 3 = Standing
' 4 = Spinning (in air, usually)

IF SonicMode = 1 THEN
	IF deltaX% = 0 THEN
		' If we're not in the air and not running, set to standing
		IF PlayerInAir = 0 THEN Player.SetMode self, 3
	END IF
END IF

IF SonicMode = 2 THEN
	IF deltaX% <> 0 THEN
		Player.SetMode self, 1
	END IF
END IF

IF SonicMode = 3 THEN
	IF PlayerInAir = 1 OR deltaX% <> 0 THEN
		Player.SetMode self, 1
	ELSE
		IF TIMER - sti! > 1 THEN
			Player.SetMode self, 2
		END IF
	END IF
END IF

IF SonicMode = 4 THEN
	IF PlayerInAir = 0 THEN
		IF deltaX% <> 0 THEN
			Player.SetMode self, 1
		ELSE
			Player.SetMode self, 3
		END IF
	END IF
END IF

Player.Touch self

END SUB

SUB PUT3 (x AS INTEGER, y AS INTEGER, offs AS INTEGER)
'IF x * 25 + 25 >= 320 THEN EXIT SUB
'IF y * 25 + 12 + 25 >= 200 THEN EXIT SUB
'PUT (x * 24, y * 24 + 12), GraphicsBuf(offs), PSET

PUT2 x * 24, y * 24 + 12, VARSEG(GraphicsBuf(0)), VARPTR(GraphicsBuf(offs))
END SUB

SUB ReDrawAround (tx, ty)
IF OS(tx - 1, ty - 1) = 1 THEN ReDrawObj tx - 1, ty - 1, tx - 1 - strx, ty - 1 - stry, 0
IF OS(tx, ty - 1) = 1 THEN ReDrawObj tx, ty - 1, tx - strx, ty - 1 - stry, 0
IF OS(tx + 1, ty - 1) = 1 THEN ReDrawObj tx + 1, ty - 1, tx + 1 - strx, ty - 1 - stry, 0
IF OS(tx - 1, ty) = 1 THEN ReDrawObj tx - 1, ty, tx - 1 - strx, ty - stry, 0
IF OS(tx + 1, ty) = 1 THEN ReDrawObj tx + 1, ty, tx + 1 - strx, ty - stry, 0

IF OS(tx - 1, ty + 1) = 1 THEN ReDrawObj tx - 1, ty + 1, tx - 1 - strx, ty + 1 - stry, 0
IF OS(tx, ty + 1) = 1 THEN ReDrawObj tx, ty + 1, tx - strx, ty + 1 - stry, 0
IF OS(tx + 1, ty + 1) = 1 THEN ReDrawObj tx + 1, ty + 1, tx + 1 - strx, ty + 1 - stry, 0

END SUB

SUB ReDrawObj (tx, ty, ttx, tty, n)
'IF ttx * 24 <= 295 AND tty * 24 + 12 <= 178 AND ttx > -1 AND tty >= 0 THEN GOTO doredraw ELSE EXIT SUB
IF ttx * 24 > 295 THEN EXIT SUB
IF ttx * 24 + 24 <= 0 THEN EXIT SUB
IF tty * 24 + 12 <= 0 THEN EXIT SUB
IF tty * 24 + 12 + 24 > 180 THEN EXIT SUB

'IF screenmode = 13 THEN
'IF ttx * 24 <= 295 AND tty * 24 + 12 <= 182 AND ttx > -1 AND tty >= 0 THEN OldOnScreen(ttx, tty) = a(tx, ty)
'END IF
'IF screenmode = 12 THEN
'IF ttx * 24 <= 620 AND tty * 24 + 12 <= 300 AND ttx > -1 AND tty >= 0 THEN OldOnScreen(ttx, tty) = a(tx, ty)
'IF ttx * 24 <= 620 AND tty * 24 + 12 <= 300 AND ttx > -1 AND tty >= 0 THEN GOTO doredraw ELSE EXIT SUB
'END IF

'EXIT SUB
'doredraw:

SELECT CASE a(tx, ty)
CASE 0
'LINE (ttx * 24, tty * 24 + 12)-(ttx * 24 + 24, tty * 24 + 12 + 24), 0, BF
'IF ttx * 24 <= 295 AND tty * 24 + 12 <= 178 AND ttx > -1 AND tty >= 0 THEN PUT (ttx * 24, tty * 24 + 12), back%, PSET
'PUT (ttx * 24, tty * 24 + 12), back%, PSET
CALL PUT3(ttx, tty, Res.Sprites(SPRITE.BACK1).offs)
CASE 1: LINE (ttx * 24, tty * 24 + 12)-(ttx * 24 + 23, tty * 24 + 12 + 23), Map(tx, ty).color, BF
CASE 2: LINE (ttx * 24, tty * 24 + 12)-(ttx * 24 + 24, tty * 24 + 12 + 24), 1, BF
CASE 3: LINE (ttx * 24, tty * 24 + 12)-(ttx * 24 + 24, tty * 24 + 12 + 24), 12, BF

END SELECT

EXIT SUB
SELECT CASE a(tx, ty)
CASE -1, -2
'DrawSonic ttx, tty
DrawState ttx, tty, entities(playerIdx).stateNum, entities(playerIdx).stateNum - 3
CASE 0
CASE 1: LINE (ttx * 24, tty * 24 + 12)-(ttx * 24 + 23, tty * 24 + 12 + 23), Map(tx, ty).color, BF
CASE 2: LINE (ttx * 24, tty * 24 + 12)-(ttx * 24 + 24, tty * 24 + 12 + 24), 1, BF
CASE 3: LINE (ttx * 24, tty * 24 + 12)-(ttx * 24 + 24, tty * 24 + 12 + 24), 12, BF
CASE 4: PUT (ttx * 24, tty * 24 + 12), SPIKEUP%, PSET
CASE 5: PUT (ttx * 24, tty * 24 + 12), SPIKEDN%, PSET
CASE 6: PUT (ttx * 24, tty * 24 + 12), SPIKELT%, PSET
CASE 7: PUT (ttx * 24, tty * 24 + 12), SPIKERT%, PSET
CASE 8: PUT (ttx * 24, tty * 24 + 12), FSPIKE%, PSET
CASE 9: PUT (ttx * 24, tty * 24 + 12), AFSPIKE%, PSET
CASE 10: LINE (ttx * 24, tty * 24 + 12)-(ttx * 24 + 24, tty * 24 + 12 + 24), p(tx, ty), BF
CASE 11: PUT (ttx * 24, tty * 24 + 12), MPL%, PSET
CASE 12: PUT (ttx * 24, tty * 24 + 12), MPR%, PSET
CASE 13: PUT (ttx * 24, tty * 24 + 12), MPLAT%, PSET
CASE 21
IF flf(n) = 0 THEN PUT (ttx * 24, tty * 24 + 12), LFLIP1%
IF flf(n) = 1 THEN PUT (ttx * 24, tty * 24 + 12), LFLIP2%
CASE 22
IF frf(n) = 0 THEN PUT (ttx * 24, tty * 24 + 12), RFLIP1%
IF frf(n) = 1 THEN PUT (ttx * 24, tty * 24 + 12), RFLIP2%
CASE 25: PUT (ttx * 24, tty * 24 + 12), BPLAT%, PSET
CASE 26, 27: PUT (ttx * 24, tty * 24 + 12), GAMBLE%, PSET
CASE 28
IF LavaState = 1 THEN PUT (ttx * 24, tty * 24 + 12), LAVA1%, PSET
IF LavaState = 2 THEN PUT (ttx * 24, tty * 24 + 12), LAVA2%, PSET
IF LavaState = 3 THEN PUT (ttx * 24, tty * 24 + 12), LAVA3%, PSET
CASE 29: PUT (ttx * 24, tty * 24 + 12), ELL%, PSET
CASE 30: PUT (ttx * 24, tty * 24 + 12), ELR%, PSET
CASE 31
IF ElState = 1 THEN PUT (ttx * 24, tty * 24 + 12), EL1%, PSET
IF ElState = 2 THEN PUT (ttx * 24, tty * 24 + 12), EL2%, PSET
IF ElState = 3 THEN PUT (ttx * 24, tty * 24 + 12), EL3%, PSET
CASE 32: PUT (ttx * 24, tty * 24 + 12), CFP%, PSET
CASE 33: PUT (ttx * 24, tty * 24 + 12), WFP%, PSET
CASE 34: PUT (ttx * 24, tty * 24 + 12), LUP%, PSET
CASE 35: PUT (ttx * 24, tty * 24 + 12), LDN%, PSET
CASE 36: PUT (ttx * 24, tty * 24 + 12), LLT%, PSET
CASE 37: PUT (ttx * 24, tty * 24 + 12), LRT%, PSET
CASE 38: IF bb = 1 THEN PUT (ttx * 24, tty * 24 + 11), BOXRNG%, PSET ELSE PUT (ttx * 24, tty * 24 + 11), BOXST%, PSET
CASE 39: IF bb = 1 THEN PUT (ttx * 24, tty * 24 + 11), BOXSHI%, PSET ELSE PUT (ttx * 24, tty * 24 + 11), BOXST%, PSET
CASE 40: IF bb = 1 THEN PUT (ttx * 24, tty * 24 + 11), BOXSPI%, PSET ELSE PUT (ttx * 24, tty * 24 + 11), BOXST%, PSET
CASE 41: IF bb = 1 THEN PUT (ttx * 24, tty * 24 + 11), BOXBUB%, PSET ELSE PUT (ttx * 24, tty * 24 + 11), BOXST%, PSET
CASE 42: IF bb = 1 THEN PUT (ttx * 24, tty * 24 + 11), BOXFIR%, PSET ELSE PUT (ttx * 24, tty * 24 + 11), BOXST%, PSET
CASE 61: PUT (ttx * 24, tty * 24 + 12), LHOR%, PSET
CASE 62: PUT (ttx * 24, tty * 24 + 12), LVER%, PSET

CASE 17
IF s1s(n) = 1 THEN PUT (ttx * 24, tty * 24 + 12), SPRINGR2%, PSET
IF s1s(n) = 0 THEN PUT (ttx * 24, tty * 24 + 12), SPRINGR1%, PSET
CASE 18
IF s2s(n) = 1 THEN PUT (ttx * 24, tty * 24 + 12), SPRINGL2%, PSET
IF s2s(n) = 0 THEN PUT (ttx * 24, tty * 24 + 12), SPRINGL1%, PSET
CASE 43
'IF rfr = 1 THEN CALL PUT2(ttx * 24, tty * 24 + 12, FRAME.RING1)
'IF rfr = 2 THEN CALL PUT2(ttx * 24, tty * 24 + 12, FRAME.RING2)
'IF rfr = 3 THEN CALL PUT2(ttx * 24, tty * 24 + 12, FRAME.RING3)
'IF rfr = 4 THEN CALL PUT2(ttx * 24, tty * 24 + 12, FRAME.RING4)
'IF rfr = 5 THEN CALL PUT2(ttx * 24, tty * 24 + 12, FRAME.RING5)
'IF rfr = 6 THEN CALL PUT2(ttx * 24, tty * 24 + 12, FRAME.RING6)
CASE 44
IF cfr = 1 THEN CALL PUT3(ttx, tty, FRAME.CHILI1)
IF cfr = 2 THEN CALL PUT3(ttx, tty, FRAME.CHILI2)
IF cfr = 3 THEN CALL PUT3(ttx, tty, FRAME.CHILI3)
IF cfr = 4 THEN CALL PUT3(ttx, tty, FRAME.CHILI4)
IF cfr = 5 THEN CALL PUT3(ttx, tty, FRAME.CHILI5)
IF cfr = 6 THEN CALL PUT3(ttx, tty, FRAME.CHILI6)
CASE 70
 IF rm(n).STATE = 1 THEN
  IF rm(n).f1 = 2 THEN CALL PUT3(ttx, tty, FRAME.RM2)
  IF rm(n).f1 = 1 THEN CALL PUT3(ttx, tty, FRAME.RM3)
 END IF
 IF rm(n).STATE = 2 THEN CALL PUT3(ttx, tty, FRAME.RM1)
CASE 71
 SELECT CASE mosqu(n).STATE
 CASE 1, 2
  IF mosqu(n).f1 = 1 THEN CALL PUT3(ttx, tty, FRAME.MOSQU1)
  IF mosqu(n).f1 = 2 THEN CALL PUT3(ttx, tty, FRAME.MOSQU2)
 CASE 3, 4, 5
  IF mosqu(n).f2 = 1 THEN CALL PUT3(ttx, tty, FRAME.MOSQU3)
  IF mosqu(n).f2 = 2 THEN CALL PUT3(ttx, tty, FRAME.MOSQU4)
 END SELECT
 

CASE 72:
 CALL PUT3(ttx, tty, frame.p1)
CASE 100
FOR z = 1 TO 15
 IF ef(z) <> 0 THEN
 IF ex(z) = tx AND ey(z) = ty THEN
 IF ef(z) = 1 THEN CALL PUT3(ttx, tty, FRAME.E5)
 IF ef(z) = 2 THEN CALL PUT3(ttx, tty, FRAME.E4)
 IF ef(z) = 3 THEN CALL PUT3(ttx, tty, FRAME.E2)
 IF ef(z) = 4 THEN CALL PUT3(ttx, tty, FRAME.E1)
 END IF
 END IF
NEXT
CASE 103
SELECT CASE passerframe
 CASE 0: PUT (ttx * 24, tty * 24 + 12), PASSER1%, PSET
 CASE 1: PUT (ttx * 24, tty * 24 + 12), PASSER2%, PSET
 CASE 2: PUT (ttx * 24, tty * 24 + 12), PASSER3%, PSET
END SELECT
IF passerspin = 1 THEN PUT (ttx * 24, tty * 24 + 12), PASSER4%, PSET
END SELECT

END SUB

SUB SetScr ()

' HUD Updates
IF rings = 0 AND TIMER - rf! >= .4 THEN
 IF rc = 14 THEN rc = 4 ELSE rc = 14
 rf! = TIMER
END IF

' Draw HUD

LINE (270, 0)-(270 + CDP, 5), 6, BF
LINE (0, 11)-(320, 11), 9
LOCATE 1, 1: COLOR rc: PRINT "RINGS:"; rings
IF Breath <= 15 AND tempa <> 0 THEN COLOR 9: LOCATE 1, 14: PRINT "Breath:"; Breath
IF so = 2 THEN Breath = 99
IF Breath = 0 THEN Die 1: Breath = 99: LOCATE 1, 14: PRINT "           ": EXIT SUB
'IF tempa = 0 THEN LOCATE 1, 14: PRINT "             ": Breath = 99
LOCATE 25, 1: COLOR 9: PRINT "Score:"; score;
LOCATE 25, 20: PRINT "Time"; 360 - INT((TIMER - GameTime));

' Chili dog power
LINE (270, 0)-(270 + CDP, 5), 6, BF

END SUB

SUB sfx (n)
IF n = 9 THEN Breath = 15: brt! = TIMER
'IF sfxf = 0 THEN EXIT SUB
SELECT CASE n
CASE 1: PLAY "mb t255l64 n30n32n34n36n38n40t120" 'Jump
CASE 2: IF PLAY(n) = 0 THEN PLAY "MB O4 L32CEL8G"  'Ring
CASE 3: IF PLAY(n) = 0 THEN PLAY "mb o0 t255l64 n0n1n2n3n4n5n6n7n8n9n10t120" 'Chilidog
CASE 4: PLAY "mbl64t255n37n38n39n40n38n36n34n32n30t120O4 L32CEL8G" 'RingBox
CASE 5: PLAY "mbl64t255n37n38n39n40n38n36n34n32n30 t255 l64o0 n1n2n3n4n5n6n7n8n7n6n5t120l8n4" 'shield
CASE 6: PLAY "mbl64t255n37n38n39n40n38n36n34n32n30 t255 l64o0 n1n2n1n3n1n4n1n5n1n6n1n7n1n8n1t120l16n3" 'fire
CASE 7: PLAY "mbl64t255n37n38n39n40n38n36n34n32n30"
PLAY "t255 l64 n5n6n7n8n9n10n11n12n13n14n15n8n9n10n11n12n13n14n15n10n11n12n13n14n15"
PLAY "n12n13n14n15n14n15n20t120" 'bub
CASE 8: PLAY "mbl64t255n37n38n39n40n38n36n34n32n30t255l64n42n46n24n22n12n6n55n16n43n55t120" 'spikes
CASE 9: PLAY "t255 l64 n0n81o0n81n0n81n0n81"
CASE 10: PLAY "mb o0 t255 l16 gl64cc+dd+ef+gg+aa+bo1cc+dd+t120" 'Flipper
CASE 11: PLAY "mbt255l64 o3gggggp64ggggp64ggggp64ggp64gt120"'Points
CASE 12: PLAY "mbl64t255n37n38n39n40n38n36n34n32n30t120" 'explode
CASE 13: PLAY "o4mbl50ecgcecgeGcececgg"                 'lose rings

END SELECT

END SUB

SUB SonicMan ()
IF gothit! <> 0 AND TIMER - gothit! < 3 THEN
 ght! = ght! + 1
 IF ght! >= 10 THEN
  IF ghs = 1 THEN ghs = 2 ELSE ghs = 1
  ght! = 0: DrawGfx -1
 END IF
ELSE
gothit! = 0: ghs = 0
END IF
EXIT SUB
IF SonicMode = 1 THEN
 ' Go to Standing
 IF TIMER - sti! >= 1 THEN
		entities(playerIdx).stateNum = STATE.PLAYER.STAND1
		SonicMode = 3
		sti! = TIMER
 END IF
END IF

IF SonicMode = 3 THEN
 ' Standing, Go to waiting?
 IF TIMER - sti! >= 2 THEN
		entities(playerIdx).stateNum = STATE.PLAYER.WAIT1

		SonicMode = 2
		
		sti! = TIMER
 END IF
END IF

IF SonicMode = 2 THEN
 ' Waiting
 'IF TIMER - sti! >= .5 THEN
 'IF SonicFrame = 1 THEN SonicFrame = 2 ELSE SonicFrame = 1
 'sti! = TIMER: DrawGfx -1: REM DrawGFX 1: EXIT SUB
 'END IF
END IF
SELECT CASE so
CASE 1
IF TIMER - sht! >= .2 THEN sht! = TIMER: IF sc = 1 THEN sc = 9 ELSE sc = 1
CIRCLE (sx * 24 + 12, sy * 24 + 12 + 11), 12, sc
CASE 2
IF TIMER - sht! >= .2 THEN sht! = TIMER: IF sc = 2 THEN sc = 10 ELSE sc = 2
CIRCLE (sx * 24 + 12, sy * 24 + 12 + 11), 12, sc
CASE 3
IF TIMER - sht! >= .2 THEN sht! = TIMER: IF sc = 4 THEN sc = 12 ELSE sc = 4
CIRCLE (sx * 24 + 12, sy * 24 + 12 + 11), 12, sc
END SELECT
END SUB

FUNCTION SpawnEntity% (x AS INTEGER, y AS INTEGER, entityType AS INTEGER)
SpawnEntity% = -1

DIM i AS INTEGER

FOR i = 1 TO 64
		
		IF (entities(i).flags AND 1) = 0 THEN
				entities(i).x = x
				entities(i).y = y
				entities(i).entityNum = i
				entities(i).flags = 1
				entities(i).stateNum = STATE.NONE
				entities(i).stateFrames = 60
				entities(i).t = entityType

				Entity.AddToTile entities(i), Map(x, y)

				SpawnEntity% = i
				EXIT FUNCTION
		END IF
NEXT i
END FUNCTION

SUB StateFunc (self AS TEntity)
DIM i, nextX, nextY AS INTEGER

SELECT CASE Res.States(self.stateNum).func
CASE 1:
 IF ChkAhead(self.x, self.y - 1) = 0 THEN
  Entity.RemoveFromTile self, Map(self.x, self.y)
  self.y = self.y - 1
  Entity.AddToTile self, Map(self.x, self.y)
 END IF
CASE 2:
 IF ChkAhead(self.x, self.y + 1) = 0 THEN
  Entity.RemoveFromTile self, Map(self.x, self.y)
  self.y = self.y + 1
  Entity.AddToTile self, Map(self.x, self.y)
 END IF
CASE 3:
 ' Mosquito Patrol

 i = self.idx

 IF mosqu(i).step = 2 THEN
  nextX = mosqu(i).x2
 ELSE
  nextX = mosqu(i).x1
 END IF

 Entity.RemoveFromTile self, Map(self.x, self.y)

 IF nextX < self.x THEN
	self.x = self.x - 1
	self.direction = 3
 ELSE
	self.x = self.x + 1
	self.direction = 4
 END IF
 Entity.AddToTile self, Map(self.x, self.y)

 IF self.x = nextX THEN
	IF mosqu(i).step = 2 THEN mosqu(i).step = 1 ELSE mosqu(i).step = 2
 END IF

 IF self.x = entities(playerIdx).x AND self.y - entities(playerIdx).y < 10 THEN
	Entity.SetState self, STATE.MOSQU.ATTACK1
 END IF

CASE 4:
	' Mosquito moving down
	IF ChkAhead(self.x, self.y + 1) = 0 THEN
		Entity.RemoveFromTile self, Map(self.x, self.y)
		self.y = self.y + 1
		Entity.AddToTile self, Map(self.x, self.y)
	ELSE
		Entity.SetState self, STATE.MOSQU.ATTACK4
	END IF
END SELECT

END SUB

SUB Tman ()
FOR z = 1 TO afs
 IF afss(z) = 0 THEN IF afsx(z) - x = 1 OR afsx(z) - x = -1 THEN afss(z) = 1: GOTO nafs
 IF afss(z) = 1 THEN GOSUB fg
nafs:
NEXT
GOTO fs2
fg:
IF afss(z) = 3 THEN RETURN
IF afsx(z) = x AND afsy(z) + 1 = y THEN Die 1: RETURN
IF afsy(z) + 1 = 55 THEN afss(z) = 3: DrawGfx 9: RETURN
IF a(afsx(z), afsy(z) + 1) = 1 THEN afss(z) = 3: DrawGfx 9: RETURN
afsy(z) = afsy(z) + 1
a(afsx(z), afsy(z) - 1) = 0
a(afsx(z), afsy(z)) = 9
IF OS(afsx(z), afsy(z)) = 1 THEN ReDrawObj afsx(z), afsy(z), afsx(z) - strx, afsy(z) - stry, 0
ReDrawObj afsx(z), afsy(z) - 1, afsx(z) - strx, afsy(z) - stry - 1, 0
RETURN
fs2:
FOR z = 1 TO fs
 IF fss(z) = 0 THEN IF fsx(z) = x AND fsy(z) - y = 1 THEN fss(z) = 1: GOTO nfs
 IF fss(z) = 1 THEN GOSUB fg2
nfs:
NEXT
GOTO fpp
fg2:
IF fss(z) = 3 THEN RETURN
IF fsx(z) = x AND fsy(z) + 1 = y THEN Die 1: RETURN
IF fsy(z) + 1 = 55 THEN fss(z) = 3: DrawGfx 8: RETURN
IF a(fsx(z), fsy(z) + 1) = 1 THEN fss(z) = 3: DrawGfx 8: RETURN
fsy(z) = fsy(z) + 1
a(fsx(z), fsy(z) - 1) = 0
a(fsx(z), fsy(z)) = 8
IF OS(fsx(z), fsy(z)) = 1 THEN ReDrawObj fsx(z), fsy(z), fsx(z) - strx, fsy(z) - stry, 0
ReDrawObj fsx(z), fsy(z) - 1, fsx(z) - strx, fsy(z) - stry - 1, 0

RETURN

fpp:
FOR z = 1 TO fp
 IF fps(z) = 0 THEN IF fpx(z) = x AND fpy(z) - y = 1 THEN fps(z) = 1: GOTO nfp
 IF fps(z) = 1 THEN GOSUB fp2
nfp:
NEXT
GOTO fcc
fp2:
IF fps(z) = 3 THEN RETURN
IF fpx(z) = x AND fpy(z) + 1 = y THEN Die 1: RETURN
IF fpy(z) + 1 = 55 THEN fps(z) = 3: DrawGfx 10: RETURN
IF a(fpx(z), fpy(z) + 1) = 1 THEN fps(z) = 3: DrawGfx 10: RETURN
fpy(z) = fpy(z) + 1
tp = p(fpx(z), fpy(z) - 1)
a(fpx(z), fpy(z) - 1) = 0: p(fpx(z), fpy(z) - 1) = 0
a(fpx(z), fpy(z)) = 10: p(fpx(z), fpy(z)) = tp
IF OS(fpx(z), fpy(z)) = 1 THEN ReDrawObj fpx(z), fpy(z), fpx(z) - strx, fpy(z) - stry, 0
ReDrawObj fpx(z), fpy(z) - 1, fpx(z) - strx, fpy(z) - stry - 1, 0
RETURN

fcc:
FOR z = 1 TO fc
 IF fcs(z) = 0 THEN IF fcx(z) = x AND fcy(z) - y = 1 THEN fcs(z) = 1: GOTO ncp
 IF fcs(z) = 1 THEN GOSUB fc2
ncp:
NEXT
GOTO fww
fc2:
IF fcs(z) = 3 THEN RETURN
IF fcx(z) = x AND fcy(z) + 1 = y THEN Die 1: RETURN
IF fcy(z) + 1 = 55 THEN fcs(z) = 3: DrawGfx 32: RETURN
IF a(fcx(z), fcy(z) + 1) = 1 THEN fcs(z) = 3: DrawGfx 32: RETURN
fcy(z) = fcy(z) + 1
a(fcx(z), fcy(z) - 1) = 0
a(fcx(z), fcy(z)) = 32
IF OS(fcx(z), fcy(z)) = 1 THEN ReDrawObj fcx(z), fcy(z), fcx(z) - strx, fcy(z) - stry, 0
ReDrawObj fcx(z), fcy(z) - 1, fcx(z) - strx, fcy(z) - stry - 1, 0
RETURN

fww:
FOR z = 1 TO fw
 IF fws(z) = 0 THEN IF fwx(z) = x AND fwy(z) - y = 1 THEN fws(z) = 1: GOTO nwp
 IF fws(z) = 1 THEN GOSUB fw2
nwp:
NEXT
EXIT SUB
fw2:
IF fws(z) = 3 THEN RETURN
IF fwx(z) = x AND fwy(z) + 1 = y THEN Die 1: RETURN
IF fwy(z) + 1 = 55 THEN fws(z) = 3: DrawGfx 33: RETURN
IF a(fwx(z), fwy(z) + 1) = 1 THEN fws(z) = 3: DrawGfx 33: RETURN
fwy(z) = fwy(z) + 1
a(fwx(z), fwy(z) - 1) = 0
a(fwx(z), fwy(z)) = 33
IF OS(fwx(z), fwy(z)) = 1 THEN ReDrawObj fwx(z), fwy(z), fwx(z) - strx, fwy(z) - stry, 0
ReDrawObj fwx(z), fwy(z) - 1, fwx(z) - strx, fwy(z) - stry - 1, 0
RETURN

END SUB

SUB UpdateEntity (self AS TEntity)
		IF self.stateNum = 0 THEN EXIT SUB
		self.stateFrames = self.stateFrames - 1
		IF self.stateFrames = 0 THEN
			  self.stateNum = Res.States(self.stateNum).nextState
			  self.stateFrames = Res.States(self.stateNum).duration

			  StateFunc self

		END IF
END SUB

