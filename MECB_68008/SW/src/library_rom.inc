;
; Fast Floating-Point library routines
;
FFPABS                   equ $002104E8  ; d7=abs(d7)
FFPNEG                   equ $002104EE  ; d7=neg(d7)
FFPADD                   equ $0021050A  ; d7=add(d6,d7)
FFPSUB                   equ $002104F8  ; d7=sub(d6,d7)
FFPAFP                   equ $002105DC  ; d7=ASCII2float(a0)
FFPATAN                  equ $00210766  ; d7=atan(d7)
FFPCMP                   equ $002107F0  ; cmp(d6,d7) i.e. d7-d6
FFPTST                   equ $00210808  ; tst(d7)
FFPDBF                   equ $0021080C  ; d7=dual_binary2float(d6,d7)
FFPDIV                   equ $002108D2  ; d7=div(d6,d7)
FFPEXP                   equ $00210968  ; d7=exp(d7)
FFPFPA                   equ $00210A38  ; float2ASCII(d7)
FFPFPI                   equ $00210AFA  ; d7=float2int(d7)
FFPIFP                   equ $00210BAC  ; d7=int2float(d7)
FFPLOG                   equ $00210BE4  ; d7=log_e(d7)
FFPMUL                   equ $00210CA0  ; d7=mul(d6,d7)
FFPPWR                   equ $00210D1A  ; d7=power(d6,d7)
FFPSIN                   equ $00210D5C  ; d7=sin(d7)
FFPCOS                   equ $00210D4A  ; d7=cos(d7)
FFPTAN                   equ $00210D44  ; d7=tan(d7)
FFPSINCS                 equ $00210D3E  ; d6,d7=sincos(d7)
FFPSINH                  equ $00210EDA  ; d7=sinh(d7)
FFPCOSH                  equ $00210EAC  ; d7=cosh(d7)
FFPTANH                  equ $00210F0C  ; d7=tanh(d7)
FFPSQRT                  equ $00210F5C  ; d7=sqrt(d7)
;
; Misc routines
;
;
random                   equ $002110B8  ; d7=sqrt(d7)
crc_buf                  equ $00211104  ; d7=sqrt(d7)
;
; Font definitions
;
;
text_font_def            equ $00211154  ; 5x8 font
;
; FLASH library routines
;
;
flash_wbytes             equ $00211554  ; 5x8 font
flash_chip_erase         equ $0021158E  ; 5x8 font
flash_erase              equ $002115CA  ; 5x8 font
flash_swid               equ $00211628  ; 5x8 font
;
; SD card library routines
;
;
SDParInit                equ $00211760  ; init parallel interface
SDParSetWrite            equ $0021177C  ; set for writing
SDParSetRead             equ $0021179E  ; set for reading
SDParWriteByte           equ $002117C0  ; write one byte
SDParReadByte            equ $002117F6  ; read one byte
SDGetClock               equ $00211A10  ; set the real-time clock
SDSetClock               equ $002119C8  ; get the real-time clock
SDDiskPing               equ $002118C2  ; exercises the interface
SDDiskOpenRead           equ $002118E6  ; open file for read
SDDiskOpenWrite          equ $002118DC  ; open file for write
SDDiskClose              equ $002119BE  ; close file
SDDiskRead               equ $0021191E  ; read from file
SDDiskWrite              equ $00211972  ; write to file
SDDiskDir                equ $00211882  ; start directory query
SDDiskDirNext            equ $00211890  ; get next directory entry
SDDiskReadSector         equ $00211824  ; read a sector TODO
SDDiskWriteSector        equ $00211826  ; write a sector TODO
SDDiskStatus             equ $00211828  ; get status TODO
SDDiskGetDrives          equ $0021182A  ; get the number of drives TODO
SDDiskGetMounted         equ $00211830  ; get the mounted drive TODO
SDDiskNextMountedDrv     equ $00211832  ; Get the next mounted drive TODO
SDDiskUnmount            equ $00211834  ; Unmount the file system TODO
SDDiskMount              equ $0021185A  ; Mount a file system TODO
;
; OLED-related library routines
;
;
oled_init                equ $00211A40  ; Initialise OLED display
oled_on                  equ $00211A62  ; Turn on display
oled_off                 equ $00211A6C  ; Turn off display
oled_set_col             equ $00211A76  ; Set column range
oled_set_row             equ $00211A96  ; Set row range
oled_spixel              equ $00211C40  ; Set pixel
oled_pixel               equ $00211C9E  ; Draw pixel
oled_sline               equ $00211AAC  ; Draw line (using oled_spixel)
oled_line                equ $00211AAE  ; Draw line
oled_fill                equ $00211D3A  ; Fill rows
oled_scircle             equ $00211D72  ; Set circle (using oled_spixel, TODO)
oled_circle              equ $00211D74  ; Draw circle
oled_schar               equ $00211EF2  ; Write a character TODO
oled_char                equ $00211EF4  ; Write a character
oled_sstr                equ $00211F58  ; Write a string TODO
oled_str                 equ $00211F5A  ; Write a string
;
; VDP Routines
;
;
; Low-level VDP functions
vdp_vram_raddr           equ $00211FB0  ; Write a string
vdp_vram_waddr           equ $00211FDE  ; Write a string
vdp_write_reg            equ $00212010  ; Write a string
vdp_read_stat            equ $00212026  ; Write a string
vdp_read_nstat           equ $0021202E  ; Write a string
vdp_read_vram            equ $0021203E  ; Write a string
vdp_write_vram           equ $00212046  ; Write a string
vdp_init_regs            equ $0021204E  ; Write a string
vdp_set_vram             equ $0021206A  ; Write a string
vdp_inc_vram             equ $00212076  ; Write a string
vdp_xfr_vram             equ $00212084  ; Write a string
vdp_clr_vram             equ $00212094  ; Write a string
vdp_wait                 equ $002120AE  ; Write a string
;
; VDP graphics functions
;
vdp_set_mode             equ $002120DC  ; Write a string
vdp_line                 equ $00212486  ; Write a string
vdp_circle               equ $00212352  ; TODO
vdp_pset                 equ $00212542  ; TODO
vdp_point                equ $0021259E  ; TODO
;
; VDP text functions
;
vdp_load_font            equ $00212610  ; TODO
vdp_text_mode            equ $00212652  ; TODO
;
; Test routines
;
;
FFPCALC                  equ $002126A4  ; Fast floating point calculator
;
;
;
;
