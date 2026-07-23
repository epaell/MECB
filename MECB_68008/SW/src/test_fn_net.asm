;
;
;
net_tests:
         move.l   #stnet,a0               ; Write test message
         bsr      print
;
         move.l   #stnopen,a0             ; Test network open
         bsr      print
;
; test fujinet_network_open
;
         move.l   #url,a0
         move.l   #txdata,a1
         bsr      strcpy                  ; copy the URL to the transmit buffer
         move.l   #fujinet_dcb,a0         ; Initialise the receive and transmit buffer in the DCB
         move.l   #rxdata,DCB_RX_BUFFER(a0)        ; Set up receive and transmit buffers
         move.l   #txdata,DCB_TX_BUFFER(a0)
         move.b   #0,d1                   ; Network handle
         move.b   #NET_TRANS_NONE,d0
         bsr      fujinet_network_open    ; Mount the host slot
         cmp.b    #FUJINET_RC_OK,d0       ; Check if OK
         bne      error                   ; if not, report error
;
; test fujinet_network_status
;
gloop:   
         move.l   #fujinet_dcb,a0         ; Initialise the receive and transmit buffer in the DCB
         move.b   #0,d1                   ; Network handle
         bsr      fujinet_network_status  ; get the status
         cmp.b    #FUJINET_RC_OK,d0       ; Check if OK
         bne      error                   ; if not, report error
         move.l   #rxdata,a1              ; point to status structure
         move.b   2(a1),d0                ; Protocol status
         move.b   3(a1),d1                ; extended error
         cmp.b    #NETWORK_ERROR_SUCCESS,d1
         beq      do_nread                ; If it was OK, read a chunk
         cmp.b    #NETWORK_ERROR_END_OF_FILE,d1
         beq      done                    ; We're done if the EOF is reached
;
         move.b   #10,d0
         bra      error
do_nread:
         move.b   1(a1),d0
         lsl.w    #8,d0
         move.b   (a1),d0                 ; d0.w = bytes waiting
         tst.w    d0
         beq      gloop                   ; Nothing waiting, poll again
         cmp.w    #512,d0
         blt      nread
         move.w   #512,d0                 ; clamp to 512 bytes
;
; test fujinet_network_read
;
nread:
         move.l   #fujinet_dcb,a0         ; Initialise the receive and transmit buffer in the DCB
         move.b   #0,d1                   ; Network handle
         bsr      fujinet_network_read    ; read the data
         cmp.b    #FUJINET_RC_OK,d0       ; Check if OK
         bne      error                   ; if not, report error
         move.l   #fujinet_dcb,a0         ; Initialise the receive and transmit buffer in the DCB
         move.w   DCB_RX_BUFFER_LEN(a0),d1
         move.l   #rxdata,a1
ploop:   move.b   (a1)+,d0
         bsr      outch1
         cmp.b    #LF,d0
         bne      ploop2
         move.b   #CR,d0
         bsr      outch1
ploop2:
         sub.w    #1,d1
         bne      ploop
         bra      gloop                   ; get net chunk, if any
;
done:
         move.l   #stnclose,a0
         bsr      print
         move.l   #fujinet_dcb,a0         ; Initialise the receive and transmit buffer in the DCB
         move.b   #0,d1
         bsr      fujinet_network_close   ; close the network channel
         cmp.b    #FUJINET_RC_OK,d0       ; Check if OK
         bne      error                   ; if not, report error
;
         rts
;
stnet:   dc.b   CR,LF,'====== Network access tests ======',CR,LF,EOT
stnopen: dc.b   "Opening URL",CR,LF,EOT
url:     dc.b   "http://elenchically.net/tools/planets.py",EOT
stnstat: dc.b   CR,LF,"Network status",CR,LF,EOT
stnwait: dc.b   "Byte waiting = $",EOT
stnpstat: dc.b   "Protocol status = $",EOT
stneerr: dc.b   "Extended error = $",EOT
stnread: dc.b   CR,LF,"Network read = ",CR,LF,EOT
stnclose: dc.b  "Network close",CR,LF,EOT
here:    dc.b   "Here!",CR,LF,EOT
