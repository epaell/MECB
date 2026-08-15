         cpu   8086
; Test suite for libfujinet
;
; Known issues:
;
; FNRESET - WiFi stops working after calling, requires hardware reset on ESP32 to re-initiate.
; fujinet_get_scan_result - firmare returns one less byte than it should (changed firmware to fix).
; fujinet_scan_for_networks - ESP32 log reports different number of networks compared to what is returned.
; fujinet_network_open - only seems to work for device 0
;
; In firmware : mediaTypeIMG.cpp, "_media_last_sector = INVALID_SECTOR_VALUE;" on line 206 prevents write to sector 0
; disk_write results in Error: FUJINET_RC_NO_ACK

;
;
%include 'src/mecb.inc'
%include 'src/libfujinet.inc'
;
; int 09h: return control to monitor
;
%macro monitor 0
            call  flush
            int   09h
%endmacro
;
         org      USERPROG_ORG
;
section     .text
;
main:
         cli
         cld
         mov   ax,ds
         mov   cs:[saveds],ax
         mov   ax,cs
         mov   ds,ax                ; Set up data segment
         mov   ax,es
         mov   cs:[savees],ax
         mov   ax,cs
         mov   es,ax
;
         mov   si, ststart                ; Print string to signal start
         call  print
;
         mov   si,fujinet_dcb
         mov   ax,ds
         mov   ds:[si+DCB_RX_BUFFERSEG],ax
         mov   ax,rxdata
         mov   ds:[si+DCB_RX_BUFFER],ax
         mov   ax,ds
         mov   ds:[si+DCB_TX_BUFFERSEG],ax
         mov   ax,txdata
         mov   ds:[si+DCB_TX_BUFFER],ax
;
;        call   fujinet_init            ; Initialise the fujinet device
;
         call   config_tests           ; Check configuration of hosts and devices
;         call   wifi_tests             ; Check WiFi commands
;         call   dir_tests              ; Check directory access
;         call   file_tests             ; Check file access
;         call   image_tests            ; Check image access
;         call   net_tests              ; Check network access
;         call   printer_tests          ; Check printer access

exit     mov   ax,[cs:savees]          ; return to monitor
         mov   es,ax
         mov   ax,[ds:saveds]
         mov   ds,ax
         monitor
;
error    call  fn_perror            ; Print the error string
         jmp   exit

%include 'src/libfujinet.asm'
%include 'src/libfujicmd.asm'
%include 'src/test_fn_config.asm'
;%include 'src/test_fn_wifi.asm'
;%include 'src/test_fn_dir.asm'
;%include 'src/test_fn_file.asm'
%include 'src/test_fn_image.asm'
;%include 'src/test_fn_net.asm'
;%include 'src/test_fn_printer.asm'
;
%include 'src/libfujierr.asm'
%include 'src/acia_io.asm'
;
section .data
;
ststart: db    CR,LF
         db    'FujiNet module tests'
         db    CR,LF,EOT
stnewline:
         db    CR,LF,EOT
;
blank:   db    '                                                               ',EOT
;
section  .bss
;
saveds:  resw  1                       ; space to save segment registers
savees:  resw  1
;
txdata:  resb  512                     ; transmit buffer
rxdata:  resb  512                     ; receive buffer
;
tbuffer: resb  64                      ; Text buffer for output
;
fujinet_dcb:
         resb  4
         resb  4
         resb  4
         resb  2                       ; length of data in bytes
         resb  2                       ; length of response buffer in bytes
         resb  2                       ; timeout in milliseconds
;
