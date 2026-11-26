; One-voice melody arrangements and event cues, expressed as PIT channel-2
; divisors and durations (effects: BIOS-rate ticks; music: reference-grid units).
; No samples, external files or busy waits.
; A zero divisor is a rest. A zero duration ends an effect or loops a theme.
NOTE_C3  equ 9121
NOTE_D3  equ 8126
NOTE_E3  equ 7239
NOTE_G3  equ 6087
NOTE_A3  equ 5423
NOTE_B3  equ 4831
NOTE_BB3 equ 5110
NOTE_GS3 equ 5746
NOTE_GS4 equ 2873
NOTE_C4  equ 4561
NOTE_D4  equ 4063
NOTE_E4  equ 3620
NOTE_EB4 equ 3835
NOTE_F4  equ 3417
NOTE_FS4 equ 3225
NOTE_G4  equ 3044
NOTE_A4  equ 2712
NOTE_B4  equ 2416
NOTE_BB4 equ 2555
NOTE_C5  equ 2280
NOTE_D5  equ 2032
NOTE_E5  equ 1810
NOTE_F5  equ 1708
NOTE_FS5 equ 1613
NOTE_EB5 equ 1918
NOTE_G5  equ 1522
NOTE_A5  equ 1356
NOTE_B5  equ 1208
NOTE_C6  equ 1140
NOTE_D6  equ 1016
NOTE_E6  equ 905
NOTE_G6  equ 761
NOTE_B6  equ 604

sound_bank:
    dw sound_menu, 2
    dw sound_start, 5
    dw sound_jump, 1
    dw sound_coin, 3
    dw sound_bump, 1
    dw sound_break, 3
    dw sound_sprout, 4
    dw sound_power, 6
    dw sound_stomp, 3
    dw sound_kick, 4
    dw sound_hurt, 7
    dw sound_death, 9
    dw sound_win, 10
    dw sound_life, 8
    dw sound_over, 9

sound_menu:
    dw NOTE_E5,1, NOTE_G5,1, 0,0
sound_start:
    dw NOTE_C5,1, NOTE_E5,1, NOTE_G5,1, NOTE_C6,1, 0,0
sound_jump:
    dw NOTE_C4,1, NOTE_G4,1, NOTE_C5,1, 0,0
sound_coin:
    dw NOTE_B5,1, NOTE_E6,3, 0,0
sound_bump:
    dw NOTE_G3,1, NOTE_C3,1, 0,0
sound_break:
    dw NOTE_C4,1, NOTE_G3,1, NOTE_D4,1, NOTE_C3,2, 0,0
sound_sprout:
    dw NOTE_C4,1, NOTE_E4,1, NOTE_G4,1, NOTE_C5,1, NOTE_E5,2, 0,0
sound_power:
    dw NOTE_C5,1, NOTE_E5,1, NOTE_G5,1, NOTE_C6,1
    dw NOTE_E5,1, NOTE_G5,1, NOTE_C6,2, NOTE_E6,3, 0,0
sound_stomp:
    dw NOTE_G4,1, NOTE_C4,1, 0,0
sound_kick:
    dw NOTE_G5,1, NOTE_D5,1, NOTE_G4,1, 0,0
sound_hurt:
    dw NOTE_G5,1, NOTE_E5,1, NOTE_C5,1, NOTE_G4,2, NOTE_C4,2, 0,0
sound_death:
    dw NOTE_C6,2, 0,1, NOTE_B5,2, NOTE_G5,2, NOTE_E5,2
    dw NOTE_C5,2, NOTE_G4,2, NOTE_C4,4, 0,0
sound_win:
    dw NOTE_C5,2, NOTE_E5,2, NOTE_G5,2, NOTE_C6,4, 0,1
    dw NOTE_A5,2, NOTE_C6,2, NOTE_E6,3, NOTE_D6,2, NOTE_C6,6, 0,0
sound_life:
    dw NOTE_E5,1, NOTE_G5,1, NOTE_E6,2, NOTE_C6,1, NOTE_D6,1, NOTE_G6,3, 0,0
sound_over:
    dw NOTE_G4,3, NOTE_E4,3, NOTE_C4,3, 0,2, NOTE_D4,2, NOTE_C4,6, 0,0

; Reference arrangement: supplied Super Mario Bros. Theme Song.mp3.
; One unit = MUSIC_UNIT_PIT input cycles; four units per eighth note.
; Opening attacks fit about 194 BPM. Gate lengths and rests are explicit:
; dotted notes, triplet-group 5/5/6 units, chromatic answer, repeated sections.
; The 1024-unit world loop includes intro, A/A, B/B and the C middle phrase.
; This is a single lead voice, not a reproduction of the reference's chords.
; Sound-effect tables above are unchanged.

music_title:
    ; Opening + main answer; same tempo and articulation as gameplay.
    dw NOTE_E5,3, 0,1
    dw NOTE_E5,3, 0,5
    dw NOTE_E5,3, 0,5
    dw NOTE_C5,3, 0,1
    dw NOTE_E5,3, 0,5
    dw NOTE_G5,4, 0,12
    dw NOTE_G4,4, 0,12
    dw NOTE_C5,4, 0,8
    dw NOTE_G4,4, 0,8
    dw NOTE_E4,4, 0,8
    dw NOTE_A4,4, 0,4
    dw NOTE_B4,4, 0,4
    dw NOTE_BB4,3, 0,1
    dw NOTE_A4,4, 0,4
    dw NOTE_G4,3, 0,2
    dw NOTE_E5,3, 0,2
    dw NOTE_G5,3, 0,3
    dw NOTE_A5,4, 0,4
    dw NOTE_F5,3, 0,1
    dw NOTE_G5,4, 0,4
    dw NOTE_E5,4, 0,4
    dw NOTE_C5,3, 0,1
    dw NOTE_D5,3, 0,1
    dw NOTE_B4,4, 0,8
    dw 0,0

