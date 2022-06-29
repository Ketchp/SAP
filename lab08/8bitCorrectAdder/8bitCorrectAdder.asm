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
	

	ldi r16, '0'
	ldi r17, 2
	call show_char

	ldi r16, 'X'
	ldi r17, 3
	call show_char




	; (4 * R16 + 3 * R17 - R18) / 8
	; number A
	ldi r16, 5
	; number B
	ldi r17, 10
	; number C
	ldi r18, 58

	mov r26, r16
	mov r27, r16

	mov r28, r17
	mov r29, r17

	mov r30, r18
	mov r31, r18

	ldi r20, 8

	fill:
		asr r26
		asr r28
		asr r30
	dec r20
	brne fill

	ldi r20, 2
	x2loop:
		lsl r27
		brcs withCarry
			lsl r26
			jmp withoutCarry
		withCarry:
			lsl r26
			ori r26, 1
		withoutCarry:
	
	dec r20
	brne x2loop


	mov r24, r28
	mov r25, r29

	lsl r25
	brcs withCarry_
		lsl r24
		jmp withoutCarry_
	withCarry_:
		lsl r24
		ori r24, 1
	withoutCarry_:

	add r29, r25
	adc r28, r24

	ldi r20, 0xFF
	eor r30, r20
	eor r31, r20

	add r27, r29
	adc r26, r28

	add r27, r31
	adc r26, r30

	ldi r20, 1
	add r27, r20

	ldi r20, 0
	adc r26, r20

	ldi r17, 4

	ldi r20, 3
	x3loop:
		asr r26
		brcs withCarry3
			lsr r27
			brcs prec1
			prec1_back:
			jmp withoutCarry3
		withCarry3:
			lsr r27
			brcs prec2
			prec2_back:
			ori r27, 0x80
		withoutCarry3:
	
	dec r20
	brne x3loop


	mov r16, r26
	call printHex

	mov r16, r27
	call printHex


end: jmp end        ; Zastavime program - nekonecna smycka


prec1:
	ldi r16, '\\'
	ldi r17, 7
	call show_char
	ldi r16, '\\'
	ldi r17, 2
	call show_char
	ldi r17, 3
	jmp prec1_back
prec2:
	ldi r16, '\\'
	ldi r17, 2
	call show_char
	ldi r16, '\\'
	ldi r17, 7
	call show_char
	ldi r17, 3
	jmp prec2_back


printHex:
	push r16
	andi r16, 0xF0
	lsr r16
	lsr r16
	lsr r16
	lsr r16
	call printSingle
	pop r16
	andi r16, 0x0F
	call printSingle
	ret


printSingle:
	subi r16, 0x0A
	brpl letter
	letter_back:
	subi r16, -('0'+0x0A)
	call show_char
	inc r17
	ret

	letter:
		subi r16, -('A'-'9'-1)
		jmp letter_back


