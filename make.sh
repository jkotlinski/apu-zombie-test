rgbasm.exe test.s -o test.o
rgblink.exe test.o -o test.gb
rgbfix.exe -v -p 0 test.gb
