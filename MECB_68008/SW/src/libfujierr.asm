;
; Error handling
;
; Print error code
; Entry: a - error code
;
fn_perror   move.l   a0,-(a7)
            cmp.b    #FUJINET_RC_NOT_IMPLEMENTED,d0
            bne      fnerr2
            move.l   #fnerrs1,a0
            bra      fnerror_ex
fnerr2      cmp.b    #FUJINET_RC_NOT_SUPPORTED,d0
            bne      fnerr3
            move.l   #fnerrs2,a0
            bra      fnerror_ex
fnerr3      cmp.b    #FUJINET_RC_INVALID,d0
            bne      fnerr4
            move.l   #fnerrs3,a0
            bra      fnerror_ex
fnerr4      cmp.b    #FUJINET_RC_TIMEOUT,d0
            bne      fnerr5
            move.l   #fnerrs4,a0
            bra      fnerror_ex
fnerr5      cmp.b    #FUJINET_RC_NO_ACK,d0
            bne      fnerr6
            move.l   #fnerrs5,a0
            bra      fnerror_ex
fnerr6      cmp.b    #FUJINET_RC_NO_COMPLETE,d0
            bne      fnerr7
            move.l   #fnerrs6,a0
            bra      fnerror_ex
fnerr7      move.l   #fnerrsx,a0
;
fnerror_ex  bsr      print
            move.l   (a7)+,a0
            rts
;
fnerrs1     dc.b  'Error: FUJINET_RC_NOT_IMPLEMENTED',CR,LF,EOT
fnerrs2     dc.b  'Error: FUJINET_RC_NOT_SUPPORTED',CR,LF,EOT
fnerrs3     dc.b  'Error: FUJINET_RC_INVALID',CR,LF,EOT
fnerrs4     dc.b  'Error: FUJINET_RC_TIMEOUT',CR,LF,EOT
fnerrs5     dc.b  'Error: FUJINET_RC_NO_ACK',CR,LF,EOT
fnerrs6     dc.b  'Error: FUJINET_RC_NO_COMPLETE',CR,LF,EOT
fnerrsx     dc.b  'Error: Undefined',CR,LF,EOT
;
            align 4
