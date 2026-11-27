; Fixed-size enemy/item records. Active entities update only in PLAYING.

; UpdateActors(): activate nearby enemies, expire flattened Goombas, move items.
; Inputs: world tables. Outputs: updated actors. Registers preserved.
UpdateActors:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    mov si, enemies
    mov cx, ENEMY_COUNT
.enemy:
    cmp word [si+A_STATE], ES_REMOVED
    je .next_enemy
    mov ax, [camera_x]
    sub ax, 32
    cmp [si+A_X], ax
    jl .remove
    cmp word [si+A_Y], 192
    jge .remove
    cmp word [si+A_ACTIVE], 0
    jne .active
    mov ax, [camera_x]
    add ax, 336
    cmp [si+A_X], ax
    jg .next_enemy
    mov word [si+A_ACTIVE], 1
.active:
    cmp word [si+A_GRACE], 0
    je .flat_test
    dec word [si+A_GRACE]
.flat_test:
    cmp word [si+A_STATE], ES_FLAT
    jne .move
    dec word [si+A_TIMER]
    jnz .next_enemy
.remove:
    mov word [si+A_STATE], ES_REMOVED
    mov word [si+A_ACTIVE], 0
    jmp .next_enemy
.move:
    push si
    call MoveActor
.next_enemy:
    add si, ACTOR_SIZE
    dec cx
    jnz .enemy
    mov si, items
    mov cx, ITEM_COUNT
.item:
    cmp word [si+A_ACTIVE], 0
    je .next_item
    mov ax, [camera_x]
    sub ax, 32
    cmp [si+A_X], ax
    jl .remove_item
    cmp word [si+A_Y], 192
    jge .remove_item
    push si
    call MoveActor
    jmp .next_item
.remove_item:
    mov word [si+A_ACTIVE], 0
.next_item:
    add si, ACTOR_SIZE
    dec cx
    jnz .item
    call ActorPairs
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; MoveActor(pointer): 16x16 world collision, gravity and wall turns.
; Koopas alone avoid ledges while walking. Registers preserved.
MoveActor:
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
    push word [si+A_VX]
    push si
    call Integrate
    mov bx, [si+A_X]
    cmp word [si+A_VX], 0
    jl .left_edge
    add bx, 15
.left_edge:
    mov dx, [si+A_Y]
    push dx
    push bx
    call SolidAt
    or ax, ax
    jnz .wall
    add dx, 15
    push dx
    push bx
    call SolidAt
    or ax, ax
    jz .ledge
.wall:
    and bx, 0FFF0h
    cmp word [si+A_VX], 0
    jl .left_wall
    sub bx, 16
    jmp .turn
.left_wall:
    add bx, 16
.turn:
    mov [si+A_X], bx
    mov word [si+A_XF], 0
    neg word [si+A_VX]
.ledge:
    cmp word [si+A_TYPE], E_KOOPA
    jne .gravity
    cmp word [si+A_STATE], ES_WALK
    jne .gravity
    cmp word [si+A_VY], 0
    jne .gravity
    mov bx, [si+A_X]
    add bx, 8
    mov dx, [si+A_Y]
    add dx, 16
    push dx
    push bx
    call SolidAt
    or ax, ax
    jz .gravity
    mov bx, [si+A_X]
    dec bx
    cmp word [si+A_VX], 0
    jl .probe
    add bx, 17
.probe:
    push dx
    push bx
    call SolidAt
    or ax, ax
    jnz .gravity
    neg word [si+A_VX]
    push word [si+A_VX]
    push si
    call Integrate
.gravity:
    mov ax, [si+A_VY]
    add ax, GRAVITY
    cmp ax, FALL_SPEED
    jle .fall
    mov ax, FALL_SPEED
.fall:
    mov [si+A_VY], ax
    push ax
    mov ax, si
    add ax, A_Y
    push ax
    call Integrate
    mov dx, [si+A_Y]
    add dx, 16
    mov bx, [si+A_X]
    push dx
    push bx
    call SolidAt
    or ax, ax
    jnz .land
    add bx, 15
    push dx
    push bx
    call SolidAt
    or ax, ax
    jz .done
