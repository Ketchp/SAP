.dseg; data memory
.org 0x100

centi_seconds: .byte 1
seconds: .byte 1
minutes: .byte 1


state: .byte 1

.equ INITIAL_CLOCK = 0b00000000
.equ RUNNING_CLOCK = 0b00000001
.equ STOPPED_CLOCK = 0b00000010

.equ TIME_OVER_MIN = 0b00000100


.equ DISP_UPDATE = 0b01000000
.equ TIME_UPDATE = 0b10000000



.cseg; program memory
.include "m169def.inc"
.include "lab10_macros.inc"

.org 0x0
jmp setup

.org 0x4
jmp PCINT0_IRS

.org 0x6
jmp PCINT1_IRS

.org 0xE
jmp TIMER1_COMPA_IRS

.org 0x14
jmp TIMER0_COMP_IRS

.org 0x1000
.include "print.inc"


setup:
    cli
	; stack init
	ldi r16, 0xFF
    out SPL, r16
    ldi r16, 0x04
    out SPH, r16

    ; display init
    call init_disp

    ; program memory init
    ldi r16, 0
    sts centi_seconds, r16
    sts seconds, r16
    sts minutes, r16
    ori r16, 0x80
    sts state, r16

    ldi r16, DISP_UPDATE
    sts state, r16

    timer0_init
    timer1_init
    joystick_init

    sei

loop:
    cli
    lds r16, state
    andi r16, TIME_UPDATE
    brne RESOLVE_TIME
    TIME_RESOLVED:
    lds r16, state
    andi r16, ( 0xff - TIME_UPDATE )
    sts state, r16

    andi r16, DISP_UPDATE
    brne UPDATE_DISPLAY
    DISPLAY_UPDATED:
    lds r16, state
    andi r16, ( 0xff - DISP_UPDATE )
    sts state, r16

    sei
    nop ; empty instructions to enable more
    nop ; interrupts to happen before next cli
    jmp loop

RESOLVE_TIME:
    lds r16, state
    andi r16, RUNNING_CLOCK
    breq MODULATE_TIME ;clock not running
    lds r16, state
    ori r16, DISP_UPDATE    
    sts state, r16

MODULATE_TIME:
    lds r16, centi_seconds
    subi r16, 100
    brne TIME_RESOLVED

    sts centi_seconds, r16
    lds r16, seconds
    inc r16
    sts seconds, r16
    subi r16, 60
    brne TIME_RESOLVED

    sts seconds, r16
    lds r16, state
    ori r16, TIME_OVER_MIN
    sts state, r16
    lds r16, minutes
    inc r16
    sts minutes, r16
    jmp TIME_RESOLVED

UPDATE_DISPLAY:
    lds r16, state
    andi r16, TIME_OVER_MIN
    brne LOAD_MIN_SEC

        lds r29, centi_seconds
        ldi r30, '-'
        lds r31, seconds
        jmp TIME_LOADED

    LOAD_MIN_SEC:
        lds r29, seconds
        ldi r30, ':'
        lds r31, minutes

    ; r31 r31 r30 r29 r29
    TIME_LOADED:
        mov r25, r31
        ldi r26, 10
        call MODULO

        mov r16, r27
		subi r16, -'0'
        ldi r17, 2
        call show_char

        mov r16, r25
		subi r16, -'0'
        inc r17
        call show_char

        mov r16, r30
        inc r17
        call show_char

        mov r25, r29
        ldi r26, 10
        call MODULO

        mov r16, r27
		subi r16, -'0'
        inc r17
        call show_char

        mov r16, r25
		subi r16, -'0'
        inc r17
        call show_char

    jmp DISPLAY_UPDATED


; r27 <- ( r25 / r26 ), r25 <- ( r25 % r26 )
MODULO:
    ser r27
    clr r28

    ONE_MODULO_STEP:
        inc r27
        sub r25, r26
        brsh ONE_MODULO_STEP

    add r25, r26
    ret


TIMER1_COMPA_IRS:
    push r16
    in r16, SREG
    push r16

    lds r16, centi_seconds
    inc r16
    sts centi_seconds, r16

    lds r16, state
    ori r16, TIME_UPDATE
    sts state, r16

    pop r16
    out SREG, r16
    pop r16
    reti


; left(0000_0100) right(0000_1000) PORT-E
PCINT0_IRS:
    push r16
    in r16, SREG
    push r16

    timer0_start

    pop r16
    out SREG, r16
    pop r16
    reti

; enter(0001_0000) PORT-B
PCINT1_IRS:
    push r16
    in r16, SREG
    push r16

    timer0_start

    pop r16
    out SREG, r16
    pop r16
    reti

TIMER0_COMP_IRS:
    push r16
    in r16, SREG
    push r16

    timer0_reset

    in r16, PINE
    andi r16, 0b00000100
    breq START_PRESSED

    in r16, PINE
    andi r16, 0b00001000
    breq RESET_PRESSED

    in r16, PINB
    andi r16, 0b00010000
    breq STOP_PRESSED

    HANDLED_PRESS:

    pop r16
    out SREG, r16
    pop r16
    reti


START_PRESSED:
    lds r16, state
    andi r16, ( STOPPED_CLOCK + RUNNING_CLOCK )
    brne HANDLED_PRESS
    
    lds r16, state
    ori r16, RUNNING_CLOCK
    sts state, r16

    timer1_start

    jmp HANDLED_PRESS
    
RESET_PRESSED:
    lds r16, state
    andi r16, ( STOPPED_CLOCK + RUNNING_CLOCK )
    breq HANDLED_PRESS

    timer1_reset
	
	ldi r16, 0
	sts minutes, r16
	sts seconds, r16
	sts centi_seconds, r16

    ldi r16, DISP_UPDATE ; + TIME_UPDATE
    sts state, r16

    jmp HANDLED_PRESS

STOP_PRESSED:
    lds r16, state
    andi r16, ( STOPPED_CLOCK + RUNNING_CLOCK ) ; clock in initial position
    breq HANDLED_PRESS 

    lds r16, state
    andi r16, ( 0xff - RUNNING_CLOCK )       ; clear RUNNING flag
    ori r16, ( DISP_UPDATE + STOPPED_CLOCK ) ; set UPDT|STOP flag
    sts state, r16

    jmp HANDLED_PRESS





