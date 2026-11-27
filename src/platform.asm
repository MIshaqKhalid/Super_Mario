; DOS/VGA ownership and the only interrupt handlers in the program.

; InitializeGame(): called after the entry file establishes SS:SP and DS/ES.
; Release unused DOS memory, allocate pixels and initialize existing systems.
; Registers preserved; allocation failures print a DOS message and terminate.
InitializeGame:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    mov bx, (ProgramEnd - $$ + 100h + 15) / 16
    mov ah, 4Ah
    int 21h
    jc .memory_error
    mov bx, 1000h                    ; 65,536-byte graphics segment
    mov ah, 48h
    int 21h
    jc .memory_error
    mov [buffer_segment], ax
    call VideoInit
    call InstallInterrupts
    call AudioInit
    call NewGame
    mov word [game_state], ST_TITLE
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
.memory_error:
    mov dx, msg_memory
    mov ah, 09h
    int 21h
    mov ax, 4C01h
    int 21h


; VideoInit(): Mode 13h and our 32-entry DAC palette. Preserves all registers.
VideoInit:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    mov ax, 0013h
    int 10h
    mov dx, 03C8h
    xor al, al
    out dx, al
    inc dx
    mov si, palette
    mov cx, PALETTE_COLOURS*3
.colour:
    lodsb
    out dx, al
    dec cx
    jnz .colour
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; InstallInterrupts(): save INT 09h/08h vectors, install our handlers and set
; a 25.3286 Hz game tick. TimerISR keeps BIOS/DOS time at the normal 18.2065 Hz.
; Inputs/outputs: none. Registers preserved.
InstallInterrupts:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    mov ax, 3509h
    int 21h
    mov [old_keyboard], bx
    mov [old_keyboard+2], es
    mov ax, 3508h
    int 21h
    mov [old_timer], bx
    mov [old_timer+2], es
    mov dx, KeyboardISR
    mov ax, 2509h
    int 21h
    mov dx, TimerISR
    mov ax, 2508h
    int 21h
    mov word [bios_tick_phase], 0
    call ProgramGameTimer
    mov byte [hooks_installed], 1
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; KeyboardISR: hardware entry. Owns port 60h, keyboard acknowledgement, EOI.
; Uses CS to recover DS, preserves changed registers and returns with IRET.
KeyboardISR:
    push ax
    push bx
    push ds
    mov ax, cs
    mov ds, ax
    in al, 60h
    cmp al, 0E0h
    je .ack
    cmp al, 0E1h
    je .ack
    mov ah, al
    and al, 7Fh
    xor bx, bx
    mov bl, al
    test ah, 80h
    jnz .released
    mov byte [key_live+bx], 1
    jmp .ack
.released:
    mov byte [key_live+bx], 0
.ack:
    in al, 61h
    mov ah, al
    or al, 80h
    out 61h, al
    mov al, ah
    out 61h, al
    mov al, 20h
    out 20h, al
    pop ds
    pop bx
    pop ax
    iret

; ProgramGameTimer(): channel 0 mode 3 at 25.3286 Hz. Interrupt state and AX
; are preserved so callers cannot accidentally enable or disable interrupts.
ProgramGameTimer:
    push ax
    pushf
    cli
    mov al, 36h
    out 43h, al
    mov ax, GAME_PIT_DIVISOR
    out 40h, al
    mov al, ah
    out 40h, al
    popf
    pop ax
    ret

; RestoreSystemTimer(): restore the standard divisor of 65,536 (encoded as 0).
RestoreSystemTimer:
    push ax
    pushf
    cli
    mov al, 36h
    out 43h, al
    xor ax, ax
    out 40h, al
    out 40h, al
    popf
    pop ax
    ret

; TimerISR: IRQ0/INT 08h callback. Every hardware tick advances the game.
; A fixed-point phase chains the BIOS handler at exactly its original average
; rate; non-BIOS ticks acknowledge the PIC here. The interrupt frame is intact.
TimerISR:
    push ax
    push ds
    mov ax, cs
    mov ds, ax
    inc word [cs:tick_count]
    call AudioTimerTick             ; no DOS/BIOS calls; independent of rendering
    pop ds
    add word [cs:bios_tick_phase], GAME_PIT_DIVISOR
    jc .bios_tick
    mov al, 20h
    out 20h, al
    pop ax
    iret
.bios_tick:
    pop ax
    jmp far [cs:old_timer]

; WaitFrame(): consume one 25.3286 Hz game tick; HLT sleeps with interrupts on.
; Long stalls discard excess backlog rather than accelerating the game forever.
WaitFrame:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
.wait:
    cli
    mov ax, [tick_count]
    sub ax, [last_tick]
    jnz .ready
    sti
    hlt
    jmp .wait
.ready:
    cmp ax, 4
    jbe .consume
    mov ax, [tick_count]
    mov [last_tick], ax
    jmp .resume
.consume:
    inc word [last_tick]
.resume:
    sti
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; ReadKeys(): atomic held-key snapshot and rising edges for menus/jump/pause.
; Outputs: key_held/key_pressed/key_previous arrays. Registers preserved.
ReadKeys:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    cli
    xor bx, bx
    mov cx, 128
.key:
    mov al, [key_live+bx]
    mov [key_held+bx], al
    mov ah, [key_previous+bx]
    xor ah, 1
    and ah, al
    mov [key_pressed+bx], ah
    mov [key_previous+bx], al
    inc bx
    dec cx
    jnz .key
    sti
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; Shutdown(): restore interrupt ownership, text mode and allocated DOS memory.
; Inputs: none. Outputs: clean DOS environment. Registers preserved.
Shutdown:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    call AudioShutdown
    cmp byte [hooks_installed], 0
    je .video
    call RestoreSystemTimer
    lds dx, [old_keyboard]
    mov ax, 2509h
    int 21h
    push cs
    pop ds
    lds dx, [old_timer]
    mov ax, 2508h
    int 21h
    push cs
    pop ds
    mov byte [hooks_installed], 0
.video:
    mov ax, 0003h
    int 10h
    mov ax, [buffer_segment]
    or ax, ax
    jz .done
    mov es, ax
    mov ah, 49h
    int 21h
    mov word [buffer_segment], 0
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
