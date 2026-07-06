fujinet_mount_all:
         pshs  b
         lda   #RC2014_DEVICEID_FUJINET
         sta   DCB_DEVICE,x
         lda   #FUJICMD_MOUNT_ALL      ; Set up DCB for mount all hosts command
         sta   DCB_COMMAND,x
         ldd   #0
         std   DCB_AUX1,x              ; Clear aux1/2
         std   DCB_RX_BUFFER_LEN,x     ; Receive length=0
         std   DCB_TX_BUFFER_LEN,x     ; Transmit length=0
         ldd   #FUJINET_TIMEOUT        ; Set time-out
         std   DCB_TIMEOUT,x
         lbsr  fujinet_dcb_exec
         puls  b,pc

; fujinet_mount_host - mount the specified host slot
; Entry: x - points to DCB area
;        b - 0-based host slot
; Exit:  a - return code
; 
fujinet_mount_host:
         pshs  b
         lda   #RC2014_DEVICEID_FUJINET
         sta   DCB_DEVICE,x
         lda   #FUJICMD_MOUNT_HOST     ; Set up DCB for mount host command
         sta   DCB_COMMAND,x
         stb   DCB_AUX1,x              ; The host slot to mount
         ldd   #0
         stb   DCB_AUX2,x              ; Clear aux2
         std   DCB_RX_BUFFER_LEN,x     ; Receive length=0
         std   DCB_TX_BUFFER_LEN,x     ; Transmit length=0
         ldd   #FUJINET_TIMEOUT        ; Set time-out
         std   DCB_TIMEOUT,x
         lbsr  fujinet_dcb_exec
         puls  b,pc

;
; fujinet_reset - reset the fujinet device
; Entry: x - points to DCB area
; Exit:  a - return code
fujinet_reset:
         pshs  b
         lda   #RC2014_DEVICEID_FUJINET
         sta   DCB_DEVICE,x
         lda   #FUJICMD_RESET ; Reset the device
         sta   DCB_COMMAND,x
         ldd   #0
         std   DCB_AUX1,x
         std   DCB_TX_BUFFER_LEN,x
         std   DCB_RX_BUFFER_LEN,x
         ldd   #FUJINET_TIMEOUT
         std   DCB_TIMEOUT,x
         lbsr  fujinet_dcb_exec
         puls  b,pc

;
; fujinet_read_host_slots - read the host slots
; Entry: x - points to DCB area
; Exit:  a - return code
;        rdata - (HostSlot[MAX_HOST_LEN=32] * FUJINET_MAX_HOST_SLOTS)
fujinet_read_host_slots:
         pshs  b
         lda   #RC2014_DEVICEID_FUJINET
         sta   DCB_DEVICE,x
         lda   #FUJICMD_READ_HOST_SLOTS ; Get Host Slots
         sta   DCB_COMMAND,x
         ldd   #0
         std   DCB_AUX1,x
         std   DCB_TX_BUFFER_LEN,x
         ldd   #FUJINET_TIMEOUT
         std   DCB_TIMEOUT,x
         ldd   #MAX_HOST_LEN*FUJINET_MAX_HOST_SLOTS
         std   DCB_RX_BUFFER_LEN,x
         lbsr  fujinet_dcb_exec
         puls  b,pc

;
; fujinet_read_host_slots - read the device slots
; Entry: x - points to DCB area
; Exit:  a - return code
;        rdata - (DeviceSlot[FUJINET_MAX_DEVICE_SLOTS=8]=38*8
;                 DeviceSlot = hostSlot=1,mode=1,file[MAX_FILE_LEN=36]=38
fujinet_read_device_slots:
         pshs  b
         lda   #RC2014_DEVICEID_FUJINET
         sta   DCB_DEVICE,x
         lda   #FUJICMD_READ_DEVICE_SLOTS ; Get Device Slots
         sta   DCB_COMMAND,x
         ldd   #0
         std   DCB_AUX1,x
         std   DCB_TX_BUFFER_LEN,x
         ldd   #FUJINET_TIMEOUT
         std   DCB_TIMEOUT,x
         ldd   #(MAX_FILE_LEN+2)*FUJINET_MAX_DEVICE_SLOTS
         std   DCB_RX_BUFFER_LEN,x
         lbsr  fujinet_dcb_exec
         puls  b,pc

; fujinet_random_number - return a random number
; Entry: x - points to DCB area
; Exit:  a - return code
;            DCB_RX_BUFFER[0-3] = random number
; 
fujinet_random_number:
         pshs  b
         lda   #RC2014_DEVICEID_FUJINET
         sta   DCB_DEVICE,x
         lda   #FUJICMD_RANDOM_NUMBER  ; Request a random number
         sta   DCB_COMMAND,x
         ldd   #0
         std   DCB_AUX1,x              ; Clear aux1/2
         std   DCB_TX_BUFFER_LEN,x     ; Transmit length=0
         ldb   #4
         std   DCB_RX_BUFFER_LEN,x     ; Receive length=4
         ldd   #FUJINET_TIMEOUT        ; Set time-out
         std   DCB_TIMEOUT,x
         lbsr  fujinet_dcb_exec
         puls  b,pc

; fujinet_get_time - get the date/time
; Entry: x - points to DCB area
; Exit:  a - return code
;            DCB_RX_BUFFER = Time
; 
fujinet_get_time:
         pshs  b
         lda   #RC2014_DEVICEID_FUJINET
         sta   DCB_DEVICE,x
         lda   #FUJICMD_GET_TIME       ; Request the date/time
         sta   DCB_COMMAND,x
         ldd   #0
         std   DCB_AUX1,x              ; Clear aux1/2
         std   DCB_TX_BUFFER_LEN,x     ; Transmit length=0
         ldb   #TIME_LEN
         std   DCB_RX_BUFFER_LEN,x     ; Receive length=7
         ldd   #FUJINET_TIMEOUT        ; Set time-out
         std   DCB_TIMEOUT,x
         lbsr  fujinet_dcb_exec
         puls  b,pc

