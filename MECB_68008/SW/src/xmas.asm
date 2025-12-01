;               org      $4000
;
;               include  'mecb.inc'
;               include  'tutor.inc'
;               include  'library_rom.inc'
;               include  'oled.inc'
;
BUFFER_SIZE    equ      255
TIMER_VAL      equ      $5000      ; timer 1 count setting
TIMER_SETH     equ      $01        ; Preset all timers a=$01, b=$42 CRX6=1 (interrupt); CRX1=1 (enable clock)
TIMER_SETL     equ      $42        ; Preset all timers a=$01, b=$42 CRX6=1 (interrupt); CRX1=1 (enable clock)
;
xmas           move.l   #RAM_END+1,a7              ; Set up stack
               jsr      oled_init
;
               move.b   #$00,d0                    ; d0 = fill value
               move.b   #$00,d1                    ; d1 = start row
               move.b   #$3f,d2                    ; d2 = end row
               jsr      oled_fill
               jsr      oled_on
               move.l   #image,a0
               jsr      oled_move
;
               move.l   #char_struct,a0            ; point to pixel data structure
               move.b   #$08,OLED_TX(a0)           ; x
               move.b   #$06,OLED_TY(a0)           ; y
               move.b   #$00,OLED_TFC(a0)          ; foreground colour
               move.b   #$0f,OLED_TBC(a0)          ; background colour
               move.b   #OLED_PAND,OLED_TL(a0)     ; Logical function
               move.l   #text_font_def,OLED_TF(a0) ; Font pointer
               move.l   #message1,a1               ; Point to string
               jsr      oled_str
;
               move.b   #$40,OLED_TX(a0)           ; x
               move.b   #$10,OLED_TY(a0)           ; y
               move.l   #message2,a1               ; Point to string
               jsr      oled_str
;
               move.b   #10,decay_count            ; Initialize decay count
               move.b   #0,psg_volume0             ; set all channels to off
               move.b   #0,psg_volume1
               move.b   #0,psg_volume2
               move.b   #0,psg_note0               ; reset note values
               move.b   #0,psg_note1
               move.b   #0,psg_note2
               move.l   #SoundByteTable,sound_ptr  ; point to sound table

               jsr      psg_init                   ; initialize the PSG
               bsr      init_isr                   ; Set up the ISRs
               bsr      ptm_init                   ; initialize the timer
               and.w    #$F8FF,sr                  ; enable interrupts
;
loop           cmp.b    #$FE,psg_note0             ; wait for last note
               bne      loop
               or.w     #$0700,sr                  ; disable interrupts
               jsr      psg_stop                   ; stop the audio
;
test_end       move.b   #TUTOR,d7                  ; return to monitor
               trap     #14
;
init_isr       move.l   #isr0,a6                   ; point all vectors to ISR
               move.l   a6,VEC_IRQ0
               move.l   #isr1,a6
               move.l   a6,VEC_IRQ1
               move.l   #isr2,a6
               move.l   a6,VEC_IRQ2
               move.l   #isr3,a6
               move.l   a6,VEC_IRQ3
               move.l   #isr4,a6
               move.l   a6,VEC_IRQ4
               move.l   #isr5,a6
               move.l   a6,VEC_IRQ5
               move.l   #isr6,a6
               move.l   a6,VEC_IRQ6
               move.l   #isr7,a6
               move.l   a6,VEC_IRQ7
               move.b   #$FF,irq_num
               rts
;
; Initialise the timer to provide the music beat
;
ptm_init:      move.w   #TIMER_VAL,d0
               move.w   d0,PTM1_T1MSB
               move.b   #TIMER_SETH,d0       ; Preset all timers : CRX6=1 (interrupt); CRX1=1 (enable clock)
               move.b   d0,PTM1_CR2          ; Write to CR2
               move.b   #TIMER_SETL,d0
               move.b   d0,PTM1_CR13 
               move.l   #0,d0
               move.b   d0,PTM1_CR2 
               move.b   PTM1_SR,d0           ; Read the interrupt flag from the status register
               move.b   #$40,d0
               move.b   d0,PTM1_CR13         ; enable interrupt and start timer
               rts 
;
; Record the ISR triggered (just for debugging)
;
isr0:          move.b   #0,irq_num
               bra      timer_isr
isr1:          move.b   #1,irq_num
               bra      timer_isr
isr2:          move.b   #2,irq_num
               bra      timer_isr
isr3:          move.b   #3,irq_num
               bra      timer_isr
isr4:          move.b   #4,irq_num
               bra      timer_isr
isr5:          move.b   #5,irq_num
               bra      timer_isr
isr6:          move.b   #6,irq_num
               bra      timer_isr
isr7:          move.b   #7,irq_num
               bra      timer_isr
;
; Function:	Play SoundByteTable notes for all 3 tone generators of the SN76489
; The function is called by the timer interrupt.
timer_isr      movem.l  d0-d2/a0-a2,-(a7) ; save registers
               move.b   PTM1_SR,d1        ; Read the interrupt flag from the status register
               move.w   PTM1_T1MSB,d1     ; clear timer interrupt flag
               move.b   PTM1_SR,d1        ; Read the interrupt flag from the status register
               move.w   PTM1_T2MSB,d1
               move.b   PTM1_SR,d1        ; Read the interrupt flag from the status register
               move.w   PTM1_T3MSB,d1

               move.l   #psg_volume0,a1   ; Initialise volume pointer for the 3 Tone Generators
               move.b   #0,d0             ; d0 = current tone generator
SoundGenLoop   move.b   (a1)+,d1          ; Check if the Tone Generator's volume is >0
               beq      NoNotePlayed      ; If Tone Generator's volume now 0 then note was silenced last time
               sub.b    #1,d1             ; Decrement the Tone Generator's volume to use
               move.b   d1,-1(a1)         ; Record the new volume
               jsr      psg_volume        ; Set the new volume in the PSG for channel d0, level d1
NoNotePlayed   add.b    #1,d0             ; next channel number
               cmp.b    #3,d0
               bne      SoundGenLoop      ; Loop back to process next channel if we're not done yet
HandleNewNotes sub.b    #1,decay_count    ; Decrement our Decay Count
               bne      isr_return        ; If volume still decaying then return from interrupt
;
; The following handles the reading of new notes to be played for each of the 3 sound channels
;
               move.b   #10,decay_count   ; Reset decay count
