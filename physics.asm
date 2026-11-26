; Integer arithmetic with eight fractional bits, no floating-point or 386 code.

; Integrate(position_pointer, signed_velocity): add 8.8 velocity to a split
; whole/fraction position. Outputs: pointed position. Registers preserved.
Integrate:
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
    mov si, [bp+4]
    mov ax, [bp+6]
    mov dx, ax
    and dx, 00FFh
    mov cl, 8
    sar ax, cl
    add dx, [si+2]
    cmp dx, 256
    jb .store
    sub dx, 256
    inc ax
.store:
    add [si], ax
    mov [si+2], dx
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 4

; PlayerHeight() -> AX = 16 or 32. No independent form variable can go stale.
PlayerHeight:
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    mov ax, [health]
    mov cl, 4
    shl ax, cl
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ret

; SetHealth(new_hp): keep Mario's feet fixed while changing sprite/hitbox size.
; Inputs: 1 or 2. Outputs: HP, top Y. Registers preserved.
SetHealth:
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
    call PlayerHeight
    add ax, [player+A_Y]
    mov dx, [bp+4]
    mov [health], dx
    mov cl, 4
    shl dx, cl
    sub ax, dx
    mov [player+A_Y], ax
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

; UpdatePlayer(): input, momentum, gravity and one-axis-at-a-time collision.
; Outputs: player/on_ground/previous_feet. Registers preserved.
UpdatePlayer:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    call PlayerHeight
    add ax, [player+A_Y]
    mov [previous_feet], ax
    mov bx, [player+A_VX]
    mov dx, WALK_SPEED
    cmp byte [key_held+KEY_SHIFT], 0
    je .direction
    mov dx, RUN_SPEED
.direction:
    mov al, [key_held+KEY_RIGHT]
    sub al, [key_held+KEY_LEFT]
    jz .friction
    js .left
    mov word [facing_left], 0
    mov ax, ACCEL
    test bx, bx
    jns .accelerate_right
    mov ax, BRAKE
.accelerate_right:
    add bx, ax
    cmp bx, dx
    jle .horizontal_ready
    mov bx, dx
    jmp .horizontal_ready
.left:
    mov word [facing_left], 1
    mov ax, ACCEL
    cmp bx, 0
    jle .accelerate_left
    mov ax, BRAKE
.accelerate_left:
    sub bx, ax
    neg dx
    cmp bx, dx
    jge .horizontal_ready
    mov bx, dx
    jmp .horizontal_ready
.friction:
    or bx, bx
    jz .horizontal_ready
    js .friction_left
    sub bx, FRICTION
    jns .horizontal_ready
    xor bx, bx
    jmp .horizontal_ready
.friction_left:
    add bx, FRICTION
    js .horizontal_ready
    xor bx, bx
.horizontal_ready:
    mov [player+A_VX], bx
    cmp byte [key_pressed+KEY_SPACE], 0
    je .jump_cut
    cmp word [on_ground], 0
    je .jump_cut
    mov word [player+A_VY], JUMP_SPEED
    mov word [on_ground], 0
    push ax                         ; save argument scratch register
    mov ax, SFX_JUMP
    push ax
    call PlaySound
    pop ax
.jump_cut:
    cmp byte [key_held+KEY_SPACE], 0
    jne .gravity
    cmp word [player+A_VY], JUMP_CUT
    jge .gravity
    mov word [player+A_VY], JUMP_CUT
.gravity:
    mov ax, [player+A_VY]
    add ax, GRAVITY
    cmp ax, FALL_SPEED
    jle .vertical_ready
    mov ax, FALL_SPEED
.vertical_ready:
    mov [player+A_VY], ax
    call PlayerHorizontal
    call PlayerVertical
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; PlayerHorizontal(): integrate X, test the entire leading hitbox edge.
; Outputs: corrected X/VX. Registers preserved.
PlayerHorizontal:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    push ax                         ; save argument scratch register
    push word [player+A_VX]
    mov ax, player+A_X
    push ax
    call Integrate
    pop ax
    mov ax, [camera_x]
    cmp [player+A_X], ax
    jge .right_bound
    mov [player+A_X], ax
    jmp .stop
.right_bound:
    cmp word [player+A_X], WORLD_W-16
    jle .test
    mov word [player+A_X], WORLD_W-16
    jmp .stop
.test:
    cmp word [player+A_VX], 0
    je .done
    mov bx, [player+A_X]
    add bx, 13
    cmp word [player+A_VX], 0
    jg .edge
    sub bx, 11
.edge:
    mov dx, [player+A_Y]
    call PlayerHeight
    add ax, dx
    dec ax
    mov di, ax
    and dx, 0FFF0h
.row:
    mov ax, dx
    cmp ax, [player+A_Y]
    jge .query
    mov ax, [player+A_Y]
.query:
    push ax
    push bx
    call SolidAt
    or ax, ax
    jnz .wall
    add dx, 16
    cmp dx, di
    jle .row
    jmp .done
.wall:
    and bx, 0FFF0h
    cmp word [player+A_VX], 0
    jl .wall_left
    sub bx, 14
    jmp .place
.wall_left:
    add bx, 14
.place:
    mov [player+A_X], bx
.stop:
    mov word [player+A_VX], 0
    mov word [player+A_XF], 0
.done:
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; PlayerVertical(): integrate Y; feet/head tile collision and block head hits.
; Outputs: corrected Y/VY, grounded flag, stomp chain. Registers preserved.
PlayerVertical:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    push ax                         ; save argument scratch register
    push word [player+A_VY]
    mov ax, player+A_Y
    push ax
    call Integrate
    pop ax
    mov word [on_ground], 0
    call PlayerHeight
    mov si, ax
    mov dx, [player+A_Y]
    cmp word [player+A_VY], 0
    jl .head
    add dx, si
    jmp .edges
.head:
    cmp dx, 16
    jge .edges
    mov word [player+A_Y], 16
    jmp .stop
.edges:
    mov bx, [player+A_X]
    add bx, 2
    push dx
    push bx
    call SolidAt
    or ax, ax
    jnz .hit
    add bx, 11
    push dx
    push bx
    call SolidAt
    or ax, ax
    jz .done
.hit:
    cmp word [player+A_VY], 0
    jl .ceiling
    and dx, 0FFF0h
    sub dx, si
    mov [player+A_Y], dx
    mov word [on_ground], 1
    mov word [stomp_chain], 0
    jmp .stop
.ceiling:
    mov ax, dx
    and ax, 0FFF0h
    add ax, 16
    mov [player+A_Y], ax
    mov bx, [player+A_X]
    add bx, 8
    push dx
    push bx
    call HitBlock
.stop:
    mov word [player+A_VY], 0
    mov word [player+A_YF], 0
.done:
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
