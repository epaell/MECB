C     J  E BOWLES HETENYI SOLUTION FINITE BEAM ON  ELAS.  FOUND
C     ORDER OF DATA CARDS IS 1= TITLE;2=UNITS;3=AA;4=R;5=FIRST DA
C     6= R;  7 2ND DATA--USE R = 0 FOR 1-COL;  USE R = 0 AT END OF 2ND
C     READ ALL UNITS AS FT OR METERS, KIPS OR  KILO-NEWTONS 
      write(*,*) 'got to first write' 
		    DIMENSION A1(5,15),B1(5,15),C1(5,15),F(15),V(15),H(15),P(10)
      DIMENSION DIST(15),TITLE(20)   
      DOUBLE PRECISION UT5,UT6
      REAL LAMBDA
 1004 READ(*,1000,END=150)TITLE,UT1,UT2,UT3,UT4,UT5,UT6
 1000 FORMAT (20A4/4(A4,6X),A8,2X,A8)
      READ(*,10)AA,ALIST      
      WRITE (*,1001)TITLE,AA
 1001 FORMAT('1',//,T5,20A4,/,T10,'RUN =',F5.2,/)
      N = 0
      M = 0
      DO 109  I = 1,4
      DO 109  J = 1,12
      A1 (1,J) = 0.
      B1 (1,J) = 0.
      C1 (1,J) = 0.
  109 CONTINUE
 1002 READ(*,10)R
      M = M + 1
      IF(R)111,111,1
    1 READ (*,10)SK,X1,EL,BF,DC,EC, P(M)
   10 FORMAT(7F10.4)
      X1 = BF*DC**3/12.
      SKS = SK*BF
      IF(DC)13,13,14
   13 READ(*,10)X1
   14 BETA = EL*((SK*BF)/(4.*X1))**.25
      LAMBDA = BETA/EL
      WRITE(*,12)BETA,LAMBDA,X1,UT1,EL,UT1,BF,UTI,DC,UT1,SK,UT5,EC,UT5,
     1X1,UT1,P(M),UT3
   12 FORMAT(//,T5,'BETA =',F7.3,3X,'LAMBDA =',F8.5,3X,'COL  DIST =',F8
     1.4,1X,A2,/,T5,   'FTG   LENGTH  =',F8.3,1X,A2,3x,'FTG WIDTH=',F8.4,1X, 
     2A2,3X, 'FTG DEPTH =',F7.4,1X,A2,/,T5, 'SOIL MODULUS =',F9.2,1X,A7,
     33X,'MOD ELAST =',F10.1,1X,A7,/,T5,'MOM OF INERTIA =',G12.6,1X,A2,
     4'**4',3X, 'COL LOAD =',F9.2,1X,A4)
      N = N + 1
      G = 1.
      W2 = .5*(EXP (BETA*G) + 1./(EXP (BETA*G)))
      X2 = .5*(EXP (BETA*G)-1./(EXP (BETA*G)))
      Y2 = SIN (BETA*G)
      Z2 = COS (BETA*G)
      Z = BETA/EL
      D = EL/10.
      D1 = X1/D
      J = D1
      D2 = J
      DIFF = D1 - D2
      IF (DIFF - 0.5)8,8,9
    8 A = D2/10.
      GO TO 16
    9 A = (D2+1.)/10.
   16 WRITE (*,17)A
   17 FORMAT (/T10, 'LOAD AT ',F3.1,' L',/,T6,'DIST', T16,'DEF',T25,'MO 
     2M',T34, 'SHEAR',//)
      DO 104 L = 1,12
		    I = L
      K = 1 
      IF(N.EQ.2)K=3 
      X = (I - 1.)/10.
      DIS = X
      IF (DIS - 1.) 19, 19, 1002
   19 IF (X - (A+0.002)) 20, 20, 50
   20 B = 1.- A
      WO = .5 * (EXP (BETA * A) + 1. / (EXP (BETA * A)))
      XO = .5 * (EXP (BETA * A) - 1. / (EXP (BETA * A)))
      YO = SIN (BETA*A)
      ZO = COS (BETA*A)
      W1 = .5*(EXP (BETA*B)+1./(EXP (BETA*B)))
      X1 = .5*(EXP (BETA*B)-1./(EXP (BETA*B)))
      Y1 = SIN (BETA*B)
      Z1 = COS (BETA*B)
      W3 = .5*(EXP (BETA*X)+1./(EXP (BETA*X)))
      X3 = .5*(EXP (BETA*X)-1./(EXP (BETA*X)))
      Y3 = SIN (BETA*X)
      Z3 = COS (BETA*X)
      Q = (X2*(YO*W1-Z0*X1) + Y2*(XO*Z1 - W0*Y1))
      S = (1./(X2**2 - Y2**2))
      A1(K,1) = S*(2.*W3*Z3*(X2*ZO*W1 - Y2*WO*Z1) + (W3*Y3 + X3*Z3)*Q)
      B1(K,1) = S*(2.*X3*Y3*(X2*ZO*W1-Y2*WO*Z1)+(W3*Y3-X3*Z3)*Q)
      C1(K,1) = S*((W3*Y3+X3*Z3)*(X2*ZO*W1-Y2*WO*Z1)+X3*Y3*Q)
      GO TO 104
   50 K=2
      IF(N.EQ.2)K=4
      A = 1. - A
      B = 1. - A
      X = A
   55 IF(X)1002,61,61
   61 WO = .5*(EXP (BETA*A)-1./(EXP (BETA*A)))
      XO = .5*(EXP (BETA*A)-1./(EXP (BETA*A)))
      YO = SIN (BETA*A)
      ZO = COS (BETA*A)
      W1 = .5*(EXP (BETA*B)+1./(EXP (BETA*B)))
      X1 = .5*(EXP (BETA*B)-1./(EXP (BETA*B)))
      Y1 = SIN (BETA*B)
      Z1 = COS (BETA*B)
      W3 = .5*(EXP (BETA*X)+1./(EXP (BETA*X)))
      X3 = .5*(EXP (BETA*X)-1./(EXP (BETA*X)))
      Y3 = SIN (BETA*X)
      Z3 = COS (BETA*X)
      Q = (X2*(YO*W1-Z0*X1) + Y2*(XO*Z1 - WO*Y1))
      S = (1./(X2**2 - Y2**2))
      A1(K,I) = S*(2.*W3*Z3*(X2*ZO*W1 - Y2*WO*Z1)+ (W3*Y3 + X3*Z3)*Q)
      B1(K,I) = S*(2.*X3*Y3*(X2*ZO*W1-Y2*WO*Z1) + (W3*Y3+X3*Z3)*Q)
      C1(K,I) = S*((W3*Y3+X3*Z3)*(X2*ZO*W1-Y2*WO*Z1)+X3*Y3*Q)*(-1.)
      DIS = 1. - X
      X = X - .1
      WRITE (*, 101) DIS, A1 (K, 1), B1 (K, 1), C1 (K, 1)
      I = I + 1
      GO TO 55
  104 WRITE (*, 101) DIS, A1 (K, 1), B1 (K, 1), C1 (K, 1)
  101 FORMAT (5X, F4.1, 3F10.4)
  111 IF (ALIST .LE. 0.) GO TO 140   
      WRITE (*, 124)
  124 FORMAT('1', T10, 'A1(1,J)', T20, 'A1(2,J)', T30, 'A1(3,J)',T40'
     1A1(4,J)', T60, 'B1(1,J),',T70, 'B1(2,J)', T80, 'B1(3,J)',T90,'B1(4
     2,J)'//)
      WRITE (*,127) ((A1(K,I), B1(K,I), K = 1,4), I = 1,12)
  127 FORMAT (T9, 4F10.5, T59, 4F10.5)
      WRITE (*,126)
  126 FORMAT(//,T10,'C1(1,J)',3X,'C1(2,J)'3X,'C1(3,J)',3X,'C1(4,J)'//)
      WRITE (*,125) ((C1(K,1), K = 1,4), I =1,12)
  125 FORMAT (T9, 4F10.5)
  140 WRITE (*,21)   
   21 FORMAT(//,T5,'TOTAL DERFL, MOM AND SHEAR AT 0.1 PTS ARE:')
      WRITE (*,22) UT1,UT1,UT4,UT3
   22 FORMAT (T8,'DIST,',A2,T20,'DEF,',A2,T33,'MOM,',A4,T45,'SHEAR,',A4/)
C     COMPUTE DEFL F(J): BENDING MOMENT V(J); SHEAR H(J)
      DO 108 J = 1,12
  108 DIST(J) = 0.
      DO 29 J = 1,13
      IF (J-13)32,25,25
   32 IF (A1(1,J))24,25,24
   24 F(J) = (A1(1,J)*P(1) + A1(3,J)*P(2))*Z/(SKS)
      V(J)=((B1(1,J)*P(1)+B1(3,J)*P(2))/(2.*Z))
      H(J)= (C1(1,J)*P(1)+C1(3,J)*P(2))
      A = J -1
      DIST (J) = DIST (J) + A*EL/10.
      GO TO 29
   25 IF (A1(3,J-1))26,27,26
   26 F(J)=(A1(2,J)*P(1)+A1(3,J-1)*P(2))*Z/(SKS)
      H(J)= (C1(2,J)*P(1)+C1(3,J-1)*P(2))
      V(J)=((B1(2,J)*P(1)+B1(3,J-1)*P(2))/(2.*Z))
						A = J - 1
      DIST(J) = A*EL/10.
      GO TO 29
   27 F(J) = (A1(2,J-1)*P(1) + A1(4,J-1)*P(2))*Z/(SKS)
      V(J)=((B1(2,J-1)*P(1)+B1(4,J-1)*P(2))/(2.*Z))
      H(J)=(C1(2,J-1)*P(1)+C1(4,J-1)*P(2))
      A = J - 3
      DIST (J) = A*EL/10
   29 WRITE (*,23)DIST(J), F(J), V(J), H(J)
   23 FORMAT (3X, F10.4, 4X,F10.3, 3X, F10.3)
      GO TO 1004
  150 STOP
      END



     

