               cpu      68008
;
               include  "mecb.inc"
               include  "tutor.inc"
               include  "libfujinet.inc"
;
TRUNDEF        equ      $0                   ; Undefined TRAP #8 handler
;
; Library compiled for use in upper part of on-board ROM
;
               org      $210000
;
               dc.b     'TRAP'               ; Magic number to indicate that there is a TRAP handler immediately following
;
install:       move.l   #trap8,a0            ; Install the trap handler
               move.l   a0,VEC_TRAP8
               rts

;
; trap 8 handler for library functions
; On entry:
;     d5.w = library function to call
; On exit:
;     d5 changed
;
trap8:
               move.l   d5,-(a7)             ; save d5
               cmp.w    #((trapend-trapbase)>>2),d5
               bcc      traperr              ; exit if function is outside of those available
               lsl.w    #2,d5                ; convert to offset
               move.l   a0,-(a7)
               move.l   trapbase(pc,d5.w),a0 ; get the function address
               cmp.l    #0,a0                ; check if it is available
               beq      traperr              ; if not, return
               move.l   #trapret,-(a7)       ; where to return to after trap function called
               move.l   a0,-(a7)             ; trap function address
               move.l   8(a7),a0             ; restore a0 before call
               rts                           ; this "returns" to the function call
trapret:       add.l    #8,a7                ; restore stack
               move.w   sr,(a7)              ; update the SR
trapexit:      rte                           ; return
;
; handler for undefined function
traperr:
               move.l   (a7),d5              ; restore the function number
               move.l   a0,(a7)              ; save a0 in its place
               move.l   d0,-(a7)             ; save d0
               move.l   #st_trap_error,a0    ; print the error message
               jsr      print
               move.l   d5,d0
               jsr      out4h                ; write the erroneous function code
               jsr      pcrlf
               move.l   (a7)+,d0             ; restore d0
               move.l   (a7)+,a0             ; restore a0
               rte                           ; return
;
trapbase:
               dc.l     GETLVER     ; F#0000 return firmware libary version in d0.l
               dc.l     OUTLVER     ; F#0001 print firmare libary version
;
; Fast Floating-Point library routines (D3-D6 may be destroyed)
;
               dc.l     FFPABS      ; F#0002 d7=abs(d7)
               dc.l     FFPNEG      ; F#0003 d7=neg(d7)
               dc.l     FFPADD      ; F#0004 d7=add(d6,d7)
               dc.l     FFPSUB      ; F#0005 d7=sub(d6,d7)
               dc.l     FFPAFP      ; F#0006 d7=ASCII2float(a0)
               dc.l     FFPATAN     ; F#0007 d7=atan(d7)
               dc.l     FFPCMP      ; F#0008 cmp(d6,d7) i.e. d7-d6
               dc.l     FFPTST      ; F#0009 tst(d7)
               dc.l     FFPDBF      ; F#000A d7=dual_binary2float(d6,d7)
               dc.l     FFPDIV      ; F#000B d7=div(d6,d7)
               dc.l     FFPEXP      ; F#000C d7=exp(d7)
               dc.l     FFPFPA      ; F#000D float2ASCII(d7)
               dc.l     FFPFPI      ; F#000E d7=float2int(d7)
               dc.l     FFPIFP      ; F#000F d7=int2float(d7)
               dc.l     FFPLOG      ; F#0010 d7=log_e(d7)
               dc.l     FFPMUL      ; F#0011 d7=mul(d6,d7)
               dc.l     FFPPWR      ; F#0012 d7=power(d6,d7)
               dc.l     FFPSIN      ; F#0013 d7=sin(d7)
               dc.l     FFPCOS      ; F#0014 d7=cos(d7)
               dc.l     FFPTAN      ; F#0015 d7=tan(d7)
               dc.l     FFPSINCS    ; F#0016 d6,d7=sincos(d7)
               dc.l     FFPSINH     ; F#0017 d7=sinh(d7)
               dc.l     FFPCOSH     ; F#0018 d7=cosh(d7)
               dc.l     FFPTANH     ; F#0019 d7=tanh(d7)
               dc.l     FFPSQRT     ; F#001A d7=sqrt(d7)
               dc.l     FFPOUT      ; F#001B output the floating point value in d7
               dc.l     TRUNDEF     ; F#001C undefined
               dc.l     TRUNDEF     ; F#001D undefined
               dc.l     TRUNDEF     ; F#001E undefined
               dc.l     TRUNDEF     ; F#001F undefined
