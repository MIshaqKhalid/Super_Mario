; Screens and world composition use only the off-screen renderer.

; RenderFrame(): select the screen for the current state. Registers preserved.
RenderFrame:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    mov ax, [game_state]
    cmp ax, ST_CREDITS
    jne .not_credits
    jmp near .credits
.not_credits:
    cmp ax, ST_TITLE
    jne .not_title
    jmp near .title
.not_title:
    cmp ax, ST_LIFE
    jne .not_life
    jmp near .life
.not_life:
    cmp ax, ST_OVER
    jne .not_over
    jmp near .over
.not_over:
    cmp ax, ST_COMPLETE
    jne .not_complete
    jmp near .complete
.not_complete:
    call DrawWorld
    cmp word [game_state], ST_PAUSE
    je .draw_pause
    jmp near .done
.draw_pause:
    ; FillRect(39, 66, 246, 64, C_INK)
    push ax                         ; save argument scratch register
    mov ax, C_INK
    push ax
    mov ax, 64
    push ax
    mov ax, 246
    push ax
    mov ax, 66
    push ax
    mov ax, 39
    push ax
    call FillRect
    pop ax
    ; FillRect(37, 64, 246, 64, C_PANEL_EDGE)
    push ax                         ; save argument scratch register
    mov ax, C_PANEL_EDGE
    push ax
    mov ax, 64
    push ax
    mov ax, 246
    push ax
    mov ax, 64
    push ax
    mov ax, 37
    push ax
    call FillRect
    pop ax
    ; FillRect(38, 65, 244, 62, C_PANEL)
    push ax                         ; save argument scratch register
    mov ax, C_PANEL
    push ax
    mov ax, 62
    push ax
    mov ax, 244
    push ax
    mov ax, 65
    push ax
    mov ax, 38
    push ax
    call FillRect
    pop ax
    ; FillRect(38, 65, 244, 1, C_GOLD)
    push ax                         ; save argument scratch register
    mov ax, C_GOLD
    push ax
    mov ax, 1
    push ax
    mov ax, 244
    push ax
    mov ax, 65
    push ax
    mov ax, 38
    push ax
    call FillRect
    pop ax
    ; DrawText(142, 80, txt_pause, C_GOLD)
    push ax                         ; save argument scratch register
    mov ax, C_GOLD
    push ax
    mov ax, txt_pause
    push ax
    mov ax, 80
    push ax
    mov ax, 142
    push ax
    call DrawText
    pop ax
    ; DrawText(82, 104, txt_resume, C_WHITE)
    push ax                         ; save argument scratch register
    mov ax, C_WHITE
    push ax
    mov ax, txt_resume
    push ax
    mov ax, 104
    push ax
    mov ax, 82
    push ax
    call DrawText
    pop ax
    jmp .done
.title:
    call DrawTitle
    jmp .done
.credits:
    call DrawCredits
    jmp .done
.life:
    call DrawLife
    jmp .done
.over:
    call DrawGameOver
    jmp .done
.complete:
    call DrawComplete
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

; DrawWorld(): compose scenery, tiles, objects, player, fixed HUD, black footer.
DrawWorld:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    push ax                         ; save argument scratch register
    mov ax, C_SKY
    push ax
    call ClearFrame
    pop ax
    ; FillRect(0, 64, 320, 48, C_SKY_MID)
    push ax                         ; save argument scratch register
    mov ax, C_SKY_MID
    push ax
    mov ax, 48
    push ax
    mov ax, 320
    push ax
    mov ax, 64
    push ax
    mov ax, 0
    push ax
    call FillRect
    pop ax
    ; FillRect(0, 112, 320, 80, C_SKY_LOW)
    push ax                         ; save argument scratch register
    mov ax, C_SKY_LOW
    push ax
    mov ax, 80
    push ax
    mov ax, 320
    push ax
    mov ax, 112
    push ax
    mov ax, 0
    push ax
    call FillRect
    pop ax
    call DrawScenery
    call DrawMap
    cmp word [coin_effect_timer], 0
    je .items
    mov ax, [coin_effect_x]
    sub ax, [camera_x]
    push word [coin_effect_y]
    push ax
    call DrawCoin
.items:
    mov si, items
    mov cx, ITEM_COUNT
.item:
    cmp word [si+A_ACTIVE], 0
    je .next_item
    mov ax, [si+A_X]
    sub ax, [camera_x]
    ; DrawSprite(ax, [si+A_Y], sprite_mushroom, 0)
    push dx                         ; save argument scratch register
    mov dx, 0
    push dx
    mov dx, sprite_mushroom
    push dx
    push word [si+A_Y]
    push ax
    call DrawSprite
    pop dx
.next_item:
    add si, ACTOR_SIZE
    dec cx
    jnz .item
    mov si, enemies
    mov cx, ENEMY_COUNT
.enemy:
    cmp word [si+A_ACTIVE], 0
    je .next_enemy
    mov ax, [si+A_X]
    sub ax, [camera_x]
    cmp ax, -16
    jle .next_enemy
    cmp ax, 320
    jge .next_enemy
    mov bx, sprite_goomba
    cmp word [si+A_TYPE], E_GOOMBA
    je .flat
    mov bx, sprite_koopa
.flat:
    cmp word [si+A_STATE], ES_FLAT
    jne .shell
    mov bx, sprite_flat
.shell:
    cmp word [si+A_STATE], ES_SHELL
    jb .face
    mov bx, sprite_shell
.face:
    xor dx, dx
    cmp word [si+A_VX], 0
    jge .draw_enemy
    inc dx
.draw_enemy:
    ; DrawSprite(ax, [si+A_Y], bx, dx)
    push dx
    push bx
    push word [si+A_Y]
    push ax
    call DrawSprite
.next_enemy:
    add si, ACTOR_SIZE
    dec cx
    jnz .enemy
    cmp word [invulnerability], 0
    je .hero
    test word [frame_number], 1
    jnz .hud
.hero:
    call DrawHero
.hud:
    call DrawHUD
    ; FillRect(0, 192, 320, 8, C_BLACK)
    push ax                         ; save argument scratch register
    mov ax, C_BLACK
    push ax
    mov ax, 8
    push ax
    mov ax, 320
    push ax
    mov ax, 192
    push ax
    mov ax, 0
    push ax
    call FillRect
    pop ax
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; DrawHero(): eight round stepping poses with separated legs and steady torso.
DrawHero:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    mov bx, sprite_small
    cmp word [health], 2
    jne .pose
    mov bx, sprite_super
.pose:
    cmp word [game_state], ST_WIN
    jne .ground_test
    cmp word [state_frames], FPS_SECOND
    jbe .draw
.ground_test:
    cmp word [on_ground], 0
    je .jump
    cmp word [game_state], ST_DYING
    je .jump
    cmp word [player+A_VX], 0
    je .draw
    mov ax, [frame_number]
    and ax, 7
    shl ax, 1
    mov si, small_walk_frames
    cmp word [health], 2
    jne .walk_frame
    mov si, super_walk_frames
.walk_frame:
    add si, ax
    mov bx, [si]
    jmp .draw
