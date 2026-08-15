      PROGRAM SIEVE
C     SIEVE OF ERATOSTHENES BENCHMARK
      LOGICAL FLAGS(8191)
      INTEGER I,J,K,COUNT,ITER,PRIME
      WRITE(*,*) ' 10 ITERATIONS'
      DO 92 ITER = 1,10
      COUNT = 0
      I = 0
      DO 10 I = 1,8191
10    FLAGS(I) = .TRUE.
      DO 91 I=1,8191
      IF(.NOT. FLAGS(I)) GO TO 91
      PRIME = I + I + 1
200   FORMAT(1X,I6)
      COUNT = COUNT + 1
      K = I + PRIME
      IF (K.GT.8191) GO TO 91
      DO 60 J = K, 8191, PRIME
60    FLAGS(J) = .FALSE.
91    CONTINUE
92    CONTINUE
      WRITE(*,300) PRIME,COUNT
300   FORMAT(1X,I6,' IS THE LARGEST OF ',I6,' PRIMES')
      STOP
      END
