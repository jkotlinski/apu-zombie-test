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

To decrease volume by one, point `c` register to NRx2_REG and execute one of following code snippets, depending on CPU speed:
            
    dec_vol_by_one_normal_speed:
            ldh     a,[4]   ; DIV
            and     $1f
            cp      a,$f
            jr      z,dec_vol_by_one_normal_speed
            ld      a,9
            ldh     [c],a
            ld      a,$11
            ldh     [c],a
            ld      a,$18
            ldh     [c],a
            ret
            
    dec_vol_by_one_cgb_double_speed:
            ldh     a,[4]   ; DIV
            and     $3f
            cp      a,$1f
            jr      z,dec_vol_by_one_cgb_double_speed
            ld      a,9
            ldh     [c],a
            ld      a,$11
            ldh     [c],a
            ld      a,$18
            ldh     [c],a
            ret
