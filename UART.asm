
ldi R21, high(ramend)
out sph, R21
ldi r21, low(ramend)
out spl, r21

ldi R16, (1<<TXEN0) ;| (1<<RXEN0)
out UCSR0B, r16
ldi r16, (1<<UCSZ00) | (1<<UCSZ01) ;| (1<<USBS0)
sts UCSR0C, R16
ldi r16, 0x33
out UBRR0L, r16

call sv_data1
mov	 R20,ZL
mov	 R21,ZH
call sv_data2

here:
ldi ZL, low(0x0200)
ldi ZH, high(0x0200)

call SendStr
call RecvStr
mov	 ZL,R20
mov	 ZH,R21
call SendStr
ldi	ZL,low(0x0400)
ldi	ZH,high(0x0400)
call SendStr

jmp here

SendStr:
	ld	R16, Z+
chck_SndStr:
	cpi	ZH, 0x04 ; check for the required stop address 0x400
	breq qtSndStr
	cpi	 R16, 0x24 ;check for the NULL ASCII $ sign
	breq qtSndStr
	call SendChar
	rjmp chck_SndStr
qtSndStr:
		ret
SendChar:
	sbis UCSR0A, UDRE0 ;Monitor the UDRE bit of the UCSRA register to make sure UDR is ready for the next byte.
	rjmp SendChar ;if UDR is empty wait more- UDRE flag is low
	out UDR0, R16 ;send data to UDR
ret

RecvStr:
	ldi ZL, low(0x0400)
	ldi ZH, high(0x0400)
chck_RcvStr:
	call RecvChar
	cpi R16, 0x0D ;check for the Enter ASCII (0x0D) input
	breq qtRcvStr

	rjmp chck_RcvStr
qtRcvStr:
	ldi R16, 0x24 ;I didn't forget $ sign
	st  Z, R16
	ret
RecvChar:
	sbis UCSR0A, RXC0 ;wait (recieve comp. '0') for the new data to be inserted from keyboard
	rjmp RecvChar
	in R16, UDR0
	st Z+, R16
	ret


sv_data1:
	ldi ZL, low(0x0200)
	ldi ZH, high(0x0200)
	ldi R16, '''
	st z+, R16
	ldi R16, 'S'
	st z+, R16
	ldi R16, 'U'
	st z+, R16
	ldi R16, 'P'
	st z+, R16
	ldi R16, 'P'
	st z+, R16
	ldi R16, '?'
	st z+, R16
	ldi R16, 0x0D
	st z+, R16
	ldi R16, 0x24
	st z+, R16
ret

sv_data2:
	mov	 ZL,R20
	mov	 ZH,R21
	ldi R16, 'W'
	st z+, R16
	ldi R16, 'R'
	st z+, R16
	ldi R16, 'O'
	st z+, R16
	ldi R16, 'N'
	st z+, R16
	ldi R16, 'G'
	st z+, R16
	ldi R16, ' '
	st z+, R16
	ldi R16, 'A'
	st z+, R16
	ldi R16, 'N'
	st z+, R16
	ldi R16, 'S'
	st z+, R16
	ldi R16, 'W'
	st z+, R16
	ldi R16, 'E'
	st z+, R16
	ldi R16, 'R'
	st z+, R16
	ldi R16, ':'
	st z+, R16
	ldi R16, ' '
	st z+, R16
	ldi R16, 0x24
	st z+, R16
ret
