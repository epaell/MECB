;
section     .text
;
;
; Fujinet configuration tests
;
config_tests:
         mov   si,stcfg   ; Write test message
         call  print
         call  test_random
         call  test_get_time
         call  test_read_hosts
         call  test_read_devices
;         call  test_device
;         call  disable_device
;         call  test_device
;         call  enable_device
;         call  test_device
         mov   ah,0
         call  testdevfullp
         mov   ah,1
         call  testdevfullp
         mov   ah,0
         call  testsetfullp
         mov   ah,0
         call  testdevfullp
         mov   ah,1
         call  testdevfullp
         ret

disable_device:
         mov   si,strdevd
         call  print
         mov   si,fujinet_dcb
         mov   ax,rxdata
         mov   ds:[si+DCB_RX_BUFFER],ax
         mov   ax,txdata
         mov   ds:[si+DCB_TX_BUFFER],ax
         mov   ah,RC2014_DEVICEID_PRINTER+2
         call  fujinet_disable_device
         cmp   al,FUJINET_RC_OK  ; Check if OK
         jnz   error             ; if not, report error
         ret

enable_device:
         mov   si,strdeve
         call  print
         mov   ax,rxdata
         mov   ds:[si+DCB_RX_BUFFER],ax
         mov   ax,txdata
         mov   ds:[si+DCB_TX_BUFFER],ax
         mov   ah,RC2014_DEVICEID_PRINTER+2
         mov   si,fujinet_dcb
         call  fujinet_enable_device
         cmp   al,FUJINET_RC_OK  ; Check if OK
         jnz   error             ; if not, report error
         ret

test_device:
         mov   si,strdevst
         call  print
         mov   ah,RC2014_DEVICEID_DISK
         call  testdev
         mov   ah,RC2014_DEVICEID_PRINTER+2
         call  testdev
         mov   ah,RC2014_DEVICEID_MODEM
         call  testdev
         mov   ah,RC2014_DEVICEID_FILE
         call  testdev
         ret

;
; Test get device slot full path
; ah = device slot
;
testdevfullp:
         mov   si,strdevsl
         call  print
         mov   al,ah
         inc   al
         call  out1h
         push  ax
         mov   si,fujinet_dcb
         mov   ax,rxdata
         mov   ds:[si+DCB_RX_BUFFER],ax
         mov   ax,txdata
         mov   ds:[si+DCB_TX_BUFFER],ax
         pop   ax
         call  fujinet_get_device_fullpath
         cmp   al,FUJINET_RC_OK  ; Check if OK
         jnz   error             ; if not, report error
         mov   si,strdevfp
         call  print
         mov   si,rxdata
         call  print
         call  pcrlf
         ret

;
; Test set device slot full path
; ah = device slot
;
testsetfullp:
         mov   si,stnewp         ; transfer path to the transmit buffer
         mov   di,txdata
         call  strcpy
         mov   si,fujinet_dcb
         call  fujinet_set_device_fullpath
         cmp   al,FUJINET_RC_OK  ; Check if OK
         jnz   error             ; if not, report error
         ret

;
; get device enable status and full path for device in ah
testdev:
         mov   si,fujinet_dcb
         push  ax
         mov   ax,rxdata
         mov   ds:[si+DCB_RX_BUFFER],ax
         mov   ax,txdata
         mov   ds:[si+DCB_TX_BUFFER],ax
         pop   ax
         mov   bh,ah
         call  fujinet_get_device_enabled_status
         cmp   al,FUJINET_RC_OK  ; Check if OK
         jnz   error             ; if not, report error
         mov   ah,bh
         mov   si,strdevn
         call  print
         mov   al,ah
         call  out2h
         mov   si,strdevs
         call  print
         mov   si,rxdata         ; Point to the receive buffer
         lodsb
         call  out2h
         call  pcrlf
         ret
         
;
; test fujinet_reset
;
         mov   si,streset       ; Write host message
         call  print
         mov   si,fujinet_dcb    ; Point to the DCB
         call  fujinet_reset
         cmp   al,FUJINET_RC_OK  ; Check if OK
         jnz   error             ; if not, report error

;
; test fujinet_random_number
;
test_random:
         mov   si,strand         ; Write random number
         call  print
         mov   si,fujinet_dcb    ; Point to the DCB
         call  fujinet_random_number
         cmp   al,FUJINET_RC_OK  ; Check if OK
         jnz   error             ; if not, report error
         mov   ax,[rxdata]       ; Write the number returned
         call  out2h
         mov   ax,[rxdata+1]     ; Write the number returned
         call  out2h
         mov   ax,[rxdata+2]
         call  out2h
         mov   ax,[rxdata+3]
         call  out2h
         call  pcrlf
         call  pcrlf
         ret

;
; test fujinet_get_time
;
test_get_time:
         mov   si,stgtime        ; Write get time
         call  print
         mov   si,fujinet_dcb    ; Point to the DCB
         call  fujinet_get_time
         cmp   al,FUJINET_RC_OK  ; Check if OK
         jnz   error             ; if not, report error
         mov   si,rxdata
         mov   di,tbuffer
         call  date2str
         mov   si,tbuffer
         call  print
         call  pcrlf
         call  pcrlf
         ret

;
; test fujinet_read_host_slots
;
test_read_hosts:
         mov   si,sthost         ; Write host
         call  print
         mov   si,fujinet_dcb    ; Point to the DCB
         mov   di,hostslot
         mov   ds:[si+DCB_RX_BUFFER],di
         call  fujinet_read_host_slots
         cmp   al,FUJINET_RC_OK  ; Check if OK
         jnz   error             ; if not, report error
;
; Write the results
;
         mov   si,sthostt
         call  print
;
         mov   ah,1              ; Start with slot 1
         mov   si,hostslot       ; Point to the hostslot information received
