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
            STX     TMP_WORD
            pdata1  STR_ERASEF      ; Erase failure message
            LDX     #TMP_WORD
            out4hs
            pcrlf
            monitr  1
;
ERASE_OK    STX     TMP_WORD
            pdata1  STR_ERASE       ; Erase success message
            LDX     #TMP_WORD 
            out4hs
            pcrlf
;
; Write a sequence of bytes to the FLASH ROM
;
            LDU     #TEST_END-TEST_BYTES
            STU     TMP_WORD        ; Save the number of bytes to write
            pdata1  STR_DO_WR       ; Log to terminal
            LDX     #TMP_WORD
            out4hs
            pcrlf
            LDU     TMP_WORD        ; Restore the number of bytes to write
            LDY     #TEST_BYTES     ; Source of data
            LDX     #$8000          ; Destination to write to
            JSR     WRITE_BYTES     ; Do the write
            BEQ     WRITE_OK        ; Check it write succeeded
            STX     TMP_WORD        ; Save the location that failed to write
            pdata1  STR_WR_FAIL     ; No, it failed
            LDX     #TMP_WORD
            out4hs
            monitr  1               ; Return to ASSIST09 monitor
;
WRITE_OK    STX     TMP_WORD   
            pdata1  STR_WR_OK       ; Write succeeded
            LDX     #TMP_WORD   
            out4hs
            monitr  1               ; Return to ASSIST09 monitor

;
; Variables used by test program
;
TMP_WORD    RMB     2               ; Used to hold data for hex output to terminal
;
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
STR_WR_FAIL FCC     "Write to FLASH failed at location: X=0x"
            FCB     EOT
STR_ERASE   FCC     "Sector erase succeeded: X=0x"
            FCB     EOT
STR_ERASEF  FCC     "Sector erase failed at location: X=0x"
            FCB     EOT
STR_DO_WR   FCC     "Number of bytes to write: 0x"
            FCB     EOT

;
; Write bytes to FLASH ROM
; Routine assumes that the sector to which is being written has already been erased.
; On Entry:
;       X = location to write to
;       Y = source location
;       U = number of bytes to transfer
; On Exit:
;       if write succeeded, Z is set
;       if write failed, Z is clear
;       X = final location written to + 1 (on failure points to failed location of write)
;       Y = final location read from + 1
;       All other register contents conserved
WRITE_BYTES PSHS    U               ; Save U
WR_NEXT     LDA     ,Y+             ; Read a byte
            BSR     WRITE_BYTE      ; Write to FLASH
            BNE     WR_BYES_NOK     ; If it failed then exit
            LEAU    -1,U            ; Decrement byte counter
            CMPU    #$0000
            BNE     WR_NEXT         ; More to do, loop back
;
WR_BYTES_OK PULS    U               ; Restore U
            sez
            RTS
;
WR_BYES_NOK PULS    U               ; Restore U
            LEAX    -1,X            ; Point to failed location
            clz
            RTS                     ; Done

;
; Write byte to ROM
; On Entry:
;       X = location to write to
;       A = Byte to write
; On Exit:
;       if write succeeded, Z is set
;       if write failed, Z is clear
;       X = location that was written + 1
;       Register contents are conserved.
WRITE_BYTE  STX     SW_WPTR         ; Save write pointer
            LDX     #BYTE_PROG      ; Send the program control sequence
            BSR     SEND_CMD
            LDX     SW_WPTR         ; Restore write pointer
            STA     ,X              ; Write the value
            BSR     SW_WAIT         ; Wait for operation to complete
            CMPA    ,X+             ; Check what was written
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
            BSR     SEND_CMD
            LDA     #$30            ; Initiate erasure of the sector
            LDX     SW_WPTR         ; By writing $30 to the sector
            STA     ,X
            LDA     #$FF            ; Erased value
            BSR     SW_WAIT
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
            clz                     ; Reset the zero flag to mark an error
            RTS

;
; Wait for FLASH operation to complete
; On Entry:
;       A = Data that was written
;       X = Location that was written
; On Exit:
;       All registers are conserved
;
SW_WAIT     STA     SW_WDATA        ; Save data that was written
            ANDA    #$80            ; Check for Bit 7 value
            BNE     SW_WAIT1        ; Waiting for Bit 7 = 1
;
SW_WAIT0    LDA     ,X              ; Get FLASH status
            ANDA    #$80            ; Check for completion, Bit 7 = 0
            BNE     SW_WAIT0        ; Bit 7 = 1, not ready yet
            BRA     SW_WAIT_END     ; Bit 7 = 0, pperation complete
;
SW_WAIT1    LDA     ,X              ; Get FLASH status
            ANDA    #$80            ; Check for completion, Bit 7 = 1
            BEQ     SW_WAIT1        ; Bit 7 = 0, not ready yet
SW_WAIT_END LDA     SW_WDATA        ; Restore register
            RTS                     ; Return

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
            BSR     SEND_CMD
            LDA     $8000           ; Read the ID of the manufacturer
            LDX     #SW_ID_ENTER    ; Software ID entry sequence
            BSR     SEND_CMD
            LDB     $8001           ; Read the ID of the chip
            LDX     #SW_ID_EXIT     ; Software ID exit sequence
            BSR     SEND_CMD
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
; Variables used by FLASH routines
;
SW_ID1      RMB     1               ; Storage for Manufacturer ID
SW_ID2      RMB     1               ; Storage for Chip ID
SW_WPTR     RMB     2               ; Current Write location
SW_WDATA    RMB     1               ; Current Data being written

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