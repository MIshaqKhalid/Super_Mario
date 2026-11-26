; Event-based scoring, health and collectible rules have one owner each.

; AddScore(points): unsigned word event; ADD/ADC 32-bit score, clamp 999999.
; Registers preserved. Central entry for every scoring event.
AddScore:
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
    mov ax, [bp+4]
    add [score_low], ax
    adc word [score_high], 0
    cmp word [score_high], 000Fh
    jb .done
    ja .clamp
    cmp word [score_low], 423Fh
    jbe .done
.clamp:
    mov word [score_high], 000Fh
    mov word [score_low], 423Fh
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

; AddLife(): lives saturate at 99. Registers preserved.
AddLife:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    cmp word [lives], 99
    jae .done
    inc word [lives]
    push ax                         ; save argument scratch register
    mov ax, SFX_LIFE
    push ax
    call PlaySound
    pop ax
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

; CollectCoin(): +200 and coin count; the hundredth coin also grants one life.
CollectCoin:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    ; AddScore(200)
    push ax                         ; save argument scratch register
    mov ax, 200
    push ax
    call AddScore
    pop ax
    push ax                         ; save argument scratch register
    mov ax, SFX_COIN
    push ax
    call PlaySound
    pop ax
    inc word [coin_count]
    cmp word [coin_count], 100
    jb .done
    mov word [coin_count], 0
    call AddLife
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

; AwardStomp(): lookup consecutive airborne stomps, 11th onward gives 1-UP.
AwardStomp:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    push ax                         ; save argument scratch register
    mov ax, SFX_STOMP
    push ax
    call PlaySound
    pop ax
    mov bx, [stomp_chain]
    cmp bx, 10
    jae .life
    shl bx, 1
    push word [stomp_points+bx]
    call AddScore
    inc word [stomp_chain]
    jmp .done
.life:
    call AddLife
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

; HurtMario(): Super shrinks/blinks for ~2s; Small starts death exactly once.
HurtMario:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    cmp word [invulnerability], 0
    jne .done
    cmp word [health], 2
    jne .die
    push ax                         ; save argument scratch register
    mov ax, 1
    push ax
    call SetHealth
    pop ax
    mov word [invulnerability], TWO_SECONDS
    push ax                         ; save argument scratch register
    mov ax, SFX_HURT
    push ax
    call PlaySound
    pop ax
    jmp .done
.die:
    push ax                         ; save argument scratch register
    mov ax, 0
    push ax
    call BeginDeath
    pop ax
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

; HitBlock(x,y): trigger only the centre head tile; each ? can be used once.
; Outputs: map/item/score changes. Registers preserved.
HitBlock:
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
    push word [bp+6]
    push word [bp+4]
    call GetTile
    cmp ax, T_BRICK
    je .brick
    cmp ax, T_QUESTION_COIN
    je .coin
    cmp ax, T_QUESTION_GROW
    je .mushroom
    cmp ax, T_EMPTY
    jne .done
    push ax                         ; save argument scratch register
    mov ax, SFX_BUMP
    push ax
    call PlaySound
    pop ax
    jmp .done
.brick:
    cmp word [health], 2
    je .break_brick
    push ax                         ; save argument scratch register
    mov ax, SFX_BUMP
    push ax
    call PlaySound
    pop ax
    jmp .done
.break_brick:
    ; AddScore(50)
    push ax                         ; save argument scratch register
    mov ax, 50
    push ax
    call AddScore
    pop ax
    push ax                         ; save argument scratch register
    mov ax, SFX_BREAK
    push ax
    call PlaySound
    pop ax
    mov ax, T_SKY
    jmp .replace
.coin:
    call CollectCoin
    mov ax, [bp+4]
    and ax, 0FFF0h
    mov [coin_effect_x], ax
    mov ax, [bp+6]
    and ax, 0FFF0h
    sub ax, 16
    mov [coin_effect_y], ax
    mov word [coin_effect_timer], 12
    mov ax, T_EMPTY
    jmp .replace
.mushroom:
    push ax                         ; save argument scratch register
    mov ax, SFX_SPROUT
    push ax
    call PlaySound
    pop ax
    push word [bp+6]
    push word [bp+4]
    call SpawnMushroom
    mov ax, T_EMPTY
.replace:
    push ax
    push word [bp+6]
    push word [bp+4]
    call SetTile
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

