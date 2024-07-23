# Creativision Sonic Invaders
A disassembly of Sonic Invaders for Creativision. There are three files assocaited with this:

# bioscv.asm
This is the BIOS ROM that is in the base machine. While it compiles to produce the binary equivalent of the ROM there has not been a great deal of effort in actually interpreting the code. As such, there is possibly some code still remaining in the data sections (and so may not work when relocated).

# sonicinv.asm
This is the Sonic Invaders code. While it compiles to produce the binary equivalent of the ROM there has not been a great deal of effort in actually interpreting the code. As such, there is possibly some code still remaining in the data sections (and so may not work when relocated).

# combined.asm
This is a combined version that mostly runs in memory on the Digicool MECB 6502. Note that the PIA access has been commented out to allow it to run without the SN76489 device installed. The code runs to the point of showing the invaders and having them move but it is possible that there are subtle issues with the relocated memory version when it comes to actual gameplay (not tested).