.jump:
    mov bx, sprite_small_jump
    cmp word [health], 2
    jne .draw
    mov bx, sprite_super_jump
.draw:
    mov ax, [player+A_X]
    sub ax, [camera_x]
    mov dx, [player+A_Y]
    push word [facing_left]
    push bx
    push dx
    push ax
    call DrawSprite
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; DrawScenery(): clouds, bushes and castle; green mountains disabled for now.
; Camera changes only drawing coordinates; none of this scenery is collidable.
DrawScenery:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    mov bx, [camera_x]
    mov cl, 3
    shr bx, cl
    neg bx
    add bx, 22
    mov cx, 4
.cloud:
    push ax                         ; save argument scratch register
    mov ax, 34
    push ax
    push bx
    call DrawCloud
    pop ax
    add bx, 110
    dec cx
    jnz .cloud
    ; The optional DrawHill routine is retained, but mountains are not drawn.
    ; Bushes form a nearer layer with a stronger green and softer outline.
    mov bx, [camera_x]
    shr bx, 1
    and bx, 127
    neg bx
    add bx, 68
.bush:
    ; FillRect(bx, 147, 43, 13, C_GRASS_DARK)
    push ax                         ; save argument scratch register
    mov ax, C_GRASS_DARK
    push ax
    mov ax, 13
    push ax
    mov ax, 43
    push ax
    mov ax, 147
    push ax
    push bx
    call FillRect
    pop ax
    mov ax, bx
    add ax, 6
    ; FillRect(ax, 142, 13, 18, C_GREEN)
    push dx                         ; save argument scratch register
    mov dx, C_GREEN
    push dx
    mov dx, 18
    push dx
    mov dx, 13
    push dx
    mov dx, 142
    push dx
    push ax
    call FillRect
    pop dx
    add ax, 13
    ; FillRect(ax, 138, 12, 22, C_GREEN)
    push dx                         ; save argument scratch register
    mov dx, C_GREEN
    push dx
    mov dx, 22
    push dx
    mov dx, 12
    push dx
    mov dx, 138
    push dx
    push ax
    call FillRect
    pop dx
    add ax, 12
    ; FillRect(ax, 144, 9, 16, C_GREEN)
    push dx                         ; save argument scratch register
    mov dx, C_GREEN
    push dx
    mov dx, 16
    push dx
    mov dx, 9
    push dx
    mov dx, 144
    push dx
    push ax
    call FillRect
    pop dx
    add bx, 144
    cmp bx, 320
    jl .bush
    ; Brickwork, crenellations, windows and an arched-looking castle door.
    mov bx, 58*16
    sub bx, [camera_x]
    ; FillRect(bx, 112, 32, 48, C_STONE)
    push ax                         ; save argument scratch register
    mov ax, C_STONE
    push ax
    mov ax, 48
    push ax
    mov ax, 32
    push ax
    mov ax, 112
    push ax
    push bx
    call FillRect
    pop ax
    ; FillRect(bx, 112, 32, 2, C_CREAM)
    push ax                         ; save argument scratch register
    mov ax, C_CREAM
    push ax
    mov ax, 2
    push ax
    mov ax, 32
    push ax
    mov ax, 112
    push ax
    push bx
    call FillRect
    pop ax
    ; FillRect(bx, 104, 8, 8, C_BRICK_LIGHT)
    push ax                         ; save argument scratch register
    mov ax, C_BRICK_LIGHT
    push ax
    mov ax, 8
    push ax
    mov ax, 8
    push ax
    mov ax, 104
    push ax
    push bx
    call FillRect
    pop ax
    mov ax, bx
    add ax, 24
    ; FillRect(ax, 104, 8, 8, C_BRICK_LIGHT)
    push dx                         ; save argument scratch register
    mov dx, C_BRICK_LIGHT
    push dx
    mov dx, 8
    push dx
    mov dx, 8
    push dx
    mov dx, 104
    push dx
    push ax
    call FillRect
    pop dx
    mov dx, 120
.mortar:
    ; FillRect(bx, dx, 32, 1, C_BRICK_SHADOW)
    push ax                         ; save argument scratch register
    mov ax, C_BRICK_SHADOW
    push ax
    mov ax, 1
    push ax
    mov ax, 32
    push ax
    push dx
    push bx
    call FillRect
    pop ax
    add dx, 8
    cmp dx, 160
    jb .mortar
    mov ax, bx
    add ax, 5
    ; FillRect(ax, 119, 5, 8, C_INK)
    push dx                         ; save argument scratch register
    mov dx, C_INK
    push dx
    mov dx, 8
    push dx
    mov dx, 5
    push dx
    mov dx, 119
    push dx
    push ax
    call FillRect
    pop dx
    add ax, 17
    ; FillRect(ax, 119, 5, 8, C_INK)
    push dx                         ; save argument scratch register
    mov dx, C_INK
    push dx
    mov dx, 8
    push dx
    mov dx, 5
    push dx
    mov dx, 119
    push dx
    push ax
    call FillRect
    pop dx
    mov ax, bx
    add ax, 11
    ; FillRect(ax, 140, 10, 20, C_INK)
    push dx                         ; save argument scratch register
    mov dx, C_INK
    push dx
    mov dx, 20
    push dx
    mov dx, 10
    push dx
    mov dx, 140
    push dx
    push ax
    call FillRect
    pop dx
    add ax, 2
    ; FillRect(ax, 137, 6, 3, C_INK)
    push dx                         ; save argument scratch register
    mov dx, C_INK
    push dx
    mov dx, 3
    push dx
    mov dx, 6
    push dx
    mov dx, 137
    push dx
    push ax
    call FillRect
    pop dx
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; DrawCloud(x,y): stepped, rounded silhouette with a shaded underside.
DrawCloud:
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
    ; FillRect(bx, dx, 42, 10, C_CLOUD)
    push ax                         ; save argument scratch register
    mov ax, C_CLOUD
    push ax
    mov ax, 10
    push ax
    mov ax, 42
    push ax
    push dx
    push bx
    call FillRect
    pop ax
    mov ax, bx
    add ax, 5
    mov cx, dx
    sub cx, 6
    ; FillRect(ax, cx, 32, 16, C_WHITE)
    push dx                         ; save argument scratch register
    mov dx, C_WHITE
    push dx
    mov dx, 16
    push dx
    mov dx, 32
    push dx
    push cx
    push ax
    call FillRect
    pop dx
    add ax, 6
    sub cx, 5
    ; FillRect(ax, cx, 11, 7, C_WHITE)
    push dx                         ; save argument scratch register
    mov dx, C_WHITE
    push dx
    mov dx, 7
    push dx
    mov dx, 11
    push dx
    push cx
    push ax
    call FillRect
    pop dx
    add ax, 12
    add cx, 2
    ; FillRect(ax, cx, 10, 5, C_WHITE)
    push dx                         ; save argument scratch register
    mov dx, C_WHITE
    push dx
    mov dx, 5
    push dx
    mov dx, 10
    push dx
    push cx
    push ax
    call FillRect
    pop dx
    add dx, 8
    add bx, 3
    ; FillRect(bx, dx, 36, 3, C_CLOUD)
    push ax                         ; save argument scratch register
    mov ax, C_CLOUD
    push ax
    mov ax, 3
    push ax
    mov ax, 36
    push ax
    push dx
    push bx
    call FillRect
    pop ax
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

