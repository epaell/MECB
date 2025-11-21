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
;
; Test routines
;
               org      $100380
;
               bra      FFPCALC              ; Fast floating point calculator
               ; TODO
;
;
;
               include  'mecb.inc'
               include  'tutor.inc'
               align    2
               include  'math.asm'
               align    2
               include  'random.asm'
               align    2
               include  'crc32.asm'
               align    2
               include  'text_font.asm'
               align    2
               include  'flash.asm'
               align    2
               include  'sdcard.asm'
               align    2
               include  'oled.asm
               align    2
               include  'vdp.asm'
               align    2
               include  'vdp_gfx.asm'
               align    2
               include  'vdp_text.asm'
               align    2
               include  'FFPCALC.X68'
               align    2
               include  'IOMECB.X68'
;
               end
