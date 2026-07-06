;
; fujinet_mount_image - mount the image in the specified device slot
; Entry: x - points to DCB area
;        a - mode
;        b - 0-based host slot
; Exit:  a - return code
; 
fujinet_mount_image:
         jsr   clr_dcb
         stb   DCB_AUX1,x              ; save the device slot
         sta   DCB_AUX2,x              ; save the mode
         lda   #RC2014_DEVICEID_FUJINET
         sta   DCB_DEVICE,x
         lda   #FUJICMD_MOUNT_IMAGE    ; Set up DCB for mount image command
         sta   DCB_COMMAND,x
         clr   DCB_TIMEOUT,x
         lda   #15                     ; Set time-out
         sta   DCB_TIMEOUT+1,x
         jsr  fujinet_dcb_exec
         rts

;
; fujinet_disk_read - read a disk
; Entry: x - points to DCB area
;        DCB_AUX1 - sector number LSB
;        DCB_AUX2 - sector number MSB
;        b - disk id (0-7)
; Exit:  a - return code
;        DCB_RX_BUFFER = data read
;
fujinet_disk_read:
         pshb
         jsr   clr_dcb
         addb  #RC2014_DEVICEID_DISK   ; working with a disk device
         stb   DCB_DEVICE,x
         lda   #DEVICE_READ            ; read from disk device
         sta   DCB_COMMAND,x
         lda   #DISK_SECTOR_SIZE>>8    ;
         sta   DCB_RX_BUFFER_LEN,x
         lda   #DISK_SECTOR_SIZE&$ff   ;
         sta   DCB_RX_BUFFER_LEN+1,x
         jsr  fujinet_dcb_exec
         pulb
         rts

;
; fujinet_unmount_image - unmount the image in the specified device slot
; Entry: x - points to DCB area
;        b - 0-based host slot
; Exit:  a - return code
fujinet_unmount_image:
         pshb
         jsr   clr_dcb
         stb   DCB_AUX1,x              ; save the device slot
         clr   DCB_AUX2,x
         lda   #RC2014_DEVICEID_FUJINET
         sta   DCB_DEVICE,x
         lda   #FUJICMD_UNMOUNT_IMAGE  ; Set up DCB for unmount image command
         sta   DCB_COMMAND,x
         clr   DCB_TIMEOUT,x
         lda   #15                     ; Set time-out
         sta   DCB_TIMEOUT+1,x
         jsr  fujinet_dcb_exec
         pulb
         rts

fujinet_disk_get_sector_size:
         jsr   clr_dcb
         rts

;
; fujinet_disk_write - write a disk
; Entry: x - points to DCB area
;        DCB_AUX1 - sector number LSB
;        DCB_AUX2 - sector number MSB
;        b - disk id (0-7)
; Exit:  a - return code
;        DCB_TX_BUFFER = data to write
;
fujinet_disk_write:
         jsr   clr_dcb
         pshb
         addb  #RC2014_DEVICEID_DISK   ; working with a disk device
         stb   DCB_DEVICE,x
         lda   #DEVICE_WRITE           ; write to disk device
         sta   DCB_COMMAND,x
         lda   #DISK_SECTOR_SIZE>>8       ;
         sta   DCB_TX_BUFFER_LEN,x
         lda   #DISK_SECTOR_SIZE&$FF       ;
         sta   DCB_TX_BUFFER_LEN+1,x
         jsr  fujinet_dcb_exec
         pulb
         rts
