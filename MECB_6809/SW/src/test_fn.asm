; Test suite for libfujinet
;
; Known issues:
;
; fujinet_reset - WiFi stops working after calling, requires hardware reset on ESP32 to re-initiate.
; fujinet_get_scan_result - firmare returns one less byte than it should (changed firmware to fix).
; fujinet_scan_for_networks - ESP32 log reports different number of networks compared to what is returned.
; fujinet_network_open - only seems to work for device 0
;
; In firmware : mediaTypeIMG.cpp, "_media_last_sector = INVALID_SECTOR_VALUE;" on line 206 prevents write to sector 0
; disk_write results in Error: FUJINET_RC_NO_ACK

;
;
         include  "mecb.inc"
         include  "ASSISTMacros.inc"
         include  "libfujinet.inc"
;
STKTOP   equ   $007F          ; System Stack Top
;
         org   USERPROG_ORG

main:
         clra                 ; Initialise Direct Page Register for Zero page
         tfr   a,dp
         lds   #STKTOP        ; Set Stack to Stack Top
         ldx   #ststart
         lbsr  print
;
         ldx   #fujinet_dcb   ; Initialise the receive and transmit buffer in the DCB
         ldd   #rxdata
         std   DCB_RX_BUFFER,x
         ldd   #txdata
         std   DCB_TX_BUFFER,x
;
         lbsr  fujinet_init   ; Initialise the fujinet device
;
;         lbsr  config_tests   ; Check configuration of hosts and devices
;         lbsr  wifi_tests     ; Check WiFi commands
;         lbsr  dir_tests      ; Check directory access
;         lbsr  file_tests      ; Check file access
;         lbsr  image_tests    ; Check image access
         lbsr  net_tests
exit     monitr  $01          ; return to monitor

         include "test_fn_config.asm"
;         include "test_fn_wifi.asm"
;         include "test_fn_dir.asm"
;         include "test_fn_file.asm"
;         include "test_fn_image.asm"
         include "test_fn_net.asm"
;
error    lbsr  fn_perror      ; Print the error string
         monitr  $01          ; return to monitor
;
;
ststart:    fcb   CR,LF,'FujiNet module tests',CR,LF,EOT
stnewline:  fcb CR,LF,EOT
;
tbuffer  rmb   64             ; Text buffer for output
blank    fcb   '                                                               ',0
;
fujinet_dcb:
         rmb   1              ; FujiNet device
         rmb   1              ; FujiNet command
         rmb   1              ; Aux1
         rmb   1              ; Aux2
         fdb   txdata         ; pointer to transmit buffer
         rmb   2              ; length of data in bytes
         fdb   rxdata         ; pointer to receive buffer
         rmb   2              ; length of response buffer in bytes
         rmb   2              ; timeout in milliseconds
;
txdata   rmb   512
rxdata   rmb   512
;
         include  "aciaio.asm"
         include  "libfujierr.asm"
         include  "libfujinet.asm"
         include  "libfujicmd.asm"
;
         end