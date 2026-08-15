C 	Test of Peek and Poke assembly routines

	PROGRAM PKMEM

	CHARACTER ANSWER
	IMPLICIT INTEGER (P)

10	WRITE (*,100)
100	FORMAT(' Type in memory segment number:')
	READ (*,*) ISEGMENT
	IF (ISEGMENT .EQ. -1) THEN
		STOP
	END IF
	WRITE (*,200)
200	FORMAT(' Type in memory offset number:')
	READ (*,*) IOFFSET
	IVALUE = PEEK(ISEGMENT, IOFFSET)
	WRITE (*,300)
300	FORMAT(' Value =')
	WRITE(*,*)IVALUE
	WRITE (*,400)
400	FORMAT(' Do you wish to modify this location:')
	READ (*,*) ANSWER
	IF (ANSWER .EQ. 'Y') THEN
		WRITE (*,500)
500		FORMAT(' Type in new value:')
		READ (*,*) IVALUE
		CALL POKE(ISEGMENT, IOFFSET, IVALUE)
	END IF
	GOTO 10

	END