ReadNewNotes1  move.l   #psg_note0,a1     ; Initialise note pointer for the 3 channels
               move.b   #0,d0             ; d0 = current tone generator
               move.l   sound_ptr,a0      ; Point to current sound byte
ReadNewNotes   move.b   (a0)+,d1          ; Get the current note
               move.b   d1,(a1)           ; Store the note for the current channel
               cmp.b    #$fe,d1           ; #$FE marks the end of the SoundBytetable, so we loop back to the start
               beq      ReturnToStart
               cmp.b    #$ff,d1           ; #$FF marks no note to play (a pause), so no note gets played this time for this sound channel
               beq      PlayNoNote
               move.b   #$10,-3(a1)       ; Initialise full volume (+1) into channel variable for the sound channel's volume
               and.l    #$ff,d1
               lsl.l    #1,d1             ; Double the note byte value for an index into freq_table 16 bit words
               add.l    #freq_table,d1
               move.l   d1,a2             ; a contains pointer to note frequency
               move.w   (a2),d1           ; get the note frequency
               jsr      psg_tone          ; Set the frequency for the current channel
PlayNoNote     lea.l    1(a1),a1          ; point to next channel
               add.b    #1,d0             ; next channel number
               cmp.b    #3,d0             ; next tone generator
               bne      ReadNewNotes      ; Read more notes if we haven't processed all 3 Tone Generators yet
               move.l   a0,sound_ptr      ; Save the note pointer
;
isr_return     movem.l  (a7)+,d0-d2/a0-a2 ; restore registers
               rte
;
; Initilise Sound Byte Offset back to zero, if we want to start over again
ReturnToStart  move.l   #SoundByteTable,sound_ptr
;              bra      ReadNewNotes1     ; Finally, re-start the sound channel loop as we're starting again
;              ; OR,
               bra      isr_return        ; Instead just return, if we just want to stop!

;
; Structure for character drawing
;
char_struct    equ      $5000
irq_num        equ      $500c
sound_ptr      equ      $5010
decay_count    equ      $5014
psg_volume0    equ      $5015
psg_volume1    equ      $5016
psg_volume2    equ      $5017
psg_note0      equ      $5018
psg_note1      equ      $5019
psg_note2      equ      $501A

;char_struct    ds.b     1              ; x
;               ds.b     1              ; y
;               ds.b     1              ; foreground colour
;               ds.b     1              ; background colour
;               ds.b     1              ; logical function
;               ds.b     3              ; alignment
;               ds.l     1              ; font pointer
;
;irq_num        ds.b     1
;
               align    2
;
;sound_ptr      ds.l     1
;
;decay_count    ds.b     1
;psg_volume0    ds.b     1
;psg_volume1    ds.b     1
;psg_volume2    ds.b     1
;psg_note0      ds.b     1
;psg_note1      ds.b     1
;psg_note2      ds.b     1
;
message1       dc.b     "Merry X-mas",0
message2       dc.b     "Greg",0
               align       2
;
; The sound generator is clocked at 1.2 MHz with the 68008, these are the counter values for a given note/frequency
freq_table     dc.w    $023D   ; C2 = 65.41
               dc.w    $021D   ; c2 = 69.30
               dc.w    $01FE   ; D2 = 73.42
               dc.w    $01E2   ; d2 = 77.78
               dc.w    $01C7   ; E2 = 82.41
               dc.w    $01AD   ; F2 = 87.31
               dc.w    $0195   ; f2 = 92.50
               dc.w    $017E   ; G2 = 98.00
               dc.w    $0169   ; g2 = 103.83
               dc.w    $0154   ; A2 = 110.00
               dc.w    $0141   ; a2 = 116.54
               dc.w    $012F   ; B2 = 123.47
               dc.w    $011E   ; C3 = 130.81
               dc.w    $010E   ; c3 = 138.59
               dc.w    $00FF   ; D3 = 146.83
               dc.w    $00F1   ; d3 = 155.56
               dc.w    $00E3   ; E3 = 164.81
               dc.w    $00D6   ; F3 = 174.61
               dc.w    $00CA   ; f3 = 185.00
               dc.w    $00BF   ; G3 = 196.00
               dc.w    $00B4   ; g3 = 207.65
               dc.w    $00AA   ; A3 = 220.00
               dc.w    $00A0   ; a3 = 233.08
               dc.w    $0097   ; B3 = 246.94
               dc.w    $008F   ; C4 = 261.63
               dc.w    $0087   ; c4 = 277.18
               dc.w    $007F   ; D4 = 293.66
               dc.w    $0078   ; d4 = 311.13
               dc.w    $0071   ; E4 = 329.63
               dc.w    $006B   ; F4 = 349.23
               dc.w    $0065   ; f4 = 369.99
               dc.w    $005F   ; G4 = 392.00
               dc.w    $005A   ; g4 = 415.30
               dc.w    $0055   ; A4 = 440.00
               dc.w    $0050   ; a4 = 466.16
               dc.w    $004B   ; B4 = 493.88
