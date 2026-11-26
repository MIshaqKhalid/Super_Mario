; Owned program data. Definitions are included once by main.asm.
buffer_segment  dw 0
old_keyboard    dd 0
old_timer       dd 0
hooks_installed db 0
tick_count      dw 0
last_tick       dw 0
bios_tick_phase dw 0
frame_number    dw 0
key_live        times 128 db 0
key_previous    times 128 db 0
key_held        times 128 db 0
key_pressed     times 128 db 0
game_state      dw ST_TITLE
state_frames    dw 0
menu_selection  dw 0
camera_x        dw 0
score_low       dw 0
score_high      dw 0
coin_count      dw 0
lives           dw 3
health          dw 1
level_time      dw 300
second_low      dw 0
second_high     dw 0
invulnerability dw 0
stomp_chain     dw 0
on_ground       dw 0
facing_left     dw 0
previous_feet   dw 160
death_is_pit    dw 0
win_time        dw 0
flag_y          dw FLAG_TOP_Y
win_start_y     dw 0
time_bonus      dw 0
coin_effect_x   dw 0
coin_effect_y   dw 0
coin_effect_timer dw 0
audio_enabled   dw 1
music_enabled   dw 1
audio_initialized dw 0
audio_old_gate  dw 0
audio_old_count dw 0
audio_last_divisor dw 0
audio_effect_ptr dw 0
audio_effect_left dw 0
audio_effect_divisor dw 0
audio_priority  dw 0
audio_tick_phase dw 0
audio_music_phase dw 0
audio_music_state dw 0FFFFh
audio_music_start dw 0
audio_music_ptr dw 0
audio_music_left dw 0
audio_music_divisor dw 0
player          times ACTOR_SIZE db 0
enemies         times ACTOR_SIZE * ENEMY_COUNT db 0
items           times ACTOR_SIZE * ITEM_COUNT db 0
working_map     times LEVEL_W * LEVEL_H db 0
stomp_points    dw 100,200,400,500,800,1000,2000,4000,5000,8000
state_handlers  dw StateTitle, StatePlay, StatePause, StateDying, StateLife
                dw StateWin, StateComplete, StateOver, StateExit, StateCredits

; Immutable level: original team-style layout, not the brief's mock-up.
; Twelve rows of sixty tile bytes. Each line is fifteen columns.
; Codes: 0 sky, 1 ground, 2 brick, 3 coin block, 4 mushroom block,
; 5 empty block, 6/7 pipe top, 8/9 pipe body, 10 stair, 11 coin, 12 flag.
original_map:
    ; Row 0
    db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    ; columns 00..14
    db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    ; columns 15..29
    db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    ; columns 30..44
    db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    ; columns 45..59
    ; Row 1
    db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    ; columns 00..14
    db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    ; columns 15..29
    db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    ; columns 30..44
    db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    ; columns 45..59
    ; Row 2
    db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    ; columns 00..14
    db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    ; columns 15..29
    db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    ; columns 30..44
    db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,12, 0, 0, 0    ; columns 45..59
    ; Row 3
    db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    ; columns 00..14
    db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    ; columns 15..29
    db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    ; columns 30..44
    db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,12, 0, 0, 0    ; columns 45..59
    ; Row 4
    db  0, 0, 0, 0, 0, 0, 0, 0,11, 0, 0, 0, 0, 0, 0    ; columns 00..14
    db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,11, 0, 0, 0, 0    ; columns 15..29
    db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    ; columns 30..44
    db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,12, 0, 0, 0    ; columns 45..59
    ; Row 5
    db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    ; columns 00..14
    db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    ; columns 15..29
    db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    ; columns 30..44
    db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,12, 0, 0, 0    ; columns 45..59
    ; Row 6
    db  0, 0, 0, 0, 0, 0, 4, 3, 2, 2, 2, 0, 0, 0, 0    ; columns 00..14
    db  0, 0, 0, 0,11, 0, 0, 0, 3, 2, 2, 2, 0, 0, 0    ; columns 15..29
    db  0, 0, 0, 0, 0, 0,11, 0, 0, 4, 0, 3, 0, 0, 0    ; columns 30..44
    db  0, 0, 0, 0, 0, 0,10, 0, 0, 0, 0,12, 0, 0, 0    ; columns 45..59
    ; Row 7
    db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    ; columns 00..14
    db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6    ; columns 15..29
    db  7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    ; columns 30..44
    db  0, 0, 0, 0, 0,10,10, 0, 0, 0, 0,12, 0, 0, 0    ; columns 45..59
    ; Row 8
    db  0, 0, 0, 0,11,11, 0, 0, 0, 0, 0, 0, 6, 7, 0    ; columns 00..14
    db 11,11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8    ; columns 15..29
    db  9, 0,11,11, 0, 0, 0, 0, 0, 0, 0, 0, 0,11,11    ; columns 30..44
    db  0, 0, 0, 0,10,10,10, 0, 0, 0, 0,12, 0, 0, 0    ; columns 45..59
    ; Row 9
    db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 9, 0    ; columns 00..14
    db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8    ; columns 15..29
    db  9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    ; columns 30..44
    db  0, 0, 0,10,10,10,10, 0, 0, 0, 0,10, 0, 0, 0    ; columns 45..59
    ; Row 10
    db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1    ; columns 00..14
    db  1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1    ; columns 15..29
    db  1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1    ; columns 30..44
    db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1    ; columns 45..59
    ; Row 11
    db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1    ; columns 00..14
    db  1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1    ; columns 15..29
    db  1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1    ; columns 30..44
    db  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1    ; columns 45..59