; DrawHill(x): curved stepped silhouette with a dark rim and two tiny eyes.
DrawHill:
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
    mov dx, 118
    mov si, 6
.slope:
    mov ax, bx
    add ax, 40
    sub ax, si
    mov cx, si
    shl cx, 1
    ; FillRect(ax, dx, cx, 3, C_HILL_SHADOW)
    push bx                         ; save argument scratch register
    mov bx, C_HILL_SHADOW
    push bx
    mov bx, 3
    push bx
    push cx
    push dx
    push ax
    call FillRect
    pop bx
    inc ax
    dec cx
    ; FillRect(ax, dx, cx, 3, C_HILL)
    push bx                         ; save argument scratch register
    mov bx, C_HILL
    push bx
    mov bx, 3
    push bx
    push cx
    push dx
    push ax
    call FillRect
    pop bx
    add si, 3
    add dx, 3
    cmp dx, 160
    jb .slope
    mov ax, bx
    add ax, 33
    ; FillRect(ax, 135, 2, 5, C_HILL_SHADOW)
    push dx                         ; save argument scratch register
    mov dx, C_HILL_SHADOW
    push dx
    mov dx, 5
    push dx
    mov dx, 2
    push dx
    mov dx, 135
    push dx
    push ax
    call FillRect
    pop dx
    add ax, 11
    ; FillRect(ax, 135, 2, 5, C_HILL_SHADOW)
    push dx                         ; save argument scratch register
    mov dx, C_HILL_SHADOW
    push dx
    mov dx, 5
    push dx
    mov dx, 2
    push dx
    mov dx, 135
    push dx
    push ax
    call FillRect
    pop dx
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

; DrawMap(): 20 columns plus a partial column, pixel-offset scrolling.
DrawMap:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    mov ax, [camera_x]
    mov cl, 4
    shr ax, cl
    mov si, ax
    mov bx, [camera_x]
    and bx, 15
    neg bx
    mov di, 21
.column:
    cmp si, LEVEL_W
    jae .done
    mov dx, 16
    mov cx, 1
.row:
    mov ax, cx
    push dx
    mov dx, LEVEL_W
    mul dx
    pop dx
    add ax, si
    push si
    mov si, ax
    xor ax, ax
    mov al, [working_map+si]
    pop si
    push ax
    push dx
    push bx
    call DrawTile
    add dx, 16
    inc cx
    cmp cx, 12
    jb .row
    add bx, 16
    inc si
    dec di
    jnz .column
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

; DrawTile(screen_x,y,code): clipped original tile artwork built from spans.
; All coordinates are screen pixels. Registers preserved.
DrawTile:
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
    cmp si, T_SKY
    jne .not_sky
    jmp near .done
.not_sky:
    cmp si, T_GROUND
    jne .not_ground
    jmp near .ground
.not_ground:
    cmp si, T_BRICK
    jne .not_brick
    jmp near .brick
.not_brick:
    cmp si, T_QUESTION_COIN
    jne .not_question_coin
    jmp near .question
.not_question_coin:
    cmp si, T_QUESTION_GROW
    jne .not_question_grow
    jmp near .question
.not_question_grow:
    cmp si, T_EMPTY
    jne .not_empty
    jmp near .empty
.not_empty:
    cmp si, T_COIN
    jne .not_coin
    jmp near .coin
.not_coin:
    cmp si, T_FLAG
    jne .not_flag
    jmp near .flag
.not_flag:
    cmp si, T_STAIR
    jne .draw_pipe
    jmp near .stair
.draw_pipe:
    ; Pipe halves join without an interior seam; each has its own lighting.
    ; FillRect(bx, dx, 16, 16, C_GREEN)
    push ax                         ; save argument scratch register
    mov ax, C_GREEN
    push ax
    mov ax, 16
    push ax
    mov ax, 16
    push ax
    push dx
    push bx
    call FillRect
    pop ax
    cmp si, T_PIPE_TL
    je .pipe_left
    cmp si, T_PIPE_BL
    je .pipe_left
    mov ax, bx
    add ax, 10
    ; FillRect(ax, dx, 5, 16, C_PIPE_SHADOW)
    push cx                         ; save argument scratch register
    mov cx, C_PIPE_SHADOW
    push cx
    mov cx, 16
    push cx
    mov cx, 5
    push cx
    push dx
    push ax
    call FillRect
    pop cx
    add ax, 5
    ; FillRect(ax, dx, 1, 16, C_INK)
    push cx                         ; save argument scratch register
    mov cx, C_INK
    push cx
    mov cx, 16
    push cx
    mov cx, 1
    push cx
    push dx
    push ax
    call FillRect
    pop cx
    jmp .pipe_rim
.pipe_left:
    ; FillRect(bx, dx, 1, 16, C_PIPE_SHADOW)
    push ax                         ; save argument scratch register
    mov ax, C_PIPE_SHADOW
    push ax
    mov ax, 16
    push ax
    mov ax, 1
    push ax
    push dx
    push bx
    call FillRect
    pop ax
    mov ax, bx
    add ax, 3
    ; FillRect(ax, dx, 3, 16, C_PIPE_LIGHT)
    push cx                         ; save argument scratch register
    mov cx, C_PIPE_LIGHT
    push cx
    mov cx, 16
    push cx
    mov cx, 3
    push cx
    push dx
    push ax
    call FillRect
    pop cx
    add ax, 3
    ; FillRect(ax, dx, 2, 16, C_LIME)
    push cx                         ; save argument scratch register
    mov cx, C_LIME
    push cx
    mov cx, 16
    push cx
    mov cx, 2
    push cx
    push dx
    push ax
    call FillRect
    pop cx
.pipe_rim:
    cmp si, T_PIPE_TR
    jbe .draw_pipe_rim
    jmp near .done
.draw_pipe_rim:
    ; FillRect(bx, dx, 16, 1, C_PIPE_SHADOW)
    push ax                         ; save argument scratch register
    mov ax, C_PIPE_SHADOW
    push ax
    mov ax, 1
    push ax
    mov ax, 16
    push ax
    push dx
    push bx
    call FillRect
    pop ax
    mov ax, dx
    inc ax
    ; FillRect(bx, ax, 16, 2, C_PIPE_LIGHT)
    push dx                         ; save argument scratch register
    mov dx, C_PIPE_LIGHT
    push dx
    mov dx, 2
    push dx
    mov dx, 16
    push dx
    push ax
    push bx
    call FillRect
    pop dx
    add ax, 4
    ; FillRect(bx, ax, 16, 2, C_PIPE_SHADOW)
    push dx                         ; save argument scratch register
    mov dx, C_PIPE_SHADOW
    push dx
    mov dx, 2
    push dx
    mov dx, 16
    push dx
    push ax
    push bx
    call FillRect
    pop dx
    jmp .done
