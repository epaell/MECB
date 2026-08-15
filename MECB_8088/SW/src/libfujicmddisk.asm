;
; fujinet_mount_image - mount the image in the specified device slot
; Entry: ds:si - points to DCB area
;        al - mode
;        ah - 0-based host slot
; Exit:  al - return code
; 
fujinet_mount_image:
         mov   ds:[si+DCB_AUX1],ah
         mov   ds:[si+DCB_AUX2],al
         mov   al,RC2014_DEVICEID_FUJINET
         mov   ah,FUJICMD_MOUNT_IMAGE
         mov   ds:[si+DCB_DEVICE],ax
         mov   ax,0
         mov   ds:[si+DCB_TX_BUFFER_LEN],ax
         mov   ds:[si+DCB_RX_BUFFER_LEN],ax
         mov   ax,15
         mov   ds:[si+DCB_TIMEOUT],ax
         call  fujinet_dcb_exec
         ret

;
; fujinet_disk_read - read a disk
; Entry: ds:si - points to DCB area
;        bx - sector number
;        ah - disk id (0-7)
; Exit:  al - return code
;        DCB_RX_BUFFER = data read
;
fujinet_disk_read:
         mov   al,RC2014_DEVICEID_DISK                      ; 31h
         add   al,ah
         mov   [si+DCB_DEVICE],al
         mov   al,DEVICE_READ
         mov   [si+DCB_COMMAND],al
         mov   ax,DISK_SECTOR_SIZE
         mov   [si+DCB_RX_BUFFER_LEN],ax
         mov   ax,0
         mov   [si+DCB_TX_BUFFER_LEN],ax
         mov   ax,FUJINET_NETWORK_TIMEOUT
         mov   [si+DCB_TIMEOUT],ax
         mov   [si+DCB_AUX1],bl                          ; LSB of sector number
         mov   [si+DCB_AUX2],bh                          ; LSB of sector number
         call  fujinet_dcb_exec
         ret

;
; fujinet_unmount_image - unmount the image in the specified device slot
; Entry: ds:si - points to DCB area
;        ah - 0-based host slot
; Exit:  al - return code
fujinet_unmount_image:
         push  ax
         mov   al,0
         mov   ds:[si+DCB_AUX1],ah
         mov   ds:[si+DCB_AUX2],al
         mov   al,RC2014_DEVICEID_FUJINET
         mov   ah,FUJICMD_UNMOUNT_IMAGE
         mov   ds:[si+DCB_DEVICE],ax
         mov   ax,0
         mov   ds:[si+DCB_TX_BUFFER_LEN],ax
         mov   ds:[si+DCB_RX_BUFFER_LEN],ax
         mov   ax,15
         mov   ds:[si+DCB_TIMEOUT],ax
         pop   ax
         call  fujinet_dcb_exec
         ret

;
; fujinet_disk_write - write a disk
; Entry: ds:si - points to DCB area
;        bx - sector number
;        ah - disk id (0-7)
; Exit:  al - return code
;        DCB_RX_BUFFER = data read
;
fujinet_disk_write:
         mov   al,RC2014_DEVICEID_DISK
         add   al,ah
         mov   [si+DCB_DEVICE],al
         mov   al,DEVICE_WRITE
         mov   [si+DCB_COMMAND],al
         mov   ax,DISK_SECTOR_SIZE
         mov   [si+DCB_TX_BUFFER_LEN],ax
         mov   ax,0
         mov   [si+DCB_RX_BUFFER_LEN],ax
         mov   ax,FUJINET_NETWORK_TIMEOUT
         mov   [si+DCB_TIMEOUT],ax
         mov   [si+DCB_AUX1],bl                          ; LSB of sector number
         mov   [si+DCB_AUX2],bh                          ; LSB of sector number
         call  fujinet_dcb_exec
         ret

