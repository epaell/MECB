               cpu      68008
; Library compiled for use in lower part of the expansion ROM
               org      $100000
vector_tbl:
;
; Fast Floating-Point library routines
;
               bra      FFPABS                  ; d7=abs(d7)
               bra      FFPNEG                  ; d7=neg(d7)
               bra      FFPADD                  ; d7=add(d6,d7)
               bra      FFPSUB                  ; d7=sub(d6,d7)
               bra      FFPAFP                  ; d7=ASCII2float(a0)
               bra      FFPATAN                 ; d7=atan(d7)
               bra      FFPCMP                  ; cmp(d6,d7) i.e. d7-d6
               bra      FFPTST                  ; tst(d7)
               bra      FFPDBF                  ; d7=dual_binary2float(d6,d7)
               bra      FFPDIV                  ; d7=div(d6,d7)
               bra      FFPEXP                  ; d7=exp(d7)
               bra      FFPFPA                  ; float2ASCII(d7)
               bra      FFPFPI                  ; d7=float2int(d7)
               bra      FFPIFP                  ; d7=int2float(d7)
               bra      FFPLOG                  ; d7=log_e(d7)
               bra      FFPMUL                  ; d7=mul(d6,d7)
               bra      FFPPWR                  ; d7=power(d6,d7)
               bra      FFPSIN                  ; d7=sin(d7)
               bra      FFPCOS                  ; d7=cos(d7)
               bra      FFPTAN                  ; d7=tan(d7)
               bra      FFPSINCS                ; d6,d7=sincos(d7)
               bra      FFPSINH                 ; d7=sinh(d7)
               bra      FFPCOSH                 ; d7=cosh(d7)
               bra      FFPTANH                 ; d7=tanh(d7)
               bra      FFPSQRT                 ; d7=sqrt(d7)
;
; Misc routines
;
               org      $100080
;
               bra      random
               bra      crc_buf
;
; Font definitions
;
               org      $100100
;
               bra      text_font_def        ; 5x8 font
;
; FLASH library routines
;
               org      $100180
;
               bra      flash_wbytes
               bra      flash_chip_erase
               bra      flash_erase
               bra      flash_swid
;
; SD card library routines
;
               org      $100200
;
               bra      SDParInit           ; init parallel interface
               bra      SDParSetWrite       ; set for writing
               bra      SDParSetRead        ; set for reading
               bra      SDParWriteByte      ; write one byte
               bra      SDParReadByte       ; read one byte
               bra      SDGetClock          ; set the real-time clock
               bra      SDSetClock          ; get the real-time clock
               bra      SDDiskPing          ; exercises the interface
               bra      SDDiskOpenRead      ; open file for read
               bra      SDDiskOpenWrite     ; open file for write
               bra      SDDiskClose         ; close file
               bra      SDDiskRead          ; read from file
               bra      SDDiskWrite         ; write to file
               bra      SDDiskDir           ; start directory query
               bra      SDDiskDirNext       ; get next directory entry
               bra      SDDiskReadSector    ; read a sector TODO
               bra      SDDiskWriteSector   ; write a sector TODO
               bra      SDDiskStatus        ; get status TODO
               bra      SDDiskGetDrives     ; get the number of drives TODO
               bra      SDDiskGetMounted    ; get the mounted drive TODO
               bra      SDDiskNextMountedDrv ; Get the next mounted drive TODO
               bra      SDDiskUnmount       ; Unmount the file system TODO
               bra      SDDiskMount         ; Mount a file system TODO
;
; OLED-related library routines
;
               org      $100280
;
               bra      oled_init            ; Initialise OLED display
               bra      oled_on              ; Turn on display
               bra      oled_off             ; Turn off display
               bra      oled_set_col         ; Set column range
               bra      oled_set_row         ; Set row range
               bra      oled_spixel          ; Set pixel
               bra      oled_pixel           ; Draw pixel
               bra      oled_sline           ; Draw line (using oled_spixel)
               bra      oled_line            ; Draw line
               bra      oled_fill            ; Fill rows
               bra      oled_scircle         ; Set circle (using oled_spixel, TODO)
               bra      oled_circle          ; Draw circle
               bra      oled_schar           ; Write a character TODO
               bra      oled_char            ; Write a character
               bra      oled_sstr            ; Write a string TODO
               bra      oled_str             ; Write a string
