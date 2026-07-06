fujinet_new_disk:
         rts

fujinet_set_host_prefix:
         rts

fujinet_get_host_prefix:
         rts

fujinet_copy_file:
         rts

fujinet_set_boot_mode:
         rts

fujinet_status:
         rts

fujinet_get_adapterconfig_extended:
         rts

fujinet_generate_guid:
         rts

fujinet_set_status:
         rts

; *** epaell *** this is not implemented in the firmware so it currently doesn't work
; fujinet_unmount_host - unmount the specified host slot
; Entry: x - points to DCB area
;        b - 0-based host slot
; Exit:  a - return code
; 
fujinet_unmount_host:
         pshs  b
         lda   #RC2014_DEVICEID_FUJINET
         sta   DCB_DEVICE,x
         lda   #FUJICMD_UNMOUNT_HOST   ; Set up DCB for unmount host command
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
