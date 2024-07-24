*
*=====================================================
* This gets one key from the user, erases it so it
* doesn't appear, then returns it in A.
*
GETKEY  JSR     GETCHR  *get a key
        PSHA
        LDAA    #BS
        JSR     PUTCHR
        LDAA    #SPACE
        JSR     PUTCHR
        LDAA    #BS
        JSR     PUTCHR
        PULA
        RTS
*
*=====================================================
* Given a pointer to a source block in SPTR and a
* destination address in DPTR, this copies B bytes
* from source to destination.  If B is 0, then it
* copies 256 bytes.
*
MOVBLK  LDX     SPTR
        LDAA    0,X
        INX
        STX     SPTR
        LDX     DPTR
        STAA    0,X
        INX
        STX     DPTR
        DECB
        BNE     MOVBLK
        RTS
*
*=====================================================
* Given a pointer to a sector buffer in X, set the
* entire buffer (256 bytes) to zero.
*
CLRBUF  LDAB    #0      *counter
CLRB2   CLR     0,X
        INX
        DECB
        BNE     CLRB2
        RTS
*
*=====================================================
* Given a pointer to a source block in SPTR and a
* destination address in DPTR, this copies B bytes
* or until a null is encountered.
*
MOVSTR  LDX     SPTR
        LDAA    0,X
        BEQ     MOVEND  *done if null loaded
        CMPA    #CR
        BEQ     MOVEND
        INX
        STX     SPTR
        LDX     DPTR
        STAA    0,X
        INX
        STX     DPTR
        DECB
        BNE     MOVSTR
MOVEND  LDX     DPTR
        CLR     0,X
        RTS
*
*=====================================================
* Given a pointer to a string in X, this prints the
* string exactly as-is.  Will end on either an EOT
* ($04) or NULL ($00).  Returns with X pointing to the
* terminating character.
*
PUTS    LDAA    0,X
        BEQ     PUTSDUN
        CMPA    #EOT
        BEQ     PUTSDUN
        JSR     PUTCHR
        INX
        BNE     PUTS
PUTSDUN RTS
*