;
; VDP Routines
;
               org      $100300
;
; Low-level VDP functions
;
               bra      vdp_vram_raddr
               bra      vdp_vram_waddr
               bra      vdp_write_reg
               bra      vdp_read_stat
               bra      vdp_read_nstat
               bra      vdp_read_vram
               bra      vdp_write_vram
               bra      vdp_init_regs
               bra      vdp_set_vram
               bra      vdp_inc_vram
               bra      vdp_xfr_vram
               bra      vdp_clr_vram
               bra      vdp_wait
;
; VDP graphics functions
;
               bra      vdp_set_mode
               bra      vdp_line
               bra      vdp_circle           ; TODO
               bra      vdp_pset
               bra      vdp_point
;
; VDP text functions
               bra      vdp_load_font
               bra      vdp_text_mode
;
               org      $100380
;
; low-level PSG functions
;
               bra      psg_init             ; Initialise PIA1 for PSG use
               bra      psg_stop             ; Stop all audio from PSG
               bra      psg_volume           ; Set channel volume
               bra      psg_tone             ; Set channel tone
;
               org      $1003A0
;
; low-level serial function
;
               bra      outch1               ; output a character in d0.b through ACIA1
               bra      out2h                ; output 2 hex digits in d0.b
               bra      out4h                ; output 4 hex digits in d0.w
               bra      out8h                ; output 8 hex digits in d0.l
               bra      print                ; print text pointed to by a0.l through ACIA1
               bra      pcrlf                ; print a CR and LF through ACIA1
               bra      hex2dec2             ; convert hex value in d0.b to a decimal string with trailing zeros and store in buffer pointed to by a1.l
               bra      chex2dec             ; convert hex value in d0.b to a signed decimal string and store in buffer pointed to by a1.l
               bra      strcpy               ; copy a string pointed to by a0.l to the buffer in a1.l
               bra      strcpynt             ; copy a string not including the EOT
;
               org      $1003D0
