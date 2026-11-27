; Nonblocking PC-speaker sequencer driven by the existing IRQ0 cadence.
; Channel 2 generates notes. Music uses reference-derived PIT-cycle timing;
; effects retain their original 18.2065 Hz durations. No DOS calls in IRQ code.

; AudioInit(): save speaker gate/count, establish silent sequencer ownership.
; Inputs/outputs: owned audio state. All registers preserved.
AudioInit:
    pushf
    cli
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    in al, 61h
    and ax, 3
    mov [audio_old_gate], ax
    mov al, 80h                     ; latch only channel 2's current count
    out 43h, al
    in al, 42h
    mov ah, al
    in al, 42h
    xchg al, ah
    mov [audio_old_count], ax
    call AudioStopAll
    mov word [audio_initialized], 1
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    popf
    ret

; SpeakerOff(): clear only speaker/gate bits, preserving keyboard control bits.
SpeakerOff:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    in al, 61h
    and al, 0FCh
    out 61h, al
    mov word [audio_last_divisor], 0
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; SpeakerTone(divisor): mode-3 square wave; zero is silence. Same notes do not
; retrigger the PIT, avoiding unnecessary phase discontinuities/clicks.
SpeakerTone:
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
    or ax, ax
    jz .silent
    cmp ax, [audio_last_divisor]
    je .done
    mov [audio_last_divisor], ax
    mov dx, ax
    mov al, 0B6h
    out 43h, al
    mov ax, dx
    out 42h, al
    mov al, ah
    out 42h, al
    in al, 61h
    or al, 3
    out 61h, al
    jmp .done
.silent:
    call SpeakerOff
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

; AudioStopAll(): reset streams and silence immediately; retain mute preference.
AudioStopAll:
    pushf
    cli
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    call SpeakerOff
    mov word [audio_effect_ptr], 0
    mov word [audio_effect_left], 0
    mov word [audio_priority], 0
    mov word [audio_tick_phase], 10000h-GAME_PIT_DIVISOR
    mov word [audio_music_phase], 0
    mov word [audio_music_ptr], 0
    mov word [audio_music_left], 0
    mov word [audio_music_divisor], 0
    mov word [audio_music_state], 0FFFFh
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    popf
    ret


; PlaySound(event_id): enqueue one cue; a lower priority cannot interrupt an
; important cue such as damage, an extra life, death or winning. No waiting.
PlaySound:
    push bp
    mov bp, sp
    pushf
    cli
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    mov bx, [bp+4]
    cmp bx, SFX_COUNT
    jae .done
    shl bx, 1
    shl bx, 1
    mov ax, [sound_bank+bx+2]
    cmp ax, [audio_priority]
    jb .done
    mov [audio_priority], ax
    mov ax, [sound_bank+bx]
    mov [audio_effect_ptr], ax
    mov word [audio_effect_left], 0
.done:
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    popf
    pop bp
    ret 2

; HandleAudioKeys(): M toggles all sound; B toggles music while retaining cues.
; Music restarts at its opening when enabled. Preferences survive a new game.
HandleAudioKeys:
    pushf
    cli
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    cmp byte [key_pressed+KEY_M], 0
    je .background
    xor word [audio_enabled], 1
    cmp word [audio_enabled], 0
    jne .background
    call SpeakerOff
.background:
    cmp byte [key_pressed+KEY_B], 0
    je .done
    xor word [music_enabled], 1
    mov word [audio_music_state], 0FFFFh
    cmp word [music_enabled], 0
    jne .done
    mov word [audio_music_divisor], 0
    cmp word [audio_effect_ptr], 0
    jne .done
    call SpeakerOff
.done:
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    popf
    ret

; SelectMusic(): synchronize state without consuming any musical time.
; Pause is handled by callers, so returning to PLAY resumes the saved phrase.
; Called only with interrupts disabled. Registers preserved.
SelectMusic:
    push ax
    push bx
    cmp word [music_enabled], 0
    jne .enabled
    mov word [audio_music_divisor], 0
    jmp .done
.enabled:
    mov ax, [game_state]
    cmp ax, [audio_music_state]
    je .done
    mov [audio_music_state], ax
    xor bx, bx
    cmp ax, ST_TITLE
    je .title
    cmp ax, ST_PLAY
    jne .select
    mov bx, music_world
    jmp .select
.title:
    mov bx, music_title
.select:
    mov [audio_music_start], bx
    mov [audio_music_ptr], bx
    mov word [audio_music_left], 0
    mov word [audio_music_divisor], 0
    mov word [audio_music_phase], 0
.done:
    pop bx
    pop ax
    ret

