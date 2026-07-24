;
; Library compiled for use in upper part of on-board ROM
;
; Library version
;
GET_LIBVERSION           equ $210456  ; return firmware libary version in d0
PRINT_LIBVERSION         equ $21045E  ; print firmare libary version
;
; Fast Floating-Point library routines
;
FFPABS                   equ $21063A  ; d7=abs(d7)
FFPNEG                   equ $210640  ; d7=neg(d7)
FFPADD                   equ $21065C  ; d7=add(d6,d7)
FFPSUB                   equ $21064A  ; d7=sub(d6,d7)
FFPAFP                   equ $210734  ; d7=ASCII2float(a0)
FFPATAN                  equ $2108D4  ; d7=atan(d7)
FFPCMP                   equ $210962  ; cmp(d6,d7) i.e. d7-d6
FFPTST                   equ $21097A  ; tst(d7)
FFPDBF                   equ $21097E  ; d7=dual_binary2float(d6,d7)
FFPDIV                   equ $210A50  ; d7=div(d6,d7)
FFPEXP                   equ $210AEC  ; d7=exp(d7)
FFPFPA                   equ $210BC4  ; float2ASCII(d7)
FFPFPI                   equ $210C9A  ; d7=float2int(d7)
FFPIFP                   equ $210D4C  ; d7=int2float(d7)
FFPLOG                   equ $210D88  ; d7=log_e(d7)
FFPMUL                   equ $210E4A  ; d7=mul(d6,d7)
FFPPWR                   equ $210EC8  ; d7=power(d6,d7)
FFPSIN                   equ $210F0A  ; d7=sin(d7)
FFPCOS                   equ $210EF8  ; d7=cos(d7)
FFPTAN                   equ $210EF2  ; d7=tan(d7)
FFPSINCS                 equ $210EEC  ; d6,d7=sincos(d7)
FFPSINH                  equ $211094  ; d7=sinh(d7)
FFPCOSH                  equ $211064  ; d7=cosh(d7)
FFPTANH                  equ $2110C8  ; d7=tanh(d7)
FFPSQRT                  equ $21111A  ; d7=sqrt(d7)
;
; Misc routines
;
RANDOM                   equ $21127E  ; d7=sqrt(d7)
CRC_BUF                  equ $2112C8  ; d7=sqrt(d7)
;
; Font definitions
;
TEXT_FONT_DEF            equ $211316  ; 5x8 font
;
; FLASH library routines
;
FLASH_WBYTES             equ $211716  ; 5x8 font
FLASH_CHIP_ERASE         equ $211754  ; 5x8 font
FLASH_ERASE              equ $211798  ; 5x8 font
FLASH_SWID               equ $2117FC  ; 5x8 font
;
; SD card library routines
;
SDPARINIT                equ $211938  ; init parallel interface
SDPARSETWRITE            equ $211954  ; set for writing
SDPARSETREAD             equ $211976  ; set for reading
SDPARWRITEBYTE           equ $211998  ; write one byte
SDPARREADBYTE            equ $2119CE  ; read one byte
SDGETCLOCK               equ $211BF0  ; set the real-time clock
SDSETCLOCK               equ $211BA6  ; get the real-time clock
SDDISKPING               equ $211A9C  ; exercises the interface
SDDISKOPENREAD           equ $211AC0  ; open file for read
SDDISKOPENWRITE          equ $211AB6  ; open file for write
SDDISKCLOSE              equ $211B9C  ; close file
SDDISKREAD               equ $211AF8  ; read from file
SDDISKWRITE              equ $211B4E  ; write to file
SDDISKDIR                equ $211A5A  ; start directory query
SDDISKDIRNEXT            equ $211A68  ; get next directory entry
SDDISKREADSECTOR         equ $2119FC  ; read a sector TODO
SDDISKWRITESECTOR        equ $2119FE  ; write a sector TODO
SDDISKSTATUS             equ $211A00  ; get status TODO
SDDISKGETDRIVES          equ $211A02  ; get the number of drives TODO
SDDISKGETMOUNTED         equ $211A08  ; get the mounted drive TODO
SDDISKNEXTMOUNTEDDRV     equ $211A0A  ; Get the next mounted drive TODO
SDDISKUNMOUNT            equ $211A0C  ; Unmount the file system TODO
SDDISKMOUNT              equ $211A32  ; Mount a file system TODO
;
; OLED-related library routines
;
OLED_INIT                equ $211C22  ; Initialise OLED display
OLED_ON                  equ $211C44  ; Turn on display
OLED_OFF                 equ $211C4E  ; Turn off display
OLED_SET_COL             equ $211C58  ; Set column range
OLED_SET_ROW             equ $211C78  ; Set row range
OLED_SPIXEL              equ $211E28  ; Set pixel
OLED_PIXEL               equ $211E86  ; Draw pixel
OLED_SLINE               equ $211C8E  ; Draw line (using oled_spixel)
OLED_LINE                equ $211C90  ; Draw line
OLED_FILL                equ $211F24  ; Fill rows
OLED_SCIRCLE             equ $211F90  ; Set circle (using oled_spixel, TODO)
OLED_CIRCLE              equ $211F92  ; Draw circle
OLED_SCHAR               equ $212128  ; Write a character TODO
OLED_CHAR                equ $21212A  ; Write a character
OLED_SSTR                equ $21219E  ; Write a string TODO
OLED_STR                 equ $2121A0  ; Write a string
OLED_MOVE                equ $211F60  ; Move a screen worth of data to OLED display
;
; VDP Routines
;
; Low-level VDP functions
VDP_VRAM_RADDR           equ $2121F8  ; Move a screen worth of data to OLED display
VDP_VRAM_WADDR           equ $212226  ; Move a screen worth of data to OLED display
VDP_WRITE_REG            equ $212258  ; Move a screen worth of data to OLED display
VDP_READ_STAT            equ $21226E  ; Move a screen worth of data to OLED display
VDP_READ_NSTAT           equ $212276  ; Move a screen worth of data to OLED display
VDP_READ_VRAM            equ $212286  ; Move a screen worth of data to OLED display
VDP_WRITE_VRAM           equ $21228E  ; Move a screen worth of data to OLED display
VDP_INIT_REGS            equ $212296  ; Move a screen worth of data to OLED display
VDP_SET_VRAM             equ $2122B4  ; Move a screen worth of data to OLED display
VDP_INC_VRAM             equ $2122C4  ; Move a screen worth of data to OLED display
VDP_XFR_VRAM             equ $2122D8  ; Move a screen worth of data to OLED display
VDP_CLR_VRAM             equ $2122EC  ; Move a screen worth of data to OLED display
VDP_WAIT                 equ $21230C  ; Move a screen worth of data to OLED display
;
; VDP graphics functions
;
VDP_SET_MODE             equ $212338  ; Move a screen worth of data to OLED display
VDP_LINE                 equ $2126F0  ; Move a screen worth of data to OLED display
VDP_CIRCLE               equ $2125B2  ; TODO
VDP_PSET                 equ $2127AC  ; TODO
VDP_POINT                equ $212808  ; TODO
;
; VDP text functions
;
VDP_LOAD_FONT            equ $212878  ; TODO
VDP_TEXT_MODE            equ $2128C2  ; TODO
;
; low-level PSG functions
;
PSG_INIT                 equ $212914  ; Initialise PIA1 for PSG use
PSG_STOP                 equ $212930  ; Stop all audio from PSG
PSG_VOLUME               equ $212956  ; Set channel volume
PSG_TONE                 equ $212972  ; Set channel tone
;
; low-level serial function
;
OUTCH1                   equ $212F90  ; output a character in d0.b through ACIA1
OUT2H                    equ $212F58  ; output 2 hex digits in d0.b
OUT4H                    equ $212F4C  ; output 4 hex digits in d0.w
OUT6H                    equ $212F42  ; output 6 hex digits in d0.l (ignores most significant byte)
OUT8H                    equ $212F38  ; output 8 hex digits in d0.l
PRINT                    equ $212F7E  ; print text pointed to by a0.l through ACIA1
PCRLF                    equ $212FA2  ; print a CR and LF through ACIA1
HEX2DEC2                 equ $212FB4  ; convert hex value in d0.b to a decimal string with trailing zeros and store in buffer pointed to by a1.l
CHEX2DEC                 equ $212FC6  ; convert hex value in d0.b to a signed decimal string and store in buffer pointed to by a1.l
STRCPY                   equ $213022  ; copy a string pointed to by a0.l to the buffer in a1.l
STRNCPY                  equ $213032  ; copy a given number of bytes from soure to destination
STRCPYNT                 equ $21304A  ; copy a string not including the EOT
;
; Fujinet routines
;
FUJINET_DCB_EXEC         equ $213182  ; low-level fujinet command execution
FUJINET_MOUNT_ALL        equ $2132D2  ; mount all devices
FUJINET_MOUNT_HOST       equ $2132EC  ; mount host
FUJINET_RESET            equ $21330E  ; reset fujinet device
FUJINET_READ_HOST_SLOTS   equ $213328  ; read host slots
FUJINET_READ_DEVICE_SLOTS   equ $213346  ; read device slots
FUJINET_RANDOM_NUMBER    equ $213364  ; get a random 32-bit number
FUJINET_GET_TIME         equ $213382  ; get the current time
FUJINET_OPEN_DIRECTORY   equ $2133A0  ; open a directory
FUJINET_READ_DIR_ENTRY   equ $2133A2  ; read a directory entry
FUJINET_CLOSE_DIRECTORY   equ $2133A4  ; close the directory
FUJINET_SET_DIRECTORY_POSITION   equ $2133A6  ; set the current directory position
FUJINET_GET_DIRECTORY_POSITION   equ $2133A8  ; get the current directory position
FUJINET_SCAN_FOR_NETWORKS   equ $2133AA  ; scan for Wi-Fi networks
FUJINET_GET_SCAN_RESULT   equ $2133AC  ; get the Wi-Fi scan result
FUJINET_GET_SSID         equ $2133AE  ; get the Wi-Fi SSID
FUJINET_GET_WIFI_STATUS   equ $2133B0  ; get the Wi-Fi status
FUJINET_SET_SSID         equ $2133B2  ; set the Wi-Fi SSID
FUJINET_GET_WIFI_ENABLED   equ $2133B4  ; get the Wi-Fi enabled status
FUJINET_FILE_OPEN        equ $2133B6  ; open a file
FUJINET_FILE_READ        equ $2133B8  ; read from a file
FUJINET_FILE_STATUS      equ $2133BA  ; get the file status
FUJINET_FILE_WRITE       equ $2133BC  ; write to a file
FUJINET_FILE_CLOSE       equ $2133BE  ; close a file
FUJINET_MOUNT_IMAGE      equ $2133C0  ; mount a disk image
FUJINET_DISK_READ        equ $2133E0  ; read a sector from the disk image
FUJINET_UNMOUNT_IMAGE    equ $213414  ; unmount a disk image
FUJINET_DISK_GET_SECTOR_SIZE   equ $213442  ; get the disk image sector size
FUJINET_DISK_WRITE       equ $213444  ; write a sector to the disk image
FUJINET_MODEM_READ       equ $213478  ; read from a MODEM device
FUJINET_MODEM_STATUS     equ $21347A  ; get the MODEM device status
FUJINET_MODEM_STREAM     equ $21347C  ; MOEDM device stream
FUJINET_MODEM_WRITE      equ $21347E  ; write to a MODEM device
FUJINET_NETWORK_OPEN     equ $213480  ; open a network channel
FUJINET_NETWORK_READ     equ $2134B4  ; read from a network channel
FUJINET_NETWORK_STATUS   equ $2134E6  ; get the network channel read status
FUJINET_NETWORK_WRITE    equ $213516  ; write to a network channel
FUJINET_NETWORK_CLOSE    equ $213548  ; close a network channel
FUJINET_NETWORK_CHANNEL_MODE   equ $213574  ; get the network channel mode
FUJINET_NETWORK_JSON_PARSE   equ $213576  ; parse a json string
FUJINET_NETWORK_JSON_QUERY   equ $213578  ; perform a json query
FUJINET_NETWORK_LOGIN    equ $21357A  ; network login
FUJINET_PRINTER_STREAM   equ $21357C  ; stream to printer device
FUJINET_PRINTER_WRITE    equ $21357E  ; write to printer device
FUJINET_OPEN_APPKEY      equ $213584  ; open an appkey
FUJINET_WRITE_APPKEY     equ $213580  ; write an appkey
FUJINET_READ_APPKEY      equ $213582  ; read an appkey
FUJINET_CLOSE_APPKEY     equ $213586  ; close appkey
FUJINET_DEVICE_CREATE_NEW   equ $213588  ; create a new device
FUJINET_DEVICE_DISABLE_DEVICE   equ $21358A  ; disable a device
FUJINET_DEVICE_ENABLE_DEVICE   equ $21358C  ; enable a device
FUJINET_DEVICE_GET_ADAPTER_CONFIG   equ $21358E  ; get the adapter config
FUJINET_DEVICE_GET_DEVICE_ENABLED_STATUS   equ $213590  ; get device status
FUJINET_DEVICE_GET_DEVICE_FILENAME   equ $213592  ; get device filename
FUJINET_WRITE_DEVICE_SLOTS   equ $213594  ; write device slots
FUJINET_WRITE_HOST_SLOTS   equ $213596  ; write host slots
FUJINET_DEVICE_SET_BOOT_CONFIG   equ $213598  ; set the boot config
FUJINET_DEVICE_SET_DEVICE_FILENAME   equ $21359A  ; set device filename
FUJINET_LOGICAL_DEVICE_TYPE   equ $21359C  ; get logical device type
FUJINET_LOGICAL_DEVICE_UNIT   equ $21359E  ; get logical device unit
FUJINET_LOGICAL_DEVICE_URL   equ $2135A0  ; get logical device url
FUJINET_NEW_DISK         equ $2135A2  ; new disk
FUJINET_SET_HOST_PREFIX   equ $2135A4  ; set host prefix
FUJINET_GET_HOST_PREFIX   equ $2135A6  ; get host prefix
FUJINET_COPY_FILE        equ $2135A8  ; copy a file
FUJINET_SET_BOOT_MODE    equ $2135AA  ; set boot mode
FUJINET_STATUS           equ $2135AC  ; get status
FUJINET_GET_ADAPTERCONFIG_EXTENDED   equ $2135AE  ; get extended adapter config
FUJINET_GENERATE_GUID    equ $2135B0  ; generate GUID
FUJINET_SET_STATUS       equ $2135B2  ; set status
FUJINET_UNMOUNT_HOST     equ $2135B4  ; unmount host
;
; CPM routines
;
MV_CPM400BIN             equ $2135D6  ; move CPM0400 to location pointed to by a1.l
MV_CPM15000BIN           equ $213614  ; move CPM15000 to location pointed to by a1.l
;
; Test routines
;
FFPCALC                  equ $2129AE  ; Fast floating point calculator
XMAS                     equ $213652  ; Fast floating point calculator
;
;
;
;
