                    ifne      MECB.D-1
MECB.D              set       1

********************************************************************
* mecb.d - NitrOS-9 System Definitions for the Digicool MECB 6809
*
* This is a high level view of the Digicool MECB 6809 memory map as setup by
* NitrOS-9.
*
*     $0000----> ==================================
*               |                                  |
*               |      NitrOS-9 Globals/Stack      |
*               |                                  |
*     $0500---->|==================================|
*               |                                  |
*                 . . . . . . . . . . . . . . . . .
*               |                                  |
*               |   RAM available for allocation   |
*               |       by NitrOS-9 and Apps       |
*               |                                  |
*                 . . . . . . . . . . . . . . . . .
*               |                                  |
*     $DFFF---->|==================================|
*               |                                  |
*  $E000-$E0FF  |    Memory Mapped I/O Region      |
*               |                                  |
*     $E100---->|==================================|
*               |                                  |
*  $E100-$FFFF  |               ROM                |
*               |                                  |
*               |==================================|
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2017/04/29  Boisy G. Pitre
* Started

                    nam       mecb.d
                    ttl       NitrOS-9 System Definitions for the Digicool MECB 6809

**********************************
* Ticks per second
*
                    IFNDEF    TkPerSec
TkPerSec            SET       50
                    ENDC


*************************************************
*
* NitrOS-9 Level 1 Section
*
*************************************************

; Presumably indicates where hardware is? epaell
HW.Page             set       $E0                 Device descriptor hardware page


********************************************************************
* NitrOS-9 Memory Definitions for the DigiCool MECB 6809
*

********************************************************************
* Digicool MECB 6809 Hardware Definitions
*

S.FNexec            EQU       $FFE3
S.Hex2Out           EQU       $FFE5
S.Hex4Out           EQU       $FFE7
S.CharOut           EQU       $FFE9
S.StringOut         EQU       $FFEB

IOBASE              equ       $E000

;----------------------------------------------------
;
; Which slot the parallel board is in.  This needs to
; be set for the system in use.  As long as the user
; programs only call functions in here, no other
; file/application should know which slot the board
; is in.

PTMBase              equ      IOBASE+$0000
UARTBase             equ      IOBASE+$0008
PIA0Base             equ      IOBASE+$0010
RTCBase              equ      IOBASE+$00C0
IOPORTBase           equ      IOBASE+$00C1
FNBASE               equ      IOBASE+$00C2

PTM                  equ      PTMBase
PTMCR13              equ      PTMBase         ; Timer Control Registers 1 & 3
PTMSR                equ      PTMBase+1       ; Timer Status Register
PTMCR2               equ      PTMBase+1       ; Timer Control Register 2
PTMT1MSB             equ      PTMBase+2       ; MSB Buffer Register
PTMT1LSB             equ      PTMBase+3       ; Timer #1 Latches

                    org       $DFC0
C.STACK             RMB       2                   TOP OF INTERNAL STACK / USER VECTOR
C.SWI3              RMB       2                   SOFTWARE INTERRUPT VECTOR #3
C.SWI2              RMB       2                   SOFTWARE INTERRUPT VECTOR #2
C.FIRQ              RMB       2                   FAST INTERRUPT VECTOR
C.IRQ               RMB       2                   INTERRUPT VECTOR
C.SWI               RMB       2                   SOFTWARE INTERRUPT VECTOR
SVCVO               RMB       2                   SUPERVISOR CALL VECTOR ORGIN
SVCVL               RMB       2                   SUPERVISOR CALL VECTOR LIMIT
LRARAM              RMB       16                  LRA ADDRESSES

Bt.Start            EQU       $E100               Start address of the boot ROM in memory
Bt.Size             EQU       $1F00
Bt.Track            EQU       0
Bt.Sec              EQU       0

; FujiNet SPI has the following bits:
;
;  Input:
;      Bit 7 = BUS_READY*     (MASK_CMD_READY, BIT_CMD_RDY)
;      Bit 6 = BUS_PROCEED*   (MASK_PROCEED, BIT_PROCEED)
;      Bit 1-5 = UNUSED
;      Bit 0 = BUS_MISO       (MASK_MISO, BIT_MISO)
;
MASK_CMD_RDY               equ   $80
MASK_PROCEED               equ   $40
MASK_MISO                  equ   $01
BIT_CMD_RDY                equ   7
BIT_PROCEED                equ   6
BIT_MISO                   equ   0

