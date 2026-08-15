; fujinet_mount_all - mount all devices
; Entry: ds:si - points to DCB area
; Exit:  al - return code
; 
fujinet_mount_all:
         mov   al,RC2014_DEVICEID_FUJINET
         mov   ah,FUJICMD_MOUNT_ALL
         mov   ds:[si+DCB_DEVICE],ax
         mov   ax,0
         mov   ds:[si+DCB_AUX1],ax
         mov   ds:[si+DCB_TX_BUFFER_LEN],ax
         mov   ds:[si+DCB_RX_BUFFER_LEN],ax
         mov   ax,FUJINET_TIMEOUT
         mov   ds:[si+DCB_TIMEOUT],ax
         call  fujinet_dcb_exec
         ret

; fujinet_mount_host - mount the specified host slot
; Entry: ds:si - points to DCB area
;        ah - 0-based host slot
; Exit:  al - return code
; 
fujinet_mount_host:
         mov   al,0
         mov   ds:[si+DCB_AUX1],ah
         mov   ds:[si+DCB_AUX2],al
         mov   al,RC2014_DEVICEID_FUJINET
         mov   ah,FUJICMD_MOUNT_HOST
         mov   ds:[si+DCB_DEVICE],ax
         mov   ax,0
         mov   ds:[si+DCB_TX_BUFFER_LEN],ax
         mov   ds:[si+DCB_RX_BUFFER_LEN],ax
         mov   ax,FUJINET_TIMEOUT
         mov   ds:[si+DCB_TIMEOUT],ax
         call  fujinet_dcb_exec
         ret

;
; fujinet_reset - reset the fujinet device
; Entry: ds:si - points to DCB area
; Exit:  al - return code
fujinet_reset:
         mov   al,RC2014_DEVICEID_FUJINET
         mov   ah,FUJICMD_RESET
         mov   ds:[si+DCB_DEVICE],ax
         mov   ax,0
         mov   ds:[si+DCB_AUX1],ax
         mov   ds:[si+DCB_TX_BUFFER_LEN],ax
         mov   ds:[si+DCB_RX_BUFFER_LEN],ax
         mov   ax,FUJINET_TIMEOUT
         mov   ds:[si+DCB_TIMEOUT],ax
         call  fujinet_dcb_exec
         ret

;
; fujinet_read_host_slots - read the host slots
; Entry: ds:si - points to DCB area
; Exit:  al - return code
;        DCB_RX_BUFFER - (HostSlot[MAX_HOST_LEN=32] * FUJINET_MAX_HOST_SLOTS)
fujinet_read_host_slots:
         mov   al,RC2014_DEVICEID_FUJINET
         mov   ah,FUJICMD_READ_HOST_SLOTS
         mov   ds:[si+DCB_DEVICE],ax
         mov   ax,0
         mov   ds:[si+DCB_AUX1],ax
         mov   ds:[si+DCB_TX_BUFFER_LEN],ax
         mov   ax,MAX_HOST_LEN*FUJINET_MAX_HOST_SLOTS
         mov   ds:[si+DCB_RX_BUFFER_LEN],ax
         mov   ax,FUJINET_TIMEOUT
         mov   ds:[si+DCB_TIMEOUT],ax
         call  fujinet_dcb_exec
         ret