loop_hosts:
         mov   di,tbuffer
         mov   al,ah
         call  chex2dec
         call  blank4
         mov   al,ds:[si]        ; check for an empty slot
         test  al,al
         jnz   host_cp
         push  si
         mov   si,stempty        ; if empty, indicate that it is undefined
         call  strcpy
         pop   si
         jmp   host2
host_cp: call  strcpy            ; Copy the host name
host2:   push  si
         mov   si,tbuffer
         call  print
         call  pcrlf
         pop   si
         inc   ah
         add   si,MAX_HOST_LEN   ; point to next host
         cmp   ah,FUJINET_MAX_HOST_SLOTS+1
         jnz   loop_hosts
         call  pcrlf
         ret
         
;
; test fujinet_read_device_slots
;
test_read_devices:
         mov   si,stdev         ; Write device message
         call  print
         mov   si,fujinet_dcb   ; Point to the DCB
         mov   di,devslot
         mov   ds:[si+DCB_RX_BUFFER],di   ; Set the receive buffer to fill the hostslot area
         call  fujinet_read_device_slots
         cmp   al,FUJINET_RC_OK  ; Check if OK
         jnz   error             ; if not, report error
;
; Write the results
;
         mov   si,stdevt
         call  print
;
         mov   ah,1              ; Start with slot 1
         mov   si,devslot        ; Point to the devslot information received
loop_devs:
         mov   di,tbuffer
         mov   al,ah
         call  chex2dec          ; Write the device slot number
         call  blank4
         mov   al,ds:[si]        ; check for an empty slot
         cmp   al,0ffh
         jnz   devhosts
         push  si
         call  blank4
         call  blank4
         call  blank4
         mov   si,stempty        ; if empty, indicate that it is undefined
         call  strcpy
         pop   si
         jmp   dev2
devhosts:    
         mov   al,[si]           ; get the host slot for the device
         inc   al                ; convert from 0-based to 1-based index
         call  chex2dec          ; write to the buffer
         call  blank4
         mov   al,[si+1]         ; get the device mode
         cmp   al,MODE_READ      ; is it read mode?
         jnz   modew
         mov   al,'R'            ; indicate read mode
         stosb
         jmp   mode_bl
modew:   cmp   al,MODE_WRITE     ; is it write mode?
         jnz   modeu
         mov   al,'W'            ; indicate write mode
         stosb
         jmp   mode_bl
modeu:   mov   al,'?'            ; unknown mode
         stosb
mode_bl: call  blank4
;
dev_cp:  push  si  
         add   si,2              ; point to the device path
         call  strcpy            ; copy the device path to string buffer
         pop   si
dev2:    push  si
         mov   si,tbuffer        ; write the buffer contents
         call  print
         call  pcrlf
         pop   si
         inc   ah
         add   si,MAX_FILE_LEN+2 ; point to next device
         cmp   ah,FUJINET_MAX_DEVICE_SLOTS+1
         jnz   loop_devs
         ret
;
; convert Time structure to string
; Entry: si - points to time structure
;        di - string buffer
;
date2str:
         push  ax
         push  si
         mov   al,ds:[si+FN_TIME_MDAY] ; get the day of month
         call  hex2dec2
         mov   al,'/'
         stosb
         mov   al,ds:[si+FN_TIME_MONTH] ; get the month
         call  hex2dec2
         mov   al,'/'
         stosb
         mov   al,ds:[si+FN_TIME_YEARH] ; get the MSB year
         call  hex2dec2
         mov   al,ds:[si+FN_TIME_YEARL] ; get the LSB year
         call  hex2dec2
         mov   al,' '
         stosb
;
         mov   al,ds:[si+FN_TIME_HOUR] ; get the hour
         call  hex2dec2
         mov   al,':'
         stosb
         mov   al,ds:[si+FN_TIME_MIN] ; get the minutes
         call  hex2dec2
         mov   al,':'
         stosb
         mov   al,ds:[si+FN_TIME_SEC] ; get the seconds
         call  hex2dec2
         mov   al,0
         stosb
         pop   si
         pop   ax
         ret
;
; store 4 spaces
; Entry: es:di = points to location where spaces should be stored
; Exit: es:di = points to location after last space
;
blank4:  call     blank2
         call     blank2
         ret
;
blank2   push  ax
         mov   al,020h
         stosb
         stosb
         pop   ax
         ret
;
section .data
;
stcfg:   db  CR,LF,'==== Configuration query tests ======',CR,LF,EOT
stgtime: db  'Test Get Time ...',CR,LF,EOT
strand:  db  'Random number: 0x',EOT
streset: db  'Reset Fujinet device ...',CR,LF,EOT
sthost:  db  'Querying host slots ...',CR,LF,EOT
sthostt: db  CR,LF,'Slot Path',CR,LF,EOT
stempty: db  '( EMPTY )',EOT
stdev:   db  'Querying device slots ...',CR,LF,EOT
stdevt:  db  CR,LF,'Slot Host Mode Device',CR,LF,EOT
strdevst: db 'Test device enable status ...',CR,LF,EOT
strdevn: db  'Device 0x',EOT
strdevs: db  ' Enable status = 0x',EOT
strdevsl: db 'Device slot=',EOT
strdevfp: db ' Path=',EOT
strdevd: db  'Disable device 0x50',CR,LF,EOT
strdeve: db  'Enable device 0x50',CR,LF,EOT
stnewp:  db  '/CPM86/CPM11.CPM',EOT
;
section  .bss
;
hostslot resb  MAX_HOST_LEN*FUJINET_MAX_HOST_SLOTS
devslot  resb  (MAX_FILE_LEN+2)*FUJINET_MAX_DEVICE_SLOTS
;

