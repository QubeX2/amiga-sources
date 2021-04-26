          IFND    SYSTEM_I
SYSTEM_I  SET     1
************************************************************
* doslib
*
_Open           equ -30
_Close          equ -36
_Read           equ -42
_Write          equ -48
_Lock           equ -84
_UnLock         equ -90
_CurrentDir     equ -126
_ReadArgs       equ -798
_FreeArgs       equ -858

************************************************************
* intuition
*
_RethinkDisplay equ -390

************************************************************
* execlib
*
_OpenLibrary    equ -552
_CloseLibrary   equ -414
_Disable        equ -120
_Enable         equ -126
_Forbid         equ -132
_Permit         equ -138
_Supervisor     equ -30
_AllocMem       equ -198
_FreeMem        equ -210
_FindTask       equ -294
_SetTaskPri     equ -300
_WaitPort       equ -384
_GetMsg         equ -372
_ReplyMsg       equ -378

AttnFlags         = 296

************************************************************
* gfxlib
*
_LoadView       equ -222
_WaitBlit       equ -228
_WaitTOF        equ -270
_OwnBlit        equ -456
_DisownBlit     equ -462

ActiView        equ $22
SysCop1         equ $26
SysCop2         equ $32

          ENDC                ; SYSTEM_I
