



                    CP/M-68K Version 1.2 README.TXT File
                    ------------------------------------

                                May 14, 1984
                                ------------

      CP/M-68K V1.2 is an upgrade to CP/M-68K V1.1.   The  new  release
      incorporates  several new features and bug fixes.  Features which
      have been added are:

          1. Typeahead support.

          2. Support for the 68010 chip.

          3. Floating point support for C.  The  compiler  and  runtime
             support  both  the  Motorola Fast Floating Point (FFP) and
             IEEE formats for floating point numbers.

          4. Support for wild cards, quoted  strings,  and  redirection
             with append on command lines for C programs.

          5. The ability to specify a user number /  drive  combination
             when  opening  a file in C.  This feature extends to files
             used in wildcarding and redirection.

          6. Various  debugger  enhancements,   including   a   limited
             symbolic capability.

          7. Support for the Motorola VME-10(tm) as the sample  system.
             The EXORmacs BIOS sources are also included as examples.

                                68010 Support
                                -------------

      With the exception of programs which execute in Supervisor state,
      it  should  be  possible  to  run all CP/M-68K V1.1 programs on a
      68010 system  without  change.   CP/M-68K  on  a  68010  supports
      programs  which use the "MOVE from SR" instruction, which was not
      privileged on the 68000, but is privileged  on  the  68010.   The
      68010  privilege violation handler dynamically changes "MOVE from
      SR" instructions to the non-privileged "MOVE from  CCR"  instruc-
      tion.   User programs which handled exceptions using the BDOS Set
      Exception function (61) need not be changed.  CP/M-68K  simulates
      the 68000 exception stack frame on the 68010.  


















      CP/M-68K Version 1.2 README.TXT File                       Page 2
                                                               05/14/84


      To build the system for a 68010, use the submit file "LCPM10.SUB"
      rather than the normal file "LCPM.SUB".  

                              DDT Enhancements
                              ----------------

      DDT has been upgraded to support symbols in the program  file  to
      be  debugged.  Two versions of the debugger are available:  "DDT"
      for the 68000 chip, and "DDT10" for the 68010.  Symbols automati-
      cally  appear in disassembled instructions using the "l" command.
      You can specify a symbol in a command by  prepending  it  with  a
      period  (".").   For  example,  to  go from the current PC to the
      symbol "quit" in the object program, you would specify:

                g,.quit

      You can use a symbol anywhere you normally would  specify  a  hex
      number.   When  using this feature with C programs, remember that
      the C compiler prepends an underscore ("") to  the  beginning  of
      external  symbols.  For example, to "go" with a breakpoint at the
      C function "blivot", you type:

                g,.blivot

      Additionally, you can use the "tw" command to single-step over  a
      call  instruction,  and  the  "p"  command  to  set  a  permanent
      breakpoint.  "-p" will remove a permanent breakpoint.

                   Generating A System with S-Record Files
                   ---------------------------------------

      The two S-Record files, "CPM400.SR" and "CPM15000.SR", are  built
      with no BIOS code.  These two systems are ORG'ed at 400 (hex) and
      15000 (hex), respectively.   A  hard-wired  equate  was  used  to
      establish  the BIOS "init" entry point within CP/M-68K.  There is
      no need to patch the S-Record files as  in  CP/M-68K  V1.1.   The
      BIOS may be placed following the "init" point in memory.  You can
      determine the address of "init" and the address of the  ccp  (for
      doing  warmboots)  by  looking  in  the  files  "CPM400.MAP", and
      "CPM15000.MAP".  These files  are  the  output  of  NM68  on  the
      "CPM.SYS"  file for these two systems.  The values of the symbols
      correspond to the actual memory addresses.  (I.e.,  we  used  the
      "-t" switch of the linker, rather than RELOC, to ORG the system).
      You can generate a system from these files  as  outlined  in  the
      "CP/M-68K System Guide".

















      CP/M-68K Version 1.2 README.TXT File                       Page 3
                                                               05/14/84


                               VME-10 Support
                               --------------

      There are now two distribution formats  for  CP/M-68K:   standard
      8-inch  3740  compatible  floppies,  and  VME-10 format 5.25 inch
      floppies.  The 8-inch version will boot on an EXORmacs(tm), while
      the 5.25 inch format boots on a Motorola VME-10.

      The sample system  for  CP/M-68K  is  now  the  Motorola  VME-10,
      instead  of  the  EXORmacs(tm).   The  floppies supplied with the
      VME-10 system are 96tpi, 160 tracks (80  cylinders),  with  eight
      512  byte  sectors  per  track.   Tracks are numbered in a manner
      compatible with the IBM Personal Computer  (tm)  format.   Tracks
      0-79  are  on  side  0 of the disk, and tracks 80-159 are on side
      one.  There are two reserved tracks, and 128 directory entries.

      Due to a TENbug requirement for bootable diskettes, track 0  con-
      tains  16  single-density  128-Byte  sectors  and  track  159  is
      reserved, in addition to tracks 0 and 1, for the LOADER.   (Track
      159  is directly opposite of Track 0 of Side 0 on Side 1.  Tracks
      0 and 1 are reserved by limiting the disk size in the  DSM  entry
      of the DPB to 157 tracks.)

                              VME/10 Memory Map
                              -----------------

      The location of the CP/M-68K system can be changed by  the  user.
      For  certain application programs it may be necessary to relocate
      the CP/M-68K system to higher system  addresses.   The  Transient
      Program  Area (TPA) starts at C00 (Hex address just above the RAM
      area reserved  for  TENbug)  and  continues  to  just  below  the
      CP/M-68K  System.   The system is shipped relocated to execute at
      28000 (Hex).  There will be  a  conflict  if  a  user  wishes  to
      utilize  the high-resolution graphics capabilities of the VME/10.
      The graphics RAM starts at 30000 (Hex) when  in  high  resolution
      mode and 48000 (Hex) when in low-resolution mode.

      Also the use of the RAM disk (device e:) conflicts with  the  use
      of  the  graphics  RAM.   Refere to the VME/10 system manuals for
      more information.

                              VME/10 Utilities
                              ----------------

      Three VME-10-specific utilities are included in the distribution:
      TERM, CONFIG and XFER86.  
















      CP/M-68K Version 1.2 README.TXT File                       Page 4
                                                               05/14/84


                     The TERM Terminal Emulation Program
                     -----------------------------------

      TERM is a terminal emulation program which allows you to  emulate
      a  DEC  VT-52(tm)  terminal  using an MVME400 serial card.  It is
      invoked as TERM.REL.  To use the terminal  program  you  need  an
      MVME-400  Dual  Serial Port Card.  It will be necessary to recon-
      figure the board for use in the term program by transferring  the
      jumpers  from  J15  to  J14 (10 jumpers total).  The TERM program
      expects to see the board at Hex  address  0xf1c1cd,  the  factory
      default.

      The serial port #1 is the Auxiliary device  used  for  the  link.
      TERM  operates  in  a  transparent mode until receiving a command
      character from the remote machine, the  command  character  is  a
      Control-A.   It  is  followed by a single letter which allows you
      to:

         o - Open a file on the CP/M-68K system and  redirect  the  I/O
             stream  from  the  serial line to that file instead of the
             screen.

         c - Close a file previously opened return output  stream  from
             the remote host to the screen.

         u - Upload a  file  from  the  CP/M-68K  system  to  the  host
             (ASCII).

      The 'o' and 'u' commands expect a filename to follow  immediately
      behind the command and terminated with a new line.

      Commands from the keyboard are:

         h - Display the help screen.

         o - Open a file and redirect the stream from the host into it.

         c - Close a file previously  opened,  flush  the  buffers  and
             direct the output stream from the back to the screen.

         q - Exit the terminal program.


      Using the TERM program as a terminal emulator  is  trivial.   The
      program  will copy all input from the keyboard to the serial port
      and all output from the remote host from the port to  the  screen
      (unless  redirected).  This is the mode in which the TERM program
      comes up.  The TERM program emulates a DEC VT52 terminal and  the
      program  has been used very successfully with screen editors such
      as the UNIX System V vi(1) screen editor.












      CP/M-68K Version 1.2 README.TXT File                       Page 5
                                                               05/14/84


      To download a file from the host to  the  VME/10,  the  following
      pseudo "C" program on the host will accomplish that:

                char filename[] = "myfile.c";
                /*
                 * send command to TERM program to open "filename"
                 * with the two byte sequence "Ctl-Ao" followed by
                 * the filename.
                 */
                printf("\001o%s", filename);
                {
                  this section just does a byte by  byte  copy  of  the
                  ASCII  source  on  the host to the standard output of
                  the program.  It will be caught by the  TERM  program
                  and put into the file specified above.
                }
                printf("\001c");

      The TERM program will detect the 'CTL-A' (\001) and 'o' pair  and
      read  the  characters  following  it  as  a file name to open and
      redirect its input from the host (the host's output stream)  into
      it until detecting the 'CTL-A', 'c' pair to close the file.

      The upload  feature  works  in  a  similar  manner.   It  is  not
      necessary  to  write  a  program  to  initiate  the downloads and
      uploads, it is possible to write a command script on some systems
      (e.g.   UNIX)  to echo the command start sequence, print the file
      and echo the close command.

                             The CONFIG Program
                             ------------------

      The CONFIG allows you to set the serial port baud rate.

                             The XFER86 Program
                             ------------------

      XFER86 is a program which will allow you to read (but not  write)
      diskettes written by CP/M-86 on an IBM Personal Computer.  XFER86
      provides a file transfer capability from CCP/M-86  disks  written
      by the IBM PC to CP/M-68K running on the VME/10.  XFER86 provides
      this capability by modifying the disk parameter block  (DPB)  for
      the CCP/M-86 disk.

      The procedure for transferring files is:

















      CP/M-68K Version 1.2 README.TXT File                       Page 6
                                                               05/14/84


          1. Execute XFER86.

          2. XFER86 will request you to insert the  CCP/M-86  disk,  do
             so.

          3. type c <return>.  XFER86 modifies the DPB and  returns  to
             CP/M-68K.

          4. transfer files from the CCP/M-86 disk (a:) to  the  VME/10
             hard  disk  (c:)  using  pip.  The disk may be removed and
             replaced with other CCP/M-86 disks with  the  same  format
             for further file transfers.

          5. Execute XFER86 to restore the DPB.

          6. XFER86 will request you to insert the  CCP/M-86  disk,  do
             so.

          7. Type r <return>.  XFER86 restores the DPB and  returns  to
             CP/M-68K.


      XFER86 requires the following disk format for proper operation of
      the file transfers:

                48 tpi, DSDD, 40 cylinders, 8 512-byte sectors/track

      XFER86 requires the following CCP/M-86 disk parameters for proper
      operation  of the file transfers.  These parameters may be varied
      on the CCP/M-86 system using its "show dsk:" command:

                2,528: 128-byte records
                  316: kilobyte drive capacity
                   64: 32-byte directory entries
                  256: 128-byte records/directory entry
                   16: 128-byte records/block
                   32: 128-byte records/track
                    1: reserved track

                       VME/10 BIOS Terminal Emulation
                       ------------------------------

      The VME-10 BIOS  emulates  a  VT-52  terminal,  so  you  can  use
      screen-oriented programs by configuring them for a VT-52.  


















      CP/M-68K Version 1.2 README.TXT File                       Page 7
                                                               05/14/84


                      Machine Specific PUTBOOT Utility
                      --------------------------------

      The PUTBOOT utility also contains VME-10 specific code.  The  old
      version  (for the EXORmacs) is contained in file "XPUTBOOT.S" and
      is included as a reference.

                         Known bugs in CP/M-68K V1.2
                         ---------------------------

          1. The assembler (AS68.68K) generates files with bad  reloca-
             tion  bits  when a "movec" instruction follows an instruc-
             tion which references a symbol.  The following example:

                            move.l  d0,a
                            movec   vbr,d0
                            move.l  d0,b
                            .data
                     a:     .dc.l   0
                     b:     .dc.l   0

             illustrates the problem.   A  workaround  is  to  place  a
             ".dc.w  $4e71"  statement  following  the  movec  instruc-
             tion.  (4e71 is a NOP instruction).  The  assembler  gives
             no error message, but neither linker (LO68 or LINK68) will
             accept the file as input.

          2. The assembler (AS68.68K) places a  single-character  ASCII
             constant in the high byte of a word operand.  For example:

                     move.w      #'U',d1

             loads d1 with the hex constant  "5500".   Of  course,  the
             argument could be made that you should use a byte instruc-
             tion to do single character moves.

          3. The assembler (AS68.68K) will evaluate  a  symbol  of  the
             form  "$xyz" as a hex constant with value 0.  If used on a
             single operand directive, such as:

                     .dc.b       $xyz

             the offending statement is not flagged with an error.

          4. The editor (ED.68K), when invoked using an  output  drive,
             e.g:
















      CP/M-68K Version 1.2 README.TXT File                       Page 8
                                                               05/14/84


                     ED file b:

             will not create the file on the output drive.

          5. The editor (ED.68K) "Juxtapose" command does not  function
             properly when specified with a repeat count.

          6. The editor (ED.68K)  X  command  does  not  respond  in  a
             friendly  manner  to  an  invalid syntax.  When an invalid
             filename is used,  such  as  "x23:t",  the  editor  prints
             "INVALID  FILENAME"  and  exits  to  the operating system.
             This obliterates any editing session in progress.

          7. The C  compiler  generates  an  incorrect  error  message,
             "Initializer  Alignment", on a statement which initializes
             a static unsigned or float array.

          8. The C compiler does not correctly handle the modulo  ("%")
             operator in constant expressions.

          9. The C compiler will not properly substitute a macro  argu-
             ment inside a quoted string if the argument is preceded by
             a backslash escape sequence.  For example,

                     #define x(a) printf("\na");

             will not expand properly.  Placing  a  space  between  the
             escape sequence and the argument fixes the problem.

         10. The C compiler will not substitute a macro argument inside
             a  quoted  string if the text to be substituted contains a
             single quote character.

         11. The C compiler will not properly handle initializations of
             auto  variables  with  register  variable parameters.  For
             example:

                     func(a,b)
                     register int a,b;
                     {
                        int i=a+b;
                     }

             will not initialize the variable "i" to the proper  value.
             If the parameters are not declared as "register", the ini-
             tialization will work.

         12. The  C  compiler  does  not  properly  handle  expressions
             involving  pointers  with non-unique structure names.  The
             sequence:












      CP/M-68K Version 1.2 README.TXT File                       Page 9
                                                               05/14/84


                     struct s1 {struct s2 *a,*b;};
                     struct s2 {struct s1 *b,*a;};
                                       .
                                       .
                                       .
                             q = ((p->a)->a)->a;

             does not properly initialize "q".

         13. The compiler  does  not  properly  handle  byte  subscript
             expressions  involving  the  "++" and "--" operators.  The
             following sequence does not work:

                     char x[100];
                     func() {
                            char y;
                            y = x[++x[0]];

             A workaround is to rewrite  the  subscript  expression  so
             that  the  "++"  operation  is  done before (or after) the
             indexing:

                            x[0]++;
                            y = x[x[0]];

         14. The compiler does  not  properly  initialize  a  structure
             which contains an array of structures.

         15. The C Preprocessor will occasionally eat  a  line  or  two
             following  a "#include" declaration.  The workaround is to
             append some blank  lines  to  the  "#include"  occurrence.
             This  can produce some hard to track down bugs if variable
             declarations are lost due to the bug.

         16. Conditional assembly occasionally  causes  loss  of  label
             immediately  preceding conditional statement in the assem-
             bler.

         17. The assembler can be made  to  generate  code  at  an  odd
             address  by  embedding  odd  byte  length data in the text
             section.  The  assembler  will  not  realign  its  program
             counter  to an even address.  The user should pad the data
             in the text section to an even byte boundary himself.

         18. The compiler will generate an error message for:

















      CP/M-68K Version 1.2 README.TXT File                      Page 10
                                                               05/14/84


                     struct a { long x; };
                     struct b { char x; };

             due to the non-unique member names in the structure.  Make
             them unique.

                            Trademark Information
                            ---------------------

      CP/M-68K is a trademark of Digital Research.  Motorola, EXORmacs,
      and  VME-10 are trademarks of Motorola.  IBM Personal Computer is
      a trademark of IBM.  DEC and  VT-52  are  trademarks  of  Digital
      Equipment Corporation.  UNIX is a trademark of Bell Laboratories.

                   