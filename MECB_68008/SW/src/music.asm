               org      $4000
;
               include  'mecb.inc'
               include  'tutor.inc'
               include  'library_rom.inc'
;
BUFFER_SIZE    equ      255
TIMER_VAL      equ      $1000      ; timer 1 count setting
TIMER_SETH     equ      $01        ; Preset all timers a=$01, b=$42 CRX6=1 (interrupt); CRX1=1 (enable clock)
TIMER_SETL     equ      $42        ; Preset all timers a=$01, b=$42 CRX6=1 (interrupt); CRX1=1 (enable clock)
;
start          move.l   #RAM_END+1,a7              ; Set up stack
;
               jsr      psg_init
;               bsr      init_isr
;               bsr      ptm_init
;               and.w    #$F8FF,sr                  ; enable interrupts
;
loop           cmp.b    #$FE,psg_note0
               beq      test_end
               bsr      isr1
               move.l   #$2000,d0
delay          sub.l    #1,d0
               bne      delay
               bra      loop
               
;               or.w     #$0700,sr                  ; disable interrupts
               jsr      psg_stop
;
;
test_end       move.b   #TUTOR,d7
               trap     #14
;
init_isr       move.l   #isr0,a6
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
;               move.b   PTM1_SR,d1        ; Read the interrupt flag from the status register
;               move.w   PTM1_T1MSB,d1     ; clear timer interrupt flag
;               move.b   PTM1_SR,d1        ; Read the interrupt flag from the status register
;               move.w   PTM1_T2MSB,d1
;               move.b   PTM1_SR,d1        ; Read the interrupt flag from the status register
;               move.w   PTM1_T3MSB,d1

               move.l   #psg_volume0,a1   ; Initialise volume pointer for the 3 channels
               move.b   #0,d0             ; d0 = current channel
SoundGenLoop   move.b   (a1)+,d1          ; Check if the channel's volume is >0
               beq      NoNotePlayed      ; If Tone Generator's volume now 0 then note was silenced last time
               sub.b    #1,d1             ; Decrement the channel's volume to use
               move.b   d1,-1(a1)         ; And save new volume
               jsr      psg_volume        ; set volume for channel d0, level d1
NoNotePlayed   add.b    #1,d0             ; next channel number
               cmp.b    #3,d0
               bne      SoundGenLoop      ; Loop back to process next channel if we're not done yet
HandleNewNotes sub.b    #1,decay_count    ; Decrement our Decay Count
               bne      isr_return        ; If volume still decaying then return from interrupt
;
; The following handles the reading of new notes to be played for each of the 3 sound channels
;
               move.b   #10,decay_count   ; Reset the decay count.
ReadNewNotes1  move.l   #psg_note0,a1     ; Initialise note pointer for the 3 Tone Generators
               move.b   #0,d0             ; d0 = current tone generator
               move.l   sound_ptr,a0      ; Point to current sound byte
ReadNewNotes   move.b   (a0)+,d1          ; Get the current note
               move.b   d1,(a1)           ; Store the current note for the current Tone Generator
               cmp.b    #$fe,d1           ; #$FE marks the end of the SoundBytetable, so we loop back to the start
               beq      ReturnToStart
               cmp.b    #$ff,d1           ; #$FF marks no note to play (a pause), so no note gets played this time for this sound channel
               beq      PlayNoNote
               move.b   #$10,-3(a1)       ; Initialise partial volume (+1) into channel variable for the sound channel's volume
               and.l    #$ff,d1
               lsl.l    #1,d1             ; Double the note byte value for an index into freq_table 16 bit words
               add.l    #freq_table,d1
               move.l   d1,a2             ; a contains pointer to note frequency
               move.w   (a2),d1           ; get the note frequency
               jsr      psg_tone          ; Set the tone for the current channel
PlayNoNote     lea.l    1(a1),a1          ; point to next channel
               add.b    #1,d0             ; next channel number
               cmp.b    #3,d0             ; next tone generator
               bne      ReadNewNotes      ; Read more notes if we haven't processed all 3 Tone Generators yet
               move.l   a0,sound_ptr      ; Save the note pointer
;
isr_return     movem.l  (a7)+,d0-d2/a0-a2 ; restore registers
               rts
;
; Initilise Sound Byte Offset back to zero, if we want to start over again
ReturnToStart  move.l   #SoundByteTable,sound_ptr
;              bra      ReadNewNotes1     ; Finally, re-start the sound channel loop as we're starting again
;              ; OR,
               bra      isr_return        ; Instead just return, if we just want to stop!
;
init_sound     move.b   #$22,PIA1CTLB     ; Setup PIA Port B for Sound ouput, select DDR Register B
                                          ; CB2 goes low following data write, returned high by IRQB1 set by low to high transition on CB1
               move.b   #$ff,PIA1DDRB     ; Set Port B as all outputs, DDR B register write
               move.b   #$26,PIA1CTLB     ; Select Port B Data Register (rest as above) 
; Initialize DecayCount
               move.b   #10,decay_count   ; Wait a bit before starting the music
; Initialize PSGVolume, PSGNote & sound_ptr storage to Zero
               move.b   #0,psg_volume0
               move.b   #0,psg_volume1
               move.b   #0,psg_volume2
               move.b   #0,psg_note0
               move.b   #0,psg_note1
               move.b   #0,psg_note2
               move.l   #SoundByteTable,sound_ptr
               jsr      psg_stop
               rts
;
irq_num        ds.b     1
;
               align    2
;
sound_ptr      ds.l     1
;
decay_count    ds.b     1
psg_volume0    ds.b     1
psg_volume1    ds.b     1
psg_volume2    ds.b     1
psg_note0      ds.b     1
psg_note1      ds.b     1
psg_note2      ds.b     1
;
               align    2
;
freq_table     
               dc.w    $023D   ; C2 = 65.41
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

               dc.b     254,254,254               ; The End
;
               end