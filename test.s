; MIT License
; Copyright (c) 2022 Johan Kotlinski

MACRO dec_vol_15_times
	call	safe_dec_vol
	call	dec_vol
	call	dec_vol
	call	dec_vol
	call	dec_vol
	call	dec_vol
	call	dec_vol
	call	dec_vol
	call	dec_vol
	call	dec_vol
	call	dec_vol
	call	dec_vol
	call	dec_vol
	call	dec_vol
	call	dec_vol
ENDM

MACRO inc_vol_15_times
	ld	a,8
	ldh	[c],a
	ldh	[c],a
	ldh	[c],a
	ldh	[c],a
	ldh	[c],a
	ldh	[c],a
	ldh	[c],a
	ldh	[c],a
	ldh	[c],a
	ldh	[c],a
	ldh	[c],a
	ldh	[c],a
	ldh	[c],a
	ldh	[c],a
	ldh	[c],a
ENDM

; -----

SECTION "boot",ROM0[$100]
        jr      $150

SECTION "hram",HRAM[$ff80]
is_dmg:	db
randhi:	db
randlo:	db

SECTION "test",ROM0[$150]
	; store cpu type
	sub	a,$11
	ldh	[is_dmg],a
	call	z,switch_to_cgb_double_speed

	; random seed (arbitrary)
	ld	a,$a2
	ldh	[randhi],a
	ld	a,$7e
	ldh	[randlo],a

        ; master volume
        ld      a,$77
        ldh     [$24],a

	; mute all channels
	ld	a,0
	ldh	[$25],a

        ; enable sound
        ld      a,$80
        ldh     [$26],a

	; PU1 sweep = disable
	ld	a,0
	ldh	[$10],a

	; PU1 sound length/wave pattern duty
	ld	a,0
	ldh	[$11],a

	; PU1 envelope = 15
	ld	a,$f8
	ldh	[$12],a

	; PU1 low frequency
	ld	a,0
	ldh	[$13],a

	; PU1 hi frequency + trig
	ld	a,$80
	ldh	[$14],a

	; NOI length
	ld	a,0
	ldh	[$20],a

	; NOI envelope
	ld	a,$f8
	ldh	[$21],a

	; NOI prng
	ld	a,0
	ldh	[$22],a

	; NOI trig
	ld	a,$80
	ldh	[$23],a

	ld	hl,0

	; We are now at max volume.
	; As a stress test, go to 0 volume and back a lot of times.

mainloop:
	ld	c,$12		; PU1 envelope
	dec_vol_15_times	; volume => 0
	inc_vol_15_times	; volume => 15

	ld	c,$21		; NOI envelope
	dec_vol_15_times	; volume => 0
	inc_vol_15_times	; volume => 15

	call	random_pause

	dec	hl
	ld	a,h
	or	a,l
	jp	nz,mainloop

	; Unmutes all channels.
	ld	a,$ff
	ldh	[$25],a

	dec_vol_15_times	; NOI volume => 0

beep: 	; Alternates between noise/pulse at max volume.

	call	beep_pause

	ld	c,$12		; PU1 envelope
	dec_vol_15_times	; volume => 0

	call	beep_pause

	ld	c,$21		; NOI envelope
	inc_vol_15_times	; volume => 15

	call	beep_pause

	dec_vol_15_times	; volume => 0

	call	beep_pause

	ld	c,$12		; PU1 envelope
	inc_vol_15_times	; volume => 15

	jp 	beep

beep_pause:
	ld	hl,0
:	dec	hl
	ld	a,h
	or	a,l
	jr	nz,:-
	ret

safe_dec_vol: ; avoids rare envelope lockup when decreasing to $e
	ldh	a,[is_dmg]
	or	a
	jr	nz,:++
:  	ldh	a,[4]	; DIV
	and	$3f
	cp	a,$1f
	jr	nz,dec_vol
	jr	:-
: 	ldh	a,[4]	; DIV
	and	$1f
	cp	a,$f
	jr	z,:-
dec_vol:
	ld	a,9
	ldh	[c],a
	ld	a,$11
	ldh	[c],a
	ld	a,$18
	ldh	[c],a
	ret

switch_to_cgb_double_speed:
	ld	a,$30
	ldh	[0],a
	ld	a,1
	ldh	[$4d],a
	stop
	ret

random_pause:
	; Random number generator using the linear congruential method
	;  X(n+1) = (a*X(n)+c) mod m
	; with a = 17, m = 16 and c = $5c93 (arbitrarily)
	; Ref: D. E. Knuth, "The Art of Computer Programming", Volume 2

	push	hl

	ldh     a,[randhi]
	ld	d,a
	ld	h,a
	ldh	a,[randlo]
	ld	e,a
	ld	l,a

	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,de
	ld	de,$5c93
	add	hl,de

	ld      a,l
	ldh     [randlo],a
	ld    	a,h
	ldh     [randhi],a

	pop	hl

:	dec	a
	jr	nz,:-
	ret