.ground:
    ; FillRect(bx, dx, 16, 16, C_EARTH_LIGHT)
    push ax                         ; save argument scratch register
    mov ax, C_EARTH_LIGHT
    push ax
    mov ax, 16
    push ax
    mov ax, 16
    push ax
    push dx
    push bx
    call FillRect
    pop ax
    ; FillRect(bx, dx, 1, 16, C_EARTH_SHADOW)
    push ax                         ; save argument scratch register
    mov ax, C_EARTH_SHADOW
    push ax
    mov ax, 16
    push ax
    mov ax, 1
    push ax
    push dx
    push bx
    call FillRect
    pop ax
    mov ax, dx
    add ax, 15
    ; FillRect(bx, ax, 16, 1, C_EARTH_SHADOW)
    push dx                         ; save argument scratch register
    mov dx, C_EARTH_SHADOW
    push dx
    mov dx, 1
    push dx
    mov dx, 16
    push dx
    push ax
    push bx
    call FillRect
    pop dx
    mov ax, bx
    add ax, 2
    mov cx, dx
    add cx, 3
    ; FillRect(ax, cx, 6, 3, C_BRICK_LIGHT)
    push dx                         ; save argument scratch register
    mov dx, C_BRICK_LIGHT
    push dx
    mov dx, 3
    push dx
    mov dx, 6
    push dx
    push cx
    push ax
    call FillRect
    pop dx
    add ax, 6
    add cx, 5
    ; FillRect(ax, cx, 6, 6, C_ORANGE)
    push dx                         ; save argument scratch register
    mov dx, C_ORANGE
    push dx
    mov dx, 6
    push dx
    mov dx, 6
    push dx
    push cx
    push ax
    call FillRect
    pop dx
    add cx, 5
    ; FillRect(ax, cx, 6, 1, C_BRICK_SHADOW)
    push dx                         ; save argument scratch register
    mov dx, C_BRICK_SHADOW
    push dx
    mov dx, 1
    push dx
    mov dx, 6
    push dx
    push cx
    push ax
    call FillRect
    pop dx
    cmp dx, 160
    je .draw_ground_top
    jmp near .done
.draw_ground_top:
    ; FillRect(bx, dx, 16, 2, C_GRASS_LIGHT)
    push ax                         ; save argument scratch register
    mov ax, C_GRASS_LIGHT
    push ax
    mov ax, 2
    push ax
    mov ax, 16
    push ax
    push dx
    push bx
    call FillRect
    pop ax
    mov ax, dx
    add ax, 2
    ; FillRect(bx, ax, 16, 2, C_GRASS_DARK)
    push dx                         ; save argument scratch register
    mov dx, C_GRASS_DARK
    push dx
    mov dx, 2
    push dx
    mov dx, 16
    push dx
    push ax
    push bx
    call FillRect
    pop dx
    mov ax, bx
    add ax, 3
    mov cx, dx
    add cx, 4
    ; FillRect(ax, cx, 3, 2, C_GRASS_DARK)
    push dx                         ; save argument scratch register
    mov dx, C_GRASS_DARK
    push dx
    mov dx, 2
    push dx
    mov dx, 3
    push dx
    push cx
    push ax
    call FillRect
    pop dx
    add ax, 8
    ; FillRect(ax, cx, 2, 3, C_GRASS_DARK)
    push dx                         ; save argument scratch register
    mov dx, C_GRASS_DARK
    push dx
    mov dx, 3
    push dx
    mov dx, 2
    push dx
    push cx
    push ax
    call FillRect
    pop dx
    jmp .done
.brick:
    ; FillRect(bx, dx, 16, 16, C_BRICK_LIGHT)
    push ax                         ; save argument scratch register
    mov ax, C_BRICK_LIGHT
    push ax
    mov ax, 16
    push ax
    mov ax, 16
    push ax
    push dx
    push bx
    call FillRect
    pop ax
    ; FillRect(bx, dx, 16, 1, C_CREAM)
    push ax                         ; save argument scratch register
    mov ax, C_CREAM
    push ax
    mov ax, 1
    push ax
    mov ax, 16
    push ax
    push dx
    push bx
    call FillRect
    pop ax
    mov ax, dx
    add ax, 7
    ; FillRect(bx, ax, 16, 1, C_BRICK_SHADOW)
    push dx                         ; save argument scratch register
    mov dx, C_BRICK_SHADOW
    push dx
    mov dx, 1
    push dx
    mov dx, 16
    push dx
    push ax
    push bx
    call FillRect
    pop dx
    add ax, 8
    ; FillRect(bx, ax, 16, 1, C_BRICK_SHADOW)
    push dx                         ; save argument scratch register
    mov dx, C_BRICK_SHADOW
    push dx
    mov dx, 1
    push dx
    mov dx, 16
    push dx
    push ax
    push bx
    call FillRect
    pop dx
    mov ax, bx
    add ax, 7
    ; FillRect(ax, dx, 1, 7, C_BRICK_SHADOW)
    push cx                         ; save argument scratch register
    mov cx, C_BRICK_SHADOW
    push cx
    mov cx, 7
    push cx
    mov cx, 1
    push cx
    push dx
    push ax
    call FillRect
    pop cx
    mov ax, dx
    add ax, 8
    ; FillRect(bx, ax, 1, 7, C_BRICK_SHADOW)
    push dx                         ; save argument scratch register
    mov dx, C_BRICK_SHADOW
    push dx
    mov dx, 7
    push dx
    mov dx, 1
    push dx
    push ax
    push bx
    call FillRect
    pop dx
    mov cx, bx
    inc cx
    ; FillRect(cx, ax, 15, 1, C_CREAM)
    push dx                         ; save argument scratch register
    mov dx, C_CREAM
    push dx
    mov dx, 1
    push dx
    mov dx, 15
    push dx
    push ax
    push cx
    call FillRect
    pop dx
    add cx, 9
    ; FillRect(cx, ax, 1, 7, C_BRICK_SHADOW)
    push dx                         ; save argument scratch register
    mov dx, C_BRICK_SHADOW
    push dx
    mov dx, 7
    push dx
    mov dx, 1
    push dx
    push ax
    push cx
    call FillRect
    pop dx
    jmp .done
.question:
    ; FillRect(bx, dx, 16, 16, C_BRICK_SHADOW)
    push ax                         ; save argument scratch register
    mov ax, C_BRICK_SHADOW
    push ax
    mov ax, 16
    push ax
    mov ax, 16
    push ax
    push dx
    push bx
    call FillRect
    pop ax
    mov ax, bx
    inc ax
    mov cx, dx
    inc cx
    ; FillRect(ax, cx, 14, 14, C_GOLD)
    push dx                         ; save argument scratch register
    mov dx, C_GOLD
    push dx
    mov dx, 14
    push dx
    mov dx, 14
    push dx
    push cx
    push ax
    call FillRect
    pop dx
    test word [frame_number], 8
    jz .question_shine
    ; FillRect(ax, cx, 14, 14, C_ORANGE)
    push dx                         ; save argument scratch register
    mov dx, C_ORANGE
    push dx
    mov dx, 14
    push dx
    mov dx, 14
    push dx
    push cx
    push ax
    call FillRect
    pop dx
