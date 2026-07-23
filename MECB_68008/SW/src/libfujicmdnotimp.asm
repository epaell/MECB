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
; Entry: a0 - points to DCB area
;        d1.b - 0-based host slot
; Exit:  d0.b - return code
; 
fujinet_unmount_host:
         move.w   #RC2014_DEVICEID_FUJINET<<8+FUJICMD_UNMOUNT_HOST,DCB_DEVICE(a0)
         move.b   d1,DCB_AUX1(a0)
         move.b   #0,DCB_AUX2(a0)
         move.l   #0,DCB_RX_BUFFER_LEN(a0)
         move.w   #FUJINET_NETWORK_TIMEOUT,DCB_TIMEOUT(a0)
         bsr      fujinet_dcb_exec
         rts
