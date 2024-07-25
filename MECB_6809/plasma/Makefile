# Makefile for MECB user programs

OUT = plasma
ASM = $(OUT).asm
SREC = $(OUT).s19
BIN = $(OUT).ex9

AS = asm6809
#LD = aslink
#SREC_CAT = srec_cat
#ORG = 0x0100

all: $(SREC)

.SUFFIXES: .asm

.asm:
	$(AS) plasma.asm -S -v -l plasma.lst -o plasma.s19

#$(SREC): $(OBJ)
#	$(LD) -ns $(SREC) $(OBJ)
#	$(SREC_CAT) $(SREC) -offset -$(ORG) -o $(BIN) -binary

#run: $(SREC)
#	$(SIM) ultim809 -cart $(BIN)

#debug: $(SREC)
#	$(SIM) ultim809 -cart $(BIN) -debug

clean:
	rm -f $(SREC) $(BIN) *.lst *.rel *.sym *.map