;
; low-level serial functions
;
               dc.l     outch1      ; F#0020 output a character in d0.b through ACIA1
               dc.l     out2h       ; F#0021 output 2 hex digits in d0.b
               dc.l     out4h       ; F#0022 output 4 hex digits in d0.w
               dc.l     out6h       ; F#0023 output 6 hex digits in d0.l (ignores most significant byte)
               dc.l     out8h       ; F#0024 output 8 hex digits in d0.l
               dc.l     outdec      ; F#0025 output binary value in d0.l as decimal string
               dc.l     print       ; F#0026 print EOT-terminated text pointed to by a0.l through ACIA1
               dc.l     pcrlf       ; F#0027 print a CR and LF through ACIA1
               dc.l     shex2dec    ; F#0028 convert hex value in d0.l to a decimal string into buffer pointed to by a1.l
               dc.l     strcpy      ; F#0029 copy a string pointed to by a0.l to the buffer in a1.l
               dc.l     strncpy     ; F#002A copy a given number of bytes from soure to destination
               dc.l     strcpynt    ; F#002B copy a string not including the EOT
               dc.l     hex2dec2    ; F#002C convert hex value in d0.b to a decimal string with trailing zeros and store in buffer pointed to by a1.l
               dc.l     chex2dec    ; F#002D convert hex value in d0.b to a signed decimal string and store in buffer pointed to by a1.l
               dc.l     strlen      ; F#002E return length of string (d0.l) pointed to by a0.l
               dc.l     TRUNDEF     ; F#002F undefined
;
;
; Fujinet routines
;
               dc.l     fujinet_dcb_exec                 ; F#0030 low-level fujinet command execution
               dc.l     fujinet_mount_all                ; F#0031 mount all devices
               dc.l     fujinet_mount_host               ; F#0032 mount host
               dc.l     fujinet_reset                    ; F#0033 reset fujinet device
               dc.l     fujinet_read_host_slots          ; F#0034 read host slots
               dc.l     fujinet_read_device_slots        ; F#0035 read device slots
               dc.l     fujinet_random_number            ; F#0036 get a random 32-bit number
               dc.l     fujinet_get_time                 ; F#0037 get the current time
               dc.l     fujinet_open_directory           ; F#0038 open a directory
               dc.l     fujinet_read_dir_entry           ; F#0039 read a directory entry
               dc.l     fujinet_close_directory          ; F#003A close the directory
               dc.l     fujinet_set_directory_position   ; F#003B set the current directory position
               dc.l     fujinet_get_directory_position   ; F#003C get the current directory position
               dc.l     fujinet_scan_for_networks        ; F#003D scan for Wi-Fi networks
               dc.l     fujinet_get_scan_result          ; F#003E get the Wi-Fi scan result
               dc.l     fujinet_get_ssid                 ; F#003F get the Wi-Fi SSID
               dc.l     fujinet_get_wifi_status          ; F#0040 get the Wi-Fi status
               dc.l     fujinet_set_ssid                 ; F#0041 set the Wi-Fi SSID
               dc.l     fujinet_get_wifi_enabled         ; F#0042 get the Wi-Fi enabled status
               dc.l     fujinet_file_open                ; F#0043 open a file
               dc.l     fujinet_file_read                ; F#0044 read from a file
               dc.l     fujinet_file_status              ; F#0045 get the file status
               dc.l     fujinet_file_write               ; F#0046 write to a file
               dc.l     fujinet_file_close               ; F#0047 close a file
               dc.l     fujinet_mount_image              ; F#0048 mount a disk image
               dc.l     fujinet_disk_read                ; F#0049 read a sector from the disk image
               dc.l     fujinet_unmount_image            ; F#004A unmount a disk image
               dc.l     TRUNDEF                          ; F#004B undefined (was fujinet_get_sector_size - FNGETSC)
               dc.l     fujinet_disk_write               ; F#004C write a sector to the disk image
               dc.l     fujinet_modem_read               ; F#004D read from a MODEM device
               dc.l     fujinet_modem_status             ; F#004E get the MODEM device status
               dc.l     fujinet_modem_stream             ; F#004F MODEM device stream
               dc.l     fujinet_modem_write              ; F#0050 write to a MODEM device
               dc.l     fujinet_network_open             ; F#0051 open a network channel
               dc.l     fujinet_network_read             ; F#0052 read from a network channel
               dc.l     fujinet_network_status           ; F#0053 get the network channel read status
               dc.l     fujinet_network_write            ; F#0054 write to a network channel
               dc.l     fujinet_network_close            ; F#0055 close a network channel
               dc.l     fujinet_network_channel_mode     ; F#0056 get the network channel mode
               dc.l     fujinet_network_json_parse       ; F#0057 parse a json string
               dc.l     fujinet_network_json_query       ; F#0058 perform a json query
               dc.l     fujinet_network_login            ; F#0059 network login
               dc.l     fujinet_printer_stream           ; F#005A stream to printer device
               dc.l     fujinet_printer_write            ; F#005B write to printer device
               dc.l     fujinet_open_appkey              ; F#005C open an appkey
               dc.l     fujinet_write_appkey             ; F#005D write an appkey
               dc.l     fujinet_read_appkey              ; F#005E read an appkey
               dc.l     fujinet_close_appkey             ; F#005F close appkey
               dc.l     fujinet_device_create_new        ; F#0060 create a new device
               dc.l     fujinet_disable_device           ; F#0061 disable a device
               dc.l     fujinet_enable_device            ; F#0062 enable a device
               dc.l     fujinet_get_adapter_config       ; F#0063 get the adapter config
               dc.l     fujinet_get_device_enabled_status  ; F#0064 get device status
               dc.l     fujinet_get_device_fullpath      ; F#0065 get device full path
               dc.l     fujinet_write_device_slots       ; F#0066 write device slots
               dc.l     fujinet_write_host_slots         ; F#0067 write host slots
               dc.l     fujinet_set_boot_config          ; F#0068 set the boot config
               dc.l     fujinet_set_device_fullpath      ; F#0069 set device full path
               dc.l     fujinet_logical_device_type      ; F#006A get logical device type
               dc.l     fujinet_logical_device_unit      ; F#006B get logical device unit
               dc.l     fujinet_logical_device_url       ; F#006C get logical device url
               dc.l     fujinet_new_disk                 ; F#006D new disk
               dc.l     fujinet_set_host_prefix          ; F#006E set host prefix
               dc.l     fujinet_get_host_prefix          ; F#006F get host prefix
               dc.l     fujinet_copy_file                ; F#0070 copy a file
               dc.l     fujinet_set_boot_mode            ; F#0071 set boot mode
               dc.l     fujinet_status                   ; F#0072 get status
               dc.l     fujinet_get_adapterconfig_extended  ; F#0073 get extended adapter config
               dc.l     fujinet_generate_guid            ; F#0074 generate GUID
               dc.l     fujinet_set_status               ; F#0075 set status
               dc.l     fujinet_unmount_host             ; F#0076 unmount host
               dc.l     TRUNDEF                          ; F#0077 undefined
               dc.l     TRUNDEF                          ; F#0078 undefined
               dc.l     TRUNDEF                          ; F#0079 undefined
               dc.l     TRUNDEF                          ; F#007A undefined
               dc.l     TRUNDEF                          ; F#007B undefined
               dc.l     TRUNDEF                          ; F#007C undefined
               dc.l     TRUNDEF                          ; F#007D undefined
               dc.l     TRUNDEF                          ; F#007E undefined
               dc.l     TRUNDEF                          ; F#007F undefined

