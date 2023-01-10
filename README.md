# APU Zombie Test

Tests the Game Boy amplitude envelope generation techniques known as "zombie mode".

## Test Instructions

1. [Download test ROM here.](https://github.com/jkotlinski/apu-zombie-test/releases)
2. Start ROM on your device.
3. Wait a while (up to two minutes, depending on device).
4. Verify that the device beeps loudly, like [expected-dmg.mp3](expected-dmg.mp3) or [expected-cgb.mp3](expected-cgb.mp3).
5. Add your results to [the Wiki page](https://github.com/jkotlinski/apu-zombie-test/wiki).

## Zombie Mode HOWTO

To enter zombie mode, start any pulse/noise channel with NRx2_REG set to $x8. (x = initial volume)

To increase volume by one, write 8 to NRx2_REG.

To decrease volume by one, point `c` register to NRx2_REG and call either `safe_dec_vol` or `dec_vol`.
            
	safe_dec_vol: ; avoids envelope lockup when decreasing to $e
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