;
; fujinet_read_device_slots - read the device slots
; Entry: ds:si - points to DCB area
; Exit:  al - return code
;        DCB_RX_BUFFER - (DeviceSlot[FUJINET_MAX_DEVICE_SLOTS=8]=38*8
;                    DeviceSlot = hostSlot=1 byte,mode=1 byte,file[MAX_FILE_LEN=36]=38
fujinet_read_device_slots:
         mov   al,RC2014_DEVICEID_FUJINET
         mov   ah,FUJICMD_READ_DEVICE_SLOTS
         mov   ds:[si+DCB_DEVICE],ax
         mov   ax,0
         mov   ds:[si+DCB_AUX1],ax
         mov   ds:[si+DCB_TX_BUFFER_LEN],ax
         mov   ax,(MAX_FILE_LEN+2)*FUJINET_MAX_DEVICE_SLOTS
         mov   ds:[si+DCB_RX_BUFFER_LEN],ax
         mov   ax,FUJINET_TIMEOUT
         mov   ds:[si+DCB_TIMEOUT],ax
         call  fujinet_dcb_exec
         ret

; fujinet_random_number - return a random number
; Entry: ds:si - points to DCB area
; Exit:  al - return code
;            DCB_RX_BUFFER[0-3] = random number
; 
fujinet_random_number:
         mov   al,RC2014_DEVICEID_FUJINET
         mov   ah,FUJICMD_RANDOM_NUMBER
         mov   ds:[si+DCB_DEVICE],ax
         mov   ax,0
         mov   ds:[si+DCB_AUX1],ax
         mov   ds:[si+DCB_TX_BUFFER_LEN],ax
         mov   al,4
         mov   ds:[si+DCB_RX_BUFFER_LEN],ax
         mov   ax,FUJINET_TIMEOUT
         mov   ds:[si+DCB_TIMEOUT],ax
         call  fujinet_dcb_exec
         ret

; fujinet_get_time - get the date/time
; Entry: ds:si - points to DCB area
; Exit:  al - return code
;        DCB_RX_BUFFER = Time
; 
fujinet_get_time:
         mov   al,RC2014_DEVICEID_FUJINET
         mov   ah,FUJICMD_GET_TIME
         mov   ds:[si+DCB_DEVICE],ax
         mov   ax,0
         mov   ds:[si+DCB_AUX1],ax
         mov   ds:[si+DCB_TX_BUFFER_LEN],ax
         mov   al,TIME_LEN
         mov   ds:[si+DCB_RX_BUFFER_LEN],ax
         mov   ax,FUJINET_TIMEOUT
         mov   ds:[si+DCB_TIMEOUT],ax
         call  fujinet_dcb_exec
         ret

;
; fujinet_write_device_slots - write the device slots
; Entry: ds:si - points to DCB area
;        DCB_TX_BUFFER - (DeviceSlot[FUJINET_MAX_DEVICE_SLOTS=8]=38*8
;                    DeviceSlot = hostSlot=1 byte,mode=1 byte,file[MAX_FILE_LEN=36]=38
; Exit:  al - return code
fujinet_write_device_slots:
         mov   al,RC2014_DEVICEID_FUJINET
         mov   ah,FUJICMD_WRITE_DEVICE_SLOTS
         mov   ds:[si+DCB_DEVICE],ax
         mov   ax,0
         mov   ds:[si+DCB_RX_BUFFER_LEN],ax
         mov   ds:[si+DCB_AUX1],ax
         mov   ax,(MAX_FILE_LEN+2)*FUJINET_MAX_DEVICE_SLOTS
         mov   ds:[si+DCB_TX_BUFFER_LEN],ax
         mov   ax,FUJINET_TIMEOUT
         mov   ds:[si+DCB_TIMEOUT],ax
         call  fujinet_dcb_exec
         ret

;
; fujinet_write_host_slots - write the host slots
; Entry: ds:si - points to DCB area
;        DCB_TX_BUFFER - (HostSlot[MAX_HOST_LEN=32] * FUJINET_MAX_HOST_SLOTS)
; Exit:  al - return code
fujinet_write_host_slots:
         mov   al,RC2014_DEVICEID_FUJINET
         mov   ah,FUJICMD_WRITE_HOST_SLOTS
         mov   ds:[si+DCB_DEVICE],ax
         mov   ax,0
         mov   ds:[si+DCB_RX_BUFFER_LEN],ax
         mov   ds:[si+DCB_AUX1],ax
         mov   ax,MAX_HOST_LEN*FUJINET_MAX_HOST_SLOTS
         mov   ds:[si+DCB_TX_BUFFER_LEN],ax
         mov   ax,FUJINET_TIMEOUT
         mov   ds:[si+DCB_TIMEOUT],ax
         call  fujinet_dcb_exec
         ret

; fujinet_device_disable_device - disable the specified device
; Entry: ds:si - points to DCB area
;        ah - DEVICEID
; Exit:  al - return code
; 
fujinet_disable_device:
         mov   al,0
         mov   ds:[si+DCB_AUX1],ah
         mov   ds:[si+DCB_AUX2],al
         mov   al,RC2014_DEVICEID_FUJINET
         mov   ah,FUJICMD_DISABLE_DEVICE
         mov   ds:[si+DCB_DEVICE],ax
         mov   ax,0
         mov   ds:[si+DCB_TX_BUFFER_LEN],ax
         mov   ds:[si+DCB_RX_BUFFER_LEN],ax
         mov   ax,15
         mov   ds:[si+DCB_TIMEOUT],ax
         call  fujinet_dcb_exec
         ret


; fujinet_device_enable_device - enable the specified device
; Entry: ds:si - points to DCB area
;        ah - DEVICEID
; Exit:  al - return code
; 
fujinet_enable_device:
         mov   al,0
         mov   ds:[si+DCB_AUX1],ah
         mov   ds:[si+DCB_AUX2],al
         mov   al,RC2014_DEVICEID_FUJINET
         mov   ah,FUJICMD_ENABLE_DEVICE
         mov   ds:[si+DCB_DEVICE],ax
         mov   ax,0
         mov   ds:[si+DCB_TX_BUFFER_LEN],ax
         mov   ds:[si+DCB_RX_BUFFER_LEN],ax
         mov   ax,15
         mov   ds:[si+DCB_TIMEOUT],ax
         call  fujinet_dcb_exec
         ret

; fujinet_get_device_enabled_status - get the enabled status of the specified device
; Entry: ds:si - points to DCB area
;        ah - DEVICEID
; Exit:  al - return code
;        DCB_RX_BUFFER - (status = 1 byte)
; 
fujinet_get_device_enabled_status:
         mov   al,0
         mov   ds:[si+DCB_AUX1],ah
         mov   ds:[si+DCB_AUX2],al
         mov   al,RC2014_DEVICEID_FUJINET
         mov   ah,FUJICMD_DEVICE_ENABLE_STATUS
         mov   ds:[si+DCB_DEVICE],ax
         mov   ax,0
         mov   ds:[si+DCB_TX_BUFFER_LEN],ax
         inc   ax
         mov   ds:[si+DCB_RX_BUFFER_LEN],ax
         mov   ax,15
         mov   ds:[si+DCB_TIMEOUT],ax
         call  fujinet_dcb_exec
         ret

; fujinet_get_device_fullpath - get the full path of the specified device slot
; Entry: ds:si - points to DCB area
;        ah - device slot
; Exit:  al - return code
;        DCB_RX_BUFFER - (path[MAX_PATH_LEN])
; 
fujinet_get_device_fullpath:
         mov   al,0
         mov   ds:[si+DCB_AUX1],ah
         mov   ds:[si+DCB_AUX2],al
         mov   al,RC2014_DEVICEID_FUJINET
         mov   ah,FUJICMD_GET_DEVICE_FULLPATH
         mov   ds:[si+DCB_DEVICE],ax
         mov   ax,0
         mov   ds:[si+DCB_TX_BUFFER_LEN],ax
         mov   ax,MAX_PATH_LEN
         mov   ds:[si+DCB_RX_BUFFER_LEN],ax
         mov   ax,15
         mov   ds:[si+DCB_TIMEOUT],ax
         call  fujinet_dcb_exec
         ret

; fujinet_set_device_fullpath - set the full path of the specified device slot
; Entry: ds:si - points to DCB area
;        ah - device slot
;        DCB_TX_BUFFER - (path[MAX_PATH_LEN])
; Exit:  al - return code
; 
fujinet_set_device_fullpath:
         mov   al,0
         mov   ds:[si+DCB_AUX1],ah
         mov   ds:[si+DCB_AUX2],al
         mov   al,RC2014_DEVICEID_FUJINET
         mov   ah,FUJICMD_SET_DEVICE_FULLPATH
         mov   ds:[si+DCB_DEVICE],ax
         mov   ax,0
         mov   ds:[si+DCB_RX_BUFFER_LEN],ax
         mov   ax,MAX_PATH_LEN
         mov   ds:[si+DCB_TX_BUFFER_LEN],ax
         mov   ax,15
         mov   ds:[si+DCB_TIMEOUT],ax
         call  fujinet_dcb_exec
         ret

fujinet_set_boot_config:
         mov   al,FUJINET_RC_NOT_IMPLEMENTED
         ret

fujinet_device_create_new:
         mov   al,FUJINET_RC_NOT_IMPLEMENTED
         ret

fujinet_get_adapter_config:
         mov   al,FUJINET_RC_NOT_IMPLEMENTED
         ret


;
; logical device commands
;
fujinet_logical_device_type:
         mov   al,FUJINET_RC_NOT_IMPLEMENTED
         ret

fujinet_logical_device_unit:
         mov   al,FUJINET_RC_NOT_IMPLEMENTED
         ret

fujinet_logical_device_url:
         mov   al,FUJINET_RC_NOT_IMPLEMENTED
         ret