; UpdateEffects(): brief coin-pop motion after a question-block head hit.
; Inputs/outputs: owned visual effect state. Registers preserved.
UpdateEffects:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    cmp word [coin_effect_timer], 0
    je .done
    dec word [coin_effect_timer]
    cmp word [coin_effect_timer], 6
    jb .fall
    sub word [coin_effect_y], 2
    jmp .done
.fall:
    add word [coin_effect_y], 2
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

; CollectMapItems(): scan all overlapped tiles for free coins and flag contact.
; Outputs: working map, counters, win state. Registers preserved.
CollectMapItems:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    mov bx, [player+A_X]
    add bx, 2
    and bx, 0FFF0h
    mov di, [player+A_X]
    add di, 13
    and di, 0FFF0h
    mov dx, [player+A_Y]
    and dx, 0FFF0h
    call PlayerHeight
    add ax, [player+A_Y]
    dec ax
    mov si, ax
.row:
    push bx
.column:
    push dx
    push bx
    call GetTile
    cmp ax, T_COIN
    je .coin
    cmp ax, T_FLAG
    jne .next
    call BeginWin
    jmp .next
.coin:
    push ax                         ; save argument scratch register
    mov ax, T_SKY
    push ax
    push dx
    push bx
    call SetTile
    pop ax
    call CollectCoin
.next:
    add bx, 16
    cmp bx, di
    jle .column
    pop bx
    add dx, 16
    cmp dx, si
    jle .row
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; CountClock(): add one game period in PIT cycles, subtract a real second.
; Called only in PLAYING; pause/death/win cannot consume game time.
CountClock:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    add word [second_low], GAME_PIT_DIVISOR
    adc word [second_high], 0
    cmp word [second_high], PIT_HZ_HIGH
    jb .invulnerability
    ja .second
    cmp word [second_low], PIT_HZ_LOW
    jb .invulnerability
.second:
    sub word [second_low], PIT_HZ_LOW
    sbb word [second_high], PIT_HZ_HIGH
    cmp word [level_time], 0
    je .invulnerability
    dec word [level_time]
.invulnerability:
    cmp word [invulnerability], 0
    je .done
    dec word [invulnerability]
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

; BeginDeath(pit_boolean): freeze play and start timed death animation.
; Registers preserved; repeated contact cannot restart the sequence.
BeginDeath:
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
    cmp word [game_state], ST_PLAY
    jne .done
    mov word [game_state], ST_DYING
    mov word [state_frames], 0
    mov ax, [bp+4]
    mov [death_is_pit], ax
    mov word [player+A_VX], 0
    mov word [player+A_VY], -0800h
    push ax                         ; save argument scratch register
    mov ax, SFX_DEATH
    push ax
    call PlaySound
    pop ax
    or ax, ax
    jz .done
    mov word [player+A_VY], FALL_SPEED
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

; BeginWin(): freeze the clock, score feet height, snap to flag and start slide.
BeginWin:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    cmp word [game_state], ST_PLAY
    jne .done
    call PlayerHeight
    add ax, [player+A_Y]
    mov cl, 4
    shr ax, cl
    mov bx, 100
    cmp ax, 8
    jae .award
    mov bx, 400
    cmp ax, 6
    jae .award
    mov bx, 800
    cmp ax, 5
    je .award
    mov bx, 2000
    cmp ax, 4
    je .award
    mov bx, 5000
.award:
    push bx
    call AddScore
    mov ax, [level_time]
    mov [win_time], ax
    mov word [game_state], ST_WIN
    mov word [state_frames], 0
    mov word [player+A_X], 56*16+8    ; grip the right side; cloth remains visible
    mov word [player+A_XF], 0
    mov word [player+A_VX], 0
    mov word [player+A_VY], 0
    ; Both sprites descend over the same interval from their contact positions.
    call PlayerHeight
    mov dx, WIN_FEET_Y
    sub dx, ax
    cmp [player+A_Y], dx
    jle .slide_start
    mov [player+A_Y], dx
.slide_start:
    mov ax, [player+A_Y]
    mov [win_start_y], ax
    mov word [player+A_YF], 0
    mov word [on_ground], 0
    mov word [facing_left], 1
    mov word [flag_y], FLAG_TOP_Y
    push ax                         ; save argument scratch register
    mov ax, SFX_WIN
    push ax
    call PlaySound
    pop ax
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
