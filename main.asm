bits 16
cpu 8086
org 100h
jmp Start
%include "engine.asm"


.frame:
    call WaitFrame
    call ReadKeys
    call HandleAudioKeys
    cmp word [game_state], ST_PAUSE
    je .dispatch
    inc word [frame_number]
.dispatch:
    mov bx, [game_state]
    shl bx, 1
    call word [state_handlers + bx]
    cmp word [game_state], ST_EXIT
    je .done
    call AudioUpdate
    call RenderFrame
    call PresentFrame
    jmp .frame
.done:
    call Shutdown
    mov ax, 4C00h
    int 21h

; Private 2 KiB stack, retained when DOS releases the unused program block.
align 2 ; adjust the next address to the nearest multiple of 2, inserting padding bytes if necessary. i.e. even memory address
StackBottom:
    times 2048 db 0
StackTop:
ProgramEnd:
