            org      $4000
;
            include  'mecb.asm'
            include  'tutor.asm'

BUFFER_SIZE equ      255
;
start       move.l   #RAM_END+1,a7        ; Set up stack
            bsr      dir
            move.l   #FNAME,a0            ; Type a file
            bsr      type_file
            bra      end
;
type_file   bsr      SDDiskOpenRead       ; Open for read
            bcs      ropen_fail           ; Check for error
;
type_loop   move.l   #buffer,a0           ; Read bytes into buffer
            move.l   #BUFFER_SIZE,d0      ; Number of bytes to read
            bsr      SDDiskRead           ; Do the read
            bcs      end                  ; Check for EoF
            move.l   a0,a2                ; End of data read
            move.l   #buffer,a1           ; Point to start of buffer
type_loop1  cmp.l    a1,a2                ; are we at the end?
            beq      type_loop            ; if so, read next chunk
            move.b   (a1)+,d0             ; Otherwise, get a byte
            move.b   #OUTCH,d7            ; output byte to terminal
            trap     #14
            cmp.b    #$0a,d0              ; was it a linefeed?
            bne      type_loop1           ; if not, check for next character
            move.b   #$0d,d0              ; otherwise output a carriage return as well
            move.b   #OUTCH,d7            ; output byte to terminal
            trap     #14
            bra      type_loop1           ; Loop back

ropen_fail  move.l   d0,-(a7)
            move.b   #OUTPUT,d7           ; Display an error
            move.l   #MS_OPENERR,a5
            move.l   #MS_OPENERRE,a6
            trap     #14
            move.l   (a7)+,d0
            
            move.b   #PNT2HX,d7           ; Add the error code
            move.l   #buffer,a6
            trap     #14
;
            move.b   #OUT1CR,d7           ; Output
            move.l   #buffer,a5
            trap     #14
;
type_done   bsr      SDDiskClose          ; Close the file
            rts
;
            bra      end
;
end         move.b   #TUTOR,d7
            trap     #14
;
; dir - display directory of SD card contents
;
dir         move.b   #OUT1CR,d7           ; Write message
            move.l   #MS_DIR,a5
            move.l   #MS_DIRE,a6
            trap     #14
;
            bsr      SDParInit            ; Set up interface
            bsr      SDDiskPing
;
            bsr      SDDiskDir            ; Initiate directory function
            bcs      dir_error
dir_loop    move.l   #buffer,a0           ; Point to buffer
            bsr      SDDiskDirNext        ; Get next entry
            bcs      dir_done             ; If it was the last entry then exit
;
            move.b   #OUT1CR,D7           ; Write the file name
            move.l   #buffer,a5
            move.l   a0,a6
            trap     #14
;
            bra      dir_loop             ; Loop back for more
;
dir_error   move.b   #OUT1CR,d7
            move.l   #MS_ERROR1,a5
            move.l   #MS_ERROR1E,a6
            trap     #14
;
dir_done    rts

            include  'sdcard.asm'
;
; File to test open (read)
;
FNAME       dc.b     'SD.CFG',$00
;
MS_OPENERR  dc.b     "File Open Error Code: "
MS_OPENERRE
;
MS_DIR      dc.b     "SD Card directory:"
MS_DIRE
;
MS_ERROR1   dc.b     "Failed  directory."
MS_ERROR1E
;
MS_ERROR2   dc.b     "Failed to mount."
MS_ERROR2E
;
; Buffer for directory
;
buffer      ds.b    BUFFER_SIZE+1
;
            end