;
; Misc routines
;
               dc.l     random                           ; F#0080 d0.l = random number(seed=a0.l)
               dc.l     crc_buf                          ; F#0081 d0.l = crc(str=a0.l, len=d0.l)
;
; FLASH library routines
;
               dc.l     flash_wbytes            ; F#0082 flash_wbytes(d0.l=rombase,d2=nbytes,a0.l=dest,a1.l=src)
               dc.l     flash_chip_erase        ; F#0083 flash_chip_erase(d0=rombase,a1.l=sector addr)
               dc.l     flash_erase             ; F#0084 flash_erase(d0=rombase,a1.l=sector addr)
               dc.l     flash_swid              ; F#0085 flash_swid(d0=rombase,d1.l=mfr,a0.l=devattr)
;
; Font definitions
;
               dc.l     text_font_def           ; F#0086 a0 points to 5x8 font
               dc.l     TRUNDEF                 ; F#0087 undefined
               dc.l     TRUNDEF                 ; F#0088 undefined
               dc.l     TRUNDEF                 ; F#0089 undefined
               dc.l     TRUNDEF                 ; F#008A undefined
               dc.l     TRUNDEF                 ; F#008B undefined
               dc.l     TRUNDEF                 ; F#008C undefined
               dc.l     TRUNDEF                 ; F#008D undefined
               dc.l     TRUNDEF                 ; F#008E undefined
               dc.l     TRUNDEF                 ; F#008F undefined
