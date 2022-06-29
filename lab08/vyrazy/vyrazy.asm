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

	
	ldi r16, 5
	ldi r17, 10
	ldi r18, 58

	lsl r16
	lsl r16

;	ldi r19, 4
;	mul r19, r16;  4 x r16
;	mov r16 r0;   r0 -> r16

	ldi r19, 3
	mul r19, r17;  3 x r17 -> r0

	add r16, r0

	sub r16, r18

	asr r16
	asr r16
	asr r16

	mov r20, r16


    ; *** ZDE muzeme psat nase instrukce
;	adiw r16, '0'
;    ldi r17, 2      ; pozice (zacinaji od 2)
;    call show_char  ; zobraz znak z R16 na pozici z R17

end: jmp end        ; Zastavime program - nekonecna smycka
