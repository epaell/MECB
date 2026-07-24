               cpu      68008
;
; Library compiled for use in upper part of on-board ROM
               org      $210000

vector_tbl:
;
; Library version
;
               jmp      get_libversion          ; return firmware libary version in d0
               jmp      print_libversion        ; print firmare libary version
;
; Fast Floating-Point library routines
;
               jmp      FFPABS                  ; d7=abs(d7)
               jmp      FFPNEG                  ; d7=neg(d7)
               jmp      FFPADD                  ; d7=add(d6,d7)
               jmp      FFPSUB                  ; d7=sub(d6,d7)
               jmp      FFPAFP                  ; d7=ASCII2float(a0)
               jmp      FFPATAN                 ; d7=atan(d7)
               jmp      FFPCMP                  ; cmp(d6,d7) i.e. d7-d6
               jmp      FFPTST                  ; tst(d7)
               jmp      FFPDBF                  ; d7=dual_binary2float(d6,d7)
               jmp      FFPDIV                  ; d7=div(d6,d7)
               jmp      FFPEXP                  ; d7=exp(d7)
               jmp      FFPFPA                  ; float2ASCII(d7)
               jmp      FFPFPI                  ; d7=float2int(d7)
               jmp      FFPIFP                  ; d7=int2float(d7)
               jmp      FFPLOG                  ; d7=log_e(d7)
               jmp      FFPMUL                  ; d7=mul(d6,d7)
               jmp      FFPPWR                  ; d7=power(d6,d7)
               jmp      FFPSIN                  ; d7=sin(d7)
               jmp      FFPCOS                  ; d7=cos(d7)
               jmp      FFPTAN                  ; d7=tan(d7)
               jmp      FFPSINCS                ; d6,d7=sincos(d7)
               jmp      FFPSINH                 ; d7=sinh(d7)
               jmp      FFPCOSH                 ; d7=cosh(d7)
               jmp      FFPTANH                 ; d7=tanh(d7)
               jmp      FFPSQRT                 ; d7=sqrt(d7)
;
; Misc routines
;
               jmp      random
               jmp      crc_buf
;
; Font definitions
;
               jmp      text_font_def        ; 5x8 font
;
; FLASH library routines
;
               jmp      flash_wbytes
               jmp      flash_chip_erase
               jmp      flash_erase
               jmp      flash_swid
;
; SD card library routines
;
               jmp      SDParInit           ; init parallel interface
               jmp      SDParSetWrite       ; set for writing
               jmp      SDParSetRead        ; set for reading
               jmp      SDParWriteByte      ; write one byte
               jmp      SDParReadByte       ; read one byte
               jmp      SDGetClock          ; set the real-time clock
               jmp      SDSetClock          ; get the real-time clock
               jmp      SDDiskPing          ; exercises the interface
               jmp      SDDiskOpenRead      ; open file for read
               jmp      SDDiskOpenWrite     ; open file for write
               jmp      SDDiskClose         ; close file
               jmp      SDDiskRead          ; read from file
               jmp      SDDiskWrite         ; write to file
               jmp      SDDiskDir           ; start directory query
               jmp      SDDiskDirNext       ; get next directory entry
               jmp      SDDiskReadSector    ; read a sector TODO
               jmp      SDDiskWriteSector   ; write a sector TODO
               jmp      SDDiskStatus        ; get status TODO
               jmp      SDDiskGetDrives     ; get the number of drives TODO
               jmp      SDDiskGetMounted    ; get the mounted drive TODO
               jmp      SDDiskNextMountedDrv ; Get the next mounted drive TODO
               jmp      SDDiskUnmount       ; Unmount the file system TODO
               jmp      SDDiskMount         ; Mount a file system TODO