.land:
    and dx, 0FFF0h
    sub dx, 16
    mov [si+A_Y], dx
    mov word [si+A_YF], 0
    mov word [si+A_VY], 0
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
    ret 2

; ActorsOverlap(a,b) -> AX rectangle intersection for two 16x16 actors.
ActorsOverlap:
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
    mov di, [bp+6]
    push dx                         ; save argument scratch register
    mov dx, 16
    push dx
    mov dx, 16
    push dx
    push word [di+A_Y]
    push word [di+A_X]
    mov dx, 16
    push dx
    mov dx, 16
    push dx
    push word [si+A_Y]
    push word [si+A_X]
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
    ret 4

; ActorPairs(): each unordered enemy pair once; shell kills award +500.
; Walking enemies face away from each other and separate after contact.
ActorPairs:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    mov si, enemies
.outer:
    cmp word [si+A_ACTIVE], 0
    jne .outer_active
    jmp near .next_outer
.outer_active:
    cmp word [si+A_STATE], ES_FLAT
    jne .outer_not_flat
    jmp near .next_outer
.outer_not_flat:
    mov di, si
    add di, ACTOR_SIZE
.inner:
    cmp di, enemies+ACTOR_SIZE*ENEMY_COUNT
    jb .inner_in_range
    jmp near .next_outer
.inner_in_range:
    cmp word [di+A_ACTIVE], 0
    jne .inner_active
    jmp near .next_inner
.inner_active:
    cmp word [di+A_STATE], ES_FLAT
    jne .inner_not_flat
    jmp near .next_inner
.inner_not_flat:
    push di
    push si
    call ActorsOverlap
    or ax, ax
    jnz .pair_overlaps
    jmp near .next_inner
.pair_overlaps:
    cmp word [si+A_STATE], ES_SLIDE
    je .kill_di
    cmp word [di+A_STATE], ES_SLIDE
    je .kill_si
    cmp word [si+A_STATE], ES_WALK
    je .first_walks
    jmp near .next_inner
.first_walks:
    cmp word [di+A_STATE], ES_WALK
    je .both_walk
    jmp near .next_inner
.both_walk:
    mov ax, [si+A_X]
    cmp ax, [di+A_X]
    jg .si_right
    mov ax, [di+A_X]
    sub ax, 16
    mov [si+A_X], ax
    mov ax, [si+A_VX]
    test ax, ax
    js .di_right
    neg word [si+A_VX]
.di_right:
    cmp word [di+A_VX], 0
    jge .next_inner
    neg word [di+A_VX]
    jmp .next_inner
.si_right:
    mov ax, [di+A_X]
    add ax, 16
    mov [si+A_X], ax
    cmp word [si+A_VX], 0
    jge .di_left
    neg word [si+A_VX]
.di_left:
    cmp word [di+A_VX], 0
    jle .next_inner
    neg word [di+A_VX]
    jmp .next_inner
.kill_di:
    mov word [di+A_ACTIVE], 0
    mov word [di+A_STATE], ES_REMOVED
    ; AddScore(500)
    push ax                         ; save argument scratch register
    mov ax, 500
    push ax
    call AddScore
    pop ax
    push ax                         ; save argument scratch register
    mov ax, SFX_KICK
    push ax
    call PlaySound
    pop ax
    jmp .next_inner
.kill_si:
    mov word [si+A_ACTIVE], 0
    mov word [si+A_STATE], ES_REMOVED
    ; AddScore(500)
    push ax                         ; save argument scratch register
    mov ax, 500
    push ax
    call AddScore
    pop ax
    push ax                         ; save argument scratch register
    mov ax, SFX_KICK
    push ax
    call PlaySound
    pop ax
    jmp .next_outer
.next_inner:
    add di, ACTOR_SIZE
    jmp .inner
.next_outer:
    add si, ACTOR_SIZE
    cmp si, enemies+ACTOR_SIZE*(ENEMY_COUNT-1)
    jb .outer
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ResolveEntities(): stomp/kick/damage first, then collect mushrooms.
; Stomp uses previous-frame feet and downward velocity. Registers preserved.
ResolveEntities:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    mov si, enemies
    mov cx, ENEMY_COUNT
.enemy:
    cmp word [game_state], ST_PLAY
    je .still_playing
    jmp near .done
