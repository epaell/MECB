; Simple routines to write data to the MECB 1 MB FLASH ROM card
; (https://digicoolthings.com/minimalist-europe-card-bus-mecb-1mb-rom-expansion-card-part-2/)
; Assumptions:
;    MECB RAM: $0000-$7FFF
;    MECB ROM: $8000-$FFFF (ASSIST09 is in upper part of ROM, mine was at $F000)
;    MECB I/O: $C000
;
; These routines will only allow access to the 32KB bank of ROM that is enabled.
; Care must be taken not to inadvertently erase/over-write the ASSIST09 part of the ROM.
;
; Written by Emil Lenc
; Date: 02/07/2024
;
; Include helper macros for the ASSIST09 software functions
;
            include "src/ASSISTMacros.inc"
;
            ORG     $0400
;
; Some basic character definitions
;
EOT         EQU     $04             ; End of text
CR          EQU     $0D             ; Carriage return
LF          EQU     $0A             ; Line feed
;
START       JSR     GET_SW_ID       ; Get the software ID data from the FLASH ROM
            STD     SW_ID1
            pdata1  STR_SW_ID1      ; Writes the value to the terminal
            LDX     #SW_ID1
            out2hs
            pcrlf
            pdata1  STR_SW_ID2
            LDX     #SW_ID2
            out2hs
            pcrlf
;
; Erase the first sector in ROM
;
            LDX     #$8000
            JSR     ERASE_SEC
            BEQ     ERASE_OK
            STX     SW_COUNT
            pdata1  STR_ERASEF      ; Erase failure message
            LDX     #SW_COUNT
            out4hs
            pcrlf
            monitr  1
;
ERASE_OK    STX     SW_COUNT
            pdata1  STR_ERASE       ; Erase success message
            LDX     #SW_COUNT
            out4hs
            pcrlf
;
; Write a sequence of bytes to the FLASH ROM
;
            LDX     #$8000          
            LDY     #TEST_BYTES
            LDD     #TEST_END-TEST_BYTES
            JSR     WRITE_BYTES
            BEQ     WRITE_OK        ; Check it write succeeded
            STX     SW_COUNT
            pdata1  STR_WR_FAIL     ; No, it failed
            LDX     #SW_COUNT
            out4hs
            monitr  1               ; Return to ASSIST09 monitor
;
WRITE_OK    STX     SW_COUNT
            pdata1  STR_WR_OK       ; Write succeeded
            LDX     #SW_COUNT
            out4hs
            monitr  1               ; Return to ASSIST09 monitor

;
; Test sequence of bytes to write to FLASH ROM
;
TEST_BYTES  FCB     $01,$81,$02,$82,$03,$83,$04,$84
            FCB     $AA,$CC,$AA,$CC,$AA,$CC,$AA,$CC
TEST_END    EQU     *

;
; String definitions
;
STR_SW_ID1  FCC     "Manufacturer ID: "
            FCB     EOT
STR_SW_ID2  FCC     "Chip ID: "
            FCB     EOT
STR_WR_OK   FCC     "Write to FLASH succeeded. X=0x"
            FCB     EOT
STR_WR_FAIL FCC     "Write to FLASH failed at location: 0x"
            FCB     EOT
STR_ERASE   FCC     "Sector erase succeeded. X=0x"
            FCB     EOT
STR_ERASEF  FCC     "Sector erase failed at location: 0x"
            FCB     EOT

;
; Write bytes to FLASH ROM
; Routine assumes that the sector to which is being written has already been erased.
; On Entry:
;       X = location to write to
;       Y = source location
;       D = number of bytes to transfer
; On Exit:
;       if write succeeded, Z is set
;       if write failed, Z is clear
;       X = final location written to + 1 (on failure points to failed location of write)
;       Y = final location read from + 1
;       All other register contents conserved
WRITE_BYTES PSHS    D               ; Save A and B registers
            STD     SW_COUNT        ; Save byte count
            STX     SW_WPTR         ; Save write pointer
WR_NEXT     LDA     ,Y+             ; Read a byte
            JSR     WRITE_BYTE      ; Write to FLASH
            BNE     WR_BYES_NOK     ; If it failed then exit
            LEAX    1,X             ; Increment write pointer
            STX     SW_WPTR         ; Save it
            LDX     SW_COUNT        ; Decrement number of bytes to transfer
            LEAX    -1,X
            BEQ     WR_BYTES_OK     ; If it is done then exit
            STX     SW_COUNT
            LDX     SW_WPTR         ; Get the write pointer
            BRA     WR_NEXT
;
WR_BYTES_OK LDX     SW_WPTR         ; Restore the write pointer
            ORCC    #$04            ; Set the Z flag because write was OK
WR_BYES_NOK PULS    D               ; Restore A and B registers
            RTS                     ; Done

;
; Write byte to ROM
; On Entry:
;       X = location to write to
;       A = Byte to write
; On Exit:
;       if write succeeded, Z is set
;       if write failed, Z is clear
;       Register contents are conserved.
WRITE_BYTE  PSHS    A,X             ; Save X
            LDX     #BYTE_PROG      ; Send the program control sequence
            JSR     SEND_CMD
            PULS    A,X             ; Restore X
            STA     ,X              ; Write the value
            PSHS    X
            LDX     #10             ; ~26.7 uS delay
WDELAY      LEAX    -1,X            ; 5 cycles
            BNE     WDELAY          ; 3 cycles 8/3 = 2.67 uS
            PULS    X
            CMPA    ,X              ; Check what was written
            RTS                     ; Return

;
; Erase a 4KB sector in ROM
; On Entry:
;       X = points to a location in the sector to erase e.g. X=$8000 will erase $0000-$0FFF
; On Exit:
;       if erase succeeded, Z is set, X points to last location erased + 1
;       if erase failed, Z is clear, X points to location where erase failed
;       All other registers are conserved.
;
ERASE_SEC   PSHS    A,Y             ; Save A and Y
            STX     SW_WPTR         ; Save start of erase location
            LDX     #SEC_ERASE      ; Send the command to initiate erase
            JSR     SEND_CMD
            LDA     #$30            ; Initiate erasure of the sector
            LDX     SW_WPTR         ; By writing $30 to the sector
            STA     ,X
            LDX     #9400           ; ~25mS wait for command to complete
SW_LOOP2    LEAX    -1,X            ; 5 cycles
            BNE     SW_LOOP2        ; 3 cycles
            LDY     #$1000          ; Size of the sector
; Verify that the erase worked
            LDX     SW_WPTR         ; Check all bytes in the sector
SW_VERIFY   LDA     ,X+
            CMPA    #$FF            ; Is it erased?
            BNE     ERASE_NOK       ; If not, it failed
            LEAY    -1,Y            ; Are we at the end of the sector
            BNE     SW_VERIFY       ; If not, loop back for more
            PULS    A,Y             ; Verify complete, restore registers
            RTS                     ; Return
;
ERASE_NOK   LEAX    -1,X            ; Restore X to point to failed location
            PULS    A,Y             ; Restore registers
            ANDCC   #$FB            ; Reset the zero flag to mark an error
            RTS

;
; Get the software ID for the ROM
; On Entry:
;       -
; On Exit:
;       A = Manufacturer ID
;       B = Chip ID
;       All other registers are conserved
;
GET_SW_ID   PSHS    X
            LDX     #SW_ID_ENTER    ; Software ID entry sequence
            JSR     SEND_CMD
            LDA     $8000           ; Read the ID of the manufacturer
            LDX     #SW_ID_ENTER    ; Software ID entry sequence
            JSR     SEND_CMD
            LDB     $8001           ; Read the ID of the chip
            LDX     #SW_ID_EXIT     ; Software ID exit sequence
            JSR     SEND_CMD
            PULS    X
            RTS

;
; Send a command to the FLASH ROM
;
; On entry:
;       X = Points to command sequence to send (SW_ID_ENTER, SW_ID_EXIT, BYTE_PROG, SEC_ERASE)
; On exit:
;       All registers are conserved
;
SEND_CMD    PSHS    A,X,Y           ; Save registers
SEND_CMD1   LDA     ,X+             ; Get next command byte to send
            BEQ     SENDEX          ; If everything is sent then exit
            LDY     ,X++            ; Get the address to send to
            LEAY    $8000,Y         ; Shift up to ROM location
            STA     ,Y              ; Send the command to the FLASH ROM
            BRA     SEND_CMD1       ; Continue until all sequence commands sent
SENDEX      PULS    A,X,Y           ; Restore registers
            RTS

;
; Variables
;
SW_ID1      RMB     1               ; Storage for Manufacturer ID
SW_ID2      RMB     1               ; Storage for Chip ID
SW_COUNT    RMB     2               ; Bytes remaining to write
SW_WPTR     RMB     2               ; Current Write location

;
; FLASH Commands
;
SW_ID_ENTER FCB     $AA
            FDB     $5555
            FCB     $55
            FDB     $2AAA
            FCB     $90
            FDB     $5555
            FCB     $00
;
SW_ID_EXIT  FCB     $AA
            FDB     $5555
            FCB     $55
            FDB     $2AAA
            FCB     $F0
            FDB     $5555
            FCB     $00
;
BYTE_PROG   FCB     $AA
            FDB     $5555
            FCB     $55
            FDB     $2AAA
            FCB     $A0
            FDB     $5555
            FCB     $00
;
SEC_ERASE   FCB     $AA
            FDB     $5555
            FCB     $55
            FDB     $2AAA
            FCB     $80
            FDB     $5555
            FCB     $AA
            FDB     $5555
            FCB     $55
            FDB     $2AAA
            FCB     $00
;
            END