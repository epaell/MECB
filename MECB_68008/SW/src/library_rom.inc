;
; Library compiled for use in upper part of on-board ROM
;
; Fast Floating-Point library routines
;
FFPABS                   equ $21076C  ; d7=abs(d7)
FFPNEG                   equ $210772  ; d7=neg(d7)
FFPADD                   equ $21078E  ; d7=add(d6,d7)
FFPSUB                   equ $21077C  ; d7=sub(d6,d7)
FFPAFP                   equ $210866  ; d7=ASCII2float(a0)
FFPATAN                  equ $210A06  ; d7=atan(d7)
FFPCMP                   equ $210A94  ; cmp(d6,d7) i.e. d7-d6
FFPTST                   equ $210AAC  ; tst(d7)
FFPDBF                   equ $210AB0  ; d7=dual_binary2float(d6,d7)
FFPDIV                   equ $210B82  ; d7=div(d6,d7)
FFPEXP                   equ $210C1E  ; d7=exp(d7)
FFPFPA                   equ $210CF6  ; float2ASCII(d7)
FFPFPI                   equ $210DCC  ; d7=float2int(d7)
FFPIFP                   equ $210E7E  ; d7=int2float(d7)
FFPLOG                   equ $210EBA  ; d7=log_e(d7)
FFPMUL                   equ $210F7C  ; d7=mul(d6,d7)
FFPPWR                   equ $210FFA  ; d7=power(d6,d7)
FFPSIN                   equ $21103C  ; d7=sin(d7)
FFPCOS                   equ $21102A  ; d7=cos(d7)
FFPTAN                   equ $211024  ; d7=tan(d7)
FFPSINCS                 equ $21101E  ; d6,d7=sincos(d7)
FFPSINH                  equ $2111C6  ; d7=sinh(d7)
FFPCOSH                  equ $211196  ; d7=cosh(d7)
FFPTANH                  equ $2111FA  ; d7=tanh(d7)
FFPSQRT                  equ $21124C  ; d7=sqrt(d7)
;
; Misc routines
;
;
RANDOM                   equ $2113B0  ; d7=sqrt(d7)
CRC_BUF                  equ $2113FA  ; d7=sqrt(d7)
;
; Font definitions
;
;
TEXT_FONT_DEF            equ $211448  ; 5x8 font
;
; FLASH library routines
;
;
FLASH_WBYTES             equ $211848  ; 5x8 font
FLASH_CHIP_ERASE         equ $211886  ; 5x8 font
FLASH_ERASE              equ $2118CA  ; 5x8 font
FLASH_SWID               equ $21192E  ; 5x8 font
;
; SD card library routines
;
;
SDPARINIT                equ $211A6A  ; init parallel interface
SDPARSETWRITE            equ $211A86  ; set for writing
SDPARSETREAD             equ $211AA8  ; set for reading
SDPARWRITEBYTE           equ $211ACA  ; write one byte
SDPARREADBYTE            equ $211B00  ; read one byte
SDGETCLOCK               equ $211D22  ; set the real-time clock
SDSETCLOCK               equ $211CD8  ; get the real-time clock
SDDISKPING               equ $211BCE  ; exercises the interface
SDDISKOPENREAD           equ $211BF2  ; open file for read
SDDISKOPENWRITE          equ $211BE8  ; open file for write
SDDISKCLOSE              equ $211CCE  ; close file
SDDISKREAD               equ $211C2A  ; read from file
SDDISKWRITE              equ $211C80  ; write to file
SDDISKDIR                equ $211B8C  ; start directory query
SDDISKDIRNEXT            equ $211B9A  ; get next directory entry
SDDISKREADSECTOR         equ $211B2E  ; read a sector TODO
SDDISKWRITESECTOR        equ $211B30  ; write a sector TODO
SDDISKSTATUS             equ $211B32  ; get status TODO
SDDISKGETDRIVES          equ $211B34  ; get the number of drives TODO
SDDISKGETMOUNTED         equ $211B3A  ; get the mounted drive TODO
SDDISKNEXTMOUNTEDDRV     equ $211B3C  ; Get the next mounted drive TODO
SDDISKUNMOUNT            equ $211B3E  ; Unmount the file system TODO
SDDISKMOUNT              equ $211B64  ; Mount a file system TODO
;
; OLED-related library routines
;
;
OLED_INIT                equ $211D54  ; Initialise OLED display
OLED_ON                  equ $211D76  ; Turn on display
OLED_OFF                 equ $211D80  ; Turn off display
OLED_SET_COL             equ $211D8A  ; Set column range
OLED_SET_ROW             equ $211DAA  ; Set row range
OLED_SPIXEL              equ $211F5A  ; Set pixel
OLED_PIXEL               equ $211FB8  ; Draw pixel
OLED_SLINE               equ $211DC0  ; Draw line (using oled_spixel)
OLED_LINE                equ $211DC2  ; Draw line
OLED_FILL                equ $212056  ; Fill rows
OLED_SCIRCLE             equ $2120C2  ; Set circle (using oled_spixel, TODO)
OLED_CIRCLE              equ $2120C4  ; Draw circle
OLED_SCHAR               equ $21225A  ; Write a character TODO
OLED_CHAR                equ $21225C  ; Write a character
OLED_SSTR                equ $2122D0  ; Write a string TODO
OLED_STR                 equ $2122D2  ; Write a string
OLED_MOVE                equ $212092  ; Move a screen worth of data to OLED display
;
; VDP Routines
;
;
; Low-level VDP functions
VDP_VRAM_RADDR           equ $21232A  ; Move a screen worth of data to OLED display
VDP_VRAM_WADDR           equ $212358  ; Move a screen worth of data to OLED display
VDP_WRITE_REG            equ $21238A  ; Move a screen worth of data to OLED display
VDP_READ_STAT            equ $2123A0  ; Move a screen worth of data to OLED display
VDP_READ_NSTAT           equ $2123A8  ; Move a screen worth of data to OLED display
VDP_READ_VRAM            equ $2123B8  ; Move a screen worth of data to OLED display
VDP_WRITE_VRAM           equ $2123C0  ; Move a screen worth of data to OLED display
VDP_INIT_REGS            equ $2123C8  ; Move a screen worth of data to OLED display
VDP_SET_VRAM             equ $2123E6  ; Move a screen worth of data to OLED display
VDP_INC_VRAM             equ $2123F6  ; Move a screen worth of data to OLED display
VDP_XFR_VRAM             equ $21240A  ; Move a screen worth of data to OLED display
VDP_CLR_VRAM             equ $21241E  ; Move a screen worth of data to OLED display
VDP_WAIT                 equ $21243E  ; Move a screen worth of data to OLED display
;
; VDP graphics functions
;
VDP_SET_MODE             equ $21246A  ; Move a screen worth of data to OLED display
VDP_LINE                 equ $212822  ; Move a screen worth of data to OLED display
VDP_CIRCLE               equ $2126E4  ; TODO
VDP_PSET                 equ $2128DE  ; TODO
VDP_POINT                equ $21293A  ; TODO
;
; VDP text functions
;
VDP_LOAD_FONT            equ $2129AA  ; TODO
VDP_TEXT_MODE            equ $2129F4  ; TODO
;
;
; low-level PSG functions
;
PSG_INIT                 equ $212A46  ; Initialise PIA1 for PSG use
PSG_STOP                 equ $212A62  ; Stop all audio from PSG
PSG_VOLUME               equ $212A88  ; Set channel volume
PSG_TONE                 equ $212AA4  ; Set channel tone
;
;
; low-level serial function
;
OUTCH1                   equ $2130B8  ; output a character in d0.b through ACIA1
OUT2H                    equ $213080  ; output 2 hex digits in d0.b
OUT4H                    equ $213074  ; output 4 hex digits in d0.w
OUT8H                    equ $21306A  ; output 8 hex digits in d0.l
PRINT                    equ $2130A6  ; print text pointed to by a0.l through ACIA1
PCRLF                    equ $2130CA  ; print a CR and LF through ACIA1
HEX2DEC2                 equ $2130DC  ; convert hex value in d0.b to a decimal string with trailing zeros and store in buffer pointed to by a1.l
CHEX2DEC                 equ $2130EE  ; convert hex value in d0.b to a signed decimal string and store in buffer pointed to by a1.l
STRCPY                   equ $21314A  ; copy a string pointed to by a0.l to the buffer in a1.l
STRCPYNT                 equ $21315A  ; copy a string not including the EOT
;
;
; Fujinet routines
;
FUJINET_DCB_EXEC         equ $213292  ; low-level fujinet command execution
FUJINET_MOUNT_ALL        equ $2133E2  ; mount all devices
FUJINET_MOUNT_HOST       equ $2133FC  ; mount host
FUJINET_RESET            equ $21341E  ; reset fujinet device
FUJINET_READ_HOST_SLOTS   equ $213438  ; read host slots
FUJINET_READ_DEVICE_SLOTS   equ $213456  ; read device slots
FUJINET_RANDOM_NUMBER    equ $213474  ; get a random 32-bit number
FUJINET_GET_TIME         equ $213492  ; get the current time
FUJINET_OPEN_DIRECTORY   equ $2134B0  ; open a directory
FUJINET_READ_DIR_ENTRY   equ $2134B2  ; read a directory entry
FUJINET_CLOSE_DIRECTORY   equ $2134B4  ; close the directory
FUJINET_SET_DIRECTORY_POSITION   equ $2134B6  ; set the current directory position
FUJINET_GET_DIRECTORY_POSITION   equ $2134B8  ; get the current directory position
FUJINET_SCAN_FOR_NETWORKS   equ $2134BA  ; scan for Wi-Fi networks
FUJINET_GET_SCAN_RESULT   equ $2134BC  ; get the Wi-Fi scan result
FUJINET_GET_SSID         equ $2134BE  ; get the Wi-Fi SSID
FUJINET_GET_WIFI_STATUS   equ $2134C0  ; get the Wi-Fi status
FUJINET_SET_SSID         equ $2134C2  ; set the Wi-Fi SSID
FUJINET_GET_WIFI_ENABLED   equ $2134C4  ; get the Wi-Fi enabled status
FUJINET_FILE_OPEN        equ $2134C6  ; open a file
FUJINET_FILE_READ        equ $2134C8  ; read from a file
FUJINET_FILE_STATUS      equ $2134CA  ; get the file status
FUJINET_FILE_WRITE       equ $2134CC  ; write to a file
FUJINET_FILE_CLOSE       equ $2134CE  ; close a file
FUJINET_MOUNT_IMAGE      equ $2134D0  ; mount a disk image
FUJINET_DISK_READ        equ $2134F0  ; read a sector from the disk image
FUJINET_UNMOUNT_IMAGE    equ $213524  ; unmount a disk image
FUJINET_DISK_GET_SECTOR_SIZE   equ $213552  ; get the disk image sector size
FUJINET_DISK_WRITE       equ $213554  ; write a sector to the disk image
FUJINET_MODEM_READ       equ $213588  ; read from a MODEM device
FUJINET_MODEM_STATUS     equ $21358A  ; get the MODEM device status
FUJINET_MODEM_STREAM     equ $21358C  ; MOEDM device stream
FUJINET_MODEM_WRITE      equ $21358E  ; write to a MODEM device
FUJINET_NETWORK_OPEN     equ $213590  ; open a network channel
FUJINET_NETWORK_READ     equ $2135C4  ; read from a network channel
FUJINET_NETWORK_STATUS   equ $2135F6  ; get the network channel read status
FUJINET_NETWORK_WRITE    equ $213626  ; write to a network channel
FUJINET_NETWORK_CLOSE    equ $213658  ; close a network channel
FUJINET_NETWORK_CHANNEL_MODE   equ $213684  ; get the network channel mode
FUJINET_NETWORK_JSON_PARSE   equ $213686  ; parse a json string
FUJINET_NETWORK_JSON_QUERY   equ $213688  ; perform a json query
FUJINET_NETWORK_LOGIN    equ $21368A  ; network login
FUJINET_PRINTER_STREAM   equ $21368C  ; stream to printer device
FUJINET_PRINTER_WRITE    equ $21368E  ; write to printer device
FUJINET_OPEN_APPKEY      equ $213694  ; open an appkey
FUJINET_WRITE_APPKEY     equ $213690  ; write an appkey
FUJINET_READ_APPKEY      equ $213692  ; read an appkey
FUJINET_CLOSE_APPKEY     equ $213696  ; close appkey
FUJINET_DEVICE_CREATE_NEW   equ $213698  ; create a new device
FUJINET_DEVICE_DISABLE_DEVICE   equ $21369A  ; disable a device
FUJINET_DEVICE_ENABLE_DEVICE   equ $21369C  ; enable a device
FUJINET_DEVICE_GET_ADAPTER_CONFIG   equ $21369E  ; get the adapter config
FUJINET_DEVICE_GET_DEVICE_ENABLED_STATUS   equ $2136A0  ; get device status
FUJINET_DEVICE_GET_DEVICE_FILENAME   equ $2136A2  ; get device filename
FUJINET_WRITE_DEVICE_SLOTS   equ $2136A4  ; write device slots
FUJINET_WRITE_HOST_SLOTS   equ $2136A6  ; write host slots
FUJINET_DEVICE_SET_BOOT_CONFIG   equ $2136A8  ; set the boot config
FUJINET_DEVICE_SET_DEVICE_FILENAME   equ $2136AA  ; set device filename
FUJINET_LOGICAL_DEVICE_TYPE   equ $2136AC  ; get logical device type
FUJINET_LOGICAL_DEVICE_UNIT   equ $2136AE  ; get logical device unit
FUJINET_LOGICAL_DEVICE_URL   equ $2136B0  ; get logical device url
FUJINET_NEW_DISK         equ $2136B2  ; new disk
FUJINET_SET_HOST_PREFIX   equ $2136B4  ; set host prefix
FUJINET_GET_HOST_PREFIX   equ $2136B6  ; get host prefix
FUJINET_COPY_FILE        equ $2136B8  ; copy a file
FUJINET_SET_BOOT_MODE    equ $2136BA  ; set boot mode
FUJINET_STATUS           equ $2136BC  ; get status
FUJINET_GET_ADAPTERCONFIG_EXTENDED   equ $2136BE  ; get extended adapter config
FUJINET_GENERATE_GUID    equ $2136C0  ; generate GUID
FUJINET_SET_STATUS       equ $2136C2  ; set status
FUJINET_UNMOUNT_HOST     equ $2136C4  ; unmount host
;
; CPM routines
;
MV_CPM400                equ $2136E6  ; move CPM0400 to location pointed to by a1.l
MV_CPM15000              equ $2136F8  ; move CPM15000 to location pointed to by a1.l
;
; Test routines
;
;
FFPCALC                  equ $212AE0  ; Fast floating point calculator
XMAS                     equ $21370A  ; Fast floating point calculator
;
;
;
;
