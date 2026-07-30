;
;
;
printer_tests:
         move.l   #stprint,a0               ; Write test message
         library  PRINT
;
; test fujinet_printer_write
;
         move.l   #stprmsg,a0
         move.l   #txdata,a1
         library  STRCPY                  ; copy the URL to the transmit buffer
         move.l   #stprmsg,a0
         library  STRLEN
         move.l   #fujinet_dcb,a0         ; Initialise the receive and transmit buffer in the DCB
         move.l   #rxdata,DCB_RX_BUFFER(a0)        ; Set up receive and transmit buffers
         move.l   #txdata,DCB_TX_BUFFER(a0)
         move.b   #2,d1                   ; Printer device
         library  FNWRPRN                 ; Open network channel
         cmp.b    #FUJINET_RC_OK,d0       ; Check if OK
         bne      prerror                   ; if not, report error
         rts
;
prerror  move.l   #stperr,a0
         library  PRINT
         rts
;
stprint: dc.b   CR,LF,'====== Printer access tests ======',CR,LF,EOT
stprmsg: dc.b     "Hello, World!",CR,LF,EOT
stperr:  dc.b     "Failed to write to printer device",CR,LF,EOT