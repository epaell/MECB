vasmm68k_mot -Fbin -L zbug.lst src/zbug.asm
mv a.out zbug.bin
./bin2rom.py
cp mecb68008.bin ../../../mymame/roms/mecb68008/.