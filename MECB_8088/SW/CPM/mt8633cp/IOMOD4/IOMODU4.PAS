(*  VERSION 0023 *)

MODULE IOMODULE;

(* Interface to CP/M-86 for PASCAL/MT+86 *)

(* COPYRIGHT 1981,1982,1983 BY DIGITAL RESEARCH, INC. *)
(* ALL RIGHTS RESERVED *)

(* Last Update: 14. Nov. 85   by Gerhard Stegemann *)

(* Update Summary: *)

(*   - Close a file always, if not a special file *)
(*   - Don't free FCB in @OPEN for special files *)
(*   - Trap reading from LST: in @RNB *)
(*   - Improved @PARSE routine *)
(*   - General optimizations *)
(*   - GETBYTE and PUTBYTE optimized *)
(*   - CHAIN Interface procedure placed into a separate module *)

(*$I FIBDEF.LIB *)
(*$P*)
CONST 
      maxfcbs = 9;

TYPE 
     FPTR = ^FIB;
     FCBLK = PACKED ARRAY [0..36] OF CHAR;
     SECTOR = PACKED ARRAY [0..127] OF CHAR;
     DUMMY = PACKED ARRAY[0..0] OF CHAR;
     PTR = ^DUMMY;

     FCBREC = RECORD
                ACTIVE : BOOLEAN;
                FCB    : FCBLK;
                BUFIDX : INTEGER;
                BUFFER : SECTOR;
                ENDFILE: BOOLEAN;
              END;

     PTRIX = RECORD
               CASE BOOLEAN OF
                 TRUE : (LO_VAL : INTEGER;
                         HI_VAL : INTEGER);
                 FALSE: (P : PTR);
             END;

VAR 
    @LFB : FPTR;
    RESULTI : INTEGER;

    @FCBS : ARRAY [0..maxfcbs] OF FCBREC;
    (* Allows 10 simultaneously open files. *)
    (* The console takes two file slots *)
    (* for CON: as input and CON: as output. *)

EXTERNAL FUNCTION  GETBYTE(I : INTEGER; VAR ENDFIL : BOOLEAN) : BYTE;
EXTERNAL PROCEDURE PUTBYTE(B : BYTE; I : INTEGER);
EXTERNAL PROCEDURE PUTSECTOR(I : INTEGER);

EXTERNAL FUNCTION @BDOS86(FUNC : INTEGER; PARM : PTR) : BYTE;
EXTERNAL FUNCTION @BDOS86A(FUNC : INTEGER; FIRST, SECOND : INTEGER) : BYTE;
(* @BDOS86A will resolve to @BDOS86 at link time but use different parms *)

EXTERNAL PROCEDURE @HLT;

(*$P*)
(*$E-*)
FUNCTION GET_AN_FCB : INTEGER;

VAR 
    I : INTEGER;

BEGIN
  I := 0;
  WHILE I <= maxfcbs DO
    WITH @FCBS[I] DO
      BEGIN
        IF NOT ACTIVE THEN    (* We found one! *)
          BEGIN
            GET_AN_FCB := I;
            ACTIVE := TRUE;
            EXIT;
          END
        ELSE
          I := I + 1;
      END;

  I := -1;
  WRITELN('FCB Table Exhausted!'); (* Return to caller anyway *)
 
END; (* GET_AN_FCB *)

PROCEDURE FREE_AN_FCB(FCBNUM : INTEGER);

BEGIN
  @FCBS[FCBNUM].ACTIVE := FALSE

END; (* FREE_AN_FCB *)

(*$P*)
(*$E-*)
FUNCTION @SPN(VAR F : FIB) : BOOLEAN;

VAR
    DEVI : INTEGER;

BEGIN
  @SPN := FALSE;
  DEVI := POS(F.FNAME, 'CON:LST:KBD:TRM:RDR:PUN:');
  
  IF (LENGTH(F.FNAME) <> 4) OR
     (DEVI = 0) THEN          (* Valid device found if non-zero *)
    EXIT;

  @SPN := TRUE;               (* Return special file to caller *)
  CASE DEVI OF 
    1: F.OPTION := FCONIO;

    5: F.OPTION := FLSTOUT;
    
    9, 13: F.OPTION := FTRMIO;

    17, 21: F.OPTION := FAUXIO;

    ELSE
      @SPN := FALSE;          (* Invalid device name *)
  END;

END; (* @SPN *)

(*$P*)
(*$E+*)
PROCEDURE @PARSE(VAR F : FCBLK; VAR S : STRING);

CONST
      F_PARSE = 152;

TYPE
     D_PFCB = RECORD
                FILENAME : INTEGER;
                FCBADR : INTEGER;
              END;

VAR 
    ADR : PTRIX;
    STR_LGTH : INTEGER;
    RESULT : INTEGER;
    DEVICE : BOOLEAN;
    PFCB : D_PFCB;
    FCB : FCBLK;
    NAME : STRING[37];

BEGIN
  WHILE (LENGTH(S) <> 0) AND (S[1] = ' ') DO
    DELETE(S, 1, 1);          (* Remove leading spaces *)

  FCB := F;                   (* Local copy of FCB *)
  NAME := S;
  ADR.P := ADDR(NAME);        (* Set up PFCB *)
  PFCB.FILENAME := ADR.LO_VAL + 1; (* Offset of Filename *)
  ADR.P := ADDR(FCB);
  PFCB.FCBADR := ADR.LO_VAL;

  STR_LGTH := LENGTH(NAME);
  NAME[STR_LGTH + 1] := CHR($0D); (* Delimit with EOL *)
  DEVICE := (NAME[STR_LGTH] = ':');
  RESULTI := @BDOS86(F_PARSE, ADDR(PFCB));
  INLINE($89/ $9E/ RESULT);   (* MOV offset[BP],BX; take whole value *)   

  IF (FCB[1] = ' ') OR (RESULT = -1) THEN
    BEGIN                     (* Illegal file name received *)
      RESULTI := 255;
      EXIT;
    END;

  RESULTI := 0;               (* Ignore other values *)
  IF DEVICE THEN
    BEGIN                     (* Return special file name *)
      MOVE(FCB[1], S[1], STR_LGTH - 1);
      S[STR_LGTH] := ':';
    END;
  F := FCB;                   (* Return FCB to caller *)

END; (* @PARSE *)

(*$P*)
FUNCTION @OPEN(VAR F : FIB; MODE : INTEGER) : INTEGER;

(* Note: This code is dependent upon the fact that the first field *)
(* of the FIB definition is FNAME! *)

VAR 
    I : INTEGER;

BEGIN
  I := GET_AN_FCB;
  @OPEN := I;                 (* Return file number *)

  IF I <> -1 THEN
    WITH @FCBS[I] DO
      BEGIN
        FILLCHAR(FCB, 36, CHR(0));
        @PARSE(FCB, F.FNAME);
        IF RESULTI = 255 THEN
          BEGIN
            @OPEN := -1;
            FREE_AN_FCB(I);   (* Don't need FCB if bad name *)
            EXIT;
          END;
      
        IF @SPN(F) THEN
          BEGIN
            RESULTI := 0;
            FCB[0] := CHR($FF); (* Mark special file *)
            (* since on 1/16/82 we implemented i/o redirection *)
            (* special files now need an fcb allocated to them! *)
            EXIT
          END;
      
        RESULTI := @BDOS86(15, ADDR(FCB));
        IF RESULTI = 255 THEN
          BEGIN
            @OPEN := -1;
            FREE_AN_FCB(I);   (* Don't need FCB if not found *)
          END
        ELSE
          BEGIN
            BUFIDX := SIZEOF(SECTOR);
            ENDFILE := FALSE;
          END;
      END
  ELSE
    RESULTI := 255;

END; (* @OPEN *)

(*$P*)
FUNCTION @CREAT(VAR F : FIB; MODE : INTEGER) : INTEGER;

VAR 
    I : INTEGER;

BEGIN
  I := GET_AN_FCB;
  @CREAT := I;                (* Return file number *)

  IF I <> -1 THEN
    WITH @FCBS[I] DO
      BEGIN
        FILLCHAR(FCB, 36, CHR(0));
        @PARSE(FCB, F.FNAME);
        IF RESULTI = 255 THEN
          BEGIN
            @CREAT := -1;
            FREE_AN_FCB(I);     (* Don't need FCB if bad name *)
            EXIT;
          END;
      
        IF @SPN(F) THEN
          BEGIN
            RESULTI := 0;
            FCB[0] := CHR($FF); (* Mark special file *)
            (* since on 1/16/82 we implemented i/o redirection *)
            (* special files now need an fcb allocated to them! *)
            EXIT;
          END;
      
        RESULTI := @BDOS86(19, ADDR(FCB)); (* Delete any old files *)
        RESULTI := @BDOS86(22, ADDR(FCB)); (* and create a new one *)
        IF RESULTI = 255 THEN
          BEGIN
            @CREAT := -1;
            FREE_AN_FCB(I);     (* Don't need FCB if error *)
          END;
        BUFIDX := 0;
      END
  ELSE
    RESULTI := 255;

END; (* @CREAT *)

(*$P*)
FUNCTION @UNLINK(VAR F : FIB) : INTEGER;

BEGIN
  IF F.SYSID = 0 THEN         (* We must allocate an FCB first *)
    F.SYSID := @OPEN(F, 2);
  IF F.SYSID <> -1 THEN       (* Valid file *)
    BEGIN
      IF F.OPTION <= FRANDOM THEN (* It is a disk file *)
        RESULTI := @BDOS86(19, ADDR(@FCBS[F.SYSID].FCB));
      @UNLINK := 0;
      FREE_AN_FCB(F.SYSID);
    END;

END; (* @UNLINK *)

(*$P*)
PROCEDURE @CLOSE(I : INTEGER; an_infile : boolean);

VAR 
    J : INTEGER;

BEGIN
  WITH @FCBS[I] DO
    BEGIN
      IF FCB[0] <> CHR($FF) THEN
        BEGIN
          IF NOT an_infile THEN (* check to see if stuff to flush *)
            IF BUFIDX <> 0 THEN
              BEGIN
                IF BUFIDX <> SIZEOF(SECTOR) THEN
                              (* Still space left to fill with ctrl-z's *)
                  FILLCHAR(BUFFER[BUFIDX], SIZEOF(SECTOR) - BUFIDX, CHR($1A));
                PUTSECTOR(I); (* Always output buffer if IDX <> 0 *)
              END;
          RESULTI := @BDOS86(16, ADDR(FCB));
        END;
    END;
  FREE_AN_FCB(I);             (* We always do this! *)

END; (* @CLOSE *)
(*$P*)
(*$E+*)
PROCEDURE @SFB(P : FPTR);

BEGIN
  @LFB := P;

END; (* @SFB *)

MODEND.