music_world:
    ; intro: 64 reference-grid units.
    dw NOTE_E5,3, 0,1
    dw NOTE_E5,3, 0,5
    dw NOTE_E5,3, 0,5
    dw NOTE_C5,3, 0,1
    dw NOTE_E5,3, 0,5
    dw NOTE_G5,4, 0,12
    dw NOTE_G4,4, 0,12
    ; A1: 128 reference-grid units.
    dw NOTE_C5,4, 0,8
    dw NOTE_G4,4, 0,8
    dw NOTE_E4,4, 0,8
    dw NOTE_A4,4, 0,4
    dw NOTE_B4,4, 0,4
    dw NOTE_BB4,3, 0,1
    dw NOTE_A4,4, 0,4
    dw NOTE_G4,3, 0,2
    dw NOTE_E5,3, 0,2
    dw NOTE_G5,3, 0,3
    dw NOTE_A5,4, 0,4
    dw NOTE_F5,3, 0,1
    dw NOTE_G5,4, 0,4
    dw NOTE_E5,4, 0,4
    dw NOTE_C5,3, 0,1
    dw NOTE_D5,3, 0,1
    dw NOTE_B4,4, 0,8
    ; A2: 128 reference-grid units.
    dw NOTE_C5,4, 0,8
    dw NOTE_G4,4, 0,8
    dw NOTE_E4,4, 0,8
    dw NOTE_A4,4, 0,4
    dw NOTE_B4,4, 0,4
    dw NOTE_BB4,3, 0,1
    dw NOTE_A4,4, 0,4
    dw NOTE_G4,3, 0,2
    dw NOTE_E5,3, 0,2
    dw NOTE_G5,3, 0,3
    dw NOTE_A5,4, 0,4
    dw NOTE_F5,3, 0,1
    dw NOTE_G5,4, 0,4
    dw NOTE_E5,4, 0,4
    dw NOTE_C5,3, 0,1
    dw NOTE_D5,3, 0,1
    dw NOTE_B4,4, 0,8
    ; B1: 256 reference-grid units.
    dw 0,8
    dw NOTE_G5,3, 0,1
    dw NOTE_FS5,3, 0,1
    dw NOTE_F5,3, 0,1
    dw NOTE_EB5,4, 0,4
    dw NOTE_E5,4, 0,4
    dw NOTE_GS4,3, 0,1
    dw NOTE_A4,3, 0,1
    dw NOTE_C5,4, 0,4
    dw NOTE_A4,3, 0,1
    dw NOTE_C5,3, 0,1
    dw NOTE_D5,3, 0,1
    dw 0,8
    dw NOTE_G5,3, 0,1
    dw NOTE_FS5,3, 0,1
    dw NOTE_F5,3, 0,1
    dw NOTE_EB5,4, 0,4
    dw NOTE_E5,4, 0,4
    dw NOTE_C6,4, 0,4
    dw NOTE_C6,7, 0,1
    dw 0,12
    dw 0,8
    dw NOTE_G5,3, 0,1
    dw NOTE_FS5,3, 0,1
    dw NOTE_F5,3, 0,1
    dw NOTE_EB5,4, 0,4
    dw NOTE_E5,4, 0,4
    dw NOTE_GS4,3, 0,1
    dw NOTE_A4,3, 0,1
    dw NOTE_C5,4, 0,4
    dw NOTE_A4,3, 0,1
    dw NOTE_C5,3, 0,1
    dw NOTE_D5,3, 0,1
    dw 0,8
    dw NOTE_EB5,4, 0,8
    dw NOTE_D5,4, 0,8
    dw NOTE_C5,5, 0,11
    dw 0,16
    ; B2: 256 reference-grid units.
    dw 0,8
    dw NOTE_G5,3, 0,1
    dw NOTE_FS5,3, 0,1
    dw NOTE_F5,3, 0,1
    dw NOTE_EB5,4, 0,4
    dw NOTE_E5,4, 0,4
    dw NOTE_GS4,3, 0,1
    dw NOTE_A4,3, 0,1
    dw NOTE_C5,4, 0,4
    dw NOTE_A4,3, 0,1
    dw NOTE_C5,3, 0,1
    dw NOTE_D5,3, 0,1
    dw 0,8
    dw NOTE_G5,3, 0,1
    dw NOTE_FS5,3, 0,1
    dw NOTE_F5,3, 0,1
    dw NOTE_EB5,4, 0,4
    dw NOTE_E5,4, 0,4
    dw NOTE_C6,4, 0,4
    dw NOTE_C6,7, 0,1
    dw 0,12
    dw 0,8
    dw NOTE_G5,3, 0,1
    dw NOTE_FS5,3, 0,1
    dw NOTE_F5,3, 0,1
    dw NOTE_EB5,4, 0,4
    dw NOTE_E5,4, 0,4
    dw NOTE_GS4,3, 0,1
    dw NOTE_A4,3, 0,1
    dw NOTE_C5,4, 0,4
    dw NOTE_A4,3, 0,1
    dw NOTE_C5,3, 0,1
    dw NOTE_D5,3, 0,1
    dw 0,8
    dw NOTE_EB5,4, 0,8
    dw NOTE_D5,4, 0,8
    dw NOTE_C5,5, 0,11
    dw 0,16
