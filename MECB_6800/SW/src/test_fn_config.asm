pshx     macro
         stx   tfntempx
         sta   tfntempa
         lda   tfntempx
         psha
         lda   tfntempx+1
         psha
         lda   tfntempa
         endm

pulx     macro
         sta   tfntempa
         pula
         sta   tfntempx+1
         pula
         sta   tfntempx
         ldx   tfntempx
         lda   tfntempa
         endm
         
addx     macro val
         psha
         pshb
         lda   val
         sta   tfntempa
         stx   tfntempx
         lda   tfntempx
         ldb   tfntempx+1
         addb  tfntempa
         adca  #0
         sta   tfntempx
         stb   tfntempx+1
         ldx   tfntempx
         pulb
         pula
         endm

;
; Fujinet configuration tests
;
config_tests:
         ldx   #stcfg         ; Write test message
         jsr   print
         jsr   set_buff       ; Reset the buffers
;
; test fujinet_reset
;
;         ldx   #streset        ; Write host message
;         jsr   print
;         ldx   #fujinet_dcb   ; Point to the DCB
;         jsr   fujinet_reset
;         cmpa  #FUJINET_RC_OK ; Check if OK
;         lbne  error          ; if not, report error
;
         ldx   #1
         stx   loop_count
test_loop:
;
; test fujinet_read_host_slots
;
;
         jsr   test_hosts
;
; test fujinet_random_number
;
         jsr   test_rnd
;
; test fujinet_get_time
;
         jsr   test_time
;
; test fujinet_read_device_slots
;
         jsr   test_dev
;
         ldx   loop_count
         dex
         stx   loop_count
         bne   test_loop
         rts
;
loop_count  rmb   2
;
         rts
;
test_rnd:
         ldx   #strand        ; Write random number
         jsr   print
         jsr   set_buff       ; Reset the buffers
         ldx   #fujinet_dcb   ; Point to the DCB
         jsr   fujinet_random_number
         cmpa  #FUJINET_RC_OK ; Check if OK
         beq   conf2
         jmp   error          ; if not, report error
conf2:   ldx   #rxdata        ; Write the number returned
         lda   ,x
         ldb   1,x
         jsr   out4h
         lda   2,x
         ldb   3,x
         jsr   out4h
         jsr   pcrlf
         rts
;
test_time:
         ldx   #stgtime       ; Write get time
         jsr   print
         jsr   set_buff       ; Reset the buffers
         ldx   #fujinet_dcb   ; Point to the DCB
         jsr   fujinet_get_time
         cmpa  #FUJINET_RC_OK ; Check if OK
         beq   conf1
         jmp   error          ; if not, report error
conf1:   ldx   #tbuffer
         stx   ptrdest
         ldx   #rxdata
         jsr   date2str
         ldx   #tbuffer
         jsr   print
         jsr   pcrlf
         rts
;
test_hosts:
         ldx   #sthost        ; Write host message
         jsr   print
         ldx   #fujinet_dcb   ; Point to the DCB
         lda   #hostslot>>8
         sta   DCB_RX_BUFFER,x   ; Set the receive buffer to fill the hostslot area
         lda   #hostslot&$ff
         sta   DCB_RX_BUFFER+1,x
         jsr   fujinet_read_host_slots
         cmpa  #FUJINET_RC_OK ; Check if OK
         beq   conf3          ; if not, report error
         jmp   error
;
; Write the results
;
conf3:   ldx   #sthostt
         jsr   print
;
         lda   #1             ; Start with slot 1
         ldx   #hostslot      ; Point to the hostslot information received
loop_hosts:
         pshx
         ldx   #tbuffer
         stx   ptrdest
         jsr   hex2dec        ; Write the host slot number
         jsr   blank4
         pulx
         tst   ,x             ; check for an empty slot
         bne   host_cp
         pshx
         ldx   #stempty       ; if empty, indicate that it is undefined
         jsr   strcpy
         pulx
         bra   host2
host_cp: jsr   strcpy         ; Copy the host name
host2:   pshx
         ldx   #tbuffer
         jsr   print
         jsr   pcrlf
         pulx
         inca
         addx  #MAX_HOST_LEN
         cmpa  #FUJINET_MAX_HOST_SLOTS+1
         beq   host_done
         jmp   loop_hosts
