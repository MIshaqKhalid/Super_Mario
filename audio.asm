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