.question_shine:
    ; FillRect(ax, cx, 14, 1, C_GOLD_LIGHT)
    push dx                         ; save argument scratch register
    mov dx, C_GOLD_LIGHT
    push dx
    mov dx, 1
    push dx
    mov dx, 14
    push dx
    push cx
    push ax
    call FillRect
    pop dx
    ; FillRect(ax, cx, 1, 14, C_GOLD_LIGHT)
    push dx                         ; save argument scratch register
    mov dx, C_GOLD_LIGHT
    push dx
    mov dx, 14
    push dx
    mov dx, 1
    push dx
    push cx
    push ax
    call FillRect
    pop dx
    inc ax
    inc cx
    ; FillRect(ax, cx, 1, 1, C_BRICK_SHADOW)
    push dx                         ; save argument scratch register
    mov dx, C_BRICK_SHADOW
    push dx
    mov dx, 1
    push dx
    mov dx, 1
    push dx
    push cx
    push ax
    call FillRect
    pop dx
    add ax, 9
    ; FillRect(ax, cx, 1, 1, C_BRICK_SHADOW)
    push dx                         ; save argument scratch register
    mov dx, C_BRICK_SHADOW
    push dx
    mov dx, 1
    push dx
    mov dx, 1
    push dx
    push cx
    push ax
    call FillRect
    pop dx
    add ax, 5
    mov ax, bx
    add ax, 6
    mov cx, dx
    add cx, 4
    ; DrawText(ax, cx, txt_question, C_BRICK_SHADOW)
    push dx                         ; save argument scratch register
    mov dx, C_BRICK_SHADOW
    push dx
    mov dx, txt_question
    push dx
    push cx
    push ax
    call DrawText
    pop dx
    jmp .done
.empty:
    ; FillRect(bx, dx, 16, 16, C_BROWN)
    push ax                         ; save argument scratch register
    mov ax, C_BROWN
    push ax
    mov ax, 16
    push ax
    mov ax, 16
    push ax
    push dx
    push bx
    call FillRect
    pop ax
    mov ax, bx
    inc ax
    mov cx, dx
    inc cx
    ; FillRect(ax, cx, 14, 14, C_STONE)
    push dx                         ; save argument scratch register
    mov dx, C_STONE
    push dx
    mov dx, 14
    push dx
    mov dx, 14
    push dx
    push cx
    push ax
    call FillRect
    pop dx
    jmp .done
.stair:
    ; FillRect(bx, dx, 16, 16, C_BRICK_SHADOW)
    push ax                         ; save argument scratch register
    mov ax, C_BRICK_SHADOW
    push ax
    mov ax, 16
    push ax
    mov ax, 16
    push ax
    push dx
    push bx
    call FillRect
    pop ax
    mov ax, bx
    inc ax
    mov cx, dx
    inc cx
    ; FillRect(ax, cx, 14, 14, C_STONE)
    push dx                         ; save argument scratch register
    mov dx, C_STONE
    push dx
    mov dx, 14
    push dx
    mov dx, 14
    push dx
    push cx
    push ax
    call FillRect
    pop dx
    ; FillRect(ax, cx, 14, 2, C_CREAM)
    push dx                         ; save argument scratch register
    mov dx, C_CREAM
    push dx
    mov dx, 2
    push dx
    mov dx, 14
    push dx
    push cx
    push ax
    call FillRect
    pop dx
    ; FillRect(ax, cx, 2, 14, C_CREAM)
    push dx                         ; save argument scratch register
    mov dx, C_CREAM
    push dx
    mov dx, 14
    push dx
    mov dx, 2
    push dx
    push cx
    push ax
    call FillRect
    pop dx
    add ax, 12
    add cx, 2
    ; FillRect(ax, cx, 2, 12, C_BROWN)
    push dx                         ; save argument scratch register
    mov dx, C_BROWN
    push dx
    mov dx, 12
    push dx
    mov dx, 2
    push dx
    push cx
    push ax
    call FillRect
    pop dx
    jmp .done
.coin:
    push dx
    push bx
    call DrawCoin
    jmp .done
.flag:
    mov ax, bx
    add ax, 7
    ; FillRect(ax, dx, 3, 16, C_CREAM)
    push cx                         ; save argument scratch register
    mov cx, C_CREAM
    push cx
    mov cx, 16
    push cx
    mov cx, 3
    push cx
    push dx
    push ax
    call FillRect
    pop cx
    cmp dx, 32
    jne .done
    mov dx, [flag_y]                 ; cloth moves; the cream pole stays fixed
    mov ax, bx
    sub ax, 5
    ; FillRect(ax, dx, 12, 7, C_RED)
    push cx                         ; save argument scratch register
    mov cx, C_RED
    push cx
    mov cx, 7
    push cx
    mov cx, 12
    push cx
    push dx
    push ax
    call FillRect
    pop cx
    add ax, 3
    mov cx, dx
    add cx, 7
    ; FillRect(ax, cx, 9, 3, C_RED)
    push dx                         ; save argument scratch register
    mov dx, C_RED
    push dx
    mov dx, 3
    push dx
    mov dx, 9
    push dx
    push cx
    push ax
    call FillRect
    pop dx
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

; DrawCoin(x,y): alternate a full face and edge for a gentle rotation.
DrawCoin:
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
    mov ax, sprite_coin
    test word [frame_number], 4
    jz .draw
    mov ax, sprite_coin_edge
.draw:
    ; DrawSprite([bp+4], [bp+6], ax, 0)
    push dx                         ; save argument scratch register
    mov dx, 0
    push dx
    push ax
    push word [bp+6]
    push word [bp+4]
    call DrawSprite
    pop dx
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


