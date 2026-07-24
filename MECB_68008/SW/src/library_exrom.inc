; Library compiled for use in lower part of the expansion ROM
;
; Fast Floating-Point library routines
;
FFPABS                   equ $10076C  ; d7=abs(d7)
FFPNEG                   equ $100772  ; d7=neg(d7)
FFPADD                   equ $10078E  ; d7=add(d6,d7)
FFPSUB                   equ $10077C  ; d7=sub(d6,d7)
FFPAFP                   equ $100866  ; d7=ASCII2float(a0)
FFPATAN                  equ $100A06  ; d7=atan(d7)
FFPCMP                   equ $100A92  ; cmp(d6,d7) i.e. d7-d6
FFPTST                   equ $100AAA  ; tst(d7)
FFPDBF                   equ $100AAE  ; d7=dual_binary2float(d6,d7)
FFPDIV                   equ $100B7E  ; d7=div(d6,d7)
FFPEXP                   equ $100C1A  ; d7=exp(d7)
FFPFPA                   equ $100CF0  ; float2ASCII(d7)
FFPFPI                   equ $100DC4  ; d7=float2int(d7)
FFPIFP                   equ $100E76  ; d7=int2float(d7)
FFPLOG                   equ $100EB2  ; d7=log_e(d7)
FFPMUL                   equ $100F72  ; d7=mul(d6,d7)
FFPPWR                   equ $100FF0  ; d7=power(d6,d7)
FFPSIN                   equ $101032  ; d7=sin(d7)
FFPCOS                   equ $101020  ; d7=cos(d7)
FFPTAN                   equ $10101A  ; d7=tan(d7)
FFPSINCS                 equ $101014  ; d6,d7=sincos(d7)
FFPSINH                  equ $1011BA  ; d7=sinh(d7)
FFPCOSH                  equ $10118A  ; d7=cosh(d7)
FFPTANH                  equ $1011EE  ; d7=tanh(d7)
FFPSQRT                  equ $101240  ; d7=sqrt(d7)
;
; Misc routines
;
;
RANDOM                   equ $1013A4  ; d7=sqrt(d7)
CRC_BUF                  equ $1013EE  ; d7=sqrt(d7)
;
; Font definitions
;
;
TEXT_FONT_DEF            equ $10143C  ; 5x8 font
;
; FLASH library routines
;
;
FLASH_WBYTES             equ $10183C  ; 5x8 font
FLASH_CHIP_ERASE         equ $10187A  ; 5x8 font
FLASH_ERASE              equ $1018BE  ; 5x8 font
FLASH_SWID               equ $101922  ; 5x8 font
;
; SD card library routines
;
;
SDPARINIT                equ $101A5E  ; init parallel interface
SDPARSETWRITE            equ $101A7A  ; set for writing
SDPARSETREAD             equ $101A9C  ; set for reading
SDPARWRITEBYTE           equ $101ABE  ; write one byte
SDPARREADBYTE            equ $101AF4  ; read one byte
SDGETCLOCK               equ $101D16  ; set the real-time clock
SDSETCLOCK               equ $101CCC  ; get the real-time clock
SDDISKPING               equ $101BC2  ; exercises the interface
SDDISKOPENREAD           equ $101BE6  ; open file for read
SDDISKOPENWRITE          equ $101BDC  ; open file for write
SDDISKCLOSE              equ $101CC2  ; close file
SDDISKREAD               equ $101C1E  ; read from file
SDDISKWRITE              equ $101C74  ; write to file
SDDISKDIR                equ $101B80  ; start directory query
SDDISKDIRNEXT            equ $101B8E  ; get next directory entry
SDDISKREADSECTOR         equ $101B22  ; read a sector TODO
SDDISKWRITESECTOR        equ $101B24  ; write a sector TODO
SDDISKSTATUS             equ $101B26  ; get status TODO
SDDISKGETDRIVES          equ $101B28  ; get the number of drives TODO
SDDISKGETMOUNTED         equ $101B2E  ; get the mounted drive TODO
SDDISKNEXTMOUNTEDDRV     equ $101B30  ; Get the next mounted drive TODO
SDDISKUNMOUNT            equ $101B32  ; Unmount the file system TODO
SDDISKMOUNT              equ $101B58  ; Mount a file system TODO
;
; OLED-related library routines
;
;
OLED_INIT                equ $101D48  ; Initialise OLED display
OLED_ON                  equ $101D6A  ; Turn on display
OLED_OFF                 equ $101D74  ; Turn off display
OLED_SET_COL             equ $101D7E  ; Set column range
OLED_SET_ROW             equ $101D9E  ; Set row range
OLED_SPIXEL              equ $101F4E  ; Set pixel
OLED_PIXEL               equ $101FAC  ; Draw pixel
OLED_SLINE               equ $101DB4  ; Draw line (using oled_spixel)
OLED_LINE                equ $101DB6  ; Draw line
OLED_FILL                equ $10204A  ; Fill rows
OLED_SCIRCLE             equ $1020B6  ; Set circle (using oled_spixel, TODO)
OLED_CIRCLE              equ $1020B8  ; Draw circle
OLED_SCHAR               equ $10223C  ; Write a character TODO
OLED_CHAR                equ $10223E  ; Write a character
OLED_SSTR                equ $1022B2  ; Write a string TODO
OLED_STR                 equ $1022B4  ; Write a string
;
; VDP Routines
;
;
; Low-level VDP functions
;
VDP_VRAM_RADDR           equ $10230C  ; Write a string
VDP_VRAM_WADDR           equ $10233A  ; Write a string
VDP_WRITE_REG            equ $10236C  ; Write a string
VDP_READ_STAT            equ $102382  ; Write a string
VDP_READ_NSTAT           equ $10238A  ; Write a string
VDP_READ_VRAM            equ $10239A  ; Write a string
VDP_WRITE_VRAM           equ $1023A2  ; Write a string
VDP_INIT_REGS            equ $1023AA  ; Write a string
VDP_SET_VRAM             equ $1023C8  ; Write a string
VDP_INC_VRAM             equ $1023D8  ; Write a string
VDP_XFR_VRAM             equ $1023EC  ; Write a string
VDP_CLR_VRAM             equ $102400  ; Write a string
VDP_WAIT                 equ $102420  ; Write a string
;
; VDP graphics functions
;
VDP_SET_MODE             equ $10244C  ; Write a string
VDP_LINE                 equ $102804  ; Write a string
VDP_CIRCLE               equ $1026C6  ; TODO
VDP_PSET                 equ $1028C0  ; TODO
VDP_POINT                equ $10291C  ; TODO
;
; VDP text functions
VDP_LOAD_FONT            equ $10298C  ; TODO
VDP_TEXT_MODE            equ $1029D6  ; TODO
;
;
; low-level PSG functions
;
PSG_INIT                 equ $102A28  ; Initialise PIA1 for PSG use
PSG_STOP                 equ $102A44  ; Stop all audio from PSG
PSG_VOLUME               equ $102A6A  ; Set channel volume
PSG_TONE                 equ $102A86  ; Set channel tone
;
;
; low-level serial function
;
OUTCH1                   equ $103066  ; output a character in d0.b through ACIA1
OUT2H                    equ $10302E  ; output 2 hex digits in d0.b
OUT4H                    equ $103022  ; output 4 hex digits in d0.w
OUT8H                    equ $10300E  ; output 8 hex digits in d0.l
PRINT                    equ $103054  ; print text pointed to by a0.l through ACIA1
PCRLF                    equ $103078  ; print a CR and LF through ACIA1
HEX2DEC2                 equ $10308A  ; convert hex value in d0.b to a decimal string with trailing zeros and store in buffer pointed to by a1.l
CHEX2DEC                 equ $10309C  ; convert hex value in d0.b to a signed decimal string and store in buffer pointed to by a1.l
STRCPY                   equ $1030F8  ; copy a string pointed to by a0.l to the buffer in a1.l
STRCPYNT                 equ $103120  ; copy a string not including the EOT
;
;
; Fujinet routines
;
FUJINET_DCB_EXEC         equ $103258  ; low-level fujinet command execution
FUJINET_MOUNT_ALL        equ $1033A8  ; mount all devices
FUJINET_MOUNT_HOST       equ $1033C2  ; mount host
FUJINET_RESET            equ $1033E4  ; reset fujinet device
FUJINET_READ_HOST_SLOTS   equ $1033FE  ; read host slots
FUJINET_READ_DEVICE_SLOTS   equ $10341C  ; read device slots
FUJINET_RANDOM_NUMBER    equ $10343A  ; get a random 32-bit number
FUJINET_GET_TIME         equ $103458  ; get the current time
FUJINET_OPEN_DIRECTORY   equ $103476  ; open a directory
FUJINET_READ_DIR_ENTRY   equ $103478  ; read a directory entry
FUJINET_CLOSE_DIRECTORY   equ $10347A  ; close the directory
FUJINET_SET_DIRECTORY_POSITION   equ $10347C  ; set the current directory position
FUJINET_GET_DIRECTORY_POSITION   equ $10347E  ; get the current directory position
FUJINET_SCAN_FOR_NETWORKS   equ $103480  ; scan for Wi-Fi networks
FUJINET_GET_SCAN_RESULT   equ $103482  ; get the Wi-Fi scan result
FUJINET_GET_SSID         equ $103484  ; get the Wi-Fi SSID
FUJINET_GET_WIFI_STATUS   equ $103486  ; get the Wi-Fi status
FUJINET_SET_SSID         equ $103488  ; set the Wi-Fi SSID
FUJINET_GET_WIFI_ENABLED   equ $10348A  ; get the Wi-Fi enabled status
FUJINET_FILE_OPEN        equ $10348C  ; open a file
FUJINET_FILE_READ        equ $10348E  ; read from a file
FUJINET_FILE_STATUS      equ $103490  ; get the file status
FUJINET_FILE_WRITE       equ $103492  ; write to a file
FUJINET_FILE_CLOSE       equ $103494  ; close a file
FUJINET_MOUNT_IMAGE      equ $103496  ; mount a disk image
FUJINET_DISK_READ        equ $1034B6  ; read a sector from the disk image
FUJINET_UNMOUNT_IMAGE    equ $1034EA  ; unmount a disk image
FUJINET_DISK_GET_SECTOR_SIZE   equ $103518  ; get the disk image sector size
FUJINET_DISK_WRITE       equ $10351A  ; write a sector to the disk image
FUJINET_MODEM_READ       equ $10354E  ; read from a MODEM device
FUJINET_MODEM_STATUS     equ $103550  ; get the MODEM device status
FUJINET_MODEM_STREAM     equ $103552  ; MOEDM device stream
FUJINET_MODEM_WRITE      equ $103554  ; write to a MODEM device
FUJINET_NETWORK_OPEN     equ $103556  ; open a network channel
FUJINET_NETWORK_READ     equ $10358A  ; read from a network channel
FUJINET_NETWORK_STATUS   equ $1035BC  ; get the network channel read status
FUJINET_NETWORK_WRITE    equ $1035EC  ; write to a network channel
FUJINET_NETWORK_CLOSE    equ $10361E  ; close a network channel
FUJINET_NETWORK_CHANNEL_MODE   equ $10364A  ; get the network channel mode
FUJINET_NETWORK_JSON_PARSE   equ $10364C  ; parse a json string
FUJINET_NETWORK_JSON_QUERY   equ $10364E  ; perform a json query
FUJINET_NETWORK_LOGIN    equ $103650  ; network login
FUJINET_PRINTER_STREAM   equ $103652  ; stream to printer device
FUJINET_PRINTER_WRITE    equ $103654  ; write to printer device
FUJINET_OPEN_APPKEY      equ $10365A  ; open an appkey
FUJINET_WRITE_APPKEY     equ $103656  ; write an appkey
FUJINET_READ_APPKEY      equ $103658  ; read an appkey
FUJINET_CLOSE_APPKEY     equ $10365C  ; close appkey
FUJINET_DEVICE_CREATE_NEW   equ $10365E  ; create a new device
FUJINET_DEVICE_DISABLE_DEVICE   equ $103660  ; disable a device
FUJINET_DEVICE_ENABLE_DEVICE   equ $103662  ; enable a device
FUJINET_DEVICE_GET_ADAPTER_CONFIG   equ $103664  ; get the adapter config
FUJINET_DEVICE_GET_DEVICE_ENABLED_STATUS   equ $103666  ; get device status
FUJINET_DEVICE_GET_DEVICE_FILENAME   equ $103668  ; get device filename
FUJINET_WRITE_DEVICE_SLOTS   equ $10366A  ; write device slots
FUJINET_WRITE_HOST_SLOTS   equ $10366C  ; write host slots
FUJINET_DEVICE_SET_BOOT_CONFIG   equ $10366E  ; set the boot config
FUJINET_DEVICE_SET_DEVICE_FILENAME   equ $103670  ; set device filename
FUJINET_LOGICAL_DEVICE_TYPE   equ $103672  ; get logical device type
FUJINET_LOGICAL_DEVICE_UNIT   equ $103674  ; get logical device unit
FUJINET_LOGICAL_DEVICE_URL   equ $103676  ; get logical device url
FUJINET_NEW_DISK         equ $103678  ; new disk
FUJINET_SET_HOST_PREFIX   equ $10367A  ; set host prefix
FUJINET_GET_HOST_PREFIX   equ $10367C  ; get host prefix
FUJINET_COPY_FILE        equ $10367E  ; copy a file
FUJINET_SET_BOOT_MODE    equ $103680  ; set boot mode
FUJINET_STATUS           equ $103682  ; get status
FUJINET_GET_ADAPTERCONFIG_EXTENDED   equ $103684  ; get extended adapter config
FUJINET_GENERATE_GUID    equ $103686  ; generate GUID
FUJINET_SET_STATUS       equ $103688  ; set status
FUJINET_UNMOUNT_HOST     equ $10368A  ; unmount host
;
;
; CPM routines
;
MV_CPM400BIN             equ $1036AC  ; move CPM0400 to location pointed to by a1.l
MV_CPM15000BIN           equ $1036EA  ; move CPM15000 to location pointed to by a1.l
;
;
; Test routines
;
;
FFPCALC                  equ $102AC2  ; Fast floating point calculator
XMAS                     equ $103728  ; Fast floating point calculator
;
;
;
;