;
; Output:
;      Bit 7 = BUS_CMD*       (MASK_CMD,BIT_CMD)
;      Bit 6 = BUS_DATA*
;      Bit 3-5 = UNUSED
;      Bit 2 = BUS_CS*
;      Bit 1 = BUS_MOSI       (MASK_MOSI,BIT_MOSI)
;      Bit 0 = BUS_CLK
;
MASK_CMD                   equ   $80
MASK_MOSI                  equ   $02
MASK_SPI                   equ   $fc   ; Mask out all but BUS_CLK and BUS_MOSI
FN_INIT                    equ   $fe   ; BUS_CLK low, BUS_MOSI high
BIT_CMD                    equ   7
BIT_MOSI                   equ   1
BIT_CLK                    equ   0

MSCNT1MHZ   equ   122      ; number of loops to delay 1 mS with 1 MHz 6809 CPU
MSCNT2MHZ   equ   247      ; number of loops to delay 1 mS with 2 MHz 6809 CPU

;****************************************************
; FujiNet protocol
;
RC2014_DEVICEID_DISK                equ   $31
RC2014_DEVICEID_DISK_LAST           equ   $3F

RC2014_DEVICEID_PRINTER             equ   $41
RC2014_DEVICEID_PRINTER_LAST        equ   $44

RC2014_DEVICEID_FILE                equ   $61

RC2014_DEVICEID_FUJINET             equ   $70
RC2014_DEVICEID_NETWORK             equ   $71
RC2014_DEVICEID_NETWORK_LAST        equ   $78

RC2014_DEVICEID_MODEM               equ   $50

RC2014_DEVICEID_CPM                 equ   $5A
;
; Device commands
;
DEVICE_OPEN                         equ   'O'
DEVICE_STATUS                       equ   'S'
DEVICE_READ                         equ   'R'
DEVICE_WRITE                        equ   'W'
DEVICE_CLOSE                        equ   'C'
DEVICE_QUERY                        equ   'Q'
DEVICE_PARSE                        equ   'P'
DEVICE_LOGIN                        equ   $FD
DEVICE_CHANNEL_MODE                 equ   $FC
;
;
; Definition of DCB offsets from common section
;
DCB_DEVICE                          equ   0
DCB_COMMAND                         equ   1
DCB_AUX1                            equ   2
DCB_AUX2                            equ   3
DCB_CHECKSUM                        equ   4
DCB_TX_BUFFER                       equ   4
DCB_TX_BUFFER_LEN                   equ   6
DCB_RX_BUFFER                       equ   8
DCB_RX_BUFFER_LEN                   equ   10
DCB_TIMEOUT                         equ   12

DCB_SIZE                            equ   14

;
; FUJINET_RC
;
FUJINET_RC_OK                       equ   0
FUJINET_RC_NOT_IMPLEMENTED          equ   1
FUJINET_RC_NOT_SUPPORTED            equ   2
FUJINET_RC_INVALID                  equ   3
FUJINET_RC_TIMEOUT                  equ   4
FUJINET_RC_NO_ACK                   equ   5
FUJINET_RC_NO_COMPLETE              equ   6
;
; WiFi Status Codes
;
WIFI_IDLE                           equ   0
WIFI_NOSSID                         equ   1
WIFI_SCAN_COMPLETE                  equ   2
WIFI_CONNECTED                      equ   3
WIFI_CONNECT_FAIL                   equ   4
WIFI_CONNECTION_LOST                equ   5
WIFI_DISCONNECTED                   equ   6