;
; OLED-related library routines
;
               jmp      oled_init            ; Initialise OLED display
               jmp      oled_on              ; Turn on display
               jmp      oled_off             ; Turn off display
               jmp      oled_set_col         ; Set column range
               jmp      oled_set_row         ; Set row range
               jmp      oled_spixel          ; Set pixel
               jmp      oled_pixel           ; Draw pixel
               jmp      oled_sline           ; Draw line (using oled_spixel)
               jmp      oled_line            ; Draw line
               jmp      oled_fill            ; Fill rows
               jmp      oled_scircle         ; Set circle (using oled_spixel, TODO)
               jmp      oled_circle          ; Draw circle
               jmp      oled_schar           ; Write a character TODO
               jmp      oled_char            ; Write a character
               jmp      oled_sstr            ; Write a string TODO
               jmp      oled_str             ; Write a string
               jmp      oled_move            ; Move a screen worth of data to OLED display
;
; VDP Routines
;
; Low-level VDP functions
               jmp      vdp_vram_raddr
               jmp      vdp_vram_waddr
               jmp      vdp_write_reg
               jmp      vdp_read_stat
               jmp      vdp_read_nstat
               jmp      vdp_read_vram
               jmp      vdp_write_vram
               jmp      vdp_init_regs
               jmp      vdp_set_vram
               jmp      vdp_inc_vram
               jmp      vdp_xfr_vram
               jmp      vdp_clr_vram
               jmp      vdp_wait
;
; VDP graphics functions
;
               jmp      vdp_set_mode
               jmp      vdp_line
               jmp      vdp_circle           ; TODO
               jmp      vdp_pset
               jmp      vdp_point
;
; VDP text functions
;
               jmp      vdp_load_font
               jmp      vdp_text_mode
;
; low-level PSG functions
;
               jmp      psg_init             ; Initialise PIA1 for PSG use
               jmp      psg_stop             ; Stop all audio from PSG
               jmp      psg_volume           ; Set channel volume
               jmp      psg_tone             ; Set channel tone
;
; low-level serial function
;
               jmp      outch1               ; output a character in d0.b through ACIA1
               jmp      out2h                ; output 2 hex digits in d0.b
               jmp      out4h                ; output 4 hex digits in d0.w
               jmp      out6h                ; output 6 hex digits in d0.l (ignores most significant byte)
               jmp      out8h                ; output 8 hex digits in d0.l
               jmp      print                ; print text pointed to by a0.l through ACIA1
               jmp      pcrlf                ; print a CR and LF through ACIA1
               jmp      hex2dec2             ; convert hex value in d0.b to a decimal string with trailing zeros and store in buffer pointed to by a1.l
               jmp      chex2dec             ; convert hex value in d0.b to a signed decimal string and store in buffer pointed to by a1.l
               jmp      strcpy               ; copy a string pointed to by a0.l to the buffer in a1.l
               jmp      strncpy              ; copy a given number of bytes from soure to destination
               jmp      strcpynt             ; copy a string not including the EOT
