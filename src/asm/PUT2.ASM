.model medium, basic

.286

.STACK 100h

.data

include asm.inc

srcSkip dw ?
destSkip dw ?

.code

; PUTEXIMPL(x, y, width, height, srcStartX, srcStartY, imageSeg, imageOffs)

; 22 srcSkip
; 20 x
; 18 y
; 16 width
; 14 height
; 12 imageSeg
; 10 imageOffs
; 08 basic seg
; 06 basic offs
; 04 ds
; 02 si
; 00 bp

public PUTEXIMPL
PUTEXIMPL proc far

        cld
        push ds
        push si
        push bp
        mov bp, sp

        ; Set ES:DI (destination)

        mov ax, screenBufferSeg
        mov es, ax

        mov ax, [bp + 18]               ; Set DI (destination)
        shl ax, 8
        mov bx, [bp + 18]
        shl bx, 6
        add ax, bx
        mov bx, [bp + 20]               ; add x
        add ax, bx
        ;add ax, screenBufferOffs
        mov di, ax

        ; dx: Destination skip
        mov dx, 320                     ; dest skip = 320 - width
        mov bx, [bp + 16]
        sub dx, bx

        ; Set DS:SI (source)
        mov bx, [bp + 12]
        mov ds, bx
        mov bx, [bp + 10]
        mov si, bx

        ; si = offs + 4 + srcStartY * spriteWidth + srcStartX

        mov bx, [bp + 14]
        mov cx, bx               ; Row counter

puteximpl_loop_row:
        push cx
        ;mov bx, [bp + 16]
        ;mov cx, bx               ; Column counter

        mov cx, [bp + 16]

puteximpl_loop_col:

        ;mov al, 9
        ;rep stosb
        rep movsb

        ;loop puteximpl_loop_col

        add di, dx                      ; Add dest skip
        add si, [bp + 22]               ; Add src skip

        pop cx
        loop puteximpl_loop_row

        pop bp
        pop si
        pop ds
        ret 14
PUTEXIMPL endp
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

        ;mov ax, 0a000h                  ; Set ES
        mov ax, screenBufferSeg
        mov es, ax
 
        mov ax, [bp + 14]               ; Set DI (destination)
        shl ax, 8
        mov bx, [bp + 14]
        shl bx, 6
        add ax, bx
        mov bx, [bp + 16]
        add ax, bx
        ;add ax, screenBufferOffs
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

END