; Network extended_error
NETWORK_ERROR_SUCCESS                        equ   1     ; $01
NETWORK_ERROR_WRITE_ONLY                     equ   131   ; $83
NETWORK_ERROR_INVALID_COMMAND                equ   132   ; $84
NETWORK_ERROR_READ_ONLY                      equ   135   ; $87
NETWORK_ERROR_END_OF_FILE                    equ   136   ; $88
NETWORK_ERROR_GENERAL_TIMEOUT                equ   138   ; $8a
NETWORK_ERROR_GENERAL                        equ   144   ; $90
NETWORK_ERROR_NOT_IMPLEMENTED                equ   146   ; $92
NETWORK_ERROR_FILE_EXISTS                    equ   151   ; $97
NETWORK_ERROR_NO_SPACE_ON_DEVICE             equ   162   ; $a2
NETWORK_ERROR_INVALID_DEVICESPEC             equ   165   ; $a5
NETWORK_ERROR_ACCESS_DENIED                  equ   167   ; $a7
NETWORK_ERROR_FILE_NOT_FOUND                 equ   170   ; $aa
NETWORK_ERROR_CONNECTION_REFUSED             equ   200   ; $c8
NETWORK_ERROR_NETWORK_UNREACHABLE            equ   201   ; $c9
NETWORK_ERROR_SOCKET_TIMEOUT                 equ   202   ; $ca
NETWORK_ERROR_NETWORK_DOWN                   equ   203   ; $cb
NETWORK_ERROR_CONNECTION_RESET               equ   204   ; $cc
NETWORK_ERROR_CONNECTION_ALREADY_IN_PROGRESS equ   205   ; $cd
NETWORK_ERROR_ADDRESS_IN_USE                 equ   206   ; $ce
NETWORK_ERROR_NOT_CONNECTED                  equ   207   ; $cf
NETWORK_ERROR_SERVER_NOT_RUNNING             equ   208   ; $d0
NETWORK_ERROR_NO_CONNECTION_WAITING          equ   209   ; $d1
NETWORK_ERROR_SERVICE_NOT_AVAILABLE          equ   210   ; $d2
NETWORK_ERROR_CONNECTION_ABORTED             equ   211   ; $d3
NETWORK_ERROR_INVALID_USERNAME_OR_PASSWORD   equ   212   ; $d4
NETWORK_ERROR_COULD_NOT_ALLOCATE_BUFFERS     equ   255   ; $ff

;
; FujiNet commands
;
FUJICMD_RESET                       equ   $FF ; done
FUJICMD_GET_SSID                    equ   $FE ; F
FUJICMD_SCAN_NETWORKS               equ   $FD ; done
FUJICMD_GET_SCAN_RESULT             equ   $FC ; done
FUJICMD_SET_SSID                    equ   $FB ; done
FUJICMD_GET_WIFISTATUS              equ   $FA ; F
FUJICMD_MOUNT_HOST                  equ   $F9 ; done
FUJICMD_MOUNT_IMAGE                 equ   $F8 ; done
FUJICMD_OPEN_DIRECTORY              equ   $F7 ; done
FUJICMD_READ_DIR_ENTRY              equ   $F6 ; done
FUJICMD_CLOSE_DIRECTORY             equ   $F5 ; done
FUJICMD_READ_HOST_SLOTS             equ   $F4 ; done
FUJICMD_WRITE_HOST_SLOTS            equ   $F3 ; F
FUJICMD_READ_DEVICE_SLOTS           equ   $F2 ; done
FUJICMD_WRITE_DEVICE_SLOTS          equ   $F1 ; F
FUJICMD_GET_WIFI_ENABLED            equ   $EA ; not implemented in firmware
FUJICMD_UNMOUNT_IMAGE               equ   $E9 ; done
FUJICMD_GET_ADAPTERCONFIG           equ   $E8 ; F
FUJICMD_NEW_DISK                    equ   $E7 ; not implemented in firmware
FUJICMD_UNMOUNT_HOST                equ   $E6 ; not implemented in firmware
FUJICMD_GET_DIRECTORY_POSITION      equ   $E5 ; F
FUJICMD_SET_DIRECTORY_POSITION      equ   $E4 ; F
FUJICMD_SET_DEVICE_FULLPATH         equ   $E2 ; F - for a given device slot set the full path for a file
FUJICMD_SET_HOST_PREFIX             equ   $E1 ; not implemented in firmware
FUJICMD_GET_HOST_PREFIX             equ   $E0 ; not implemented in firmware
FUJICMD_WRITE_APPKEY                equ   $DE ; not implemented in firmware
FUJICMD_READ_APPKEY                 equ   $DD ; not implemented in firmware
FUJICMD_OPEN_APPKEY                 equ   $DC ; not implemented in firmware
FUJICMD_CLOSE_APPKEY                equ   $DB ; not implemented in firmware
FUJICMD_GET_DEVICE_FULLPATH         equ   $DA ; F - for a given device slot return the full path for a file
FUJICMD_CONFIG_BOOT                 equ   $D9 ; F
FUJICMD_COPY_FILE                   equ   $D8 ; not implemented in firmware
FUJICMD_MOUNT_ALL                   equ   $D7 ; done
FUJICMD_SET_BOOT_MODE               equ   $D6 ; not implemented in firmware
FUJICMD_STATUS                      equ   $53 ; not implemented in firmware
FUJICMD_ENABLE_DEVICE               equ   $D5 ; F
FUJICMD_DISABLE_DEVICE              equ   $D4 ; F
FUJICMD_RANDOM_NUMBER               equ   $D3 ; done
FUJICMD_GET_TIME                    equ   $D2 ; done
FUJICMD_DEVICE_ENABLE_STATUS        equ   $D1 ; F
FUJICMD_BASE64_ENCODE_INPUT         equ   $D0 ; F
FUJICMD_BASE64_ENCODE_COMPUTE       equ   $CF ; F
FUJICMD_BASE64_ENCODE_LENGTH        equ   $CE ; F
FUJICMD_BASE64_ENCODE_OUTPUT        equ   $CD ; F
FUJICMD_BASE64_DECODE_INPUT         equ   $CC ; F
FUJICMD_BASE64_DECODE_COMPUTE       equ   $CB ; F
FUJICMD_BASE64_DECODE_LENGTH        equ   $CA ; F
FUJICMD_BASE64_DECODE_OUTPUT        equ   $C9 ; F
FUJICMD_HASH_INPUT                  equ   $C8 ; F
FUJICMD_HASH_COMPUTE                equ   $C7 ; F
FUJICMD_HASH_LENGTH                 equ   $C6 ; F
FUJICMD_HASH_OUTPUT                 equ   $C5 ; F
FUJICMD_GET_ADAPTERCONFIG_EXTENDED  equ   $C4 ; not implemented in firmware
FUJICMD_HASH_COMPUTE_NO_CLEAR       equ   $C3 ; F
FUJICMD_HASH_CLEAR                  equ   $C2 ; F
FUJICMD_GENERATE_GUID               equ   $BB ; not implemented in firmware
FUJICMD_SET_STATUS                  equ   $81 ; not implemented in firmware
;
FUJINET_TIMEOUT                     equ   15000
FUJINET_NETWORK_TIMEOUT             equ   30000
;
; Data structures used by FuijiNet
;
MAX_FILE_LEN                        equ   36
MAX_SSID_LEN                        equ   33 ; 32 + NULL
MAX_SSID_PW_LEN                     equ   64
MODE_READ                           equ   1
MODE_WRITE                          equ   2