;
; OLED-related library routines
;
               dc.l     oled_init            ; F#0090 Initialise OLED display
               dc.l     oled_on              ; F#0091 Turn on display
               dc.l     oled_off             ; F#0092 Turn off display
               dc.l     oled_set_col         ; F#0093 Set column range
               dc.l     oled_set_row         ; F#0094 Set row range
               dc.l     oled_spixel          ; F#0095 Set pixel
               dc.l     oled_pixel           ; F#0096 Draw pixel
               dc.l     oled_sline           ; F#0097 Draw line (using oled_spixel)
               dc.l     oled_line            ; F#0098 Draw line
               dc.l     oled_fill            ; F#0099 Fill rows
               dc.l     oled_scircle         ; F#009A Set circle (using oled_spixel, TODO)
               dc.l     oled_circle          ; F#009B Draw circle
               dc.l     oled_schar           ; F#009C Write a character TODO
               dc.l     oled_char            ; F#009D Write a character
               dc.l     oled_sstr            ; F#009E Write a string TODO
               dc.l     oled_str             ; F#009F Write a string
               dc.l     oled_move            ; F#00A0 Move a screen worth of data to OLED display
               dc.l     TRUNDEF              ; F#00A1
               dc.l     TRUNDEF              ; F#00A2
               dc.l     TRUNDEF              ; F#00A3
               dc.l     TRUNDEF              ; F#00A4
               dc.l     TRUNDEF              ; F#00A5
               dc.l     TRUNDEF              ; F#00A6
               dc.l     TRUNDEF              ; F#00A7
               dc.l     TRUNDEF              ; F#00A8
               dc.l     TRUNDEF              ; F#00A9
               dc.l     TRUNDEF              ; F#00AA
               dc.l     TRUNDEF              ; F#00AB
               dc.l     TRUNDEF              ; F#00AC
               dc.l     TRUNDEF              ; F#00AD
               dc.l     TRUNDEF              ; F#00AE
               dc.l     TRUNDEF              ; F#00AF
;
; VDP Routines
;
; Low-level VDP functions
               dc.l     vdp_vram_raddr       ; F#00B0
               dc.l     vdp_vram_waddr       ; F#00B1
               dc.l     vdp_write_reg        ; F#00B2
               dc.l     vdp_read_stat        ; F#00B3
               dc.l     vdp_read_nstat       ; F#00B4
               dc.l     vdp_read_vram        ; F#00B5
               dc.l     vdp_write_vram       ; F#00B6
               dc.l     vdp_init_regs        ; F#00B7
               dc.l     vdp_set_vram         ; F#00B8
               dc.l     vdp_inc_vram         ; F#00B9
               dc.l     vdp_xfr_vram         ; F#00BA
               dc.l     vdp_clr_vram         ; F#00BB
               dc.l     vdp_wait             ; F#00BC
               dc.l     TRUNDEF              ; F#00BD
               dc.l     TRUNDEF              ; F#00BE
               dc.l     TRUNDEF              ; F#00BF
;
; VDP graphics functions
;
               dc.l     vdp_set_mode         ; F#00C0
               dc.l     vdp_line             ; F#00C1
               dc.l     vdp_circle           ; F#00C2   TODO
               dc.l     vdp_pset             ; F#00C3
               dc.l     vdp_point            ; F#00C4
;
; VDP text functions
;
               dc.l     vdp_load_font        ; F#00C5
               dc.l     vdp_text_mode        ; F#00C6
               dc.l     TRUNDEF              ; F#00C7
               dc.l     TRUNDEF              ; F#00C8
               dc.l     TRUNDEF              ; F#00C9
               dc.l     TRUNDEF              ; F#00CA
               dc.l     TRUNDEF              ; F#00CB
               dc.l     TRUNDEF              ; F#00CC
               dc.l     TRUNDEF              ; F#00CD
               dc.l     TRUNDEF              ; F#00CE
               dc.l     TRUNDEF              ; F#00CF
;
; low-level PSG functions
;
               dc.l     psg_init             ; F#00D0 Initialise PIA1 for PSG use
               dc.l     psg_stop             ; F#00D1 Stop all audio from PSG
               dc.l     psg_volume           ; F#00D2 Set channel volume
               dc.l     psg_tone             ; F#00D3 Set channel tone
               dc.l     TRUNDEF              ; F#00D4
               dc.l     TRUNDEF              ; F#00D5
               dc.l     TRUNDEF              ; F#00D6
               dc.l     TRUNDEF              ; F#00D7
               dc.l     TRUNDEF              ; F#00D8
               dc.l     TRUNDEF              ; F#00D9
               dc.l     TRUNDEF              ; F#00DA
               dc.l     TRUNDEF              ; F#00DB
               dc.l     TRUNDEF              ; F#00DC
               dc.l     TRUNDEF              ; F#00DD
               dc.l     TRUNDEF              ; F#00DE
               dc.l     TRUNDEF              ; F#00DF
