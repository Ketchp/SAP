; definice pro nas typ procesoru
.include "m169def.inc"
; podprogramy pro praci s displejem
.org 0x1000
.include "print.inc"

; Zacatek programu - po resetu
.org 0
jmp start

; Zacatek programu - hlavni program
.org 0x100
start:
    ; Inicializace zasobniku
    ldi r16, 0xFF
    out SPL, r16
    ldi r16, 0x04
    out SPH, r16
    ; Inicializace displeje
    call init_disp
    ; konec inicializace displeje

	; number A
	ldi r20, 0x5A
	ldi r21, 0x5A
	ldi r22, 0x5A
	ldi r23, 0x5A

	; number B
	ldi r24, 0x5A
	ldi r25, 0x5A
	ldi r26, 0x5A
	ldi r27, 0x5A


	ldi r16, '0'
	ldi r17, 2
	call show_char

	add r20, r24
	adc r21, r25
	adc r22, r26
	adc r23, r27

	in r18, SREG
	ldi r19, 2


	brvs printOverflow
afterOverflow:
	
	ldi r19, 2
	out SREG, r18
	brcs printCarry

afterCarry:
	
end: jmp end        ; Zastavime program - nekonecna smycka


printOverflow:
	ldi r16, 'O'
	mov r17, r19
	inc r19
	call show_char
	
	ldi r16, 'V'
	mov r17, r19
	inc r19
	call show_char

	ldi r16, 'E'
	mov r17, r19
	inc r19
	call show_char

	ldi r16, 'R'
	mov r17, r19
	inc r19
	call show_char

	jmp afterOverflow

printCarry:
	ldi r16, 'C'
	mov r17, r19
	inc r19
	call show_char

	ldi r16, 'A'
	mov r17, r19
	inc r19
	call show_char

	ldi r16, 'R'
	mov r17, r19
	inc r19
	call show_char

	ldi r16, 'R'
	mov r17, r19
	inc r19
	call show_char

	ldi r16, 'Y'
	mov r17, r19
	inc r19
	call show_char

	jmp afterCarry

	
