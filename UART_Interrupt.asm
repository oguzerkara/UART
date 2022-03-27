
.equ ones = 0xFF
.equ zeros = 0x00

.cseg
.org 0x0000
	jmp start
.org 0x0024
	jmp IsrRec ;recieving char
;.org 0x0026
;	jmp data reg emp
.org 0x0028
	jmp IsrTr ;transmitting char

start:

ldi r16, low(RAMEND)
out spl, r16
ldi r16, High(RAMEND)
out sph, r16

call sv_data1
call sv_data2

ldi R16, (1<<TXEN0) | (1<<RXEN0) | (1<<TXCIE0) | (1<<RXCIE0) | (1<<UDRIE0)
out UCSR0B, R16 ;Both transmitter and receiver enabled,
ldi R16, 0x40
out UBRR0L, R16 ;64 = (10 MHz/16(9600))- 1
ldi R16, (1<<UCSZ00) | (1<<UCSZ01) ;already default for character bits, also USBS0 = 0 by default for 1-bit stop bit
sts UCSR0C, R16;(011) => 8-bit size
;1 stop bit USBS = '0'
;UPM1 is disabled for no parity
;no interrupt : RXCIE=TXCIE=UDRIE='0'

ldi YL, low(0x0200)
ldi YH, high(0x0200) ;reload the address to register for monitoring
ldi R16, (0<<RXC0) | (1<<TXC0)
sts UCSR0A, R16
sei

here: rjmp here

IsrTr:

ld R16, Y+
cpi YH, 0x04 ; check for the required stop address 0x0400 which is separated for recieved data
breq qtTrStr1
cpi R16, 0x24 ;check for the NULL ASCII $ sign
breq qtTrStr1
out UDR0,R16
reti
qtTrStr1:
ldi R16, (1<<RXC0) | (0<<TXC0)
sts UCSR0A, R16

reti


IsrRec:

in R17, UDR0
cpi R17, 0x0D ;check for the Enter ASCII (0x0D) input
breq qtRecStr
st Z+,R17
reti

qtRecStr:
ldi R17, 0x24 ;I didn't forget $ sign
st Z, R17
ldi R17, (0<<RXC0) | (1<<TXC0)
sts UCSR0A, R17

reti

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

ret