MAX_HOST_LEN                        equ   32
NUM_HOST_SLOTS                      equ   8
FUJINET_MAX_HOST_SLOTS              equ   8
FUJINET_MAX_DEVICE_SLOTS            equ   8
DIR_ENTRY_ATTR_LEN                  equ   12
MAX_PATH_LEN                        equ   256
DISK_SECTOR_SIZE                    equ   256
MAX_NETWORK_UNITS                   equ   8

; Network
CHANNELMODE_PROTOCOL                equ   0
CHANNELMODE_JSON                    equ   1
FN_TIME_YEARH                       equ   0
FN_TIME_YEARL                       equ   1
FN_TIME_MONTH                       equ   2
FN_TIME_MDAY                        equ   3
FN_TIME_HOUR                        equ   4
FN_TIME_MIN                         equ   5
FN_TIME_SEC                         equ   6

MAX_FILE_HANDLE                     equ   8
FILE_STATUS_LEN                     equ   6  ; 2 bytes and a long int
NETWORK_STATUS_LEN                  equ   4
TIME_LEN                            equ   7
APPKEY_OPEN_LEN                     equ   6

;
; file modes
;
OREAD                               equ   $4
OWRITE                              equ   $8
OUPDATE                             equ   $C
;
ENTRY_TYPE_TEXT                     equ   0
ENTRY_TYPE_FOLDER                   equ   1
ENTRY_TYPE_FILE                     equ   2
ENTRY_TYPE_LINK                     equ   3
ENTRY_TYPE_MENU                     equ   4

; file_flags definitions
DIR_ENTRY_FF_DIR                    equ   1
DIR_ENTRY_FF_TRUNC                  equ   2

; file_type definitions
DIR_ENTRY_FT_UNKNOWN                equ   0

; Network line translation
NET_TRANS_NONE                      equ   0
NET_TRANS_CR                        equ   1
NET_TRANS_LF                        equ   2
NET_TRANS_CRLF                      equ   3

;=====================================================
; FNIO subroutine module offsets
;
                    org       0
FNIO$Init           rmb       3
FNIO$Exec           rmb       3
FNIO$Term           rmb       3

                    endc