; DrawHUD(): fixed top strip, all six fields, zero-padded score/time/coins.
DrawHUD:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    ; FillRect(0, 0, 320, 16, C_INK)
    push ax                         ; save argument scratch register
    mov ax, C_INK
    push ax
    mov ax, 16
    push ax
    mov ax, 320
    push ax
    mov ax, 0
    push ax
    mov ax, 0
    push ax
    call FillRect
    pop ax
    ; FillRect(0, 15, 320, 1, C_PANEL_EDGE)
    push ax                         ; save argument scratch register
    mov ax, C_PANEL_EDGE
    push ax
    mov ax, 1
    push ax
    mov ax, 320
    push ax
    mov ax, 15
    push ax
    mov ax, 0
    push ax
    call FillRect
    pop ax
    ; DrawText(4, 0, txt_score, C_GOLD)
    push ax                         ; save argument scratch register
    mov ax, C_GOLD
    push ax
    mov ax, txt_score
    push ax
    mov ax, 0
    push ax
    mov ax, 4
    push ax
    call DrawText
    pop ax
    ; DrawNumber(4, 8, [score_low], [score_high], 6, C_WHITE)
    push ax                         ; save argument scratch register
    mov ax, C_WHITE
    push ax
    mov ax, 6
    push ax
    push word [score_high]
    push word [score_low]
    mov ax, 8
    push ax
    mov ax, 4
    push ax
    call DrawNumber
    pop ax
    ; DrawText(52, 0, txt_coins, C_GOLD)
    push ax                         ; save argument scratch register
    mov ax, C_GOLD
    push ax
    mov ax, txt_coins
    push ax
    mov ax, 0
    push ax
    mov ax, 52
    push ax
    call DrawText
    pop ax
    ; DrawText(52, 8, txt_x, C_WHITE)
    push ax                         ; save argument scratch register
    mov ax, C_WHITE
    push ax
    mov ax, txt_x
    push ax
    mov ax, 8
    push ax
    mov ax, 52
    push ax
    call DrawText
    pop ax
    ; DrawNumber(58, 8, [coin_count], 0, 2, C_WHITE)
    push ax                         ; save argument scratch register
    mov ax, C_WHITE
    push ax
    mov ax, 2
    push ax
    mov ax, 0
    push ax
    push word [coin_count]
    mov ax, 8
    push ax
    mov ax, 58
    push ax
    call DrawNumber
    pop ax
    ; DrawText(92, 0, txt_world_label, C_GOLD)
    push ax                         ; save argument scratch register
    mov ax, C_GOLD
    push ax
    mov ax, txt_world_label
    push ax
    mov ax, 0
    push ax
    mov ax, 92
    push ax
    call DrawText
    pop ax
    ; DrawText(92, 8, txt_world, C_WHITE)
    push ax                         ; save argument scratch register
    mov ax, C_WHITE
    push ax
    mov ax, txt_world
    push ax
    mov ax, 8
    push ax
    mov ax, 92
    push ax
    call DrawText
    pop ax
    ; DrawText(130, 0, txt_time, C_GOLD)
    push ax                         ; save argument scratch register
    mov ax, C_GOLD
    push ax
    mov ax, txt_time
    push ax
    mov ax, 0
    push ax
    mov ax, 130
    push ax
    call DrawText
    pop ax
    ; DrawNumber(133, 8, [level_time], 0, 3, C_WHITE)
    push ax                         ; save argument scratch register
    mov ax, C_WHITE
    push ax
    mov ax, 3
    push ax
    mov ax, 0
    push ax
    push word [level_time]
    mov ax, 8
    push ax
    mov ax, 133
    push ax
    call DrawNumber
    pop ax
    ; DrawText(176, 0, txt_lives, C_GOLD)
    push ax                         ; save argument scratch register
    mov ax, C_GOLD
    push ax
    mov ax, txt_lives
    push ax
    mov ax, 0
    push ax
    mov ax, 176
    push ax
    call DrawText
    pop ax
    ; DrawText(176, 8, txt_x, C_WHITE)
    push ax                         ; save argument scratch register
    mov ax, C_WHITE
    push ax
    mov ax, txt_x
    push ax
    mov ax, 8
    push ax
    mov ax, 176
    push ax
    call DrawText
    pop ax
    ; DrawNumber(182, 8, [lives], 0, 2, C_WHITE)
    push ax                         ; save argument scratch register
    mov ax, C_WHITE
    push ax
    mov ax, 2
    push ax
    mov ax, 0
    push ax
    push word [lives]
    mov ax, 8
    push ax
    mov ax, 182
    push ax
    call DrawNumber
    pop ax
    ; DrawText(226, 0, txt_hp, C_GOLD)
    push ax                         ; save argument scratch register
    mov ax, C_GOLD
    push ax
    mov ax, txt_hp
    push ax
    mov ax, 0
    push ax
    mov ax, 226
    push ax
    call DrawText
    pop ax
    ; DrawSprite(249, 1, sprite_heart, 0)
    push ax                         ; save argument scratch register
    mov ax, 0
    push ax
    mov ax, sprite_heart
    push ax
    mov ax, 1
    push ax
    mov ax, 249
    push ax
    call DrawSprite
    pop ax
    cmp word [health], 2
    jne .empty
    ; DrawSprite(268, 1, sprite_heart, 0)
    push ax                         ; save argument scratch register
    mov ax, 0
    push ax
    mov ax, sprite_heart
    push ax
    mov ax, 1
    push ax
    mov ax, 268
    push ax
    call DrawSprite
    pop ax
    jmp .done
.empty:
    ; DrawSprite(268, 1, sprite_heart_empty, 0)
    push ax                         ; save argument scratch register
    mov ax, 0
    push ax
    mov ax, sprite_heart_empty
    push ax
    mov ax, 1
    push ax
    mov ax, 268
    push ax
    call DrawSprite
    pop ax
.done:
    cmp word [music_enabled], 0
    je .effects_label
    ; DrawText(297, 0, txt_mute_key, C_GOLD)
    push ax                         ; save argument scratch register
    mov ax, C_GOLD
    push ax
    mov ax, txt_mute_key
    push ax
    mov ax, 0
    push ax
    mov ax, 297
    push ax
    call DrawText
    pop ax
    jmp .audio_status
.effects_label:
    ; DrawText(294, 0, txt_effects_only, C_GOLD)
    push ax                         ; save argument scratch register
    mov ax, C_GOLD
    push ax
    mov ax, txt_effects_only
    push ax
    mov ax, 0
    push ax
    mov ax, 294
    push ax
    call DrawText
    pop ax
.audio_status:
    cmp word [audio_enabled], 0
    je .muted
    ; DrawText(291, 8, txt_audio_on, C_LIME)
    push ax                         ; save argument scratch register
    mov ax, C_LIME
    push ax
    mov ax, txt_audio_on
    push ax
    mov ax, 8
    push ax
    mov ax, 291
    push ax
    call DrawText
    pop ax
    jmp .finished
.muted:
    ; DrawText(291, 8, txt_audio_off, C_STONE)
    push ax                         ; save argument scratch register
    mov ax, C_STONE
    push ax
    mov ax, txt_audio_off
    push ax
    mov ax, 8
    push ax
    mov ax, 291
    push ax
    call DrawText
    pop ax
.finished:
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; DrawTitle(): clean three-button title page with keyboard focus.
DrawTitle:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    mov ax, C_SKY
    push ax
    call ClearFrame
    mov ax, C_SKY_MID
    push ax
    mov ax, 144
    push ax
    mov ax, 320
    push ax
    mov ax, 48
    push ax
    xor ax, ax
    push ax
    call FillRect

    mov ax, C_INK
    push ax
    mov ax, txt_logo_top
    push ax
    mov ax, 13
    push ax
    mov ax, 95
    push ax
    call DrawLargeText
    mov ax, C_GOLD_LIGHT
    push ax
    mov ax, txt_logo_top
    push ax
    mov ax, 11
    push ax
    mov ax, 94
    push ax
    call DrawLargeText

    ; Three vertically aligned buttons fit the native 320x200 screen cleanly.
    mov ax, [menu_selection]
    cmp ax, 0
    jne .start_off
    mov bx, 1
    jmp .start_draw
.start_off:
    xor bx, bx
.start_draw:
    push bx
    mov ax, txt_start
    push ax
    mov ax, 76
    push ax
    mov ax, 97
    push ax
    call DrawMenuButton

    mov ax, [menu_selection]
    cmp ax, 1
    jne .credits_off
    mov bx, 1
    jmp .credits_draw
