section .text
;
; Error handling
;
; Print error code
; Entry: al - error code
;
fn_perror:
         push  si
         cmp   al,FUJINET_RC_NOT_IMPLEMENTED
         jnz   fnerr2
         mov   si,fnerrs1
         jmp   fnerror_ex
fnerr2   cmp   al,FUJINET_RC_NOT_SUPPORTED
         jnz   fnerr3
         mov   si,fnerrs2
         jmp   fnerror_ex
fnerr3   cmp   al,FUJINET_RC_INVALID
         jnz      fnerr4
         mov   si,fnerrs3
         jmp   fnerror_ex
fnerr4   cmp   al,FUJINET_RC_TIMEOUT
         jnz   fnerr5
         mov   si,fnerrs4
         jmp   fnerror_ex
fnerr5   cmp   al,FUJINET_RC_NO_ACK
         jnz   fnerr6
         mov   si,fnerrs5
         jmp   fnerror_ex
fnerr6   cmp   al,FUJINET_RC_NO_COMPLETE
         jnz   fnerr7
         mov   si,fnerrs6
         jmp   fnerror_ex
fnerr7   mov   si,fnerrsx
;
fnerror_ex:
         call  print
         pop   si
         ret
;
section .data

fnerrs1: db  'Error: FUJINET_RC_NOT_IMPLEMENTED',CR,LF,EOT
fnerrs2: db  'Error: FUJINET_RC_NOT_SUPPORTED',CR,LF,EOT
fnerrs3: db  'Error: FUJINET_RC_INVALID',CR,LF,EOT
fnerrs4: db  'Error: FUJINET_RC_TIMEOUT',CR,LF,EOT
fnerrs5: db  'Error: FUJINET_RC_NO_ACK',CR,LF,EOT
fnerrs6: db  'Error: FUJINET_RC_NO_COMPLETE',CR,LF,EOT
fnerrsx: db  'Error: Undefined',CR,LF,EOT
;
