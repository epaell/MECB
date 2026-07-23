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
         include  "tutor.inc"
         include  "libfujinet.inc"
;
         org      USERPROG_ORG
;
main:
         move.l   #RAM_END+1,a7           ; Set up stack
         move.l   #ststart,a0
         bsr      print
;
         move.l   #fujinet_dcb,a0         ; Initialise the receive and transmit buffer in the DCB
         move.l   #rxdata,DCB_RX_BUFFER(a0)
         move.l   #txdata,DCB_TX_BUFFER(a0)
;
;         bsr      fujinet_init            ; Initialise the fujinet device
;
         bsr      config_tests            ; Check configuration of hosts and devices
;         bsr      wifi_tests              ; Check WiFi commands
;         bsr      dir_tests               ; Check directory access
;         bsr      file_tests              ; Check file access
         bsr      image_tests             ; Check image access
;         bsr      net_tests               ; Check network access
exit     move.b   #TUTOR,d7
         trap     #14

         include "test_fn_config.asm"
;         include "test_fn_wifi.asm"
;         include "test_fn_dir.asm"
;         include "test_fn_file.asm"
         include "test_fn_image.asm"
;         include "test_fn_net.asm"
;
error       bsr    fn_perror      ; Print the error string
            move.b #TUTOR,d7
            trap   #14
;
;
ststart:    dc.b   CR,LF
            dc.b   'FujiNet module tests'
            dc.b   CR,LF,EOT
stnewline:  dc.b   CR,LF,EOT
;
tbuffer     ds.b   64             ; Text buffer for output
blank       dc.b   '                                                               '
            dc.b   0
;
            align 4
;
txdata      ds.b   512
rxdata      ds.b   512
;
fujinet_dcb:
            ds.b   4
            ds.b   4
            ds.b   4
            ds.b   2              ; length of data in bytes
            ds.b   2              ; length of response buffer in bytes
            ds.b   2              ; timeout in milliseconds
;
            align 4
;
            include  "aciaio.asm"
            include  "libfujierr.asm"
            include  "libfujinet.asm"
            include  "libfujicmd.asm"
;
            end