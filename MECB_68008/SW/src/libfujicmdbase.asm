; fujinet_mount_all - mount all devices
; Entry: a0 - points to DCB area
; Exit:  d0.b - return code
; 
fujinet_mount_all:
         move.l   #RC2014_DEVICEID_FUJINET<<24+FUJICMD_MOUNT_ALL<<16,DCB_DEVICE(a0)
         move.l   #0,DCB_RX_BUFFER_LEN(a0)
         move.w   #FUJINET_TIMEOUT,DCB_TIMEOUT(a0)
         bsr      fujinet_dcb_exec
         rts

; fujinet_mount_host - mount the specified host slot
; Entry: a0 - points to DCB area
;        d1.b - 0-based host slot
; Exit:  d0.b - return code
; 
fujinet_mount_host:
         move.w   #RC2014_DEVICEID_FUJINET<<8+FUJICMD_MOUNT_HOST,DCB_DEVICE(a0)
         move.b   d1,DCB_AUX1(a0)
         move.b   #0,DCB_AUX2(a0)
         move.l   #0,DCB_RX_BUFFER_LEN(a0)
         move.w   #FUJINET_TIMEOUT,DCB_TIMEOUT(a0)
         bsr      fujinet_dcb_exec
         rts

;
; fujinet_reset - reset the fujinet device
; Entry: a0 - points to DCB area
; Exit:  d0.b - return code
fujinet_reset:
         move.l   #RC2014_DEVICEID_FUJINET<<24+FUJICMD_RESET<<16,DCB_DEVICE(a0)
         move.l   #0,DCB_RX_BUFFER_LEN(a0)
         move.w   #FUJINET_TIMEOUT,DCB_TIMEOUT(a0)
         bsr      fujinet_dcb_exec
         rts

;
; fujinet_read_host_slots - read the host slots
; Entry: a0 - points to DCB area
; Exit:  d0.b - return code
;        DCB_RX_BUFFER - (HostSlot[MAX_HOST_LEN=32] * FUJINET_MAX_HOST_SLOTS)
fujinet_read_host_slots:
         move.l   #RC2014_DEVICEID_FUJINET<<24+FUJICMD_READ_HOST_SLOTS<<16,DCB_DEVICE(a0)
         move.w   #0,DCB_TX_BUFFER_LEN(a0)
         move.w   #MAX_HOST_LEN*FUJINET_MAX_HOST_SLOTS,DCB_RX_BUFFER_LEN(a0)
         move.w   #FUJINET_TIMEOUT,DCB_TIMEOUT(a0)
         bsr      fujinet_dcb_exec
         rts

;
; fujinet_read_host_slots - read the device slots
; Entry: a0 - points to DCB area
; Exit:  d0.b - return code
;        DCB_RX_BUFFER - (DeviceSlot[FUJINET_MAX_DEVICE_SLOTS=8]=38*8
;                    DeviceSlot = hostSlot=1,mode=1,file[MAX_FILE_LEN=36]=38
fujinet_read_device_slots:
         move.l   #RC2014_DEVICEID_FUJINET<<24+FUJICMD_READ_DEVICE_SLOTS<<16,DCB_DEVICE(a0)
         move.w   #0,DCB_TX_BUFFER_LEN(a0)
         move.w   #(MAX_FILE_LEN+2)*FUJINET_MAX_DEVICE_SLOTS,DCB_RX_BUFFER_LEN(a0)
         move.w   #FUJINET_TIMEOUT,DCB_TIMEOUT(a0)
         bsr      fujinet_dcb_exec
         rts

; fujinet_random_number - return a random number
; Entry: a0 - points to DCB area
; Exit:  d0.b - return code
;            DCB_RX_BUFFER[0-3] = random number
; 
fujinet_random_number:
         move.l   #RC2014_DEVICEID_FUJINET<<24+FUJICMD_RANDOM_NUMBER<<16,DCB_DEVICE(a0)
         move.w   #0,DCB_TX_BUFFER_LEN(a0)
         move.w   #4,DCB_RX_BUFFER_LEN(a0)
         move.w   #FUJINET_TIMEOUT,DCB_TIMEOUT(a0)
         bsr      fujinet_dcb_exec
         rts

; fujinet_get_time - get the date/time
; Entry: a0 - points to DCB area
; Exit:  d0.b - return code
;            DCB_RX_BUFFER = Time
; 
fujinet_get_time:
         move.l   #RC2014_DEVICEID_FUJINET<<24+FUJICMD_GET_TIME<<16,DCB_DEVICE(a0)
         move.w   #0,DCB_TX_BUFFER_LEN(a0)
         move.w   #TIME_LEN,DCB_RX_BUFFER_LEN(a0)
         move.w   #FUJINET_TIMEOUT,DCB_TIMEOUT(a0)
         bsr      fujinet_dcb_exec
         rts

