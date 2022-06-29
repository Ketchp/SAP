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

	ldi r16, 0x5A

	mov r18, r16
	mov r19, r16
	andi r18, 0xF0
	lsr r18
	lsr r18
	lsr r18
	lsr r18
	andi r19, 0x0F
	
	ldi r16, '0'
	ldi r17, 2
	call show_char

	ldi r16, 'X'
	ldi r17, 3
	call show_char

	subi r18, 0x0A
	brpl letter1

back1:
	ldi r20, '0'+0x0A
	add r18, r20

	mov r16, r18
	ldi r17, 4
	call show_char


	mov r18, r19

	subi r18, 0x0A
	brpl letter2

back2:
	ldi r20, '0'+0x0A
	add r18, r20

	mov r16, r18
	ldi r17, 5
	call show_char



end: jmp end        ; Zastavime program - nekonecna smycka

letter1:
	ldi r20, 'A'-'9'-1
	add r18, r20
	jmp back1

letter2:
	ldi r20, 'A'-'9'-1
	add r18, r20
	jmp back2
