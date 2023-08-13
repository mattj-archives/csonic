.model medium, basic
.286

.STACK 100h

.data

oldHandlerSeg dw      ?
oldHandlerOff dw      ?

kbdArray     DB  128 dup(0)

kbdArraySeg		dw		?
kbdArrayOff		dw		?

prevStateArraySeg      dw      ?
prevStateArrayOff      dw      ?

spriteHeight dw ?
spriteWidth dw ?

.code

; https://github.com/VincentDS/Assembly-Breakout/blob/master/KEYB.ASM
; https://stackoverflow.com/questions/10524855/how-to-check-keys-status-in-x86-assembly

keyboardHandler	proc
		push ax
		push bx
		push ds
                push si
		
                ;mov bx, kbdArraySeg
                ;mov ds, bx

                in al, 60h
                xor ah, ah
                mov si, ax

                in al, 61h
                or al, 80h
                out 61h, al

                mov al, 20h
                out 20h, al

                cmp al, 7fh
                test si, 128
                jnz release

                ;shl al, 1
                ;mov bx, ax
                ;mov al, 1
                ;mov [bx], al

                mov bl, 1
                jmp keyboardHandler_done2

release:
                and si, 127
                xor bl, bl
                ;and al, 7fh
                ;shl al, 1
                ;mov bx, ax
                ;mov al, 0
                ;mov [bx], al

keyboardHandler_done2:
                mov ax, @DATA
                mov ds, ax
                mov kbdArray[si], bl


                pop si
                pop ds
                pop bx
                pop ax
                
		iret

keyboardHandler endp


public GetKey
GetKey proc far


mov cx, bp                           ; the key state of a
  mov bp,sp                            ; given key scancode
  mov si,[bp+4]                        ;
  mov al, kbdArray[si]                ; A list of scancodes is available
  xor ah, ah                           ; in the QB help
  mov bp, cx
  ret 2
GetKey  endp

public ClearScreen
ClearScreen proc far
        cld
        mov ax, 0a000h
        mov es, ax
        mov di, 0
        mov ax, 0
        mov cx, 1440
        rep stosw
        ret
; 16 x
; 14 y
; 12 image seg?
; 10 image offs?
; 08 basic segment
; 06 basic offset
; 04 ds
; 02 si
; 00 bp
        public PUT2
PUT2 proc far
        
        cld
        push ds
        push si
        push bp
        mov bp, sp

        mov ax, 0a000h                  ; Set ES
        mov es, ax
 
        mov ax, [bp + 14]               ; Set DI (destination)
        shl ax, 8
        mov bx, [bp + 14]
        shl bx, 6
        add ax, bx
        mov bx, [bp + 16]
        add ax, bx
        mov di, ax

        ; lodsw, lodsb: ds:si 

        mov bx, [bp + 12]                ; Set DS
        mov ds, bx
        ;mov si, [bp + 10]
        mov bx, [bp + 10]                ; Set SI (source)
        mov si, bx

        lodsw
        shr ax, 3
        push ax                 ; Push sprite width onto stack
        mov dx, 320          
        sub dx, ax

        lodsw                   ; Load sprite height                 
        mov cx, ax

        pop bx                  ; bx = sprite width            

loop_row:
        push cx
        mov cx, bx
        rep movsb
        

;loop_col:
;        lodsb
;        cmp al, 0
;        jnz write_pixel
;        inc di
;        jmp loop_col_done
;write_pixel:
;        stosb  
;loop_col_done:    
;        loop loop_col

        
        ; increment di by 320 - width
        add di, dx
        ;add di, 312

        pop cx
        loop loop_row


        pop bp
        pop si
        pop ds
        
        ret 8   ; pop 4 params and return   
PUT2 endp   
;-----------------------------------------------------------------------------
; KeyboardLibInit
;-----------------------------------------------------------------------------
;
; Params:
; [bp + 8] segment of scan code array (By value)
; [bp + 6] offset of scan code array (By value)

; 16 - array seg
; 14 - array offs
; 12 - basic
; 10 - basic
; 08 - ds
; 06 - es
; 04 - si
; 02 - di
; 00 - bp
        public  KEYBOARDLIBINIT
keyboardLibInit         proc    far
		
        ;push    bp
        ;mov     bp,sp
        ;push    ds
        ;push    es
        ;push    si
        ;push    di                      ;preserve registers

        push    ds
        push    es
        push    si
        push    di                      ;preserve registers
        push    bp
        mov     bp,sp

        mov     bx,[bp + 16]             ;Array segment (was 12)
        mov     kbdArraySeg,bx

        mov     bx,[bp + 14]             ;Array offset (was 10)
        mov     kbdArrayOff,bx

        ;mov     bx,[bp + 8]             ;Prev array segment
        ;mov     prevStateArraySeg,bx

        ;mov     bx,[bp + 6]             ;Prev array offset
        ;mov     prevStateArrayOff,bx


	mov		ax, 3509h				;Get interrupt handler to ES:BX
	int 	21h

	mov		ax, es
	mov		oldHandlerSeg, ax
	mov		oldHandlerOff, bx

        pop bp
        pop di
        pop si
        pop es
        pop ds
        ret 4

keyboardLibInit         endp

;-----------------------------------------------------------------------------
; KeyboardLibEnable
;-----------------------------------------------------------------------------
        public  KEYBOARDENABLE
keyboardEnable         proc    far
        push    bp
        mov     bp,sp
        push    ds
        push    es
        push    si
        push    di                      ;preserve registers

		; Set new handler

		mov		ax, cs
		mov		ds, ax					
		mov		dx, offset keyboardHandler
		mov		ax, 2509h
		int 	21h						; Set handler to DS:DX

        pop     di
        pop     si
        pop     es
        pop     ds
        pop     bp                      ;restore registers
        ret     0
keyboardEnable 		endp


;-----------------------------------------------------------------------------
; KeyboardLibDisable
;-----------------------------------------------------------------------------
        public  KEYBOARDDISABLE
keyboardDisable         proc    far
        push    bp
        mov     bp,sp
        push    ds
        push    es
        push    si
        push    di                      ;preserve registers

		; Set new handler

		mov		ax, oldHandlerSeg
		mov		dx, oldHandlerOff
		mov		ds, ax					
		mov		ax, 2509h
		int 	21h						; Set handler to DS:DX

        ; Clear keyboard array

        mov ax, SEG kbdArray
        mov di, OFFSET kbdArray
        mov es, ax
        mov cx, 128
        xor ax, ax
        rep stosb

        pop     di
        pop     si
        pop     es
        pop     ds
        pop     bp                      ;restore registers
        ret     0
keyboardDisable 		endp

;-----------------------------------------------------------------------------
; FOO test
;-----------------------------------------------------------------------------
        public  GETHANDLERSEG
getHandlerSeg         proc    far
        push    bp
        mov     bp,sp
        push    ds
        push    es
        push    si
        push    di                      ;preserve registers


		mov		ax, oldHandlerSeg
		
        pop     di
        pop     si
        pop     es
        pop     ds
        pop     bp                      ;restore registers
        ret     0
getHandlerSeg 		endp
;-----------------------------------------------------------------------------
        public  GETHANDLEROFF
getHandlerOff         proc    far
        push    bp
        mov     bp,sp
        push    ds
        push    es
        push    si
        push    di                      ;preserve registers

		mov		ax, oldHandlerOff
		
        pop     di
        pop     si
        pop     es
        pop     ds
        pop     bp                      ;restore registers
        ret     0
getHandlerOff 		endp
END
