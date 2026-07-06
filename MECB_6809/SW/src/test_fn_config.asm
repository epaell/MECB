;
; Fujinet configuration tests
;
config_tests:
         ldx   #stcfg         ; Write test message
         lbsr  print
;
; test fujinet_reset
;
;         ldx   #streset        ; Write host message
;         lbsr  print
;         ldx   #fujinet_dcb   ; Point to the DCB
;         lbsr  fujinet_reset
;         cmpa  #FUJINET_RC_OK ; Check if OK
;         lbne  error          ; if not, report error
;
; test fujinet_get_time
;
         ldx   #stgtime       ; Write get time
         lbsr  print
         ldx   #fujinet_dcb   ; Point to the DCB
         lbsr  fujinet_get_time
         cmpa  #FUJINET_RC_OK ; Check if OK
         lbne  error          ; if not, report error
         ldx   #rxdata
         ldy   #tbuffer
         lbsr  date2str
         tfr   y,x
         lbsr  print
         pcrlf

;
; test fujinet_random_number
;
         ldx   #strand        ; Write random number
         lbsr  print
         ldx   #fujinet_dcb   ; Point to the DCB
         lbsr  fujinet_random_number
         cmpa  #FUJINET_RC_OK ; Check if OK
         lbne  error          ; if not, report error
         ldx   #rxdata        ; Write the number returned
         ldd   ,x
         lbsr  out4h
         ldd   2,x
         lbsr  out4h
         pcrlf
;
; test fujinet_read_host_slots
;
         ldx   #sthost        ; Write host message
         lbsr  print
         ldx   #fujinet_dcb   ; Point to the DCB
         ldd   #hostslot
         std   DCB_RX_BUFFER,x   ; Set the receive buffer to fill the hostslot area
         lbsr  fujinet_read_host_slots
         cmpa  #FUJINET_RC_OK ; Check if OK
         lbne  error          ; if not, report error
;
; Write the results
;
         ldx   #sthostt
         lbsr  print
;
         lda   #1             ; Start with slot 1
         ldx   #hostslot      ; Point to the hostslot information received
loop_hosts:
         ldy   #tbuffer
         lbsr  hex2dec        ; Write the host slot number
         ldb   #' '
         stb   ,y+
         stb   ,y+
         stb   ,y+
         stb   ,y+
         tst   ,x             ; check for an empty slot
         bne   host_cp
         pshs  x
         ldx   #stempty       ; if empty, indicate that it is undefined
         lbsr  strcpy
         puls  x
         bra   host2
host_cp: lbsr  strcpy         ; Copy the host name
host2:   pshs  x
         ldx   #tbuffer
         lbsr  print
         pcrlf
         puls  x
         inca
         leax  MAX_HOST_LEN,x ; Point to next host
         cmpa  #FUJINET_MAX_HOST_SLOTS+1
         bne   loop_hosts
;
; test fujinet_read_device_slots
;
         ldx   #stdev         ; Write device message
         lbsr  print
         ldx   #fujinet_dcb   ; Point to the DCB
         ldd   #devslot
         std   DCB_RX_BUFFER,x   ; Set the receive buffer to fill the hostslot area
         lbsr  fujinet_read_device_slots
         cmpa  #FUJINET_RC_OK ; Check if OK
         lbne  error          ; if not, report error
;
; Write the results
;
         ldx   #stdevt
         lbsr  print
;
         lda   #1             ; Start with slot 1
         ldx   #devslot       ; Point to the devslot information received
loop_devs:
         ldy   #tbuffer
         lbsr  hex2dec        ; Write the device slot number
         lbsr  blank4
         ldb   ,x             ; check for an empty slot
         cmpb  #$ff
         bne   devhosts
         pshs  x
         lbsr  blank4
         lbsr  blank4
         lbsr  blank2
         ldx   #stempty       ; if empty, indicate that it is undefined
         lbsr  strcpy
         puls  x
         bra   dev2
devhosts:    
         pshs  a              ; save the dev slot
         lda   0,x            ; get the host slot for the device
         inca                 ; convert from 0-based to 1-based index
         lbsr  hex2dec        ; write to the buffer
         bsr   blank4
         lda   1,x            ; get the device mode
         cmpa  #MODE_READ     ; indicate read mode
         bne   modew
         lda   #'R'
         sta   ,y+
         bra   mode_bl
modew:   cmpa  #MODE_WRITE
         bne   modeu
         lda   #'W'           ; indicate write mode
         sta   ,y+
         bra   mode_bl
modeu:   lda   #'?'
         sta   ,y+
mode_bl: bsr   blank4
         puls  a
;
dev_cp:  pshs  x              ; Write the device path
         leax  2,x
         lbsr  strcpy
         puls  x
dev2:    pshs  x
         ldx   #tbuffer
         lbsr  print
         pcrlf
         puls  x
         inca
         leax  MAX_FILE_LEN+2,x ; Point to next device
         cmpa  #FUJINET_MAX_DEVICE_SLOTS+1
         bne   loop_devs
         rts
;
; convert Time structure to string
; Entry: x - points to time structure
;        y - string buffer
;
date2str:
         pshs  a,b,y
         lda   3,x            ; Get the day of month
         lbsr  hex2dec2
         ldb   #'/'
         stb   ,y+
         lda   2,x            ; Get the month
         lbsr  hex2dec2
         lda   #'/'
         std   ,y+
         lda   ,x             ; Get the MSB year
         lbsr  hex2dec2
         lda   1,x            ; Get the MSB year
         lbsr  hex2dec2
         ldb   #' '
         stb   ,y+
         lda   4,x            ; Get the hour
         lbsr  hex2dec2
         ldb   #':'
         stb   ,y+
         lda   5,x            ; Get the minutes
         lbsr  hex2dec2
         stb   ,y+
         lda   6,x            ; Get the seconds
         lbsr  hex2dec2
         clrb
         stb   ,y             ; terminate the string
         puls  a,b,y,pc
;
; store 4 spaces
; Entry: y = points to location where spaces should be stored
; Exit: y = points to location after last space
;
blank4   pshs  b
         ldb   #' '
         stb   ,y+
         stb   ,y+
blank2a  stb   ,y+
         stb   ,y+
         puls  b,pc
blank2   pshs  b
         ldb   #' '
         bra   blank2a
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
hostslot rmb   MAX_HOST_LEN*FUJINET_MAX_HOST_SLOTS
devslot  rmb   (MAX_FILE_LEN+2)*FUJINET_MAX_DEVICE_SLOTS
