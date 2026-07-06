; fujinet_mount_host - mount all host slots
; Entry: x - points to DCB area
; Exit:  a - return code
; 
fujinet_mount_all:
         jsr   clr_dcb
         clr   DCB_AUX1,x
         clr   DCB_AUX2,x
         lda   #RC2014_DEVICEID_FUJINET
         sta   DCB_DEVICE,x
         lda   #FUJICMD_MOUNT_ALL      ; Set up DCB for mount all hosts command
         sta   DCB_COMMAND,x
         jsr   fujinet_dcb_exec
         rts

; fujinet_mount_host - mount the specified host slot
; Entry: x - points to DCB area
;        b - 0-based host slot
; Exit:  a - return code
; 
fujinet_mount_host:
         jsr   clr_dcb
         clr   DCB_AUX1,x
         lda   #RC2014_DEVICEID_FUJINET
         sta   DCB_DEVICE,x
         lda   #FUJICMD_MOUNT_HOST     ; Set up DCB for mount host command
         sta   DCB_COMMAND,x
         stb   DCB_AUX1,x              ; The host slot to mount
         jsr   fujinet_dcb_exec
         rts

;
; fujinet_reset - reset the fujinet device
; Entry: x - points to DCB area
; Exit:  a - return code
fujinet_reset:
         jsr   clr_dcb
         clr   DCB_AUX1,x
         clr   DCB_AUX2,x
         lda   #RC2014_DEVICEID_FUJINET
         sta   DCB_DEVICE,x
         lda   #FUJICMD_RESET ; Reset the device
         sta   DCB_COMMAND,x
         jsr   fujinet_dcb_exec
         rts

;
; fujinet_read_host_slots - read the host slots
; Entry: x - points to DCB area
; Exit:  a - return code
;        rdata - (HostSlot[MAX_HOST_LEN=32] * FUJINET_MAX_HOST_SLOTS)
fujinet_read_host_slots:
         jsr   clr_dcb
         clr   DCB_AUX1,x
         clr   DCB_AUX2,x
         lda   #RC2014_DEVICEID_FUJINET
         sta   DCB_DEVICE,x
         lda   #FUJICMD_READ_HOST_SLOTS ; Get Host Slots
         sta   DCB_COMMAND,x
         lda   #(MAX_HOST_LEN*FUJINET_MAX_HOST_SLOTS)>>8
         sta   DCB_RX_BUFFER_LEN,x
         lda   #(MAX_HOST_LEN*FUJINET_MAX_HOST_SLOTS)&$FF
         sta   DCB_RX_BUFFER_LEN+1,x
         jsr   fujinet_dcb_exec
         rts

;
; fujinet_read_host_slots - read the device slots
; Entry: x - points to DCB area
; Exit:  a - return code
;        rdata - (DeviceSlot[FUJINET_MAX_DEVICE_SLOTS=8]=38*8
;                 DeviceSlot = hostSlot=1,mode=1,file[MAX_FILE_LEN=36]=38
fujinet_read_device_slots:
         jsr   clr_dcb
         clr   DCB_AUX1,x
         clr   DCB_AUX2,x
         lda   #RC2014_DEVICEID_FUJINET
         sta   DCB_DEVICE,x
         lda   #FUJICMD_READ_DEVICE_SLOTS ; Get Device Slots
         sta   DCB_COMMAND,x
         lda   #((MAX_FILE_LEN+2)*FUJINET_MAX_DEVICE_SLOTS)>>8
         sta   DCB_RX_BUFFER_LEN,x
         lda   #((MAX_FILE_LEN+2)*FUJINET_MAX_DEVICE_SLOTS)&$FF
         sta   DCB_RX_BUFFER_LEN+1,x
         jsr   fujinet_dcb_exec
         rts

; fujinet_random_number - return a random number
; Entry: x - points to DCB area
; Exit:  a - return code
;            DCB_RX_BUFFER[0-3] = random number
; 
fujinet_random_number:
         jsr   clr_dcb
         clr   DCB_AUX1,x
         clr   DCB_AUX2,x
         lda   #RC2014_DEVICEID_FUJINET
         sta   DCB_DEVICE,x
         lda   #FUJICMD_RANDOM_NUMBER  ; Request a random number
         sta   DCB_COMMAND,x
         lda   #4
         sta   DCB_RX_BUFFER_LEN+1,x   ; Receive length=4
         jsr   fujinet_dcb_exec
         rts

; fujinet_get_time - get the date/time
; Entry: x - points to DCB area
; Exit:  a - return code
;            DCB_RX_BUFFER = Time
; 
fujinet_get_time:
         jsr   clr_dcb
         clr   DCB_AUX1,x
         clr   DCB_AUX2,x
         lda   #RC2014_DEVICEID_FUJINET
         sta   DCB_DEVICE,x
         lda   #FUJICMD_GET_TIME       ; Request the date/time
         sta   DCB_COMMAND,x
         lda   #TIME_LEN
         sta   DCB_RX_BUFFER_LEN+1,x     ; Receive length=7
         jsr   fujinet_dcb_exec
         rts

