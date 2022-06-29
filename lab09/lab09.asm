.dseg; data memory
.org 0x100

data_flow_direction: .byte 1
data_text_offset:	 .byte 1

.cseg; program memory
.include "m169def.inc"

.org 0x0
jmp setup

.org 0x4
jmp PCINT0_HANDLER

.org 0x1000
.include "print.inc"


.org 0x100
prog_text:
	.db "HELLO WORLD - AVR IS AWESOME"  ;READ ONLY

.equ DISP_W = 6
.equ TEXT_W = ( DISP_W + 2*PC - 2*prog_text )

.def temporary = r25
.def temporary2 = r24
.include "macros.inc"

setup:
	ldi r16, 0xFF
    out SPL, r16
    ldi r16, 0x04
    out SPH, r16
    call init_disp


	in r16, DDRE
	in r17, PORTE
	andi r16, 0b1111_0011
	ori r17, 0b0000_1100
	out DDRE, r16
	out PORTE, r17

	ldi r16, 0b0000_0000
	sts DIDR1, r16

	; todo I/O
	in r16, EIMSK
	ori r16, 0b0100_0000
	out EIMSK, r16

;	ldi r31, 0x00      ;PCMSK0
;	ldi r30, 0x6b

	lds r16, PCMSK0
	ori r16, 0b0000_1100
	sts PCMSK0, r16

	; initial text flow direction
	to_data_mem_i data_flow_direction, 0x01

	; initial text offset
	to_data_mem_i data_text_offset, 0x00

	sei
	jmp loop

.def offset = r20
.def disp_offset = r23
loop:
	from_data_mem offset, data_text_offset


	ldi disp_offset, 0
	disp_offset_loop:
		mov temporary, offset
		add temporary, disp_offset
		ldi temporary2, TEXT_W
		call modulate


		.def letter = r16
		.def letter_pos = r17
		.def current_offset = r21
		mov current_offset, temporary
		subi current_offset, DISP_W
		brmi empty_char

		cpi current_offset, TEXT_W
		brsh empty_char

			from_program_mem_k letter, prog_text, current_offset
			cpi letter, 0
			brne print_one

		empty_char:
			ldi letter, 'X'
		
		print_one:
		ldi letter_pos, 2
		add letter_pos, disp_offset
		call show_char



		inc disp_offset
		ldi temporary, DISP_W
		cpse disp_offset, temporary
		jmp disp_offset_loop
		.undef current_offset


	.def direction = r21
	from_data_mem direction, data_flow_direction
	add offset, direction
	subi offset, -TEXT_W
	.undef direction


	mov temporary, offset
	ldi temporary2, TEXT_W
	call modulate


	to_data_mem data_text_offset, temporary

	call wait
	jmp loop


substract:
	sub temporary, temporary2
modulate:
	cp temporary, temporary2
	brsh substract
	ret


wait:
	ldi temporary, 0xff
wait_loop:
	call wait2
	call wait2
	call wait2
	call wait2
	dec temporary
	brne wait_loop
	ret


wait2:
	ldi temporary2, 0xff
wait2_loop:
	nop
	nop
	nop
	nop
	dec temporary2
	brne wait2_loop
	ret


PCINT0_HANDLER:
	push r16
	in r16, SREG
	push r16
	push r17


	in r16, PINE
	mov r17, r16

	andi r16, 0b0000_1000
	breq right

	andi r17, 0b0000_0100
	breq left

	jmp after

left:
	to_data_mem_i data_flow_direction, 0x01
	jmp after

right:
	to_data_mem_i data_flow_direction, 0xff
	
after:

	pop r17
	pop r16
	out SREG, r16
	pop r16
	reti