.credits_off:
    xor bx, bx
.credits_draw:
    push bx
    mov ax, txt_credits
    push ax
    mov ax, 102
    push ax
    mov ax, 97
    push ax
    call DrawMenuButton

    mov ax, [menu_selection]
    cmp ax, 2
    jne .exit_off
    mov bx, 1
    jmp .exit_draw
.exit_off:
    xor bx, bx
.exit_draw:
    push bx
    mov ax, txt_exit
    push ax
    mov ax, 128
    push ax
    mov ax, 97
    push ax
    call DrawMenuButton

    mov ax, C_INK
    push ax
    mov ax, txt_menu_keys
    push ax
    mov ax, 164
    push ax
    mov ax, 79
    push ax
    call DrawText
    mov ax, C_BLACK
    push ax
    mov ax, 20
    push ax
    mov ax, 320
    push ax
    mov ax, 180
    push ax
    xor ax, ax
    push ax
    call FillRect
    mov ax, C_WHITE
    push ax
    mov ax, txt_controls
    push ax
    mov ax, 187
    push ax
    mov ax, 55
    push ax
    call DrawText
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; DrawCredits(): project information formerly shown on the title page.
DrawCredits:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    mov ax, C_SKY
    push ax
    call ClearFrame
    mov ax, C_PANEL_EDGE
    push ax
    mov ax, 164
    push ax
    mov ax, 288
    push ax
    mov ax, 18
    push ax
    mov ax, 16
    push ax
    call FillRect
    mov ax, C_PANEL
    push ax
    mov ax, 160
    push ax
    mov ax, 284
    push ax
    mov ax, 20
    push ax
    mov ax, 18
    push ax
    call FillRect
    mov ax, C_GOLD_LIGHT
    push ax
    mov ax, txt_credit_title
    push ax
    mov ax, 29
    push ax
    mov ax, 118
    push ax
    call DrawLargeText
    mov ax, C_CLOUD
    push ax
    mov ax, txt_project
    push ax
    mov ax, 56
    push ax
    mov ax, 97
    push ax
    call DrawText

    mov ax, C_WHITE
    push ax
    mov ax, txt_taha
    push ax
    mov ax, 83
    push ax
    mov ax, 30
    push ax
    call DrawText
    mov ax, C_GOLD
    push ax
    mov ax, txt_taha_roll
    push ax
    mov ax, 83
    push ax
    mov ax, 242
    push ax
    call DrawText

    mov ax, C_WHITE
    push ax
    mov ax, txt_ishaq
    push ax
    mov ax, 104
    push ax
    mov ax, 30
    push ax
    call DrawText
    mov ax, C_GOLD
    push ax
    mov ax, txt_ishaq_roll
    push ax
    mov ax, 104
    push ax
    mov ax, 242
    push ax
    call DrawText

    mov ax, C_WHITE
    push ax
    mov ax, txt_asad
    push ax
    mov ax, 125
    push ax
    mov ax, 30
    push ax
    call DrawText
    mov ax, C_GOLD
    push ax
    mov ax, txt_asad_roll
    push ax
    mov ax, 125
    push ax
    mov ax, 242
    push ax
    call DrawText

    mov ax, C_WHITE
    push ax
    mov ax, txt_section
    push ax
    mov ax, 146
    push ax
    mov ax, 30
    push ax
    call DrawText
    mov ax, C_GOLD
    push ax
    mov ax, txt_section_id
    push ax
    mov ax, 146
    push ax
    mov ax, 248
    push ax
    call DrawText
    mov ax, C_INK
    push ax
    mov ax, txt_credit_back
    push ax
    mov ax, 190
    push ax
    mov ax, 100
    push ax
    call DrawText
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; DrawMenuButton(x,y,label,selected): centred label and high-contrast focus.
; Input selected is 0/1; output is a 126x19 button. Registers preserved.
DrawMenuButton:
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
    mov ax, bx
    add ax, 2
    mov cx, dx
    add cx, 2
    ; FillRect(ax, cx, 126, 19, C_INK)
    push dx                         ; save argument scratch register
    mov dx, C_INK
    push dx
    mov dx, 19
    push dx
    mov dx, 126
    push dx
    push cx
    push ax
    call FillRect
    pop dx
    mov si, C_PANEL_EDGE
    cmp word [bp+10], 0
    je .border
    mov si, C_GOLD
.border:
    ; FillRect(bx, dx, 126, 19, si)
    push ax                         ; save argument scratch register
    push si
    mov ax, 19
    push ax
    mov ax, 126
    push ax
    push dx
    push bx
    call FillRect
    pop ax
    inc bx
    inc dx
    ; FillRect(bx, dx, 124, 17, C_PANEL)
    push ax                         ; save argument scratch register
    mov ax, C_PANEL
    push ax
    mov ax, 17
    push ax
    mov ax, 124
    push ax
    push dx
    push bx
    call FillRect
    pop ax
    mov si, [bp+8]
    xor cx, cx
.length:
    lodsb
    or al, al
    jz .centre
    add cx, 6
    jmp .length
.centre:
    mov ax, 126
    sub ax, cx
    shr ax, 1
    add ax, [bp+4]
    mov dx, [bp+6]
    add dx, 6
    mov si, C_CLOUD
    cmp word [bp+10], 0
    je .label
    mov si, C_GOLD_LIGHT
.label:
    ; DrawText(ax, dx, [bp+8], si)
    push si
    push word [bp+8]
    push dx
    push ax
    call DrawText
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

