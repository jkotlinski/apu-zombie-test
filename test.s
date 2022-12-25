; MIT License
; Copyright (c) 2022 Johan Kotlinski

MACRO dec_vol_15_times
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

SECTION "test",ROM0[$150]
	; store cpu type
	sub	a,$11
	ldh	[is_dmg],a
	call	z,switch_to_cgb_double_speed

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

dec_vol:
	; Spins until DIV reached a safe value.
	ldh	a,[is_dmg]
	or	a
	jr	nz,:++
:  	ldh	a,[4]	; DIV
	and	$3f
	cp	a,$1f
	jr	nz,do_dec_vol
	jr	:-
: 	ldh	a,[4]	; DIV
	and	$1f
	cp	a,$f
	jr	z,:-

do_dec_vol:
	; Decrements volume.
	ld	a,9
	ldh	[c],a
	ld	a,$11
	ldh	[c],a
	ld	a,$18
	ldh	[c],a
	ret

random_pause:
	ldh	a,[$44]	; LCDC
	inc	a
:	dec	a
	jr	nz,:-
	ret

switch_to_cgb_double_speed:
	ld	a,$30
	ldh	[0],a
	ld	a,1
	ldh	[$4d],a
	stop
	ret
