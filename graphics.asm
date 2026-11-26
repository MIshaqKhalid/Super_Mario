; Software renderer. All primitives clip before touching the frame buffer.

; ClearFrame(colour): block-fill 64,000 bytes. Outputs: buffer. Registers saved.
ClearFrame:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    mov es, [buffer_segment]
    xor di, di
    mov ax, [bp+4]
    mov ah, al
    mov cx, FRAME_BYTES/2
    cld
    rep stosw
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 2

; PresentFrame(): one REP MOVSW upload to A000h. All registers preserved.
PresentFrame:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    mov ax, VGA_SEG
    mov es, ax
    mov ds, [buffer_segment]
    xor si, si
    xor di, di
    mov cx, FRAME_BYTES/2
    cld
    rep movsw
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; PutPixel(x,y,colour): signed clipping; offset = y*256 + y*64 + x.
; Outputs: one buffer pixel if visible. Registers preserved.
PutPixel:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    mov bx, [bp+4]
    cmp bx, SCREEN_W
    jae .done
    mov ax, [bp+6]
    cmp ax, SCREEN_H
    jae .done
    mov di, ax
    mov cl, 8
    shl di, cl
    mov cl, 6
    shl ax, cl
    add di, ax
    add di, bx
    mov es, [buffer_segment]
    mov ax, [bp+8]
    mov [es:di], al
.done:
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 6

; FillRect(x,y,width,height,colour): clip rectangle then fill horizontal spans.
; Inputs: signed origin, positive size. Outputs: buffer. Registers preserved.
FillRect:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    mov bx, [bp+4]
    mov dx, [bp+6]
    mov si, [bp+8]
    mov di, [bp+10]
    or si, si
    jle .done
    or di, di
    jle .done
    cmp bx, 0
    jge .clip_y
    add si, bx
    xor bx, bx
.clip_y:
    cmp dx, 0
    jge .right
    add di, dx
    xor dx, dx
.right:
    mov ax, SCREEN_W
    sub ax, bx
    jle .done
    cmp si, ax
    jle .bottom
    mov si, ax
.bottom:
    mov ax, SCREEN_H
    sub ax, dx
    jle .done
    cmp di, ax
    jle .validate
    mov di, ax
.validate:
    or si, si
    jle .done
    or di, di
    jle .done
    mov ax, dx
    mov cx, 320
    mul cx
    add ax, bx
    mov bx, di
    mov di, ax
    mov dx, 320
    sub dx, si
    mov es, [buffer_segment]
    mov ax, [bp+12]
    cld
.row:
    mov cx, si
    rep stosb
    add di, dx
    dec bx
    jnz .row
.done:
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 10

; DrawSprite(x,y,bitmap,flags): 16-wide indexed artwork, '0'..'V' (32 colours).
; Bitmap starts with height; flag bit 0 mirrors X. Clips each row and pixel.
; Writes directly into ES instead of making a procedure call for every pixel.
; Outputs: transparent/clipped buffer pixels. Registers preserved.
DrawSprite:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    mov si, [bp+8]
    mov dx, [si]
    add si, 2
    mov bx, [bp+6]
    mov es, [buffer_segment]
.row:
    cmp bx, SCREEN_H
    jae .skip_row
    mov ax, bx
    mov di, ax
    mov cl, 8
    shl di, cl
    mov cl, 6
    shl ax, cl
    add di, ax
    add di, [bp+4]
    push bx
    mov bx, [bp+4]
    mov cx, 16
    test word [bp+10], 1
    jnz .mirror_start
.pixel:
    lodsb
    cmp bx, SCREEN_W
    jae .next
    sub al, '0'
    cmp al, 9
    jbe .decoded
    sub al, 7
.decoded:
    or al, al
    jz .next
    mov [es:di], al
.next:
    inc bx
    inc di
    dec cx
    jnz .pixel
    jmp .row_done
.mirror_start:
    add di, 15
    add bx, 15
