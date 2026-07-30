            include  "mecb.inc"
            include  "tutor.inc"
            include  "library.inc"
;
            org      USERPROG_ORG
;
main:
            move.l   #RAM_END+1,a7           ; Set up stack

            move.l   #1234567890,d0
            library  OUTDEC
            library  PCRLF
            move.l   #-1234567890,d0
            library  OUTDEC
            library  PCRLF
            move.l   #-890,d0
            library  OUTDEC
            library  PCRLF
            move.l   #0,d0
            library  OUTDEC
            library  PCRLF
            move.l   #-1,d0
            library  OUTDEC
            library  PCRLF
            move.l   #1,d0
            library  OUTDEC
            library  PCRLF
;
main_end    move.b   #TUTOR,d7
            trap     #14
;
            end
