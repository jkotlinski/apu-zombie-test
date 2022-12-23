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

	ld	c,$12 ; point c to PU1 envelope

	ld	hl,0

	; we are now at max volume.
	; as a stress test, go to 0 volume and back a lot of times.

mainloop:
	dec_vol_15_times
	inc_vol_15_times

	call	random_pause

	dec	hl
	ld	a,h
	or	a,l
	jp	nz,mainloop

	; unmute all channels
	ld	a,$ff
	ldh	[$25],a

beep:
	; we should now be at max volume again.
	; to prove this, emit max volume beeps with silent pauses.

	call	beep_pause
	dec_vol_15_times
	call	beep_pause
	inc_vol_15_times
	jr 	beep

beep_pause:
	ld	hl,0
:	dec	hl
	ld	a,h
	or	a,l
	jr	nz,:-
	ret

dec_vol:
	; Zombie mode fails when writing 9 to NRx2 while DIV bit 4 changes to 1.
	; (This was observed during $6F=>$70 transition in SameBoy, single-speed mode.)
	; The below loops avoids that by delaying the NRx2 write.
	; On CGB double speed, the problem ought to be with bit 5 instead.

	ldh	a,[is_dmg]
	or	a
	jr	nz,:++
:  	ldh	a,[4]
	and	$3f
	cp	a,$1f
	jr	nz,zombie_decrease_volume
	jr	:-
: 	ldh	a,[4]
	and	$1f
	cp	a,$f
	jr	z,:-

	; Now that DIV has a safe value, actually decrease volume.
zombie_decrease_volume:
	ld	a,9
	ldh	[c],a
	ld	a,$11
	ldh	[c],a
	ld	a,$18
	ldh	[c],a
	ret

	; Not particularly random, but should increase coverage a bit.
random_pause:
	ldh	a,[$44]	; LCDC Y-coordinate
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