; AdvanceMusic(): consume one reference-grid unit; table lengths are exact.
; Sentinel loops the whole arrangement. Registers preserved; IRQ-safe.
AdvanceMusic:
    push ax
    push si
    cmp word [audio_music_ptr], 0
    je .done
    cmp word [audio_music_left], 0
    je .load
    dec word [audio_music_left]
    jnz .done
.load:
    mov si, [audio_music_ptr]
    cmp word [si+2], 0
    jne .note
    mov si, [audio_music_start]
.note:
    mov ax, [si]
    mov [audio_music_divisor], ax
    mov ax, [si+2]
    mov [audio_music_left], ax
    add si, 4
    mov [audio_music_ptr], si
.done:
    pop si
    pop ax
    ret

; AdvanceEffect(): advance active cue; sentinel releases priority to music.
AdvanceEffect:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    cmp word [audio_effect_ptr], 0
    je .done
    cmp word [audio_effect_left], 0
    je .load
    dec word [audio_effect_left]
    jnz .done
.load:
    mov si, [audio_effect_ptr]
    mov ax, [si+2]
    or ax, ax
    jz .finished
    mov [audio_effect_left], ax
    mov ax, [si]
    mov [audio_effect_divisor], ax
    add si, 4
    mov [audio_effect_ptr], si
    jmp .done
.finished:
    mov word [audio_effect_ptr], 0
    mov word [audio_priority], 0
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

; AudioUpdate(): main-loop control only. Start queued cues promptly, synchronize
; state and silence pause/mute immediately. IRQ0 alone consumes note durations.
AudioUpdate:
    pushf
    cli
    push ax
    cmp word [audio_initialized], 0
    je .done
    cmp word [audio_enabled], 0
    je .silent
    cmp word [game_state], ST_PAUSE
    je .silent
    call SelectMusic
    cmp word [audio_effect_ptr], 0
    je .tone
    cmp word [audio_effect_left], 0
    jne .tone
    call AdvanceEffect
.tone:
    mov ax, [audio_music_divisor]
    cmp word [audio_effect_ptr], 0
    je .output
    mov ax, [audio_effect_divisor]
.output:
    push ax
    call SpeakerTone
    jmp .done
.silent:
    call SpeakerOff
.done:
    pop ax
    popf
    ret

; AudioTimerTick(): one existing hardware period, with DS=CS and IF=0.
; Preserve all registers. Sound effects suspend music, including its fractional
; phase, then release the voice back to that phrase. Rendering cannot alter
; tempo. Pause/mute freeze both clocks. Channel 0 is never reprogrammed here.
AudioTimerTick:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    cmp word [audio_initialized], 0
    jne .initialized
    jmp near .done
.initialized:
    cmp word [audio_enabled], 0
    je .silent
    cmp word [game_state], ST_PAUSE
    je .silent
    call SelectMusic
    cmp word [audio_effect_ptr], 0
    jne .effect_clock
    cmp word [music_enabled], 0
    je .effect_clock
    cmp word [audio_music_ptr], 0
    je .effect_clock
    add word [audio_music_phase], GAME_PIT_DIVISOR
    jc .music_tick
    cmp word [audio_music_phase], MUSIC_UNIT_PIT
    jb .effect_clock
.music_tick:
    ; Carry above represents a 17-bit sum. The wrapped subtraction gives
    ; its true remainder, which fits in a word. A second unit may be due.
    sub word [audio_music_phase], MUSIC_UNIT_PIT
    call AdvanceMusic
    cmp word [audio_music_phase], MUSIC_UNIT_PIT
    jae .music_tick
.effect_clock:
    add word [audio_tick_phase], GAME_PIT_DIVISOR
    jc .advance
    ; A newly queued effect still starts promptly on the one held audio frame.
    cmp word [audio_effect_ptr], 0
    je .select_tone
    cmp word [audio_effect_left], 0
    jne .select_tone
    call AdvanceEffect
    jmp .select_tone
.advance:
    call AdvanceEffect
.select_tone:
    mov ax, [audio_music_divisor]
    cmp word [audio_effect_ptr], 0
    je .tone
    mov ax, [audio_effect_divisor]
.tone:
    push ax
    call SpeakerTone
    jmp .done
.silent:
    call SpeakerOff
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

; AudioShutdown(): stop streams, restore channel-2 count and original gate bits.
; Restores only the speaker bits of port 61h, leaving keyboard bits unchanged.
AudioShutdown:
    pushf
    cli
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    cmp word [audio_initialized], 0
    je .done
    call AudioStopAll
    mov al, 0B6h
    out 43h, al
    mov ax, [audio_old_count]
    out 42h, al
    mov al, ah
    out 42h, al
    in al, 61h
    and al, 0FCh
    or al, [audio_old_gate]
    out 61h, al
    mov word [audio_initialized], 0
.done:
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    popf
    ret
