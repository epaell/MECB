vasmm68k_mot -Fbin -L tutor.lst src/TUTOR13.X68
mv a.out tutor.bin

vasmm68k_mot -Fbin -L combo_68k.lst src/combo_68k.asm
mv a.out combo_68k.bin