;
; Fujinet routines
;
               jmp      fujinet_dcb_exec                 ; low-level fujinet command execution
               jmp      fujinet_mount_all                ; mount all devices
               jmp      fujinet_mount_host               ; mount host
               jmp      fujinet_reset                    ; reset fujinet device
               jmp      fujinet_read_host_slots          ; read host slots
               jmp      fujinet_read_device_slots        ; read device slots
               jmp      fujinet_random_number            ; get a random 32-bit number
               jmp      fujinet_get_time                 ; get the current time
               jmp      fujinet_open_directory           ; open a directory
               jmp      fujinet_read_dir_entry           ; read a directory entry
               jmp      fujinet_close_directory          ; close the directory
               jmp      fujinet_set_directory_position   ; set the current directory position
               jmp      fujinet_get_directory_position   ; get the current directory position
               jmp      fujinet_scan_for_networks        ; scan for Wi-Fi networks
               jmp      fujinet_get_scan_result          ; get the Wi-Fi scan result
               jmp      fujinet_get_ssid                 ; get the Wi-Fi SSID
               jmp      fujinet_get_wifi_status          ; get the Wi-Fi status
               jmp      fujinet_set_ssid                 ; set the Wi-Fi SSID
               jmp      fujinet_get_wifi_enabled         ; get the Wi-Fi enabled status
               jmp      fujinet_file_open                ; open a file
               jmp      fujinet_file_read                ; read from a file
               jmp      fujinet_file_status              ; get the file status
               jmp      fujinet_file_write               ; write to a file
               jmp      fujinet_file_close               ; close a file
               jmp      fujinet_mount_image              ; mount a disk image
               jmp      fujinet_disk_read                ; read a sector from the disk image
               jmp      fujinet_unmount_image            ; unmount a disk image
               jmp      fujinet_disk_get_sector_size     ; get the disk image sector size
               jmp      fujinet_disk_write               ; write a sector to the disk image
               jmp      fujinet_modem_read               ; read from a MODEM device
               jmp      fujinet_modem_status             ; get the MODEM device status
               jmp      fujinet_modem_stream             ; MOEDM device stream
               jmp      fujinet_modem_write              ; write to a MODEM device
               jmp      fujinet_network_open             ; open a network channel
               jmp      fujinet_network_read             ; read from a network channel
               jmp      fujinet_network_status           ; get the network channel read status
               jmp      fujinet_network_write            ; write to a network channel
               jmp      fujinet_network_close            ; close a network channel
               jmp      fujinet_network_channel_mode     ; get the network channel mode
               jmp      fujinet_network_json_parse       ; parse a json string
               jmp      fujinet_network_json_query       ; perform a json query
               jmp      fujinet_network_login            ; network login
               jmp      fujinet_printer_stream           ; stream to printer device
               jmp      fujinet_printer_write            ; write to printer device
               jmp      fujinet_open_appkey              ; open an appkey
               jmp      fujinet_write_appkey             ; write an appkey
               jmp      fujinet_read_appkey              ; read an appkey
               jmp      fujinet_close_appkey             ; close appkey
               jmp      fujinet_device_create_new        ; create a new device
               jmp      fujinet_device_disable_device    ; disable a device
               jmp      fujinet_device_enable_device     ; enable a device
               jmp      fujinet_device_get_adapter_config   ; get the adapter config
               jmp      fujinet_device_get_device_enabled_status  ; get device status
               jmp      fujinet_device_get_device_filename        ; get device filename
               jmp      fujinet_write_device_slots       ; write device slots
               jmp      fujinet_write_host_slots         ; write host slots
               jmp      fujinet_device_set_boot_config   ; set the boot config
               jmp      fujinet_device_set_device_filename  ; set device filename
               jmp      fujinet_logical_device_type      ; get logical device type
               jmp      fujinet_logical_device_unit      ; get logical device unit
               jmp      fujinet_logical_device_url       ; get logical device url
               jmp      fujinet_new_disk                 ; new disk
               jmp      fujinet_set_host_prefix          ; set host prefix
               jmp      fujinet_get_host_prefix          ; get host prefix
               jmp      fujinet_copy_file                ; copy a file
               jmp      fujinet_set_boot_mode            ; set boot mode
               jmp      fujinet_status                   ; get status
               jmp      fujinet_get_adapterconfig_extended  ; get extended adapter config
               jmp      fujinet_generate_guid            ; generate GUID
               jmp      fujinet_set_status               ; set status
               jmp      fujinet_unmount_host             ; unmount host
;
; CPM routines
;
               jmp      mv_cpm400bin                     ; move CPM0400 to location pointed to by a1.l
               jmp      mv_cpm15000bin                   ; move CPM15000 to location pointed to by a1.l
;
; Test routines
;
               jmp      FFPCALC              ; Fast floating point calculator
               jmp      xmas
               ; TODO
;
;
;
               include  "mecb.inc"
               include  "tutor.inc"
               include  "libfujinet.inc"
               align    2
               include  "libver.asm"
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
               include  "CPM400_v1.1.asm"
               include  "CPM400_v1.2.asm"
               include  "CPM400_v1.3.asm"
               include  "CPM15000_v1.1.asm"
               include  "CPM15000_v1.2.asm"
               include  "CPM15000_v1.3.asm"
;
               end
