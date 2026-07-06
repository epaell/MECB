;
; fujinet_mount_image - mount the image in the specified device slot
; Entry: x - points to DCB area
;        a - mode
;        b - 0-based host slot
; Exit:  a - return code
; 
fujinet_mount_image:
         pshs  b
         stb   DCB_AUX1,x              ; save the device slot
         sta   DCB_AUX2,x              ; save the mode
         lda   #RC2014_DEVICEID_FUJINET
         sta   DCB_DEVICE,x
         lda   #FUJICMD_MOUNT_IMAGE    ; Set up DCB for mount image command
         sta   DCB_COMMAND,x
         ldd   #0
         std   DCB_RX_BUFFER_LEN,x     ; Receive length=0
         std   DCB_TX_BUFFER_LEN,x     ; Transmit length=0
         ldd   #15 ; *** epaell *** not sure why this isn't FUJINET_TIMEOUT        ; Set time-out
         std   DCB_TIMEOUT,x
         lbsr  fujinet_dcb_exec
         puls  b,pc

;
; fujinet_disk_read - read a disk
; Entry: x - points to DCB area
;        y - sector number
;        b - disk id (0-7)
; Exit:  a - return code
;        DCB_RX_BUFFER = data read
;
fujinet_disk_read:
         pshs  b
         addb  #RC2014_DEVICEID_DISK   ; working with a disk device
         stb   DCB_DEVICE,x
         lda   #DEVICE_READ            ; read from disk device
         sta   DCB_COMMAND,x
         tfr   y,d                     ; get the sector number
         sta   DCB_AUX2,x              ; set the sector number
         stb   DCB_AUX1,x
         ldd   #DISK_SECTOR_SIZE       ;
         std   DCB_RX_BUFFER_LEN,x
         ldd   #0
         std   DCB_TX_BUFFER_LEN,x
         ldd   #FUJINET_TIMEOUT
         std   DCB_TIMEOUT,x
         lbsr  fujinet_dcb_exec
         puls  b,pc
         rts

;
; fujinet_unmount_image - unmount the image in the specified device slot
; Entry: x - points to DCB area
;        b - 0-based host slot
; Exit:  a - return code
fujinet_unmount_image:
         pshs  b
         stb   DCB_AUX1,x              ; save the device slot
         lda   #RC2014_DEVICEID_FUJINET
         sta   DCB_DEVICE,x
         lda   #FUJICMD_UNMOUNT_IMAGE  ; Set up DCB for unmount image command
         sta   DCB_COMMAND,x
         ldd   #0
         sta   DCB_AUX2,x              ; reset AUX2
         std   DCB_RX_BUFFER_LEN,x     ; Receive length=0
         std   DCB_TX_BUFFER_LEN,x     ; Transmit length=0
         ldd   #15 ; *** epaell *** not sure why this isn't FUJINET_TIMEOUT        ; Set time-out
         std   DCB_TIMEOUT,x
         lbsr  fujinet_dcb_exec
         puls  b,pc

fujinet_disk_get_sector_size:
         rts

;
; fujinet_disk_write - write a disk
; Entry: x - points to DCB area
;        y - sector number
;        b - disk id (0-7)
; Exit:  a - return code
;        DCB_RX_BUFFER = data read
;
fujinet_disk_write:
         pshs  b
         addb  #RC2014_DEVICEID_DISK   ; working with a disk device
         stb   DCB_DEVICE,x
         lda   #DEVICE_WRITE           ; write to disk device
         sta   DCB_COMMAND,x
         tfr   y,d                     ; get the sector number
         sta   DCB_AUX2,x              ; set the sector number
         stb   DCB_AUX1,x
         ldd   #DISK_SECTOR_SIZE       ;
         std   DCB_TX_BUFFER_LEN,x
         ldd   #0
         std   DCB_RX_BUFFER_LEN,x
         ldd   #FUJINET_TIMEOUT
         std   DCB_TIMEOUT,x
         lbsr  fujinet_dcb_exec
         puls  b,pc
         rts
