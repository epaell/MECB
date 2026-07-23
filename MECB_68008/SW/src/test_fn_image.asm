;
;
;
image_tests:
         move.l   #stimage,a0       ; Write test message
         bsr      print
;
         move.l   #stmounth,a0      ; Mount the host slot
         move.l   #tbuffer,a1
         bsr      strcpynt
         move.b   im_host_slot,d0   ; Get the host slot
         add.b    #1,d0             ; convert to 1-based value
         bsr      chex2dec
         move.l   #stnewline,a0
         bsr      strcpy
         move.l   #tbuffer,a0
         bsr      print
         bsr      pcrlf
;
; test fujinet_mount_slot
;
         move.l   #fujinet_dcb,a0            ; Initialise the receive and transmit buffer in the DCB
         move.l   #rxdata,DCB_RX_BUFFER(a0)  ; Set up receive and transmit buffers
         move.l   #txdata,DCB_TX_BUFFER(a0)  ; Set up receive and transmit buffers
         move.b   im_host_slot,d1
         bsr      fujinet_mount_host         ; Mount the host slot
         cmp.b    #FUJINET_RC_OK,d0          ; Check if OK
         bne      error                      ; if not, report error
;
         move.l   #stmount3,a0               ; Mount the device slot
         move.l   #tbuffer,a1
         bsr      strcpynt
         move.b   device_slot,d0             ; Get the device slot
         add.b    #1,d0                      ; convert to 1-based value
         bsr      chex2dec
         move.l   #stnewline,a0
         bsr      strcpy
         move.l   #tbuffer,a0
         bsr      print
         bsr      pcrlf
;
; test fujinet_mount_image
;
         move.l   #fujinet_dcb,a0            ; Initialise the receive and transmit buffer in the DCB
         move.l   #rxdata,DCB_RX_BUFFER(a0)  ; Set up receive and transmit buffers
         move.l   #txdata,DCB_TX_BUFFER(a0)  ; Set up receive and transmit buffers
         move.b   device_slot,d1
         move.b   #MODE_WRITE,d0
         bsr      fujinet_mount_image        ; Mount the device image
         cmp.b    #FUJINET_RC_OK,d0          ; Check if OK
         bne      error                      ; if not, report error

;
; test fujinet_disk_read
;
         move.l   #stimread,a0               ; Read from image
         bsr      print
;
         move.l   #fujinet_dcb,a0            ; Initialise the receive and transmit buffer in the DCB
         move.l   #rxdata,DCB_RX_BUFFER(a0)  ; Set up receive and transmit buffers
         move.l   #txdata,DCB_TX_BUFFER(a0)  ; Set up receive and transmit buffers
         move.b   device_slot,d1
         move.w   #0,d0                      ; read sector 0
         bsr      fujinet_disk_read          ; Read the disk
         cmp.b    #FUJINET_RC_OK,d0          ; Check if OK
         bne      error                      ; if not, report error
;
; test fujinet_disk_write
;
         move.l   #stimwrite,a0              ; Write to image
         bsr      print
;
         move.l   #txdata,a0                 ; fill the transmit buffer with data
         move.w   #DISK_SECTOR_SIZE,d0
txloop1  move.b   #0,(a0)+                   ; clear sector buffer
         sub.b    #1,d0
         bne      txloop1
         move.l   #fujinet_dcb,a0            ; Initialise the receive and transmit buffer in the DCB
         move.l   #rxdata,DCB_RX_BUFFER(a0)  ; Set up receive and transmit buffers
         move.l   #txdata,DCB_TX_BUFFER(a0)  ; Set up receive and transmit buffers
         move.b   device_slot,d1
         move.w   #0,d0                      ; write sector 0
         bsr      fujinet_disk_write         ; Write to the disk
         cmp.b    #FUJINET_RC_OK,d0          ; Check if OK
         bne      error                      ; if not, report error
;
; Read back what was written
;
         move.l   #stimread,a0               ; Read from image
         bsr      print
;
         move.l   #fujinet_dcb,a0            ; Initialise the receive and transmit buffer in the DCB
         move.l   #rxdata,DCB_RX_BUFFER(a0)  ; Set up receive and transmit buffers
         move.l   #txdata,DCB_TX_BUFFER(a0)  ; Set up receive and transmit buffers
         move.b   device_slot,d1
         move.w   #0,d0                      ; read sector 0
         bsr      fujinet_disk_read          ; Read the disk
         cmp.b    #FUJINET_RC_OK,d0          ; Check if OK
         bne      error                      ; if not, report error
         rts
;
; test fujinet_unmount_image
;
         move.l   #stunmount3,a0             ; Unmount the device slot image
         move.l   #tbuffer,a1
         bsr      strcpynt
         move.b   device_slot,d0             ; Get the device slot
         add.b    #1,d0                      ; convert to 1-based value
         bsr      chex2dec
         move.l   #stnewline,a0
         bsr      strcpy
         move.l   #tbuffer,a0
         bsr      print
         bsr      pcrlf

         move.l   #fujinet_dcb,a0            ; Initialise the receive and transmit buffer in the DCB
         move.b   device_slot,d1
         bsr      fujinet_unmount_image      ; Unount the device image
         cmp.b    #FUJINET_RC_OK,d0          ; Check if OK
         bne  error                          ; if not, report error

         rts
;
stimage:          dc.b   CR,LF,'====== Image access tests ======',CR,LF,EOT
stmounth:         dc.b   'Mounting host slot ',EOT
stmount3:         dc.b   'Mounting image in device slot ',EOT
stimread:         dc.b   'Reading sector from image',CR,LF,EOT
stimwrite:        dc.b   'Writing sector to image',CR,LF,EOT
stunmount3:       dc.b   'Unmounting image in device slot ',EOT
im_host_slot:     dc.b   0
device_slot:      dc.b   0
