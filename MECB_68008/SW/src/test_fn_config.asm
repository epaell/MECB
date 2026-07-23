;
; Fujinet configuration tests
;
config_tests:
         move.l   #stcfg,a0   ; Write test message
         bsr      print
         bsr      test_random
         bsr      test_get_time
         bsr      test_random
         bsr      test_get_time
         bsr      test_read_hosts
         bsr      test_read_devices
         rts

;
; test fujinet_reset
;
;         move.l  #streset,a0       ; Write host message
;         bsr     print
;         move.l  #fujinet_dcb,a0   ; Point to the DCB
;         bsr     fujinet_reset
;         cmp.b   #FUJINET_RC_OK,d0 ; Check if OK
;         bne     error             ; if not, report error

;
; test fujinet_random_number
;
test_random:
         move.l   #strand,a0        ; Write random number
         bsr      print
         move.l   #fujinet_dcb,a0   ; Point to the DCB
         bsr      fujinet_random_number
         cmp.b    #FUJINET_RC_OK,d0 ; Check if OK
         bne      error             ; if not, report error
         move.l   rxdata,d0        ; Write the number returned
         bsr      out8h
         bsr      pcrlf
         rts

;
; test fujinet_get_time
;
test_get_time:
         move.l   #stgtime,a0       ; Write get time
         bsr      print
         move.l   #fujinet_dcb,a0   ; Point to the DCB
         bsr      fujinet_get_time
         cmp.b    #FUJINET_RC_OK,d0 ; Check if OK
         bne      error             ; if not, report error
         move.l   #rxdata,a0
         move.l   #tbuffer,a1
         bsr      date2str
         exg      a0,a1
         bsr      print
         bsr      pcrlf
         rts

;
; test fujinet_read_host_slots
;
test_read_hosts:
         move.l   #sthost,a0        ; Write host
         bsr      print
         move.l   #fujinet_dcb,a0   ; Point to the DCB
         move.l   #hostslot,DCB_RX_BUFFER(a0)
         bsr      fujinet_read_host_slots
         cmp.b    #FUJINET_RC_OK,d0 ; Check if OK
         bne      error             ; if not, report error
;
; Write the results
;
         move.l   #sthostt,a0
         bsr      print
;
         move.b   #1,d0             ; Start with slot 1
         move.l   #hostslot,a0      ; Point to the hostslot information received
loop_hosts:
         move.l   #tbuffer,a1
         bsr      chex2dec          ; Write the host slot number
         bsr      blank4
         tst.b    (a0)              ; check for an empty slot
         bne      host_cp
         move.l   a0,a2
         move.l   #stempty,a0       ; if empty, indicate that it is undefined
         bsr      strcpy
         move.l   a2,a0
         bra      host2
host_cp: bsr      strcpy            ; Copy the host name
host2:   move.l   a0,a2
         move.l   #tbuffer,a0
         bsr      print
         bsr      pcrlf
         move.l   a2,a0
         add.b    #1,d0
         add.l    #MAX_HOST_LEN,a0  ; Point to next host
         cmp.b    #FUJINET_MAX_HOST_SLOTS+1,d0
         bne      loop_hosts
         rts
         
;
; test fujinet_read_device_slots
;
test_read_devices:
         move.l   #stdev,a0         ; Write device message
         bsr      print
         move.l   #fujinet_dcb,a0   ; Point to the DCB
         move.l   #devslot,DCB_RX_BUFFER(a0)   ; Set the receive buffer to fill the hostslot area
         bsr      fujinet_read_device_slots
         cmp.b    #FUJINET_RC_OK,d0 ; Check if OK
         bne      error             ; if not, report error
;
; Write the results
;
         move.l   #stdevt,a0
         bsr      print
;
         move.b   #1,d0             ; Start with slot 1
         move.l   #devslot,a0       ; Point to the devslot information received