;
; Fujinet routines
;
               bra      fujinet_dcb_exec                 ; low-level fujinet command execution
               bra      fujinet_mount_all                ; mount all devices
               bra      fujinet_mount_host               ; mount host
               bra      fujinet_reset                    ; reset fujinet device
               bra      fujinet_read_host_slots          ; read host slots
               bra      fujinet_read_device_slots        ; read device slots
               bra      fujinet_random_number            ; get a random 32-bit number
               bra      fujinet_get_time                 ; get the current time
               bra      fujinet_open_directory           ; open a directory
               bra      fujinet_read_dir_entry           ; read a directory entry
               bra      fujinet_close_directory          ; close the directory
               bra      fujinet_set_directory_position   ; set the current directory position
               bra      fujinet_get_directory_position   ; get the current directory position
               bra      fujinet_scan_for_networks        ; scan for Wi-Fi networks
               bra      fujinet_get_scan_result          ; get the Wi-Fi scan result
               bra      fujinet_get_ssid                 ; get the Wi-Fi SSID
               bra      fujinet_get_wifi_status          ; get the Wi-Fi status
               bra      fujinet_set_ssid                 ; set the Wi-Fi SSID
               bra      fujinet_get_wifi_enabled         ; get the Wi-Fi enabled status
               bra      fujinet_file_open                ; open a file
               bra      fujinet_file_read                ; read from a file
               bra      fujinet_file_status              ; get the file status
               bra      fujinet_file_write               ; write to a file
               bra      fujinet_file_close               ; close a file
               bra      fujinet_mount_image              ; mount a disk image
               bra      fujinet_disk_read                ; read a sector from the disk image
               bra      fujinet_unmount_image            ; unmount a disk image
               bra      fujinet_disk_get_sector_size     ; get the disk image sector size
               bra      fujinet_disk_write               ; write a sector to the disk image
               bra      fujinet_modem_read               ; read from a MODEM device
               bra      fujinet_modem_status             ; get the MODEM device status
               bra      fujinet_modem_stream             ; MOEDM device stream
               bra      fujinet_modem_write              ; write to a MODEM device
               bra      fujinet_network_open             ; open a network channel
               bra      fujinet_network_read             ; read from a network channel
               bra      fujinet_network_status           ; get the network channel read status
               bra      fujinet_network_write            ; write to a network channel
               bra      fujinet_network_close            ; close a network channel
               bra      fujinet_network_channel_mode     ; get the network channel mode
               bra      fujinet_network_json_parse       ; parse a json string
               bra      fujinet_network_json_query       ; perform a json query
               bra      fujinet_network_login            ; network login
               bra      fujinet_printer_stream           ; stream to printer device
               bra      fujinet_printer_write            ; write to printer device
               bra      fujinet_open_appkey              ; open an appkey
               bra      fujinet_write_appkey             ; write an appkey
               bra      fujinet_read_appkey              ; read an appkey
               bra      fujinet_close_appkey             ; close appkey
               bra      fujinet_device_create_new        ; create a new device
               bra      fujinet_device_disable_device    ; disable a device
               bra      fujinet_device_enable_device     ; enable a device
               bra      fujinet_device_get_adapter_config   ; get the adapter config
               bra      fujinet_device_get_device_enabled_status  ; get device status
               bra      fujinet_device_get_device_filename        ; get device filename
               bra      fujinet_write_device_slots       ; write device slots
               bra      fujinet_write_host_slots         ; write host slots
               bra      fujinet_device_set_boot_config   ; set the boot config
               bra      fujinet_device_set_device_filename  ; set device filename
               bra      fujinet_logical_device_type      ; get logical device type
               bra      fujinet_logical_device_unit      ; get logical device unit
               bra      fujinet_logical_device_url       ; get logical device url
               bra      fujinet_new_disk                 ; new disk
               bra      fujinet_set_host_prefix          ; set host prefix
               bra      fujinet_get_host_prefix          ; get host prefix
               bra      fujinet_copy_file                ; copy a file
               bra      fujinet_set_boot_mode            ; set boot mode
               bra      fujinet_status                   ; get status
               bra      fujinet_get_adapterconfig_extended  ; get extended adapter config
               bra      fujinet_generate_guid            ; generate GUID
               bra      fujinet_set_status               ; set status
               bra      fujinet_unmount_host             ; unmount host
;
               org      $100500
;
; CPM routines
;
               bra      mv_cpm400                        ; move CPM0400 to location pointed to by a1.l
               bra      mv_cpm15000                      ; move CPM15000 to location pointed to by a1.l
;
;
; Test routines
;
               org      $100600
;
               bra      FFPCALC              ; Fast floating point calculator
               bra      xmas
               ; TODO
;
;
;
               include  "mecb.inc"
               include  "tutor.inc"
               include  "libfujinet.inc"
               align    2
               include  "math.asm"
               align    2
               include  "random.asm"
               align    2
               include  "crc32.asm"
               align    2
               include  "text_font.asm"
               align    2
               include  "flash.asm"
               align    2
               include  "sdcard.asm"
               align    2
               include  "oled.asm"
               align    2
               include  "vdp.asm"
               align    2
               include  "vdp_gfx.asm"
               align    2
               include  "vdp_text.asm"
               align    2
               include  "psg.asm"
               align    2
               include  "FFPCALC.X68"
               align    2
               include  "IOMECB.X68"
               align    2
               include  "aciaio.asm"
               align    2
               include  "libfujinet.asm"
               align    2
               include  "libfujicmd.asm"
               align    2
               include  "loadcpm.asm"
               align    2
               include  "xmas.asm"
               align    2
               include  "CPM400.asm"
               align    2
               include  "CPM15000.asm"
;
               end
