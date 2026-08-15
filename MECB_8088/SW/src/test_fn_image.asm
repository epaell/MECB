;
section     .text
;
image_tests:
         mov   si,stimage                 ; Write test message
         call  print
;
         mov   si,stmounth                ; Mount the host slot
         mov   di,tbuffer
         call  strcpynt
         mov   ah,im_host_slot            ; Get the host slot
         mov   al,ah
         inc   al                         ; convert to 1-based value
         call  chex2dec
         mov   si,stnewline
         call  strcpy
         mov   si,tbuffer
         call  print
         call  pcrlf
;
; test fujinet_mount_slot
;
         mov   si,fujinet_dcb             ; Initialise the receive and transmit buffer in the DCB
         mov   ax,rxdata
         mov   ds:[si+DCB_RX_BUFFER],ax
         mov   ax,txdata
         mov   ds:[si+DCB_TX_BUFFER],ax
         mov   ah,im_host_slot
         call  fujinet_mount_host         ; Mount the host slot
         cmp   al,FUJINET_RC_OK           ; Check if OK
         jnz   error                      ; if not, report error
;
         mov   si,stmount3                ; Mount the device slot
         mov   di,tbuffer
         call  strcpynt
         mov   ah,device_slot             ; Get the device slot
         mov   al,ah
         inc   al                         ; convert to 1-based value
         call  chex2dec
         mov   si,stnewline
         call  strcpy
         mov   si,tbuffer
         call  print
         call  pcrlf
;
; test fujinet_mount_image
;
         mov   si,fujinet_dcb             ; Initialise the receive and transmit buffer in the DCB
         mov   ax,rxdata
         mov   ds:[si+DCB_RX_BUFFER],ax
         mov   ax,txdata
         mov   ds:[si+DCB_TX_BUFFER],ax
         mov   ah,device_slot
         mov   al,MODE_WRITE
         call  fujinet_mount_image        ; Mount the device image
         cmp   al,FUJINET_RC_OK           ; Check if OK
         jnz   error                      ; if not, report error

;
; test fujinet_disk_read
;
         mov   si,stimread                ; Read from image
         call  print
;
         mov   si,fujinet_dcb             ; Initialise the receive and transmit buffer in the DCB
         mov   ax,rxdata
         mov   ds:[si+DCB_RX_BUFFER],ax
         mov   ax,txdata
         mov   ds:[si+DCB_TX_BUFFER],ax
         mov   ah,device_slot
         mov   bx,0                       ; read sector 0
         call  fujinet_disk_read          ; Read the disk
         cmp   al,FUJINET_RC_OK           ; Check if OK
         jnz   error                      ; if not, report error
;
; test fujinet_disk_write
;
         mov   si,stimwrite               ; Write to image
         call  print
;
         mov   di,txdata                  ; fill the transmit buffer with data
         mov   cx,DISK_SECTOR_SIZE
         mov   al,0
txloop1: stosb                            ; clear sector buffer
         loop  txloop1

         mov   si,fujinet_dcb             ; Initialise the receive and transmit buffer in the DCB
         mov   ax,rxdata
         mov   ds:[si+DCB_RX_BUFFER],ax
         mov   ax,txdata
         mov   ds:[si+DCB_TX_BUFFER],ax
         mov   ah,device_slot
         mov   bx,0                       ; read sector 0
         call  fujinet_disk_write         ; Write to the disk
         cmp   al,FUJINET_RC_OK           ; Check if OK
         jnz   error                      ; if not, report error
;
; Read back what was written
;
         mov   si,stimread                ; Read from image
         call  print
;
         mov   si,fujinet_dcb             ; Initialise the receive and transmit buffer in the DCB
         mov   ax,rxdata
         mov   ds:[si+DCB_RX_BUFFER],ax
         mov   ax,txdata
         mov   ds:[si+DCB_TX_BUFFER],ax
         mov   ah,device_slot
         mov   bx,0                       ; read sector 0
         call  fujinet_disk_read          ; Read the disk
         cmp   al,FUJINET_RC_OK           ; Check if OK
         jnz   error                      ; if not, report error
         ret
;
; test fujinet_unmount_image
;
         mov   si,stunmount3              ; Unmount the device slot image
         mov   di,tbuffer
         call  strcpynt
         mov   ah,device_slot             ; Get the device slot
         mov   al,ah
         inc   al                         ; convert to 1-based value
         call  chex2dec
         mov   si,stnewline
         call  strcpy
         mov   si,tbuffer
         call  print
         call  pcrlf

         mov   si,fujinet_dcb             ; Initialise the receive and transmit buffer in the DCB
         mov   ah,device_slot
         call  fujinet_unmount_image      ; Unount the device image
         cmp   al,FUJINET_RC_OK           ; Check if OK
         jnz   error                      ; if not, report error
         ret
;
section .data
;
stimage:          db   CR,LF,'====== Image access tests ======',CR,LF,EOT
stmounth:         db   'Mounting host slot ',EOT
stmount3:         db   'Mounting image in device slot ',EOT
stimread:         db   'Reading sector from image',CR,LF,EOT
stimwrite:        db   'Writing sector to image',CR,LF,EOT
stunmount3:       db   'Unmounting image in device slot ',EOT
im_host_slot:     db   0
device_slot:      db   0
