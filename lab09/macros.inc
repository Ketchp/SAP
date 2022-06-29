.macro to_data_mem ;data_address, register
	sts @0, @1
.endmacro

.macro to_data_mem_i ;data_addres, value_i
	ldi temporary, @1
	sts @0, temporary
.endmacro

.macro from_data_mem ;register, data_address
	lds @0, @1
.endmacro

.macro from_program_mem
	ldi r30, low (2*@1)
	ldi r31, high(2*@1)

	lpm @0, Z
.endmacro


.macro from_program_mem_k
	ldi r30, low (2*@1)
	ldi r31, high(2*@1)

	add r30, @2

	lpm @0, Z
.endmacro
