      PROGRAM MNDLBR
      INTEGER X, Y, I
      REAL CA, CB, A, B, T

      DO 30 Y = -12, 12
         DO 20 X = -39, 39
            CA = 0.0458 * X
            CB = 0.08333 * Y
            A = CA
            B = CB

            DO 10 I = 0, 15
               T = A*A - B*B + CA
               B = 2.0 * A * B + CB
               A = T
               IF ((A*A + B*B) .GT. 4.0) GOTO 15
 10         CONTINUE

C        IF LOOP FINISHES WITHOUT BREAKING, I INCREMENTS TO 16
 15         IF (I .GE. 16) THEN
               WRITE(*, 100) ' '
            ELSE IF (I .GT. 9) THEN
               WRITE(*, 100) CHAR(I + 7 + 48)
            ELSE
               WRITE(*, 100) CHAR(I + 48)
            ENDIF

 20      CONTINUE
         WRITE(*, *)
 30   CONTINUE
 100  FORMAT(A1, $)
      END