loop_devs:
         move.l   #tbuffer,a1
         bsr      chex2dec          ; Write the device slot number
         bsr      blank4
         move.b   (a0),d1           ; check for an empty slot
         cmp.b    #$ff,d1
         bne      devhosts
         move.l   a0,a2
         bsr      blank4
         bsr      blank4
         bsr      blank2
         move.l   #stempty,a0       ; if empty, indicate that it is undefined
         bsr      strcpy
         move.l   a2,a0
         bra   dev2
devhosts:    
         swap     d0                ; save the dev slot
         move.b   (a0),d0           ; get the host slot for the device
         add.b    #1,d0             ; convert from 0-based to 1-based index
         bsr      chex2dec          ; write to the buffer
         bsr      blank4
         move.b   1(a0),d0          ; get the device mode
         cmp.b    #MODE_READ,d0     ; indicate read mode
         bne      modew
         move.b   #'R',(a1)+
         bra      mode_bl
modew:   cmp.b    #MODE_WRITE,d0
         bne      modeu
         move.b   #'W',(a1)+        ; indicate write mode
         bra      mode_bl
modeu:   move.b   #'?',(a1)+
mode_bl: bsr      blank4
         swap     d0
;
dev_cp:  move.l   a0,a2             ; Write the device path
         add.l    #2,a0
         bsr      strcpy
         move.l   a2,a0
dev2:    move.l   a0,a2
         move.l   #tbuffer,a0
         bsr      print
         bsr      pcrlf
         move.l   a2,a0
         add.b    #1,d0
         add.l    #MAX_FILE_LEN+2,a0   ; Point to next device
         cmp.b    #FUJINET_MAX_DEVICE_SLOTS+1,d0
         bne   loop_devs
         rts
;
; convert Time structure to string
; Entry: a0 - points to time structure
;        a1 - string buffer
;
date2str:
         movem.l  d0/a1,-(a7)
         move.b   FN_TIME_MDAY(a0),d0     ; Get the day of month
         bsr      hex2dec2
         move.b   #'/',(a1)+
         move.b   FN_TIME_MONTH(a0),d0    ; Get the month
         bsr      hex2dec2
         move.b   #'/',(a1)+
         move.b   FN_TIME_YEARH(a0),d0    ; Get the MSB year
         bsr      hex2dec2
         move.b   FN_TIME_YEARL(a0),d0    ; Get the LSB year
         bsr      hex2dec2
         move.b   #' ',(a1)+
         move.b   FN_TIME_HOUR(a0),d0     ; Get the hour
         bsr      hex2dec2
         move.b   #':',(a1)+
         move.b   FN_TIME_MIN(a0),d0      ; Get the minutes
         bsr      hex2dec2
         move.b   #':',(a1)+
         move.b   FN_TIME_SEC(a0),d0      ; Get the seconds
         bsr      hex2dec2
         move.b   #0,(a1)+
         movem.l  (a7)+,d0/a1
         rts
;
; store 4 spaces
; Entry: a1 = points to location where spaces should be stored
; Exit: a1 = points to location after last space
;
blank4   move.b   #$20,(a1)+
         move.b   #$20,(a1)+
blank2   move.b   #$20,(a1)+
         move.b   #$20,(a1)+
         rts
;
stcfg:   dc.b  CR,LF,'==== Configuration query tests ======',CR,LF,EOT
stgtime: dc.b  'Test Get Time ...',CR,LF,EOT
strand:  dc.b  'Random number: $',EOT
streset: dc.b  'Reset Fujinet device ...',CR,LF,EOT
sthost:  dc.b  'Querying host slots ...',CR,LF,EOT
sthostt: dc.b  CR,LF,'Slot Path',CR,LF,EOT
stempty: dc.b  '( EMPTY )',EOT
stdev:   dc.b  'Querying device slots ...',CR,LF,EOT
stdevt:  dc.b  CR,LF,'Slot Host Mode Device',CR,LF,EOT
;
hostslot ds.b  MAX_HOST_LEN*FUJINET_MAX_HOST_SLOTS
devslot  ds.b  (MAX_FILE_LEN+2)*FUJINET_MAX_DEVICE_SLOTS
;
            align 4
