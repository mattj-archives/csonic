.model medium, basic

.286

.STACK 100h

.data

public screenBufferSeg, screenBufferOffs
public oldHandlerSeg, oldHandlerOff
public kbdArraySeg, kbdArrayOff

public kbdArray

oldHandlerSeg dw      ?
oldHandlerOff dw      ?

kbdArray     DB  128 dup(0)

kbdArraySeg		dw		?
kbdArrayOff		dw		?

prevStateArraySeg      dw      ?
prevStateArrayOff      dw      ?

spriteHeight dw ?
spriteWidth dw ?

screenBufferSeg         dw      ?
screenBufferOffs        dw      ?

END