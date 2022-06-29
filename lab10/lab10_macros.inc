.macro joystick_init
    ; nastaveni portu E (smer vlevo a vpravo) change interrupt 8-15
    in r16, PORTE
    in r17, DDRE
    ori r16, 0b00001100
    andi r17, 0b11110011
    out PORTE, r16
    out DDRE, r17

    ; nastaveni portu B (enter) change interrupt 8-15
    in r16, PORTB
    in r17, DDRB
    ori r16, 0b00010000
    andi r17, 0b11101111
    out PORTB, r16
    out DDRB, r17

    clr r16
    sts DIDR1, r16 ; maybe not needed

    ldi r16, 0b00001100
    sts PCMSK0, r16      ; PCINT mask port E

    ldi r16, 0b00010000
    sts PCMSK1, r16      ; PCINT mask port B

	in r16, EIMSK
    ori r16, 0b11000000 ; enable PCINT1/0
    out EIMSK, r16
.endmacro



.equ TIMER1_OCR1A = 20000
.macro timer1_init
	; timer stopped at start
	ldi r16, 0b00001000 ; CTC mode TOP = OCR1A & timer stopped
	sts TCCR1B, r16

	ldi r16, high( TIMER1_OCR1A )
	ldi r17, low( TIMER1_OCR1A )
	sts OCR1AH, r16
	sts OCR1AL, r17

    ldi r16, 0b00000010 ; ouput compare A match interupt enable
    sts TIMSK1, r16
.endmacro


.macro timer1_start
	lds r16, TCCR1B
	ori r16, 0b00000001 ; start with no prescaling
	sts TCCR1B, r16
.endmacro

.macro timer1_reset
	lds r16, TCCR1B
	andi r16, 0b11111000 ; clear prescaler select bits = clock stopped
	sts TCCR1B, r16
	
	clr r16

	sts TCNT1H, r16
	sts TCNT1L, r16 ; clear timer/counter
.endmacro

.macro timer0_init
	; timer stopped at start
	ldi r16, 0b00001000 ; CTC mode
	out TCCR0A, r16

	; time to match ~10ms with prescaling 256
	ldi r16, 78
	out OCR0A, r16 ; set compare register

	ldi r16, 0b00000010 ; Output Compare Match A Interrupt Enable
	sts TIMSK0, r16
.endmacro

.macro timer0_start
	clr r16
	out TCNT0, r16 ; clear timer/counter

	in r16, TCCR0A
	ori r16, 0b00000100 ; start with /256 prescaling
	out TCCR0A, r16
.endmacro

.macro timer0_reset
	in r16, TCCR0A
	andi r16, 0b11111000 ; clear prescaler select bits = clock stopped
	out TCCR0A, r16
.endmacro





