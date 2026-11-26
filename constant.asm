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
