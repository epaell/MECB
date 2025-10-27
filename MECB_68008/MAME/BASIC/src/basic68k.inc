
* This lot is in RAM

ram_strt    = $0000
ram_base    = $0400
LAB_WARM    = $0400
Wrmjpv      = $0402
Usrjmp      = $0406
Usrjpv      = $0408
V_INPT      = $040C
V_INPTv     = $040E
V_OUTP      = $0412
V_OUTPv     = $0414
V_LOAD      = $0418
V_LOADv     = $041A
V_SAVE      = $041E
V_SAVEv     = $0420
V_CTLC      = $0424
V_CTLCv     = $0426
Itemp       = $042A
Smeml       = $042E
Sfncl       = $0432
Svarl       = $0436
Sstrl       = $043A
Sarryl      = $043E
Earryl      = $0442
Sstorl      = $0446
Ememl       = $044A
Sutill      = $044E
Clinel      = $0452
Blinel      = $0456
Cpntrl      = $045A
Dlinel      = $045E
Dptrl       = $0462
Rdptrl      = $0466
Varname     = $046A
Cvaral      = $046E
Lvarpl      = $0472
des_sk_e    = $0476
des_sk      = $048E
Ibuffs      = $0490
Ibuffe      = $0590
FAC1_m      = $0590
FAC1_e      = $0594
FAC1_s      = $0595
FAC2_m      = $0598
FAC2_e      = $059C
FAC2_s      = $059D
FAC_sc      = $059E
flag        = $059F
PRNlword    = $05A0
ut1_pl      = $05A4
Asptl       = $05A8
Astrtl      = $05AC
numexp      = $05AC
expcnt      = $05AD
expneg      = $05AF
func_l      = $05B0
Defdim      = $05B4
cosout      = $05B4
Dtypef      = $05B5
Binss       = $05B6
Decss       = $05C6
Usdss       = $05CC
Hexss       = $05CE
BHsend      = $05D6
prstk       = $05D8
tpower      = $05D9
Asrch       = $05DA
Dimcnt      = $05DB
Breakf      = $05DC
Oquote      = $05DD
Gclctd      = $05DE
Sufnxf      = $05DF
Imode       = $05E0
Cflag       = $05E1
TabSiz      = $05E2
comp_f      = $05E3
Nullct      = $05E4
TPos        = $05E5
TWidth      = $05E6
Iclim       = $05E7
ccflag      = $05E8
ccbyte      = $05E9
ccnull      = $05EA
load_first  = $05EB
load_filename  = $05EC
prg_strt    = $05EC

* Use these two lines when running from ROM
ram_addr	EQU	$08000		* RAM start address
ram_size	EQU	$18000		* RAM size

* Use these two lines when running from RAM
*ram_addr	EQU	$04000		* RAM start address
*ram_size	EQU	$04000		* RAM size