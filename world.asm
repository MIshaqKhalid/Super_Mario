; Level storage, tile queries, map reset and the one-way camera.

; GetTile(x,y) -> AX tile code. Off-map bottom is air (pits); sides/HUD solid.
; Inputs: whole world pixels on stack. Registers changed: AX only.
GetTile:
    push bp
    mov bp, sp
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    mov bx, [bp+4]
    mov ax, [bp+6]
    cmp bx, WORLD_W
    jae .wall
    cmp ax, 16
    jl .wall
    cmp ax, 192
    jge .air
    mov cl, 4
    shr bx, cl
    shr ax, cl
    mov dx, LEVEL_W
    mul dx
    add bx, ax
    xor ax, ax
    mov al, [working_map+bx]
    jmp .done
.wall:
    mov ax, T_GROUND
    jmp .done
.air:
    xor ax, ax
.done:
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop bp
    ret 4

; IsSolid(tile) -> AX boolean. Only codes 1..10 block movement.
IsSolid:
    push bp
    mov bp, sp
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    mov ax, [bp+4]
    cmp ax, 1
    jb .no
    cmp ax, T_STAIR
    ja .no
    mov ax, 1
    jmp .done
.no:
    xor ax, ax
.done:
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop bp
    ret 2

; SolidAt(x,y) -> AX boolean. Central collision query, AX is the only output.
SolidAt:
    push bp
    mov bp, sp
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    push word [bp+6]
    push word [bp+4]
    call GetTile
    push ax
    call IsSolid
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop bp
    ret 4

; SetTile(x,y,code): mutate working map only, ignoring out-of-map requests.
; Registers preserved. Original map is never written.
SetTile:
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
    mov ax, [bp+6]
    cmp bx, WORLD_W
    jae .done
    cmp ax, 16
    jl .done
    cmp ax, 192
    jge .done
    mov cl, 4
    shr bx, cl
    shr ax, cl
    mov dx, LEVEL_W
    mul dx
    add bx, ax
    mov ax, [bp+8]
    mov [working_map+bx], al
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

; ResetMap(): restore all 720 tile bytes using a single block move.
ResetMap:
    mov word [flag_y], FLAG_TOP_Y
    mov word [win_start_y], 0
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    push ds
    pop es
    mov si, original_map
    mov di, working_map
    mov cx, LEVEL_W*LEVEL_H
    cld
    rep movsb
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ResetLevel(): restore actors/map/time/camera, preserving score/coins/lives.
; Inputs/outputs: shared game state. Registers preserved.
ResetLevel:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    call ResetMap
    push ds
    pop es
    mov di, player
    mov cx, ACTOR_SIZE*(1+ENEMY_COUNT+ITEM_COUNT)/2
    ; Player/enemy/item tables are contiguous in data.asm.
    xor ax, ax
    rep stosw
    mov word [player+A_X], 32
    mov word [player+A_Y], 144
    mov word [health], 1
    mov word [level_time], 300
    mov word [camera_x], 0
    mov word [invulnerability], 0
    mov word [stomp_chain], 0
    mov word [on_ground], 1
    mov word [facing_left], 0
    mov word [second_low], 0
    mov word [second_high], 0
    mov word [state_frames], 0
    mov word [previous_feet], 160
    mov word [death_is_pit], 0
    mov word [coin_effect_timer], 0
    mov si, enemy_spawns
    mov di, enemies
    mov cx, ENEMY_COUNT
.spawn:
    lodsw
    mov [di+A_TYPE], ax
    lodsw
    mov [di+A_X], ax
    lodsw
    mov [di+A_Y], ax
    mov word [di+A_VX], -GOOMBA_SPEED
    cmp word [di+A_TYPE], E_GOOMBA
    je .next
    mov word [di+A_VX], -KOOPA_SPEED
.next:
    add di, ACTOR_SIZE
    dec cx
    jnz .spawn
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; UpdateCamera(): right-only follow; fixed player screen wall; pixels only.
UpdateCamera:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    mov ax, [player+A_X]
    sub ax, 160
    cmp ax, [camera_x]
    jle .left_wall
    cmp ax, CAMERA_MAX
    jle .set
    mov ax, CAMERA_MAX
.set:
    mov [camera_x], ax
.left_wall:
    mov ax, [camera_x]
    cmp [player+A_X], ax
    jge .done
    mov [player+A_X], ax
    mov word [player+A_XF], 0
    mov word [player+A_VX], 0
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

; RectOverlap(x1,y1,w1,h1,x2,y2,w2,h2) -> AX strict rectangle intersection.
; Touching edges alone do not overlap. Registers changed: AX.
RectOverlap:
    push bp
    mov bp, sp
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    mov ax, [bp+4]
    add ax, [bp+8]
    cmp ax, [bp+12]
    jle .no
    mov ax, [bp+12]
    add ax, [bp+16]
    cmp ax, [bp+4]
    jle .no
    mov ax, [bp+6]
    add ax, [bp+10]
    cmp ax, [bp+14]
    jle .no
    mov ax, [bp+14]
    add ax, [bp+18]
    cmp ax, [bp+6]
    jle .no
    mov ax, 1
    jmp .done
.no:
    xor ax, ax
.done:
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop bp
    ret 16

; PlayerOverlaps(actor_pointer) -> AX boolean, using the current hero height.
PlayerOverlaps:
    push bp
    mov bp, sp
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    mov si, [bp+4]
    push dx                         ; save argument scratch register
    mov dx, 16
    push dx
    mov dx, 16
    push dx
    push word [si+A_Y]
    push word [si+A_X]
    call PlayerHeight
    push ax
    mov dx, 12
    push dx
    push word [player+A_Y]
    mov ax, [player+A_X]
    add ax, 2
    push ax
    call RectOverlap
    pop dx
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop bp
    ret 2