; DrawLife(): remaining lives between death and level reset.
DrawLife:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    call DrawEndBackdrop
    ; DrawText(133, 53, txt_life, C_GOLD)
    push ax                         ; save argument scratch register
    mov ax, C_GOLD
    push ax
    mov ax, txt_life
    push ax
    mov ax, 53
    push ax
    mov ax, 133
    push ax
    call DrawText
    pop ax
    ; DrawText(130, 112, txt_ready, C_WHITE)
    push ax                         ; save argument scratch register
    mov ax, C_WHITE
    push ax
    mov ax, txt_ready
    push ax
    mov ax, 112
    push ax
    mov ax, 130
    push ax
    call DrawText
    pop ax
    ; DrawSprite(131, 78, sprite_small, 0)
    push ax                         ; save argument scratch register
    mov ax, 0
    push ax
    mov ax, sprite_small
    push ax
    mov ax, 78
    push ax
    mov ax, 131
    push ax
    call DrawSprite
    pop ax
    ; DrawNumber(166, 83, [lives], 0, 2, C_WHITE)
    push ax                         ; save argument scratch register
    mov ax, C_WHITE
    push ax
    mov ax, 2
    push ax
    mov ax, 0
    push ax
    push word [lives]
    mov ax, 83
    push ax
    mov ax, 166
    push ax
    call DrawNumber
    pop ax
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; DrawGameOver(): final score and Enter navigation.
DrawGameOver:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    call DrawEndBackdrop
    ; FillRect(32, 36, 256, 2, C_RED)
    push ax                         ; save argument scratch register
    mov ax, C_RED
    push ax
    mov ax, 2
    push ax
    mov ax, 256
    push ax
    mov ax, 36
    push ax
    mov ax, 32
    push ax
    call FillRect
    pop ax
    ; DrawText(133, 55, txt_over, C_RED)
    push ax                         ; save argument scratch register
    mov ax, C_RED
    push ax
    mov ax, txt_over
    push ax
    mov ax, 55
    push ax
    mov ax, 133
    push ax
    call DrawText
    pop ax
    ; DrawText(127, 82, txt_final, C_GOLD)
    push ax                         ; save argument scratch register
    mov ax, C_GOLD
    push ax
    mov ax, txt_final
    push ax
    mov ax, 82
    push ax
    mov ax, 127
    push ax
    call DrawText
    pop ax
    ; DrawNumber(142, 99, [score_low], [score_high], 6, C_WHITE)
    push ax                         ; save argument scratch register
    mov ax, C_WHITE
    push ax
    mov ax, 6
    push ax
    push word [score_high]
    push word [score_low]
    mov ax, 99
    push ax
    mov ax, 142
    push ax
    call DrawNumber
    pop ax
    ; DrawText(88, 143, txt_enter, C_CREAM)
    push ax                         ; save argument scratch register
    mov ax, C_CREAM
    push ax
    mov ax, txt_enter
    push ax
    mov ax, 143
    push ax
    mov ax, 88
    push ax
    call DrawText
    pop ax
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; DrawComplete(): frozen time, time*50 bonus, coins and final score.
DrawComplete:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    call DrawEndBackdrop
    ; FillRect(24, 25, 272, 2, C_GOLD)
    push ax                         ; save argument scratch register
    mov ax, C_GOLD
    push ax
    mov ax, 2
    push ax
    mov ax, 272
    push ax
    mov ax, 25
    push ax
    mov ax, 24
    push ax
    call FillRect
    pop ax
    ; DrawText(118, 42, txt_complete, C_GOLD)
    push ax                         ; save argument scratch register
    mov ax, C_GOLD
    push ax
    mov ax, txt_complete
    push ax
    mov ax, 42
    push ax
    mov ax, 118
    push ax
    call DrawText
    pop ax
    ; DrawText(58, 68, txt_remaining, C_CREAM)
    push ax                         ; save argument scratch register
    mov ax, C_CREAM
    push ax
    mov ax, txt_remaining
    push ax
    mov ax, 68
    push ax
    mov ax, 58
    push ax
    call DrawText
    pop ax
    ; DrawNumber(232, 68, [win_time], 0, 3, C_WHITE)
    push ax                         ; save argument scratch register
    mov ax, C_WHITE
    push ax
    mov ax, 3
    push ax
    mov ax, 0
    push ax
    push word [win_time]
    mov ax, 68
    push ax
    mov ax, 232
    push ax
    call DrawNumber
    pop ax
    ; DrawText(58, 86, txt_timebonus, C_CREAM)
    push ax                         ; save argument scratch register
    mov ax, C_CREAM
    push ax
    mov ax, txt_timebonus
    push ax
    mov ax, 86
    push ax
    mov ax, 58
    push ax
    call DrawText
    pop ax
    ; DrawNumber(220, 86, [time_bonus], 0, 5, C_WHITE)
    push ax                         ; save argument scratch register
    mov ax, C_WHITE
    push ax
    mov ax, 5
    push ax
    mov ax, 0
    push ax
    push word [time_bonus]
    mov ax, 86
    push ax
    mov ax, 220
    push ax
    call DrawNumber
    pop ax
    ; DrawText(58, 104, txt_coins, C_CREAM)
    push ax                         ; save argument scratch register
    mov ax, C_CREAM
    push ax
    mov ax, txt_coins
    push ax
    mov ax, 104
    push ax
    mov ax, 58
    push ax
    call DrawText
    pop ax
    ; DrawNumber(238, 104, [coin_count], 0, 2, C_WHITE)
    push ax                         ; save argument scratch register
    mov ax, C_WHITE
    push ax
    mov ax, 2
    push ax
    mov ax, 0
    push ax
    push word [coin_count]
    mov ax, 104
    push ax
    mov ax, 238
    push ax
    call DrawNumber
    pop ax
    ; DrawText(58, 122, txt_final, C_GOLD)
    push ax                         ; save argument scratch register
    mov ax, C_GOLD
    push ax
    mov ax, txt_final
    push ax
    mov ax, 122
    push ax
    mov ax, 58
    push ax
    call DrawText
    pop ax
    ; DrawNumber(214, 122, [score_low], [score_high], 6, C_WHITE)
    push ax                         ; save argument scratch register
    mov ax, C_WHITE
    push ax
    mov ax, 6
    push ax
    push word [score_high]
    push word [score_low]
    mov ax, 122
    push ax
    mov ax, 214
    push ax
    call DrawNumber
    pop ax
    ; DrawText(88, 159, txt_enter, C_CREAM)
    push ax                         ; save argument scratch register
    mov ax, C_CREAM
    push ax
    mov ax, txt_enter
    push ax
    mov ax, 159
    push ax
    mov ax, 88
    push ax
    call DrawText
    pop ax
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; DrawEndBackdrop(): consistent framed presentation for lifecycle screens.
; Inputs/outputs: framebuffer only. All registers preserved.
DrawEndBackdrop:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    push ax                         ; save argument scratch register
    mov ax, C_INK
    push ax
    call ClearFrame
    pop ax
    ; FillRect(0, 16, 320, 1, C_PANEL_EDGE)
    push ax                         ; save argument scratch register
    mov ax, C_PANEL_EDGE
    push ax
    mov ax, 1
    push ax
    mov ax, 320
    push ax
    mov ax, 16
    push ax
    mov ax, 0
    push ax
    call FillRect
    pop ax
    ; FillRect(26, 27, 272, 150, C_BLACK)
    push ax                         ; save argument scratch register
    mov ax, C_BLACK
    push ax
    mov ax, 150
    push ax
    mov ax, 272
    push ax
    mov ax, 27
    push ax
    mov ax, 26
    push ax
    call FillRect
    pop ax
    ; FillRect(24, 25, 272, 150, C_PANEL_EDGE)
    push ax                         ; save argument scratch register
    mov ax, C_PANEL_EDGE
    push ax
    mov ax, 150
    push ax
    mov ax, 272
    push ax
    mov ax, 25
    push ax
    mov ax, 24
    push ax
    call FillRect
    pop ax
    ; FillRect(25, 26, 270, 148, C_PANEL)
    push ax                         ; save argument scratch register
    mov ax, C_PANEL
    push ax
    mov ax, 148
    push ax
    mov ax, 270
    push ax
    mov ax, 26
    push ax
    mov ax, 25
    push ax
    call FillRect
    pop ax
    ; FillRect(25, 26, 270, 1, C_GOLD)
    push ax                         ; save argument scratch register
    mov ax, C_GOLD
    push ax
    mov ax, 1
    push ax
    mov ax, 270
    push ax
    mov ax, 26
    push ax
    mov ax, 25
    push ax
    call FillRect
    pop ax
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

txt_question db '?',0