host_done:
         rts
;
test_dev:
         ldx   #stdev         ; Write device message
         jsr   print
         ldx   #fujinet_dcb   ; Point to the DCB
         lda   #devslot>>8
         sta   DCB_RX_BUFFER,x   ; Set the receive buffer to fill the hostslot area
         lda   #devslot&$ff
         sta   DCB_RX_BUFFER+1,x
         jsr   fujinet_read_device_slots
         cmpa  #FUJINET_RC_OK ; Check if OK
         beq   test_dev2      ; if not, report error
         jmp   error

;
; Write the results
;
test_dev2:
         ldx   #stdevt
         jsr   print
;
         lda   #1             ; Start with slot 1
         ldx   #devslot       ; Point to the devslot information received
loop_devs:
         pshx
         ldx   #tbuffer
         stx   ptrdest
         pulx
         jsr   hex2dec        ; Write the device slot number
         jsr   blank4
         ldb   ,x             ; check for an empty slot
         cmpb  #$ff
         bne   devhosts
         pshx
         jsr   blank4
         jsr   blank4
         jsr   blank2
         ldx   #stempty       ; if empty, indicate that it is undefined
         jsr   strcpy
         pulx
         bra   dev2
devhosts:    
         psha              ; save the dev slot
         lda   0,x            ; get the host slot for the device
         inca                 ; convert from 0-based to 1-based index
         jsr   hex2dec        ; write to the buffer
         jsr   blank4
         lda   1,x            ; get the device mode
         cmpa  #MODE_READ     ; indicate read mode
         bne   modew
         lda   #'R'
         jsr   appendc
         bra   mode_bl
modew:   cmpa  #MODE_WRITE
         bne   modeu
         lda   #'W'           ; indicate write mode
         jsr   appendc
         bra   mode_bl
modeu:   lda   #'?'
         jsr   appendc
mode_bl: jsr   blank4
         pula
;
dev_cp:  pshx              ; Write the device path
         inx
         inx
         jsr   strcpy
         pulx
dev2:    pshx
         ldx   #tbuffer
         jsr   print
         jsr   pcrlf
         pulx
         inca
         addx  #MAX_FILE_LEN+2 ; Point to next device
         cmpa  #FUJINET_MAX_DEVICE_SLOTS+1
         beq   dev_ret
         jmp   loop_devs
dev_ret: rts
;
;
; convert Time structure to string
; Entry: x - points to time structure
;        ptrdest - string buffer
;
date2str:
         psha
         lda   3,x            ; Get the day of month
         jsr   hex2dec2
         lda   #'/'
         jsr   appendc
         lda   2,x            ; Get the month
         jsr   hex2dec2
         lda   #'/'
         jsr   appendc
         lda   ,x             ; Get the MSB year
         jsr   hex2dec2
         lda   1,x            ; Get the MSB year
         jsr   hex2dec2
         lda   #' '
         jsr   appendc
         lda   4,x            ; Get the hour
         jsr   hex2dec2
         lda   #':'
         jsr   appendc
         lda   5,x            ; Get the minutes
         jsr   hex2dec2
         lda   #':'
         jsr   appendc
         lda   6,x            ; Get the seconds
         jsr   hex2dec2
         clra
         jsr   appendc        ; Terminate the string
         pula
         rts
;
stcfg:   fcb   CR,LF,'==== Configuration query tests ======',CR,LF,EOT
stgtime: fcb   'Test Get Time ...',CR,LF,EOT
strand:  fcb   'Random number: $',EOT
streset: fcb   'Reset Fujinet device ...',CR,LF,EOT
sthost:  fcb   'Querying host slots ...',CR,LF,EOT
sthostt: fcb   CR,LF,'Slot Path',CR,LF,EOT
stempty: fcb   '( EMPTY )',EOT
stdev:   fcb   'Querying device slots ...',CR,LF,EOT
stdevt:  fcb   CR,LF,'Slot Host Mode Device',CR,LF,EOT
;
tfntempx rmb   2
tfntempa rmb   1
hostslot rmb   MAX_HOST_LEN*FUJINET_MAX_HOST_SLOTS
devslot  rmb   (MAX_FILE_LEN+2)*FUJINET_MAX_DEVICE_SLOTS
