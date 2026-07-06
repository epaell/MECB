;
; FujiNet commands
;

         include "libfujicmdbase.asm"
;
; FujiNet device directory commands
;
;         include "libfujicmddir.asm"

;
; FujiNet WiFi commands
;
;         include "libfujicmdwifi.asm"

;
; file commands - not implemented
;
;         include  "libfujicmdfile.asm"
;
; disk commands
;
         include "libfujicmddisk.asm"
;
; MODEM commands - not implemented
;
;         include "libfujicmdmodem.asm"
;
; Network commands - not implemented
;
;         include "libfujicmdnet.asm"

;
; Printer commands - not implemented
;
;         include "libfujicmdprint.asm"

;
; AppKey commands - not implemented
;
;         include "libfujicmdappkey.asm"
;

;
; Other - not implemented
;
fujinet_device_create_new:
         rts

fujinet_device_disable_device:
         rts

fujinet_device_enable_device:
         rts

fujinet_device_get_adapter_config:
         rts

fujinet_device_get_device_enabled_status:
         rts

fujinet_device_get_device_filename:
         rts

fujinet_write_device_slots:
         rts

fujinet_write_host_slots:
         rts

fujinet_device_set_boot_config:
         rts

fujinet_device_set_device_filename:
         rts

;
; logical device commands
;
fujinet_logical_device_type:
         rts

fujinet_logical_device_unit:
         rts

fujinet_logical_device_url:
         rts


;
; Unimplemented commands
;
;         include "libfujicmdnotimp.asm"
