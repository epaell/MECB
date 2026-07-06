;
; Error handling
;
; Print error code
; Entry: a - error code
;
fn_perror   pshs  x
            cmpa  #FUJINET_RC_NOT_IMPLEMENTED
            bne   fnerr2
            ldx   #fnerrs1
            bra   fnerror_ex
fnerr2      cmpa  #FUJINET_RC_NOT_SUPPORTED
            bne   fnerr3
            ldx   #fnerrs2
            bra   fnerror_ex
fnerr3      cmpa  #FUJINET_RC_INVALID
            bne   fnerr4
            ldx   #fnerrs3
            bra   fnerror_ex
fnerr4      cmpa  #FUJINET_RC_TIMEOUT
            bne   fnerr5
            ldx   #fnerrs4
            bra   fnerror_ex
fnerr5      cmpa  #FUJINET_RC_NO_ACK
            bne   fnerr6
            ldx   #fnerrs5
            bra   fnerror_ex
fnerr6      cmpa  #FUJINET_RC_NO_COMPLETE
            bne   fnerr7
            ldx   #fnerrs6
            bra   fnerror_ex
fnerr7      ldx   #fnerrsx
;
fnerror_ex  lbsr  print
            puls  x
            rts
;
fnerrs1     fcb   'Error: FUJINET_RC_NOT_IMPLEMENTED',CR,LF,EOT
fnerrs2     fcb   'Error: FUJINET_RC_NOT_SUPPORTED',CR,LF,EOT
fnerrs3     fcb   'Error: FUJINET_RC_INVALID',CR,LF,EOT
fnerrs4     fcb   'Error: FUJINET_RC_TIMEOUT',CR,LF,EOT
fnerrs5     fcb   'Error: FUJINET_RC_NO_ACK',CR,LF,EOT
fnerrs6     fcb   'Error: FUJINET_RC_NO_COMPLETE',CR,LF,EOT
fnerrsx     fcb   'Error: Undefined',CR,LF,EOT

