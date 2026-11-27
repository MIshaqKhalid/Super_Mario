; EQU	defines a constant and does not reserve memory. we cannot write db, dw, dd with constants as it will become memory variable , will reserve memory and hence can change value.
SCREEN_W        equ 320
SCREEN_H        equ 200
FRAME_BYTES     equ 64000
LEVEL_W         equ 60
LEVEL_H         equ 12
WORLD_W         equ LEVEL_W * 16
CAMERA_MAX      equ WORLD_W - SCREEN_W
VGA_SEG         equ 0A000h
FPS_SECOND      equ 18             ; original simulation durations; clock is real-time
TWO_SECONDS     equ 36
DEATH_FRAMES    equ 28
GAME_PIT_DIVISOR equ 47108         ; 25.3286 Hz: another ~4% above the previous build
MUSIC_UNIT_PIT  equ 46032         ; 38.58 ms; eight units/beat = ~194.4 BPM
PIT_HZ_LOW      equ 034DEh          ; 1,193,182 Hz = 0012:34DEh
PIT_HZ_HIGH     equ 0012h

ST_TITLE        equ 0
ST_PLAY         equ 1
ST_PAUSE        equ 2
ST_DYING        equ 3
ST_LIFE         equ 4
ST_WIN          equ 5
ST_COMPLETE     equ 6
ST_OVER         equ 7
ST_EXIT         equ 8
ST_CREDITS      equ 9

FLAG_TOP_Y      equ 32
FLAG_BASE_Y     equ 134            ; cloth stays above the flag pedestal
WIN_FEET_Y      equ 144

KEY_ESC         equ 01h
KEY_ENTER       equ 1Ch
KEY_SPACE       equ 39h
KEY_SHIFT       equ 2Ah
KEY_LEFT        equ 4Bh
KEY_RIGHT       equ 4Dh
KEY_UP          equ 48h
KEY_DOWN        equ 50h
KEY_P           equ 19h
KEY_M           equ 32h
KEY_B           equ 30h
KEY_F1          equ 3Bh
KEY_F2          equ 3Ch
KEY_F3          equ 3Dh
KEY_F4          equ 3Eh
KEY_F5          equ 3Fh

T_SKY           equ 0
T_GROUND        equ 1
T_BRICK         equ 2
T_QUESTION_COIN equ 3
T_QUESTION_GROW equ 4
T_EMPTY         equ 5
T_PIPE_TL       equ 6
T_PIPE_TR       equ 7
T_PIPE_BL       equ 8
T_PIPE_BR       equ 9
T_STAIR         equ 10
T_COIN          equ 11
T_FLAG          equ 12

; Each position has a signed whole-pixel word followed by a fraction word
; (0..255). This extends 8.8 positions past 255 pixels without 386 opcodes.
A_X             equ 0
A_XF            equ 2
A_Y             equ 4
A_YF            equ 6
A_VX            equ 8
A_VY            equ 10
A_TYPE          equ 12
A_STATE         equ 14
A_TIMER         equ 16
A_GRACE         equ 18
A_ACTIVE        equ 20
ACTOR_SIZE      equ 22
ENEMY_COUNT     equ 6
ITEM_COUNT      equ 4
E_GOOMBA        equ 1
E_KOOPA         equ 2
E_MUSHROOM      equ 3
ES_WALK         equ 0
ES_FLAT         equ 1
ES_SHELL        equ 2
ES_SLIDE        equ 3
ES_REMOVED      equ 4

; Original signed 8.8 velocities. Keep the same per-step acceleration, jump
; path and collision distances; only the game tick frequency changes.
ACCEL           equ 0057h
BRAKE           equ 00AEh
FRICTION        equ 002Ch
WALK_SPEED      equ 0278h
RUN_SPEED       equ 041Eh
GRAVITY         equ 00AEh
JUMP_SPEED      equ -090Dh
JUMP_CUT        equ -034Ch
FALL_SPEED      equ 0698h
BOUNCE_SPEED    equ -04F1h
HIGH_BOUNCE     equ -0698h
GOOMBA_SPEED    equ 00D3h
KOOPA_SPEED     equ 013Ch
SHELL_SPEED     equ 04F1h
MUSHROOM_SPEED  equ 01A6h

; Original 32-colour palette, stored as VGA DAC values in assets/art.asm.
C_BLACK         equ 0
C_SKY           equ 1
C_WHITE         equ 2
C_RED           equ 3
C_SKIN          equ 4
C_BLUE          equ 5
C_BROWN         equ 6
C_GOLD          equ 7
C_GREEN         equ 8
C_LIME          equ 9
C_DARK          equ 10
C_STONE         equ 11
C_ORANGE        equ 12
C_CREAM         equ 13
C_CLOUD         equ 14
C_INK           equ 15
C_PIPE_LIGHT    equ 16
C_PIPE_SHADOW   equ 17
C_GRASS_LIGHT   equ 18
C_GRASS_DARK    equ 19
C_EARTH_LIGHT   equ 20
C_EARTH_SHADOW  equ 21
C_BRICK_LIGHT   equ 22
C_BRICK_SHADOW  equ 23
C_SKY_MID       equ 24
C_SKY_LOW       equ 25
C_HILL          equ 26
C_HILL_SHADOW   equ 27
C_PANEL         equ 28
C_PANEL_EDGE    equ 29
C_GOLD_LIGHT    equ 30
C_RED_DARK      equ 31
PALETTE_COLOURS equ 32

; Event IDs index sound_bank; priorities are declared with each sound there.
SFX_MENU        equ 0
SFX_START       equ 1
SFX_JUMP        equ 2
SFX_COIN        equ 3
SFX_BUMP        equ 4
SFX_BREAK       equ 5
SFX_SPROUT      equ 6
SFX_POWER       equ 7
SFX_STOMP       equ 8
SFX_KICK        equ 9
SFX_HURT        equ 10
SFX_DEATH       equ 11
SFX_WIN         equ 12
SFX_LIFE        equ 13
SFX_OVER        equ 14
SFX_COUNT       equ 15