;
;
; What follow is Kurt Woloch's original notes:
; Here we store the melody data; 255 means pause, 254 means back to start; all other are indexes into the frequency table
; This means that a byte value of 0 plays about the lowest possible "C" note (actually, 18 cents below that, which is 64,73 Hz).
; A value of 12 plays the "C" one octave above it and so on... the highest possible note is a A#2 (described as H2 in the table above)      
; since I've encoded 36 note steps. I've often given the notes as "5+12+x" or something like that to somehow simulate the octaves and notes in that.
; Yes, I know, I could also have defined constants like "C#1" for the note values, but I didn't feel like that.
; I've added 5 at the start because the lowest note played is a G (relative to the main key of the melody, which in this case is actually F major,
; so that that note is acually a "C". Yes, I know it's confusing, but this is how I perceive and memorize music).
; Each line holds the an 1/8 note played on all three sound generators, each group of 8 lines thus is a measure. 
; The spaces of two lines denote the boundaries of different "parts" of the melody.
; Table of Sound Byte Indexes into the Frequency Table for each of the 3 SN76489 Tone Generators
SoundByteTable
               dc.b     0, 12+7, 12+4     ;Ru-
               dc.b     255, 12+9, 12+4   ;dolph,
               dc.b     7, 255, 255
               dc.b     255, 12+7, 12+4   ;the
               dc.b     4, 12+4, 12       ;red-
               dc.b     255, 255, 255
               dc.b     7, 12+12, 12+4    ;nosed
               dc.b     255, 255, 255

               dc.b     0, 12+9, 12+4     ;rain-
               dc.b     255, 255, 255
               dc.b     7, 12+7, 12+4     ;deer
               dc.b     255, 255, 255
               dc.b     4, 255, 255
               dc.b     255, 255, 255
               dc.b     7, 255, 255
               dc.b     255, 255, 255

               dc.b     0, 12+7, 12+4     ;had
               dc.b     255, 12+9, 12+5   ;a
               dc.b     7, 12+7, 12+4     ;ve-
               dc.b     255, 12+9, 12+5   ;ry
               dc.b     4, 12+7, 12+4     ;shi-
               dc.b     255, 255, 255
               dc.b     3, 12+12, 12+9    ;ny
               dc.b     255, 255, 255

               dc.b     2, 12+7, 12+11    ;nose
               dc.b     255, 255, 255
               dc.b     7, 255, 255
               dc.b     255, 255, 255
               dc.b     5, 255, 255
               dc.b     255, 255, 255
               dc.b     2, 255, 255
               dc.b     255, 255, 255

               dc.b     7, 12+5, 12+2     ;and 
               dc.b     255, 12+7, 12+2   ;if
               dc.b     11, 255, 255
               dc.b     255, 12+5, 12+2   ;you
               dc.b     2, 12+2, 12-1     ;e-
               dc.b     255, 255, 255
               dc.b     5, 12+11, 12+7    ;ver
               dc.b     255, 255, 255

               dc.b     7, 12+9, 12+2     ;saw
               dc.b     255, 255, 255
               dc.b     11, 12+7, 12+2    ;it,
               dc.b     255, 255, 255
               dc.b     2, 255, 255
               dc.b     255, 255, 255
               dc.b     5, 255, 255
               dc.b     255, 255, 255

               dc.b     7, 12+7, 12+5     ;you
               dc.b     255, 12+9, 12+5   ;would
               dc.b     5, 12+7, 12+5     ;e-
               dc.b     255, 12+9, 12+5   ;ven
               dc.b     4, 12+7, 12+5     ;say
               dc.b     255, 255, 255
               dc.b     2, 12+9, 12+5     ;it
               dc.b     255, 255, 255

               dc.b     0, 12+4, 12       ;glo-
               dc.b     255, 255, 255
               dc.b     11, 12+7, 12+4    ;ws.
               dc.b     11, 255, 255
               dc.b     9, 255, 255
               dc.b     9, 255, 255
               dc.b     7, 255, 255
               dc.b     7, 255, 255


               dc.b     0, 12+7, 12+4     ;All
               dc.b     255, 12+9, 12+4   ;of
               dc.b     7, 255, 255
               dc.b     255, 12+7, 12+4   ;the
               dc.b     4, 12+4, 12       ;ot-
               dc.b     255, 255, 255
               dc.b     7, 12+12, 12+4    ;her
               dc.b     255, 255, 255

               dc.b     0, 12+9, 12+4     ;rain-
               dc.b     255, 255, 255
               dc.b     7, 12+7, 12+4     ;deer
               dc.b     255, 255, 255
               dc.b     4, 12+12+9, 12+12+4
               dc.b     255, 255, 255
               dc.b     7, 12+12+7, 12+12+4
               dc.b     255, 255, 255

               dc.b     0, 12+7, 12+4     ;used
               dc.b     255, 12+9, 12+5   ;to
               dc.b     7, 12+7, 12+4     ;laugh
               dc.b     255, 12+9, 12+5   ;and
               dc.b     4, 12+7, 12+4     ;call
               dc.b     255, 255, 255 
               dc.b     3, 12+12, 12+9    ;him
               dc.b     255, 255, 255

               dc.b     2, 12+11, 12+2    ;names
               dc.b     255, 255, 255
               dc.b     7, 255, 12+2
               dc.b     255, 255, 12+4
               dc.b     5, 255, 12+5
               dc.b     255, 255, 255
               dc.b     2, 255, 255
               dc.b     255, 255, 255

               dc.b     7, 12+5, 12+2     ;they
               dc.b     255, 12+7, 12+2   ;ne-
               dc.b     11, 255, 255
               dc.b     255, 12+5, 12+2   ;ver
               dc.b     2, 12+2, 12-1     ;let
               dc.b     255, 255, 255
               dc.b     5, 12+11, 12+7    ;poor
               dc.b     255, 255, 255

               dc.b     7, 12+9, 12+4     ;Ru-
               dc.b     255, 255, 255
               dc.b     11, 12+7, 12+2    ;dolph
               dc.b     255, 255, 255
               dc.b     2, 12+12+9, 12+12+5
               dc.b     255, 255, 255
               dc.b     5, 12+12+7, 12+12+2
               dc.b     255, 255, 255

               dc.b     7, 12+7, 12+5     ;join
               dc.b     255, 12+9, 12+5   ;in
               dc.b     5, 12+7, 12+5     ;a-
               dc.b     255, 12+9, 12+5   ;ny
               dc.b     4, 12+7, 12+5     ;rain
               dc.b     255, 255, 255
               dc.b     2, 12+12+2, 12+7  ;deer
               dc.b     255, 255, 255

               dc.b     0, 12+12, 12+4    ;games
               dc.b     12, 255, 12+4
               dc.b     10, 255, 12+2
               dc.b     255, 255, 255
               dc.b     9, 255, 12
               dc.b     255, 255, 255
               dc.b     7, 255, 10
               dc.b     255, 255, 255


               dc.b     5, 12+9, 12+5     ;Then
               dc.b     255, 255, 255
               dc.b     9, 12+9, 12+5     ;one
               dc.b     255, 255, 255
               dc.b     0, 12+12, 12+9    ;fog-
               dc.b     255, 255, 255
               dc.b     9, 12+12, 12+9    ;gy
               dc.b     255, 255, 255

               dc.b     0, 12+7, 12+4     ;Christ-
               dc.b     255, 255, 255
               dc.b     7, 12+4, 12+0     ;mas
               dc.b     255, 255, 255
               dc.b     4, 12+7, 12+4     ;eve,
               dc.b     255, 255, 255
               dc.b     3, 255, 255
               dc.b     255, 255, 255

               dc.b     2, 12+5, 12+2     ;San-
               dc.b     255, 255, 255
               dc.b     7, 12+9, 12+5     ;ta
               dc.b     255, 255, 255
               dc.b     5, 12+7, 12+4     ;came
               dc.b     255, 255, 255
               dc.b     7, 12+5, 12+2     ;to
               dc.b     255, 255, 255

               dc.b     0, 12+4, 12       ;say
               dc.b     255, 255, 255
               dc.b     12, 255, 12+4
               dc.b     12, 255, 12+4
               dc.b     11, 255, 12+2
               dc.b     11, 255, 12+2
               dc.b     9, 255, 12
               dc.b     9, 255, 12

               dc.b     2, 12+2, 11       ;Ru-
               dc.b     255, 255, 255
               dc.b     11, 12+2, 11      ;dolph
               dc.b     255, 255, 255
               dc.b     2, 12+7, 12+2     ;with
               dc.b     255, 255, 255
               dc.b     6, 12+9, 12+6     ;your
               dc.b     255, 255, 255

               dc.b     7, 12+11, 12+7    ;nose
               dc.b     255, 255, 255
               dc.b     2, 12+11, 12+7    ;so 
               dc.b     255, 255, 255
               dc.b     7, 12+11, 12+7    ;bright,
               dc.b     255, 255, 255
               dc.b     8, 255, 255
               dc.b     255, 255, 255

               dc.b     9, 12+12, 12+9    ;won't
               dc.b     255, 255, 255
               dc.b     9, 12+12, 12+9    ;you
               dc.b     255, 255, 255
               dc.b     2, 12+11, 12+6    ;guide
               dc.b     255, 255, 255
               dc.b     2, 12+9, 12+6     ;my
               dc.b     255, 255, 255

               dc.b     7, 12+7, 12+2     ;sleigh
               dc.b     7, 255, 255
               dc.b     5, 12+5, 12+2     ;to-
               dc.b     255, 255, 255
               dc.b     4, 12+2, 11       ;night?
               dc.b     255, 255, 255
               dc.b     2, 255, 255
               dc.b     255, 255, 255

               dc.b     0, 12+7, 12+4     ;Then
               dc.b     255, 12+9, 12+4   ;how
               dc.b     7, 255, 255
               dc.b     255, 12+7, 12+4   ;the
               dc.b     4, 12+4, 12       ;child-
               dc.b     255, 255, 255
               dc.b     7, 12+12, 12+4    ;ren
               dc.b     255, 255, 255

               dc.b     0, 12+9, 12+4     ;loved
               dc.b     255, 255, 255
               dc.b     7, 12+7, 12+4     ;him
               dc.b     255, 255, 255
               dc.b     4, 12+12+9, 12+12+4
               dc.b     255, 255, 255
               dc.b     7, 12+12+7, 12+12+4
               dc.b     255, 255, 255

               dc.b     0, 12+7, 12+4     ;as
               dc.b     255, 12+9, 12+5   ;they
               dc.b     7, 12+7, 12+4     ;shou-
               dc.b     255, 12+9, 12+5   ;ted
               dc.b     4, 12+7, 12+4     ;out
               dc.b     255, 255, 255
               dc.b     3, 12+12, 12+9    ;with
               dc.b     255, 255, 255

               dc.b     2, 12+11, 12+2    ;glee
               dc.b     255, 255, 255
               dc.b     7, 12+11, 12+2
               dc.b     255, 12+12, 12+4
               dc.b     5, 12+14, 12+5
               dc.b     255, 255, 255
               dc.b     2, 255, 255
               dc.b     255, 255, 255

               dc.b     7, 12+5, 12+2     ;Ru-
               dc.b     255, 12+7, 12+2   ;dolph,
               dc.b     11, 255, 255
               dc.b     255, 12+5, 12+2   ;the
               dc.b     2, 12+2, 12-1     ;red-
               dc.b     255, 255, 255
               dc.b     5, 12+11, 12+7    ;nosed
               dc.b     255, 255, 255

               dc.b     7, 12+9, 12+4     ;rain-
               dc.b     255, 255, 255
               dc.b     11, 12+7, 12+2    ;deer,
               dc.b     255, 255, 255
               dc.b     2, 12+12+9, 12+12+5
               dc.b     255, 255, 255
               dc.b     5, 12+12+7, 12+12+2
               dc.b     255, 255, 255

               dc.b     7, 12+7, 12+5     ;you'll
               dc.b     255, 12+9, 12+5   ;go
               dc.b     5, 12+7, 12+5     ;down
               dc.b     255, 12+9, 12+5   ;in
               dc.b     4, 12+7, 12+5     ;his-
               dc.b     255, 255, 255
               dc.b     2, 12+12+2, 12+7  ;to-
               dc.b     255, 255, 255

               dc.b     0, 12+12, 12+4    ;ry.
               dc.b     12, 255, 12+4
               dc.b     7, 12+12+7, 12+12+2
               dc.b     255, 255, 255
               dc.b     12, 12+12+7, 12+12+4
               dc.b     7, 255, 255
               dc.b     4, 255, 255
               dc.b     2, 255, 255

               dc.b     254               ; The End