;
; SD card library routines
;
               dc.l     SDParInit            ; F#00E0 init parallel interface
               dc.l     SDParSetWrite        ; F#00E1 set for writing
               dc.l     SDParSetRead         ; F#00E2 set for reading
               dc.l     SDParWriteByte       ; F#00E3 write one byte
               dc.l     SDParReadByte        ; F#00E4 read one byte
               dc.l     SDGetClock           ; F#00E5 set the real-time clock
               dc.l     SDSetClock           ; F#00E6 get the real-time clock
               dc.l     SDDiskPing           ; F#00E7 exercises the interface
               dc.l     SDDiskOpenRead       ; F#00E8 open file for read
               dc.l     SDDiskOpenWrite      ; F#00E9 open file for write
               dc.l     SDDiskClose          ; F#00EA close file
               dc.l     SDDiskRead           ; F#00EB read from file
               dc.l     SDDiskWrite          ; F#00EC write to file
               dc.l     SDDiskDir            ; F#00ED start directory query
               dc.l     SDDiskDirNext        ; F#00EE get next directory entry
               dc.l     SDDiskReadSector     ; F#00EF read a sector TODO
               dc.l     SDDiskWriteSector    ; F#00F0 write a sector TODO
               dc.l     SDDiskStatus         ; F#00F1 get status TODO
               dc.l     SDDiskGetDrives      ; F#00F2 get the number of drives TODO
               dc.l     SDDiskGetMounted     ; F#00F3 get the mounted drive TODO
               dc.l     SDDiskNextMountedDrv ; F#00F4 Get the next mounted drive TODO
               dc.l     SDDiskUnmount        ; F#00F5 Unmount the file system TODO
               dc.l     SDDiskMount          ; F#00F6 Mount a file system TODO
               dc.l     TRUNDEF              ; F#00F7
               dc.l     TRUNDEF              ; F#00F8
               dc.l     TRUNDEF              ; F#00F9
               dc.l     TRUNDEF              ; F#00FA
               dc.l     TRUNDEF              ; F#00FB
               dc.l     TRUNDEF              ; F#00FC
               dc.l     TRUNDEF              ; F#00FD
               dc.l     TRUNDEF              ; F#00FE
               dc.l     TRUNDEF              ; F#00FF
;
; CPM routines
;
               dc.l     mv_cpm400bin         ; F#0100 move CPM0400 to location pointed to by a1.l (generally $0400)
               dc.l     mv_cpm15000bin       ; F#0101 move CPM15000 to location pointed to by a1.l (generally $14000)
               dc.l     mv_bios              ; F#0102 move BIOS to location pointed to by a1.l (generally $6200)
               dc.l     mv_firmware_update   ; F#0103 move firmware updater to location pointed to by a1.l (generally $4000)
               dc.l     TRUNDEF              ; F#0104
               dc.l     TRUNDEF              ; F#0105
               dc.l     TRUNDEF              ; F#0106
               dc.l     TRUNDEF              ; F#0107
               dc.l     TRUNDEF              ; F#0108
               dc.l     TRUNDEF              ; F#0109
               dc.l     TRUNDEF              ; F#010A
               dc.l     TRUNDEF              ; F#010B
               dc.l     TRUNDEF              ; F#010C
               dc.l     TRUNDEF              ; F#010D
               dc.l     TRUNDEF              ; F#010E
               dc.l     TRUNDEF              ; F#010F
;
; Test routines
;
               dc.l     FFPCALC              ; F#0110 Fast floating point calculator
               dc.l     xmas                 ; F#0111
trapend:
;
;
;
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
               include  "FFPOUT.X68"
               align    2
               include  "IOMECB.X68"
               align    2
               include  "aciaio.asm"
               align    2
               include  "libfujinet.asm"
               align    2
               include  "libfujicmd.asm"
               align    2
               include  "loadmodule.asm"
               align    2
               include  "xmas.asm"
               align    2
               include  "CPM400_v1.1.asm"
               include  "CPM400_v1.2.asm"
               include  "CPM400_v1.3.asm"
               include  "CPM15000_v1.1.asm"
               include  "CPM15000_v1.2.asm"
               include  "CPM15000_v1.3.asm"
               include  "cpm400_bios_bin.asm"
               include  "firmware_update_bin.asm"
;
st_trap_error: dc.b     'ERROR: Undefined trap #8 call initiated: #$',EOT
;
               end
