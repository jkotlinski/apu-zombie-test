; MIT License
; Copyright (c) 2022 Johan Kotlinski

MACRO dec_vol		
	; Tries to avoid APU tick during decrease.
	; $1f was determined by trial and error.
: 	ldh	a,[4]
	and	$1f
	cp	a,$1f
	jr	z,:-

	ld	a,9
	ldh	[c],a
	ld	a,$11
	ldh	[c],a
	ld	a,$18
	ldh	[c],a
ENDM

MACRO dec_vol_15_times	
	dec_vol
	dec_vol
	dec_vol
	dec_vol
	dec_vol
	dec_vol
	dec_vol
	dec_vol
	dec_vol
	dec_vol
	dec_vol
	dec_vol
	dec_vol
	dec_vol
	dec_vol
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

SECTION "test",ROM0[$150]
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

	dec	hl
	ld	a,h
	or	a,l
	jp	nz,mainloop

	; unmute all channels
	ld	a,$ff
	ldh	[$25],a

pulse:
	; we should now be at max volume again.
	; to prove this, switch between max/min volume with a pause.

	call	pause
	dec_vol_15_times
	call	pause
	inc_vol_15_times
	jp 	pulse

pause:
	ld	hl,0
pause_loop:
	dec	hl
	ld	a,h
	or	a,l
	jr	nz,pause_loop
	ret