.still_playing:
    cmp word [si+A_ACTIVE], 0
    jne .enemy_active
    jmp near .next
.enemy_active:
    cmp word [si+A_STATE], ES_FLAT
    jne .enemy_not_flat
    jmp near .next
.enemy_not_flat:
    push si
    call PlayerOverlaps
    or ax, ax
    jnz .player_touches_enemy
    jmp near .next
.player_touches_enemy:
    cmp word [si+A_STATE], ES_SHELL
    je .kick
    cmp word [player+A_VY], 0
    jg .player_is_falling
    jmp near .hurt
.player_is_falling:
    mov ax, [si+A_Y]
    add ax, 8
    cmp [previous_feet], ax
    jle .valid_stomp
    jmp near .hurt
.valid_stomp:
    ; A sliding shell's grace applies to damaging contact, not a valid stomp.
    call AwardStomp
    cmp word [si+A_STATE], ES_SLIDE
    je .stop_shell
    cmp word [si+A_TYPE], E_KOOPA
    je .stop_shell
    mov word [si+A_STATE], ES_FLAT
    mov word [si+A_TIMER], FPS_SECOND
    mov word [si+A_VX], 0
    jmp .bounce
.stop_shell:
    mov word [si+A_STATE], ES_SHELL
    mov word [si+A_VX], 0
.bounce:
    mov word [player+A_VY], BOUNCE_SPEED
    cmp byte [key_held+KEY_SPACE], 0
    je .place
    mov word [player+A_VY], HIGH_BOUNCE
.place:
    call PlayerHeight
    mov dx, [si+A_Y]
    sub dx, ax
    mov [player+A_Y], dx
    mov word [player+A_YF], 0
    mov word [on_ground], 0
    jmp .next
.kick:
    mov word [si+A_STATE], ES_SLIDE
    mov word [si+A_GRACE], 8
    mov word [si+A_VX], SHELL_SPEED
    mov ax, [player+A_X]
    cmp ax, [si+A_X]
    jle .kick_score
    neg word [si+A_VX]
.kick_score:
    ; AddScore(400)
    push ax                         ; save argument scratch register
    mov ax, 400
    push ax
    call AddScore
    pop ax
    push ax                         ; save argument scratch register
    mov ax, SFX_KICK
    push ax
    call PlaySound
    pop ax
    jmp .next
.hurt:
    cmp word [si+A_GRACE], 0
    jne .next
    call HurtMario
.next:
    add si, ACTOR_SIZE
    dec cx
    jnz .enemy
    mov si, items
    mov cx, ITEM_COUNT
.item:
    cmp word [si+A_ACTIVE], 0
    je .next_item
    push si
    call PlayerOverlaps
    or ax, ax
    jz .next_item
    mov word [si+A_ACTIVE], 0
    ; AddScore(1000)
    push ax                         ; save argument scratch register
    mov ax, 1000
    push ax
    call AddScore
    pop ax
    push ax                         ; save argument scratch register
    mov ax, 2
    push ax
    call SetHealth
    pop ax
    push ax                         ; save argument scratch register
    mov ax, SFX_POWER
    push ax
    call PlaySound
    pop ax
.next_item:
    add si, ACTOR_SIZE
    dec cx
    jnz .item
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

; SpawnMushroom(x,y): create item above a block; four slots exceed two blocks.
; Inputs: block world pixel origin. Outputs: first free item. Registers saved.
SpawnMushroom:
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
    mov si, items
    mov cx, ITEM_COUNT
.find:
    cmp word [si+A_ACTIVE], 0
    je .spawn
    add si, ACTOR_SIZE
    dec cx
    jnz .find
    jmp .done
.spawn:
    push ds
    pop es
    mov di, si
    mov cx, ACTOR_SIZE/2
    xor ax, ax
    rep stosw
    mov ax, [bp+4]
    and ax, 0FFF0h
    mov [si+A_X], ax
    mov ax, [bp+6]
    and ax, 0FFF0h
    sub ax, 16
    mov [si+A_Y], ax
    mov word [si+A_TYPE], E_MUSHROOM
    mov word [si+A_VX], MUSHROOM_SPEED
    mov word [si+A_ACTIVE], 1
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
    ret 4
