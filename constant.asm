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