;
image          dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$EF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$EE,$EE,$DD,$DF
               dc.b     $FF,$FF,$FF,$DE,$CE,$DD,$EF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$BC,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$ED,$CC,$CC,$CC,$CC,$CC,$CD
               dc.b     $FF,$FF,$FF,$FF,$EF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$AC,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$EF,$FF,$FF,$FE,$DE,$EE
               dc.b     $EE,$DD,$DC,$DC,$BB,$BC,$CE,$DD
               dc.b     $FF,$FF,$FF,$FF,$EF,$FF,$FF,$C9
               dc.b     $EF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$EC,$EF,$EC
               dc.b     $CA,$6A,$CC,$BA,$CB,$CC,$CE,$FE
               dc.b     $FF,$FF,$EF,$ED,$BF,$FE,$EF,$DC
               dc.b     $EF,$FF,$EF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FE,$DE,$EE,$DD
               dc.b     $DE,$FF,$EE,$ED,$BB,$FB,$9E,$EF
               dc.b     $FF,$FF,$AD,$FD,$CE,$FF,$DF,$EF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$ED,$EE,$FF,$E9
               dc.b     $8F,$FF,$FF,$FE,$CD,$DD,$DC,$CD
               dc.b     $FF,$FF,$FF,$DD,$CC,$EC,$BE,$EF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$EF,$EF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$EF,$FF,$FF,$FF,$FF,$FE
               dc.b     $FF,$FF,$FF,$FE,$DD,$DE,$FD,$75
               dc.b     $AA,$DD,$ED,$DC,$9B,$CC,$CC,$BC
               dc.b     $FF,$FF,$FC,$AC,$BD,$DF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$F9,$DF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FB,$BF,$FF,$FF,$FF,$FF,$FE
               dc.b     $EF,$FF,$EB,$BD,$FF,$FF,$FD,$A4
               dc.b     $8B,$EE,$DD,$CC,$99,$AB,$BC,$CC
               dc.b     $FF,$FF,$EB,$BC,$DF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$C7,$BD,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$D5,$7D,$FF,$DD,$FF,$FF,$FF
               dc.b     $FF,$FF,$EC,$DE,$FF,$FC,$96,$57
               dc.b     $77,$CB,$DE,$DD,$B9,$BB,$BB,$CE
               dc.b     $FF,$FD,$AD,$EF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FE,$97,$89,$BF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FA
               dc.b     $CA,$65,$49,$BB,$6B,$FF,$FF,$FF
               dc.b     $FF,$FF,$BC,$EF,$FF,$C5,$77,$56
               dc.b     $BA,$7A,$EE,$FD,$CB,$BB,$CC,$DF
               dc.b     $FF,$DC,$CF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$DC,$D9,$B9,$77,$77,$79
               dc.b     $CE,$EF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$EC,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $F7,$55,$89,$AE,$FF,$FF,$FF,$FF
               dc.b     $FF,$FE,$DE,$FF,$D7,$54,$54,$56
               dc.b     $AD,$D5,$CC,$FF,$DC,$BB,$CC,$CD
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$EE,$BA,$99,$87,$78,$87
               dc.b     $9B,$CE,$FF,$FF,$FF,$CF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$C7,$EF,$FF,$FF
               dc.b     $DE,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $C6,$BB,$87,$AF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$EF,$FE,$B2,$33,$25,$89
               dc.b     $BD,$D4,$87,$EE,$FE,$CD,$CD,$DD
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$D9,$66,$79,$CE
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$D8,$9E,$FD,$A7
               dc.b     $9F,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $CE,$FF,$FC,$8F,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$EF,$FF,$FB,$29,$43,$CA
               dc.b     $8A,$86,$3D,$FC,$EE,$EE,$DD,$ED
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FD,$97,$8B,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$85,$67,$A9,$8B
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FD,$2B,$94,$BA
               dc.b     $AC,$85,$9F,$FF,$DD,$DD,$DE,$DD
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$D6,$68,$64,$CE
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$D9,$56,$67,$99,$BF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$F9,$3F,$C6,$BB
               dc.b     $AC,$64,$CF,$FF,$FF,$FF,$FF,$FE
               dc.b     $FF,$FF,$FF,$EC,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FB,$EF,$B2,$5B,$41,$5C
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FE,$98,$68,$76,$76,$99,$9F
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$ED,$7D,$FA,$DB
               dc.b     $ED,$B7,$CE,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$EE,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$A5,$32,$22,$6E
               dc.b     $FF,$FF,$F8,$DF,$FF,$FF,$FF,$FF
               dc.b     $FF,$E9,$98,$BC,$66,$77,$78,$89
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$EE
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FE,$67,$A8,$EA
               dc.b     $E6,$CA,$CF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$EE,$FF
               dc.b     $FF,$FF,$FE,$F9,$76,$42,$23,$57
               dc.b     $9F,$FF,$EA,$EF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$75,$9D,$BC,$B8
               dc.b     $DF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$D2,$11,$6E
               dc.b     $DA,$CE,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FD,$7C,$FF
               dc.b     $FF,$FF,$C4,$58,$53,$33,$43,$59
               dc.b     $8E,$FF,$F7,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$EF,$FF,$FE,$8A,$EF,$FF,$EC
               dc.b     $AE,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FC,$42,$5C
               dc.b     $CF,$FF,$FF,$FE,$8E,$FF,$FF,$FF
               dc.b     $FF,$FF,$FE,$AE,$FF,$FF,$8C,$FF
               dc.b     $FF,$FC,$51,$12,$64,$76,$44,$38
               dc.b     $54,$BF,$C6,$FF,$FF,$FF,$FF,$FF
               dc.b     $FE,$DF,$FF,$FD,$BF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$61,$38
               dc.b     $FF,$FF,$FF,$FE,$BF,$FF,$FF,$FF
               dc.b     $FD,$ED,$EE,$FF,$FF,$FF,$6B,$FF
               dc.b     $FF,$C2,$12,$01,$21,$31,$11,$11
               dc.b     $11,$16,$75,$DF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$EE,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FE,$81,$58
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$EE,$DF,$FF,$FF,$FE,$67,$FD
               dc.b     $DF,$FB,$99,$41,$11,$13,$76,$51
               dc.b     $11,$11,$28,$FF,$EB,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$EF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$B5,$79
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FE,$DD,$EF,$FF,$FD,$AA,$47,$85
               dc.b     $87,$9C,$75,$31,$12,$12,$45,$42
               dc.b     $23,$42,$6A,$94,$26,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$BE,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$F7,$9F
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$EE,$FF,$FF,$E6,$23,$33,$45
               dc.b     $44,$64,$34,$20,$13,$12,$22,$22
               dc.b     $23,$45,$33,$15,$4A,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FA,$7F
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FE
               dc.b     $FF,$DE,$FF,$FF,$A2,$22,$22,$33
               dc.b     $46,$56,$53,$33,$66,$51,$33,$34
               dc.b     $43,$45,$52,$37,$8B,$FF,$DC,$EF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $EF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$DC,$CD,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$C8,$9F
               dc.b     $FE,$FF,$FF,$FF,$FF,$FF,$FF,$FE
               dc.b     $FF,$FF,$FF,$FC,$22,$12,$12,$12
               dc.b     $25,$45,$A5,$7A,$B5,$57,$87,$43
               dc.b     $36,$85,$45,$66,$87,$B9,$37,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FE
               dc.b     $DE,$FF,$FF,$FF,$FF,$FF,$FE,$B9
               dc.b     $64,$23,$22,$22,$6A,$EF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$CB,$BF
               dc.b     $FE,$FF,$FF,$FF,$FF,$FF,$FF,$EE
               dc.b     $FF,$FF,$FF,$FE,$C6,$25,$98,$84
               dc.b     $35,$66,$65,$76,$53,$34,$66,$23
               dc.b     $55,$56,$65,$66,$99,$A7,$25,$BF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$DD,$CC
               dc.b     $EF,$FF,$FF,$FF,$FF,$BD,$61,$00
               dc.b     $00,$11,$12,$22,$22,$3A,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$CB,$AF
               dc.b     $FE,$FF,$FF,$FF,$FF,$FF,$FF,$FE
               dc.b     $FF,$FF,$FF,$FF,$FE,$AE,$FF,$C2
               dc.b     $44,$66,$65,$43,$45,$67,$52,$33
               dc.b     $44,$22,$69,$BD,$9A,$A5,$46,$7F
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$CC,$DE
               dc.b     $EF,$FF,$FF,$FF,$FA,$EF,$B2,$01
               dc.b     $11,$12,$22,$22,$22,$12,$9F,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$EC,$9F
               dc.b     $FF,$FE,$FF,$FC,$DD,$FF,$FF,$FF
               dc.b     $FF,$DF,$FF,$FF,$FF,$FF,$FF,$DB
               dc.b     $DA,$32,$54,$35,$33,$44,$23,$33
               dc.b     $46,$31,$8C,$56,$67,$D7,$46,$AD
               dc.b     $FF,$FF,$FF,$FF,$FF,$ED,$CE,$FE
               dc.b     $EF,$FF,$FF,$EE,$B5,$8D,$FC,$41
               dc.b     $12,$22,$22,$22,$21,$11,$38,$FE
               dc.b     $DF,$FF,$FF,$FF,$FF,$FF,$9B,$BF
               dc.b     $FF,$FE,$FF,$FB,$FF,$FF,$FF,$FF
               dc.b     $FF,$DF,$FF,$FF,$FF,$FF,$F8,$7A
               dc.b     $8A,$21,$22,$24,$52,$11,$12,$14
               dc.b     $86,$84,$21,$11,$03,$31,$12,$58
               dc.b     $6F,$FF,$EF,$FF,$FF,$DD,$DF,$FF
               dc.b     $FF,$FF,$C9,$53,$56,$63,$8F,$F8
               dc.b     $22,$33,$32,$22,$23,$44,$35,$56
               dc.b     $DF,$FF,$FF,$FF,$FF,$FF,$EE,$CF
               dc.b     $FF,$EE,$EE,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$F7,$DF,$FF,$51,$11
               dc.b     $01,$23,$21,$11,$21,$13,$32,$12
               dc.b     $66,$76,$41,$11,$10,$00,$22,$11
               dc.b     $6E,$FF,$DD,$FF,$FF,$FF,$EF,$FE
               dc.b     $FE,$FC,$CF,$D6,$23,$59,$4F,$FF
               dc.b     $53,$33,$33,$21,$5E,$FF,$B4,$27
               dc.b     $DF,$FF,$FF,$FF,$FF,$FF,$AC,$AF
               dc.b     $FF,$ED,$DE,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$F7,$EF,$FF,$52,$11
               dc.b     $4A,$CF,$B6,$31,$23,$23,$43,$23
               dc.b     $33,$11,$12,$21,$11,$00,$11,$27
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $EF,$EE,$FF,$FE,$53,$45,$8C,$FF
               dc.b     $FA,$53,$32,$26,$FF,$FF,$63,$BF
               dc.b     $FF,$FF,$FD,$FF,$FF,$FF,$6B,$9F
               dc.b     $FE,$EE,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$F3,$BE,$FA,$66,$46
               dc.b     $48,$CD,$FD,$32,$46,$11,$33,$24
               dc.b     $68,$62,$11,$11,$5D,$A4,$2B,$EF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $CF,$AE,$FF,$FF,$75,$55,$66,$AF
               dc.b     $FE,$D8,$11,$AF,$FE,$DF,$95,$5E
               dc.b     $FF,$FF,$DF,$FF,$FF,$FF,$AD,$9F
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FE,$94,$55,$75,$45,$68
               dc.b     $CA,$BD,$CE,$DC,$78,$46,$A9,$AB
               dc.b     $AA,$88,$88,$55,$8D,$CE,$DF,$FF
               dc.b     $FF,$FB,$FF,$FF,$FF,$FF,$EF,$FF
               dc.b     $D9,$36,$FF,$FF,$55,$54,$66,$68
               dc.b     $CF,$F7,$57,$FF,$ED,$DF,$FA,$8C
               dc.b     $DF,$FF,$FF,$FF,$FF,$FF,$AD,$BF
               dc.b     $FE,$EF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FD,$77,$55,$56,$57,$9A
               dc.b     $CA,$A6,$23,$CC,$67,$86,$AA,$BC
               dc.b     $C9,$A8,$CB,$CB,$BC,$8A,$FF,$FF
               dc.b     $FE,$8A,$FF,$FF,$FF,$FE,$EF,$FF
               dc.b     $CD,$BD,$FF,$FC,$79,$AA,$46,$56
               dc.b     $7E,$F8,$9A,$FF,$ED,$EF,$FF,$EE
               dc.b     $BD,$FF,$FF,$FF,$FF,$FF,$9D,$FF
               dc.b     $FE,$EF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FA,$46,$66,$64,$89,$97
               dc.b     $79,$60,$23,$45,$49,$A7,$6B,$DD
               dc.b     $D9,$9C,$98,$88,$AA,$AA,$B8,$6F
               dc.b     $FF,$8D,$FF,$FF,$FF,$FF,$DE,$FF
               dc.b     $DF,$DF,$FF,$F6,$56,$55,$44,$65
               dc.b     $5B,$FE,$FF,$FF,$ED,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FE,$CB,$FF
               dc.b     $FE,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$DA,$AD,$A4,$67,$76
               dc.b     $89,$61,$12,$11,$24,$42,$13,$95
               dc.b     $A4,$6A,$AA,$BD,$95,$64,$75,$6A
               dc.b     $DB,$6D,$FF,$FF,$FF,$FF,$ED,$DF
               dc.b     $DE,$CC,$FE,$82,$55,$45,$55,$65
               dc.b     $46,$DF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FE,$BB,$DF
               dc.b     $FE,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FA,$78,$87
               dc.b     $67,$62,$22,$22,$46,$43,$53,$53
               dc.b     $32,$43,$23,$33,$34,$23,$55,$43
               dc.b     $67,$3F,$FF,$FF,$FF,$DE,$FE,$CC
               dc.b     $FD,$D8,$64,$24,$44,$55,$54,$43
               dc.b     $3A,$FF,$FF,$FF,$FF,$FF,$FF,$DC
               dc.b     $EF,$FF,$FF,$FF,$FF,$FE,$AC,$AE
               dc.b     $FF,$FF,$FF,$FF,$FF,$ED,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FC,$67,$59,$58
               dc.b     $78,$84,$44,$35,$33,$46,$B5,$11
               dc.b     $11,$11,$22,$22,$33,$43,$34,$55
               dc.b     $89,$4C,$FF,$BD,$FF,$EC,$DE,$DD
               dc.b     $EE,$FC,$64,$34,$43,$55,$54,$57
               dc.b     $DF,$FF,$FD,$99,$9D,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$BD,$AF
               dc.b     $FF,$FF,$FF,$FF,$FF,$BE,$FF,$EA
               dc.b     $FF,$FF,$FF,$FF,$FC,$44,$43,$44
               dc.b     $66,$42,$54,$43,$23,$34,$51,$22
               dc.b     $02,$21,$12,$22,$33,$23,$65,$66
               dc.b     $7A,$CF,$FF,$BC,$FF,$ED,$DE,$EE
               dc.b     $EE,$EE,$DA,$44,$45,$55,$69,$EF
               dc.b     $FF,$DA,$53,$13,$65,$49,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FE,$8C,$AE
               dc.b     $FF,$FF,$FD,$FF,$FF,$FF,$FF,$FE
               dc.b     $6C,$FF,$F9,$FF,$E6,$34,$44,$44
               dc.b     $74,$55,$74,$33,$33,$46,$43,$11
               dc.b     $15,$22,$23,$33,$33,$32,$36,$86
               dc.b     $65,$6A,$FD,$AD,$FF,$FE,$CD,$DD
               dc.b     $EE,$FF,$FF,$55,$66,$66,$CF,$FF
               dc.b     $FC,$41,$58,$8B,$CB,$54,$7F,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FD,$6A,$8F
               dc.b     $FB,$EF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $73,$69,$B5,$67,$23,$12,$23,$65
               dc.b     $99,$78,$76,$54,$33,$34,$53,$23
               dc.b     $30,$22,$27,$78,$63,$33,$48,$86
               dc.b     $55,$69,$B8,$59,$FF,$FF,$CC,$DD
               dc.b     $EE,$DD,$FF,$54,$66,$AF,$FF,$FF
               dc.b     $C3,$24,$AC,$BC,$AA,$A5,$29,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FE,$BC,$6E
               dc.b     $BF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $B1,$38,$78,$77,$21,$10,$11,$35
               dc.b     $88,$36,$46,$98,$31,$24,$74,$36
               dc.b     $74,$52,$23,$55,$43,$43,$34,$35
               dc.b     $57,$68,$65,$39,$FF,$FF,$FD,$DE
               dc.b     $EF,$FF,$FB,$55,$79,$EF,$FF,$FB
               dc.b     $52,$3A,$BA,$AA,$BB,$B7,$47,$AF
               dc.b     $FF,$FF,$FF,$FF,$FE,$DF,$CB,$5D
               dc.b     $DF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $E6,$11,$17,$35,$30,$00,$11,$36
               dc.b     $54,$09,$83,$66,$23,$45,$7A,$7A
               dc.b     $A6,$52,$22,$22,$36,$66,$54,$55
               dc.b     $64,$46,$47,$8A,$FF,$FF,$FD,$DE
               dc.b     $DD,$FF,$F9,$47,$8F,$FF,$FF,$C3
               dc.b     $23,$6A,$BC,$CC,$BC,$C6,$55,$67
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$EB,$3E
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $F9,$30,$11,$10,$01,$01,$11,$22
               dc.b     $01,$26,$33,$57,$7B,$A9,$88,$75
               dc.b     $44,$43,$11,$21,$41,$12,$11,$12
               dc.b     $11,$12,$21,$25,$BA,$8F,$FC,$DF
               dc.b     $ED,$FF,$F9,$88,$CF,$FF,$FE,$32
               dc.b     $23,$22,$44,$44,$54,$55,$44,$44
               dc.b     $7F,$FF,$FF,$FF,$FF,$FF,$FD,$8B
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FB,$84,$11,$00,$11,$33,$45
               dc.b     $62,$48,$56,$DB,$DE,$DC,$44,$44
               dc.b     $44,$55,$77,$11,$00,$00,$13,$10
               dc.b     $11,$12,$22,$42,$5A,$AE,$EC,$DE
               dc.b     $EF,$EE,$B6,$7B,$FF,$FF,$D3,$22
               dc.b     $33,$22,$22,$22,$33,$23,$33,$34
               dc.b     $47,$FF,$FF,$FF,$FF,$FE,$9B,$89
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$E9,$21,$11,$11,$10,$55,$55
               dc.b     $C7,$9C,$BA,$EC,$94,$58,$57,$43
               dc.b     $25,$55,$64,$10,$00,$00,$11,$12
               dc.b     $43,$32,$22,$21,$37,$9E,$ED,$DE
               dc.b     $EF,$FF,$54,$4D,$FF,$FA,$32,$24
               dc.b     $89,$86,$33,$33,$33,$89,$A8,$45
               dc.b     $53,$6C,$FF,$FF,$FF,$FE,$79,$8A
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FA,$20,$01,$11,$10,$12,$12,$61
               dc.b     $23,$43,$35,$43,$22,$21,$36,$41
               dc.b     $01,$25,$31,$01,$41,$11,$11,$11
               dc.b     $31,$21,$32,$21,$69,$9E,$ED,$CE
               dc.b     $EE,$FA,$44,$6F,$FD,$61,$14,$88
               dc.b     $77,$9A,$54,$35,$99,$7A,$BB,$84
               dc.b     $43,$13,$BF,$FF,$FF,$FB,$DE,$58
               dc.b     $EF,$FF,$FF,$FF,$FF,$FF,$EF,$FF
               dc.b     $FF,$C8,$21,$11,$10,$12,$22,$11
               dc.b     $22,$21,$12,$12,$33,$32,$11,$21
               dc.b     $21,$00,$00,$01,$31,$11,$12,$11
               dc.b     $12,$31,$22,$21,$4B,$AE,$FF,$ED
               dc.b     $FF,$F9,$35,$79,$73,$11,$27,$89
               dc.b     $87,$99,$44,$34,$44,$34,$47,$74
               dc.b     $46,$53,$37,$DF,$FF,$F9,$CF,$59
               dc.b     $AF,$FF,$FF,$FF,$FF,$FF,$BF,$FF
               dc.b     $FF,$E9,$74,$63,$22,$22,$11,$21
               dc.b     $11,$12,$23,$12,$11,$11,$02,$33
               dc.b     $32,$10,$00,$11,$22,$11,$02,$22
               dc.b     $22,$11,$11,$11,$14,$79,$AE,$FE
               dc.b     $FF,$F6,$36,$B8,$12,$24,$67,$77
               dc.b     $88,$98,$63,$34,$44,$44,$56,$79
               dc.b     $75,$57,$76,$8C,$FE,$75,$9E,$CA
               dc.b     $8F,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FB,$73,$25,$64,$20,$11,$22
               dc.b     $12,$11,$00,$00,$00,$00,$23,$33
               dc.b     $32,$11,$01,$21,$02,$21,$12,$22
               dc.b     $12,$21,$21,$12,$33,$32,$37,$FF
               dc.b     $FF,$FA,$23,$84,$22,$69,$88,$99
               dc.b     $89,$8A,$74,$26,$55,$78,$BC,$AC
               dc.b     $A6,$79,$B7,$8A,$9B,$DF,$FF,$FD
               dc.b     $9D,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$DA,$6D,$D9,$54,$46,$31
               dc.b     $11,$01,$10,$00,$44,$42,$42,$12
               dc.b     $45,$21,$00,$10,$10,$11,$11,$10
               dc.b     $01,$01,$00,$11,$48,$42,$8C,$FF
               dc.b     $FF,$FF,$94,$12,$36,$9A,$C9,$99
               dc.b     $89,$BD,$84,$58,$AB,$CC,$DC,$DF
               dc.b     $ED,$97,$68,$BD,$DD,$AD,$FF,$FF
               dc.b     $CA,$DF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$F6,$23,$33,$33,$45,$33,$10
               dc.b     $11,$11,$21,$10,$45,$31,$11,$21
               dc.b     $13,$32,$11,$23,$31,$11,$00,$02
               dc.b     $76,$10,$11,$11,$11,$12,$29,$FF
               dc.b     $FF,$FF,$D2,$23,$45,$43,$43,$33
               dc.b     $65,$66,$45,$45,$79,$B9,$CD,$CA
               dc.b     $ED,$DA,$AB,$9B,$EF,$FE,$FF,$FE
               dc.b     $7E,$CD,$EF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$F5,$11,$11,$12,$14,$31,$11
               dc.b     $11,$17,$61,$11,$00,$01,$12,$22
               dc.b     $20,$32,$12,$23,$32,$33,$11,$01
               dc.b     $21,$10,$00,$11,$65,$56,$5A,$FF
               dc.b     $FF,$FF,$B2,$13,$43,$24,$57,$77
               dc.b     $78,$89,$99,$88,$9A,$A9,$AA,$BB
               dc.b     $DD,$DB,$A4,$6F,$FF,$EC,$AD,$DB
               dc.b     $7A,$99,$89,$EF,$FF,$FF,$FF,$FF
               dc.b     $FF,$F4,$12,$22,$22,$22,$11,$10
               dc.b     $11,$06,$90,$00,$00,$01,$21,$00
               dc.b     $01,$21,$10,$00,$10,$00,$00,$00
               dc.b     $00,$00,$01,$12,$77,$88,$67,$BE
               dc.b     $CF,$FF,$FC,$76,$59,$A6,$44,$66
               dc.b     $AC,$CA,$98,$9A,$BB,$BD,$BD,$DC
               dc.b     $DB,$F9,$9A,$DF,$EE,$9B,$EF,$EE
               dc.b     $FF,$FF,$C6,$9E,$FF,$FF,$FF,$FF
               dc.b     $FF,$FA,$32,$22,$22,$12,$23,$32
               dc.b     $24,$8A,$84,$89,$AB,$BB,$97,$37
               dc.b     $82,$21,$12,$00,$14,$44,$34,$32
               dc.b     $11,$23,$35,$47,$DC,$AA,$76,$47
               dc.b     $4B,$CC,$FA,$AA,$BD,$EC,$BE,$FE
               dc.b     $FF,$FF,$ED,$CC,$DD,$FF,$FE,$AD
               dc.b     $ED,$BA,$EF,$FF,$EF,$FE,$FF,$FE
               dc.b     $EF,$FF,$FE,$DF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$EE,$EE,$ED,$DC,$DD,$DA
               dc.b     $DF,$FE,$DF,$FF,$AB,$CA,$BD,$EE
               dc.b     $FE,$EC,$BD,$CA,$DF,$FF,$FF,$EE
               dc.b     $EE,$EF,$FF,$FF,$FF,$FF,$FD,$DE
               dc.b     $DE,$DE,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FD,$FF,$FF,$FF,$FE
               dc.b     $B8,$79,$DF,$FD,$EF,$FF,$FF,$FF
               dc.b     $FF,$FD,$DF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FE,$FF,$FF,$FF,$FB,$D9
               dc.b     $BF,$FD,$CF,$CF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$EC,$DF,$FF,$FF,$FF,$D7
               dc.b     $8D,$FF,$FB,$BF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$CE,$EE,$BE,$CF,$EB,$9C
               dc.b     $AC,$FF,$DA,$BD,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$CD,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$EE,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$EE,$FF,$FF,$FF,$FF,$DE
               dc.b     $FF,$EF,$DD,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FD,$DC,$DF
               dc.b     $FF,$EE,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$EF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               dc.b     $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
;
               end