.mirror:
    lodsb
    cmp bx, SCREEN_W
    jae .mirror_next
    sub al, '0'
    cmp al, 9
    jbe .mirror_decoded
    sub al, 7
.mirror_decoded:
    or al, al
    jz .mirror_next
    mov [es:di], al
.mirror_next:
    dec bx
    dec di
    dec cx
    jnz .mirror
.row_done:
    pop bx
    jmp .advance_row
.skip_row:
    add si, 16
.advance_row:
    inc bx
    dec dx
    jnz .row
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 8

; DrawText(x,y,string,colour): zero-terminated 5x7 font, 6-pixel advance.
; Unsupported characters become '?'. Outputs: buffer. Registers preserved.
DrawText:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    mov si, [bp+8]
    mov di, [bp+4]
.character:
    lodsb
    or al, al
    jz .done
    cmp al, 32
    jb .fallback
    cmp al, 122
    jbe .lookup
.fallback:
    mov al, '?'
.lookup:
    sub al, 32
    xor ah, ah
    mov bx, 7
    mul bx
    mov bx, ax
    add bx, font_data
    xor dx, dx
.row:
    xor cx, cx
.column:
    mov al, 10h
    shr al, cl
    test [bx], al
    jz .skip
    push word [bp+10]
    mov ax, [bp+6]
    add ax, dx
    push ax
    mov ax, di
    add ax, cx
    push ax
    call PutPixel
.skip:
    inc cx
    cmp cx, 5
    jb .column
    inc bx
    inc dx
    cmp dx, 7
    jb .row
    add di, 6
    jmp .character
.done:
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 8

; DrawLargeText(x,y,string,colour): 2x bitmap lettering for the title logo.
; Inputs: stack; outputs: clipped 10x14 glyphs at a 12-pixel advance.
; Registers preserved; uses the same font as HUD and mixed-case credits.
DrawLargeText:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    mov si, [bp+8]
    mov di, [bp+4]
.character:
    lodsb
    or al, al
    jz .done
    cmp al, 32
    jb .fallback
    cmp al, 122
    jbe .lookup
.fallback:
    mov al, '?'
.lookup:
    sub al, 32
    xor ah, ah
    mov bx, 7
    mul bx
    mov bx, ax
    add bx, font_data
    xor dx, dx
.row:
    xor cx, cx
.column:
    mov al, 10h
    shr al, cl
    test [bx], al
    jz .skip
    push bx                         ; save argument scratch register
    push word [bp+10]
    mov bx, 2
    push bx
    mov bx, 2
    push bx
    mov ax, dx
    shl ax, 1
    add ax, [bp+6]
    push ax
    mov ax, cx
    shl ax, 1
    add ax, di
    push ax
    call FillRect
    pop bx
.skip:
    inc cx
    cmp cx, 5
    jb .column
    inc bx
    inc dx
    cmp dx, 7
    jb .row
    add di, 12
    jmp .character
.done:
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 8


; DrawNumber(x,y,value_low,value_high,digits,colour): unsigned decimal.
; Division of the high word then low word handles the full 32-bit score.
; Remainders are pushed then popped in display order. Registers preserved.
DrawNumber:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    sub sp, 8                        ; local zero-terminated digit string
    mov si, sp
    mov ax, [bp+8]
    mov di, [bp+10]
    mov cx, [bp+12]
    mov bx, 10
.divide:
    push ax
    mov ax, di
    xor dx, dx
    div bx
    mov di, ax
    pop ax
    div bx
    push dx
    dec cx
    jnz .divide
    mov cx, [bp+12]
    xor bx, bx
.digits:
    pop ax
    add al, '0'
    mov [ss:si+bx], al
    inc bx
    dec cx
    jnz .digits
    mov byte [ss:si+bx], 0
    push word [bp+14]
    push si
    push word [bp+6]
    push word [bp+4]
    call DrawText
    add sp, 8
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 12
