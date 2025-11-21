;
; Fast Floating-Point library routines
;
FFPABS                   equ $001004E8  ; d7=abs(d7)
FFPNEG                   equ $001004EE  ; d7=neg(d7)
FFPADD                   equ $0010050A  ; d7=add(d6,d7)
FFPSUB                   equ $001004F8  ; d7=sub(d6,d7)
FFPAFP                   equ $001005DC  ; d7=ASCII2float(a0)
FFPATAN                  equ $00100766  ; d7=atan(d7)
FFPCMP                   equ $001007F0  ; cmp(d6,d7) i.e. d7-d6
FFPTST                   equ $00100808  ; tst(d7)
FFPDBF                   equ $0010080C  ; d7=dual_binary2float(d6,d7)
FFPDIV                   equ $001008D2  ; d7=div(d6,d7)
FFPEXP                   equ $00100968  ; d7=exp(d7)
FFPFPA                   equ $00100A38  ; float2ASCII(d7)
FFPFPI                   equ $00100AFA  ; d7=float2int(d7)
FFPIFP                   equ $00100BAC  ; d7=int2float(d7)
FFPLOG                   equ $00100BE4  ; d7=log_e(d7)
FFPMUL                   equ $00100CA0  ; d7=mul(d6,d7)
FFPPWR                   equ $00100D1A  ; d7=power(d6,d7)
FFPSIN                   equ $00100D5C  ; d7=sin(d7)
FFPCOS                   equ $00100D4A  ; d7=cos(d7)
FFPTAN                   equ $00100D44  ; d7=tan(d7)
FFPSINCS                 equ $00100D3E  ; d6,d7=sincos(d7)
FFPSINH                  equ $00100EDA  ; d7=sinh(d7)
FFPCOSH                  equ $00100EAC  ; d7=cosh(d7)
FFPTANH                  equ $00100F0C  ; d7=tanh(d7)
FFPSQRT                  equ $00100F5C  ; d7=sqrt(d7)
;
; Misc routines
;
;
random                   equ $001010B8  ; d7=sqrt(d7)
crc_buf                  equ $00101104  ; d7=sqrt(d7)
;
; Font definitions
;
;
text_font_def            equ $00101154  ; 5x8 font
;
; FLASH library routines
;
;
flash_wbytes             equ $00101554  ; 5x8 font
flash_chip_erase         equ $0010158E  ; 5x8 font
flash_erase              equ $001015CA  ; 5x8 font
flash_swid               equ $00101628  ; 5x8 font
;
; SD card library routines
;
;
SDParInit                equ $00101760  ; init parallel interface
SDParSetWrite            equ $0010177C  ; set for writing
SDParSetRead             equ $0010179E  ; set for reading
SDParWriteByte           equ $001017C0  ; write one byte
SDParReadByte            equ $001017F6  ; read one byte
SDGetClock               equ $00101A10  ; set the real-time clock
SDSetClock               equ $001019C8  ; get the real-time clock
SDDiskPing               equ $001018C2  ; exercises the interface
SDDiskOpenRead           equ $001018E6  ; open file for read
SDDiskOpenWrite          equ $001018DC  ; open file for write
SDDiskClose              equ $001019BE  ; close file
SDDiskRead               equ $0010191E  ; read from file
SDDiskWrite              equ $00101972  ; write to file
SDDiskDir                equ $00101882  ; start directory query
SDDiskDirNext            equ $00101890  ; get next directory entry
SDDiskReadSector         equ $00101824  ; read a sector TODO
SDDiskWriteSector        equ $00101826  ; write a sector TODO
SDDiskStatus             equ $00101828  ; get status TODO
SDDiskGetDrives          equ $0010182A  ; get the number of drives TODO
SDDiskGetMounted         equ $00101830  ; get the mounted drive TODO
SDDiskNextMountedDrv     equ $00101832  ; Get the next mounted drive TODO
SDDiskUnmount            equ $00101834  ; Unmount the file system TODO
SDDiskMount              equ $0010185A  ; Mount a file system TODO
;
; OLED-related library routines
;
;
oled_init                equ $00101A40  ; Initialise OLED display
oled_on                  equ $00101A62  ; Turn on display
oled_off                 equ $00101A6C  ; Turn off display
oled_set_col             equ $00101A76  ; Set column range
oled_set_row             equ $00101A96  ; Set row range
oled_spixel              equ $00101C40  ; Set pixel
oled_pixel               equ $00101C9E  ; Draw pixel
oled_sline               equ $00101AAC  ; Draw line (using oled_spixel)
oled_line                equ $00101AAE  ; Draw line
oled_fill                equ $00101D3A  ; Fill rows
oled_scircle             equ $00101D72  ; Set circle (using oled_spixel, TODO)
oled_circle              equ $00101D74  ; Draw circle
oled_schar               equ $00101EF2  ; Write a character TODO
oled_char                equ $00101EF4  ; Write a character
oled_sstr                equ $00101F58  ; Write a string TODO
oled_str                 equ $00101F5A  ; Write a string
;
; VDP Routines
;
;
; Low-level VDP functions
;
vdp_vram_raddr           equ $00101FB0  ; Write a string
vdp_vram_waddr           equ $00101FDE  ; Write a string
vdp_write_reg            equ $00102010  ; Write a string
vdp_read_stat            equ $00102026  ; Write a string
vdp_read_nstat           equ $0010202E  ; Write a string
vdp_read_vram            equ $0010203E  ; Write a string
vdp_write_vram           equ $00102046  ; Write a string
vdp_init_regs            equ $0010204E  ; Write a string
vdp_set_vram             equ $0010206A  ; Write a string
vdp_inc_vram             equ $00102076  ; Write a string
vdp_xfr_vram             equ $00102084  ; Write a string
vdp_clr_vram             equ $00102094  ; Write a string
vdp_wait                 equ $001020AE  ; Write a string
;
; VDP graphics functions
;
vdp_set_mode             equ $001020DC  ; Write a string
vdp_line                 equ $00102486  ; Write a string
vdp_circle               equ $00102352  ; TODO
vdp_pset                 equ $00102542  ; TODO
vdp_point                equ $0010259E  ; TODO
;
; VDP text functions
vdp_load_font            equ $00102610  ; TODO
vdp_text_mode            equ $00102652  ; TODO
;
;
; Test routines
;
;
FFPCALC                  equ $001026A4  ; Fast floating point calculator
;
;
;
;
