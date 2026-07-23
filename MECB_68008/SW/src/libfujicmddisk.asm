;
; fujinet_mount_image - mount the image in the specified device slot
; Entry: a0 - points to DCB area
;        d0.b - mode
;        d1.b - 0-based host slot
; Exit:  d0.b - return code
; 
fujinet_mount_image:
         move.w   #RC2014_DEVICEID_FUJINET<<8+FUJICMD_MOUNT_IMAGE,DCB_DEVICE(a0)
         move.b   d1,DCB_AUX1(a0)
         move.b   d0,DCB_AUX2(a0)
         move.l   #0,DCB_RX_BUFFER_LEN(a0)
         move.w   #15,DCB_TIMEOUT(a0)
         bsr      fujinet_dcb_exec
         rts

;
; fujinet_disk_read - read a disk
; Entry: a0 - points to DCB area
;        d0.w - sector number
;        d1.b - disk id (0-7)
; Exit:  d0.b - return code
;        DCB_RX_BUFFER = data read
;
fujinet_disk_read:
         move.l   d1,-(a7)
         and.l    #$ff,d1
         lsl.w    #8,d1
         add.w #  RC2014_DEVICEID_DISK<<8+DEVICE_READ,d1   ; working with a network device and opening
         move.w   d1,DCB_DEVICE(a0)
         move.w   #DISK_SECTOR_SIZE,DCB_RX_BUFFER_LEN(a0)
         move.w   #0,DCB_TX_BUFFER_LEN(a0)
         move.w   #FUJINET_NETWORK_TIMEOUT,DCB_TIMEOUT(a0)
         move.b   d0,DCB_AUX1(a0)                          ; LSB of sector number
         lsr.w    #8,d0
         move.b   d0,DCB_AUX2(a0)                          ; MSB of sector number
         bsr      fujinet_dcb_exec
         move.l   (a7)+,d1
         rts

;
; fujinet_unmount_image - unmount the image in the specified device slot
; Entry: a0 - points to DCB area
;        d1.b - 0-based host slot
; Exit:  d0.b - return code
fujinet_unmount_image:
         move.l   d1,-(a7)
         and.l    #$ff,d1
         lsl.w    #8,d1
         add.l    #RC2014_DEVICEID_FUJINET<<24+FUJICMD_UNMOUNT_IMAGE<<16,d1
         move.l   d1,DCB_DEVICE(a0)
         move.w   #DISK_SECTOR_SIZE,DCB_RX_BUFFER_LEN(a0)
         move.l   #0,DCB_RX_BUFFER_LEN(a0)
         move.w   #15,DCB_TIMEOUT(a0)
         bsr      fujinet_dcb_exec
         move.l   (a7)+,d1
         rts

fujinet_disk_get_sector_size:
         rts

;
; fujinet_disk_write - write a disk
; Entry: a0 - points to DCB area
;        d0.w - sector number
;        d1.b - disk id (0-7)
; Exit:  a0 - return code
;        DCB_RX_BUFFER = data read
;
fujinet_disk_write:
         move.l   d1,-(a7)
         and.l    #$ff,d1
         lsl.w    #8,d1
         add.w    #RC2014_DEVICEID_DISK<<8+DEVICE_WRITE,d1 ; working with a network device and opening
         move.w   d1,DCB_DEVICE(a0)
         move.w   #DISK_SECTOR_SIZE,DCB_TX_BUFFER_LEN(a0)
         move.w   #0,DCB_RX_BUFFER_LEN(a0)
         move.w   #FUJINET_NETWORK_TIMEOUT,DCB_TIMEOUT(a0)
         move.b   d0,DCB_AUX1(a0)                          ; LSB of sector number
         lsr.w    #8,d0
         move.b   d0,DCB_AUX2(a0)                          ; MSB of sector number
         bsr      fujinet_dcb_exec
         move.l   (a7)+,d1
         rts