; Enemy spawn triples: type, x, y; X/Y are whole pixels.
enemy_spawns:
    dw E_GOOMBA, 240,144
    dw E_GOOMBA, 384,144
    dw E_KOOPA,  432,144
    dw E_GOOMBA, 640,144
    dw E_GOOMBA, 676,144
    dw E_KOOPA,  724,144

msg_memory      db 'Cannot reserve the 64,000-byte frame buffer.',13,10,'$'
txt_title       db 'MARIO',0
txt_engine      db 'SUPER MARIO ENGINE',0
txt_subtitle    db 'A REAL MODE ADVENTURE',0
txt_start       db 'START GAME',0
txt_credits     db 'CREDITS',0
txt_exit        db 'EXIT',0
txt_title_help  db 'UP / DOWN   ENTER TO SELECT',0
txt_controls    db 'ARROWS MOVE   SHIFT RUN   SPACE JUMP',0
txt_footer      db 'NASM / 8086 / MODE 13H',0
txt_pause       db 'PAUSED',0
txt_resume      db 'P TO RESUME   ESC TO TITLE',0
txt_life        db 'WORLD 1-1',0
txt_ready       db 'GET READY!',0
txt_over        db 'GAME OVER',0
txt_complete    db 'LEVEL COMPLETE',0
txt_enter       db 'ENTER TO RETURN TO TITLE',0
txt_final       db 'FINAL SCORE',0
txt_timebonus   db 'TIME BONUS',0
txt_remaining   db 'SECONDS LEFT',0
txt_score       db 'SCORE',0
txt_coins       db 'COIN',0
txt_world       db '1-1',0
txt_world_label db 'WORLD',0
txt_x           db 'X',0
txt_time        db 'TIME',0
txt_lives       db 'LIFE',0
txt_hp          db 'HP',0
txt_logo_top    db 'SUPER MARIO',0
txt_logo_bottom db 'ENGINE',0
txt_menu_keys   db 'UP / DOWN   ENTER TO SELECT',0
txt_credit_title db 'CREDITS',0
txt_project     db 'COAL SEMESTER PROJECT',0
txt_taha        db 'MUHAMMAD TAHA',0
txt_taha_roll   db '25F-0755',0
txt_ishaq       db 'MUHAMMAD ISHAQ KHALID',0
txt_ishaq_roll  db '25F-0653',0
txt_asad        db 'ASAD ALI',0
txt_asad_roll   db '25F-0698',0
txt_section     db 'SECTION',0
txt_section_id  db 'BCS-3B',0
txt_credit_back db 'ENTER / ESC TO RETURN',0
txt_mute_key    db 'M',0
txt_effects_only db 'FX',0
txt_audio_on    db 'ON',0
txt_audio_off   db 'OFF',0
