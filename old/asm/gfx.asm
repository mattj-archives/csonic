.model medium, basic

.286

.STACK 100h

.data

include asm.inc

.code

; 08 - screen buffer seg
; 06 - screen buffer offs
; 04 - basic seg
; 02 - basic offs
; 00 - bp

public GFXLIBINIT
GFXLIBINIT proc far
	    push bp
	    mov bp, sp

	    mov bx, [bp + 8]
	    mov screenBufferSeg, bx

	    mov bx, [bp + 6]
	    mov screenBufferOffs, bx

	    pop bp
		ret 4
GFXLIBINIT endp


public SWAPBUFFERS
SWAPBUFFERS proc far
	push ds

		; Set ES:DI (destination)

	    mov ax, 0a000h                  
		mov es, ax
		mov di, 0

		; Set DS:SI (src)

		mov ax, screenBufferSeg
		mov ds, ax

		mov si, 0

		mov cx, 32000
		rep movsw
	pop ds

	ret
SWAPBUFFERS endp

END
