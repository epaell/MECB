;
; TRAP #8 library calls
;
GETLVER     equ      $0000 ; Get library version
OUTLVER     equ      $0001 ; Output library version
FFPABS      equ      $0002 ; d7=abs(d7)
FFPNEG      equ      $0003 ; d7=neg(d7)
FFPADD      equ      $0004 ; d7=add(d6,d7)
FFPSUB      equ      $0005 ; d7=sub(d6,d7)
FFPAFP      equ      $0006 ; d7=ASCII2float(a0)
FFPATAN     equ      $0007 ; d7=atan(d7)
FFPCMP      equ      $0008 ; cmp(d6,d7) i.e. d7-d6
FFPTST      equ      $0009 ; tst(d7)
FFPDBF      equ      $000A ; d7=dual_binary2float(d6,d7)
FFPDIV      equ      $000B ; d7=div(d6,d7)
FFPEXP      equ      $000C ; d7=exp(d7)
FFPFPA      equ      $000D ; float2ASCII(d7)
FFPFPI      equ      $000E ; d7=float2int(d7)
FFPIFP      equ      $000F ; d7=int2float(d7)
FFPLOG      equ      $0010 ; d7=log_e(d7)
FFPMUL      equ      $0011 ; d7=mul(d6,d7)
FFPPWR      equ      $0012 ; d7=power(d6,d7)
FFPSIN      equ      $0013 ; d7=sin(d7)
FFPCOS      equ      $0014 ; d7=cos(d7)
FFPTAN      equ      $0015 ; d7=tan(d7)
FFPSINCS    equ      $0016 ; d6,d7=sincos(d7)
FFPSINH     equ      $0017 ; d7=sinh(d7)
FFPCOSH     equ      $0018 ; d7=cosh(d7)
FFPTANH     equ      $0019 ; d7=tanh(d7)
FFPSQRT     equ      $001A ; d7=sqrt(d7)
FFPOUT      equ      $001B ; output the floating point value in d7
;
OUTCH1      equ      $0020 ; output a character in d0.b through ACIA1
OUT2H       equ      $0021 ; output 2 hex digits in d0.b
OUT4H       equ      $0022 ; output 4 hex digits in d0.w
OUT6H       equ      $0023 ; output 6 hex digits in d0.l (ignores most significant byte)
OUT8H       equ      $0024 ; output 8 hex digits in d0.l
OUTDEC      equ      $0025 ; output binary value in d0.l as decimal string
PRINT       equ      $0026 ; print EOT-terminated text pointed to by a0.l through ACIA1
PCRLF       equ      $0027 ; print a CR and LF through ACIA1
SHEX2DEC    equ      $0028 ; convert hex value in d0.l to a decimal string into buffer pointed to by a1.l
STRCPY      equ      $0029 ; copy a string pointed to by a0.l to the buffer in a1.l
STRNCPY     equ      $002A ; copy a given number of bytes from soure to destination
STRCPYNT    equ      $002B ; copy a string not including the EOT
HEX2DEC2    equ      $002C ; convert hex value in d0.b to a decimal string with trailing zeros and store in buffer pointed to by a1.l
CHEX2DEC    equ      $002D ; convert hex value in d0.b to a signed decimal string and store in buffer pointed to by a1.l
STRLEN      equ      $002E ; return length of string (d0.l) pointed to by a0.l
;
FNEXEC      equ      $0030 ; low-level fujinet command execution
FNMNALL     equ      $0031 ; mount all devices
FNMNHST     equ      $0032 ; mount host
FNRESET     equ      $0033 ; reset fujinet device
FNRDHST     equ      $0034 ; read host slots
FNRDDEV     equ      $0035 ; read device slots
FNRANDM     equ      $0036 ; get a random 32-bit number
FNGETDT     equ      $0037 ; get the current date and time
FNOPDIR     equ      $0038 ; TODO open a directory
FNRDDIR     equ      $0039 ; TODO read a directory entry
FNCLDIR     equ      $003A ; TODO close the directory
FNSETDP     equ      $003B ; TODO set the current directory position
FNGETDP     equ      $003C ; TODO get the current directory position
FNSCANN     equ      $003D ; TODO scan for Wi-Fi networks
FNGETSR     equ      $003E ; TODO get the Wi-Fi scan result
FNGETSS     equ      $003F ; TODO get the Wi-Fi SSID
FNGETWS     equ      $0040 ; TODO get the Wi-Fi status
FNSETSS     equ      $0041 ; TODO set the Wi-Fi SSID
FNGETWE     equ      $0042 ; TODO get the Wi-Fi enabled status
FNOPFIL     equ      $0043 ; open a file
FNRDFIL     equ      $0044 ; read from a file
FNSTFIL     equ      $0045 ; get the file status
FNWRFIL     equ      $0046 ; write to a file
FNCLFIL     equ      $0047 ; close a file
FNMNIMG     equ      $0048 ; mount a disk image
FNRDIMG     equ      $0049 ; read a sector from the disk image
FNUMIMG     equ      $004A ; unmount a disk image
;FNGETSC     equ      $004B ; TODO get the disk image sector size
FNWRIMG     equ      $004C ; write a sector to the disk image
FNRDMOD     equ      $004D ; TODO read from a MODEM device
FNSTMOD     equ      $004E ; TODO get the MODEM device status
FNMODST     equ      $004F ; TODO MODEM device stream
FNWRMOD     equ      $0050 ; TODO write to a MODEM device
FNOPNET     equ      $0051 ; open a network channel
FNRDNET     equ      $0052 ; read from a network channel
FNSTNET     equ      $0053 ; get the network channel read status
FNWRNET     equ      $0054 ; write to a network channel
FNCLNET     equ      $0055 ; close a network channel
FNNETCM     equ      $0056 ; get the network channel mode
FNNETPJ     equ      $0057 ; TODO parse a json string
FNNETJQ     equ      $0058 ; TODO perform a json query
FNNETLG     equ      $0059 ; TODO network login
FNPRNST     equ      $005A ; TODO stream to printer device
FNWRPRN     equ      $005B ; write to printer device
FNOPAPP     equ      $005C ; TODO open an appkey
FNWRAPP     equ      $005D ; TODO write an appkey
FNRDAPP     equ      $005E ; TODO read an appkey
FNCLAPP     equ      $005F ; TODO close appkey
FNCRDEV     equ      $0060 ; TODO create a new device
FNDIDEV     equ      $0061 ; disable a device
FNENDEV     equ      $0062 ; enable a device
FNGETAC     equ      $0063 ; TODO get the adapter config
FNSTDEV     equ      $0064 ; get device status
FNGETDF     equ      $0065 ; get device slot full path
FNWRDEV     equ      $0066 ; write device slots
FNWRHST     equ      $0067 ; write host slots
FNSETBC     equ      $0068 ; TODO set the boot config
FNSETDF     equ      $0069 ; set device slot full path
FNLDVTY     equ      $006A ; TODO get logical device type
FNLDVUN     equ      $006B ; TODO get logical device unit
FNLDVUR     equ      $006C ; TODO get logical device url
FNNDISK     equ      $006D ; TODO new disk
FNSETHP     equ      $006E ; TODO set host prefix
FNGETHP     equ      $006F ; TODO get host prefix
FNCPFIL     equ      $0070 ; TODO copy a file
FNSETBM     equ      $0071 ; TODO set boot mode
FNSTAT      equ      $0072 ; TODO get status
FNSETAC     equ      $0073 ; TODO get extended adapter config
FNGGUID     equ      $0074 ; TODO generate GUID
FNSSTAT     equ      $0075 ; TODO set status
FNUMHST     equ      $0076 ; unmount host (not implemented in firmware)
;
RANDOM      equ      $0080 ; d0.l = random number(seed=a0.l)
crc_buf     equ      $0081 ; d0.l = crc(str=a0.l, len=d0.l)
;
; FLASH library routines
;
FLWRBYT     equ      $0082 ; flash_wbytes(d0.l=rombase,d2=nbytes,a0.l=dest,a1.l=src)
FLCHERA     equ      $0083 ; flash_chip_erase(d0=rombase,a1.l=sector addr)
FLERASE     equ      $0084 ; flash_erase(d0=rombase,a1.l=sector addr)
FLGSWID     equ      $0085 ; flash_swid(d0=rombase,d1.l=mfr,a0.l=devattr)
;
; Font definitions
;
GET5X8F     equ      $0086 ; a0 points to 5x8 font
OLINIT      equ      $0090 ; Initialise OLED display
OLON        equ      $0091 ; Turn on display
OLOFF       equ      $0092 ; Turn off display
OLSETC      equ      $0093 ; Set column range
OLSETR      equ      $0094 ; Set row range
OLSETP      equ      $0095 ; Set pixel
OLPIX       equ      $0096 ; Draw pixel
OLDRL1      equ      $0097 ; Draw line (using oled_spixel)
OLDEL2      equ      $0098 ; Draw line
OLFLRW      equ      $0099 ; Fill rows
OLSECI      equ      $009A ; Set circle (using oled_spixel, TODO)
OLDRCI      equ      $009B ; Draw circle
OLSCHR      equ      $009C ; Write a character TODO
OLCHR       equ      $009D ; Write a character
OLSSTR      equ      $009E ; Write a string TODO
OLSTR       equ      $009F ; Write a string
OLMOVE      equ      $00A0 ; Move a screen worth of data to OLED display
VDRADR      equ      $00B0
VDWADR      equ      $00B1
VDWREG      equ      $00B2
VDRST       equ      $00B3
VDRNST      equ      $00B4
VDRRAM      equ      $00B5
VDWRAM      equ      $00B6
VDIREG      equ      $00B7
VDSRAM      equ      $00B8
VDIRAM      equ      $00B9
VDXRAM      equ      $00BA
VDCRAM      equ      $00BB
VDWAIT      equ      $00BC
;
VDMODE      equ      $00C0
VDLINE      equ      $00C1
VDCIRC      equ      $00C2 ;  TODO
VDPSET      equ      $00C3
VDPNT       equ      $00C4
;
; VDP text functions
;
VDLDFNT     equ      $00C5
VDTMODE     equ      $00C6
;
; low-level PSG functions
;
PSGINIT     equ      $00D0 ; Initialise PIA1 for PSG use
PSGSTOP     equ      $00D1 ; Stop all audio from PSG
PSGSVOL     equ      $00D2 ; Set channel volume
PSGSTON     equ      $00D3 ; Set channel tone
;
; SD card library routines
;
SDINIT      equ      $00E0 ; init parallel interface
SDSWR       equ      $00E1 ; set for writing
SDSRD       equ      $00E2 ; set for reading
SDWRBY      equ      $00E3 ; write one byte
SDRDBY      equ      $00E4 ; read one byte
SDGCLK      equ      $00E5 ; set the real-time clock
SDSCLK      equ      $00E6 ; get the real-time clock
SDPING      equ      $00E7 ; exercises the interface
SDOPRD      equ      $00E8 ; open file for read
SDOPWR      equ      $00E9 ; open file for write
SDCL        equ      $00EA ; close file
SDRD        equ      $00EB ; read from file
SDWR        equ      $00EC ; write to file
SDDIR       equ      $00ED ; start directory query
SDDIRNX     equ      $00EE ; get next directory entry
SDRDSEC     equ      $00EF ; read a sector TODO
SDWRSEC     equ      $00F0 ; write a sector TODO
SDSTAT      equ      $00F1 ; get status TODO
SDGDR       equ      $00F2 ; get the number of drives TODO
SDFMNT      equ      $00F3 ; get the mounted drive TODO
SDNMNT      equ      $00F4 ; Get the next mounted drive TODO
SDUMNT      equ      $00F5 ; Unmount the file system TODO
SDMNT       equ      $00F6 ; Mount a file system TODO
;
; CPM routines
;
CPM400MV    equ      $0100 ; move CPM0400 to location pointed to by a1.l
CPM15KMV    equ      $0101 ; move CPM15000 to location pointed to by a1.l
BIOSMV      equ      $0102 ; move BIOS to location pointed to by a1.l
FUPDATEMV   equ      $0103 ; move firmware updater to location pointed to by a1.l
;
; Test routines
;
FFPCALC     equ      $0110 ; Fast floating point calculator
XMAS        equ      $0111
;
; Macro to call library trap function
LIBRARY     macro    function
            move.w   #function,d5
            trap     #8
            endm