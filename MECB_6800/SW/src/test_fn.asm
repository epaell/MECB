; Test suite for libfujinet
;
; Known issues:
;
; fujinet_reset - WiFi stops working after calling, requires hardware reset on ESP32 to re-initiate.
; fujinet_get_scan_result - firmare returns one less byte than it should (changed to fix).
; fujinet_scan_for_networks - ESP32 log reports different number of networks compared to what is returned.
;
; In firmware : mediaTypeIMG.cpp, "_media_last_sector = INVALID_SECTOR_VALUE;" on line 206 prevents write to sector 0
; disk_write results in Error: FUJINET_RC_NO_ACK

;
;
         include  "mecb.inc"
         include  "libfujinet.inc"
         include  "DigiBug.inc"
         include  "aciaio.inc"
;
STKTOP   equ   $007F          ; System Stack Top
DEBUG    equ   0
;
         org   USERPROG_ORG

main:
         lds   #STKTOP        ; Set Stack to Stack Top
         ldx   #ststart
         jsr   print
;
         jsr   set_buff       ; Reset the buffers
         jsr   fujinet_init   ; Initialise the fujinet device
;
         jsr   config_tests   ; Check configuration of hosts and devices
;         jsr   wifi_tests     ; Check WiFi commands
;         jsr   dir_tests      ; Check directory access
;         jsr   file_tests      ; Check file access
         jsr   image_tests    ; Check image access
;         jsr   network_tests
exit     jmp   CONTRL          ; return to monitor

;
error    jsr   fn_perror      ; Print the error string
         jsr   fujinet_init
         jmp   CONTRL          ; return to monitor
;
set_buff:
         ldx   #fujinet_dcb   ; Initialise the receive and transmit buffer in the DCB
         lda   #rxdata>>8
         sta   DCB_RX_BUFFER,x
         lda   #rxdata&$FF
         sta   DCB_RX_BUFFER+1,x
         lda   #txdata>>8
         sta   DCB_TX_BUFFER,x
         lda   #txdata&$FF
         sta   DCB_TX_BUFFER+1,x
         rts
;
ststart:    fcb CR,LF,'FujiNet module tests',CR,LF,EOT
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
         include  "libfujicmdbase.asm"
         include  "libfujicmddisk.asm"
;
         include "test_fn_config.asm"
;         include "test_fn_wifi.asm"
;         include "test_fn_dir.asm"
;         include "test_fn_file.asm"
         include "test_fn_image.asm"
;         include "test_fn_network.asm"
;
         end