;APS00000000000000000000000000000000000000000000000000000000000000000000000000000000
	IFND	HARDWARE_I
HARDWARE_I	SET	1
**
**
**
***********************************************************************************

	IFND	HARDWARE_CUSTOM_I
	INCLUDE	"hardware/custom.i"
	ENDC

***********************************************************************************
*
*
*
COPPER_HALT	equ	$fffffffe

CUSTOM		equ	$dff000
*
* AGA
*
BPLCON3		equ	bplcon3
FMODE		equ	fmode
BLTSIZV		equ	bltsizv
BLTSIZH		equ	bltsizh


*
* Various control registers
*
DMACONR		equ	dmaconr
VPOSR		equ	vposr
VHPOSR		equ	vhposr
JOY0DAT		equ	joy0dat
JOY1DAT		equ	joy1dat
CLXDAT		equ	clxdat
ADKCONR		equ	adkconr
POT0DAT		equ	pot0dat
POT1DAT		equ	pot1dat
POTINP		equ	potinp
SERDATR		equ	serdatr
INTENAR		equ	intenar
INTREQR		equ	intreqr
REFPTR		equ	refptr
VPOSW		equ	vposw
VHPOSW		equ	vhposw
SERDAT		equ	serdat
SERPER		equ	serper
POTGO		equ	potgo
JOYTEST		equ	joytest
STREQU		equ	strequ
STRVBL		equ	strvbl
STRHOR		equ	strhor
STRLONG		equ	strlong
DIWSTRT		equ	diwstrt
DIWSTOP		equ	diwstop
DDFSTRT		equ	ddfstrt
DDFSTOP		equ	ddfstop
DMACON		equ	dmacon
INTENA		equ	intena
INTREQ		equ	intreq
*
* Disk control registers
*
DSKBYTR		equ	dskbytr
DSKPT		equ	dskpt
DSKPTH		equ	dskpt
DSKPTL		equ	dskpt+$02
DSKLEN		equ	dsklen
DSKDAT		equ	dskdat
DSKSYNC		equ	dsksync
*
* Blitter registers
*
BLTCON0		equ	bltcon0
BLTCON1		equ	bltcon1
BLTAFWM		equ	bltafwm
BLTALWM		equ	bltalwm
BLTCPT		equ	bltcpt
BLTCPTH		equ	bltcpt
BLTCPTL		equ	bltcpt+$02
BLTBPT		equ	bltbpt
BLTBPTH		equ	bltbpt
BLTBPTL		equ	bltbpt+$02
BLTAPT		equ	bltapt
BLTAPTH		equ	bltapt
BLTAPTL		equ	bltapt+$02
BLTDPT		equ	bltdpt
BLTDPTH		equ	bltdpt
BLTDPTL		equ	bltdpt+$02
BLTSIZE		equ	bltsize
BLTCMOD		equ	bltcmod
BLTBMOD		equ	bltbmod
BLTAMOD		equ	bltamod
BLTDMOD		equ	bltdmod
BLTCDAT		equ	bltcdat
BLTBDAT		equ	bltbdat
BLTADAT		equ	bltadat
BLTDDAT		equ	bltddat
*
* Copper control registers
*
COPCON		equ	copcon
COPINS		equ	copins
COPJMP1		equ	copjmp1
COPJMP2		equ	copjmp2
COP1LC		equ	cop1lc
COP1LCH		equ	cop1lc
COP1LCL		equ	cop1lc+$02
COP2LC		equ	cop2lc
COP2LCH		equ	cop2lc
COP2LCL		equ	cop2lc+$02
*
* Audio channels registers
*
ADKCON		equ	adkcon
AUD0LC		equ	aud0
AUD0LCH		equ	aud0
AUD0LCL		equ	aud0+$02
AUD0LEN		equ	aud0+ac_len
AUD0PER		equ	aud0+ac_per
AUD0VOL		equ	aud0+ac_vol
AUD0DAT		equ	aud0+ac_dat

AUD1LC		equ	aud1
AUD1LCH		equ	aud1
AUD1LCL		equ	aud1+$02
AUD1LEN		equ	aud1+ac_len
AUD1PER		equ	aud1+ac_per
AUD1VOL		equ	aud1+ac_vol
AUD1DAT		equ	aud1+ac_dat

AUD2LC		equ	aud2
AUD2LCH		equ	aud2
AUD2LCL		equ	aud2+$02
AUD2LEN		equ	aud2+ac_len
AUD2PER		equ	aud2+ac_per
AUD2VOL		equ	aud2+ac_vol
AUD2DAT		equ	aud2+ac_dat

AUD3LC		equ	aud3
AUD3LCH		equ	aud3
AUD3LCL		equ	aud3+$02
AUD3LEN		equ	aud3+ac_len
AUD3PER		equ	aud3+ac_per
AUD3VOL		equ	aud3+ac_vol
AUD3DAT		equ	aud3+ac_dat
*
* The bitplane registers
*
BPL1PT		equ	bplpt+$00
BPL1PTH		equ	bplpt+$00
BPL1PTL		equ	bplpt+$02
BPL2PT		equ	bplpt+$04
BPL2PTH		equ	bplpt+$04
BPL2PTL		equ	bplpt+$06
BPL3PT		equ	bplpt+$08
BPL3PTH		equ	bplpt+$08
BPL3PTL		equ	bplpt+$0a
BPL4PT		equ	bplpt+$0c
BPL4PTH		equ	bplpt+$0c
BPL4PTL		equ	bplpt+$0e
BPL5PT		equ	bplpt+$10
BPL5PTH		equ	bplpt+$10
BPL5PTL		equ	bplpt+$12
BPL6PT		equ	bplpt+$14
BPL6PTH		equ	bplpt+$14
BPL6PTL		equ	bplpt+$16

BPLCON0		equ	bplcon0
BPLCON1		equ	bplcon1
BPLCON2		equ	bplcon2
BPL1MOD		equ	bpl1mod
BPL2MOD		equ	bpl2mod
DPL1DATA	equ	bpldat+$00
DPL2DATA	equ	bpldat+$02
DPL3DATA	equ	bpldat+$04
DPL4DATA	equ	bpldat+$06
DPL5DATA	equ	bpldat+$08
DPL6DATA	equ	bpldat+$0a
*
* Sprite control registers
*
SPR0PT		equ	sprpt+$00
SPR0PTH		equ	SPR0PT+$00
SPR0PTL		equ	SPR0PT+$02
SPR1PT		equ	sprpt+$04
SPR1PTH		equ	SPR1PT+$00
SPR1PTL		equ	SPR1PT+$02
SPR2PT		equ	sprpt+$08
SPR2PTH		equ	SPR2PT+$00
SPR2PTL		equ	SPR2PT+$02
SPR3PT		equ	sprpt+$0c
SPR3PTH		equ	SPR3PT+$00
SPR3PTL		equ	SPR3PT+$02
SPR4PT		equ	sprpt+$10
SPR4PTH		equ	SPR4PT+$00
SPR4PTL		equ	SPR4PT+$02
SPR5PT		equ	sprpt+$14
SPR5PTH		equ	SPR5PT+$00
SPR5PTL		equ	SPR5PT+$02
SPR6PT		equ	sprpt+$18
SPR6PTH		equ	SPR6PT+$00
SPR6PTL		equ	SPR6PT+$02
SPR7PT		equ	sprpt+$1c
SPR7PTH		equ	SPR7PT+$00
SPR7PTL		equ	SPR7PT+$02

SPR0POS		equ	spr+$00
SPR0CTL		equ	SPR0POS+sd_ctl
SPR0DATA	equ	SPR0POS+sd_dataa
SPR0DATB	equ	SPR0POS+sd_datab

SPR1POS		equ	spr+$08
SPR1CTL		equ	SPR1POS+sd_ctl
SPR1DATA	equ	SPR1POS+sd_dataa
SPR1DATB	equ	SPR1POS+sd_datab

SPR2POS		equ	spr+$10
SPR2CTL		equ	SPR2POS+sd_ctl
SPR2DATA	equ	SPR2POS+sd_dataa
SPR2DATB	equ	SPR2POS+sd_datab

SPR3POS		equ	spr+$18
SPR3CTL		equ	SPR3POS+sd_ctl
SPR3DATA	equ	SPR3POS+sd_dataa
SPR3DATB	equ	SPR3POS+sd_datab

SPR4POS		equ	spr+$20
SPR4CTL		equ	SPR4POS+sd_ctl
SPR4DATA	equ	SPR4POS+sd_dataa
SPR4DATB	equ	SPR4POS+sd_datab

SPR5POS		equ	spr+$28
SPR5CTL		equ	SPR5POS+sd_ctl
SPR5DATA	equ	SPR5POS+sd_dataa
SPR5DATB	equ	SPR5POS+sd_datab

SPR6POS		equ	spr+$30
SPR6CTL		equ	SPR6POS+sd_ctl
SPR6DATA	equ	SPR6POS+sd_dataa
SPR6DATB	equ	SPR6POS+sd_datab

SPR7POS		equ	spr+$38
SPR7CTL		equ	SPR7POS+sd_ctl
SPR7DATA	equ	SPR7POS+sd_dataa
SPR7DATB	equ	SPR7POS+sd_datab
*
* Color registers
*
COLOR00		equ	color+$00
COLOR01		equ	color+$02
COLOR02		equ	color+$04
COLOR03		equ	color+$06
COLOR04		equ	color+$08
COLOR05		equ	color+$0a
COLOR06		equ	color+$0c
COLOR07		equ	color+$0e
COLOR08		equ	color+$10
COLOR09		equ	color+$12
COLOR10		equ	color+$14
COLOR11		equ	color+$16
COLOR12		equ	color+$18
COLOR13		equ	color+$1a
COLOR14		equ	color+$1c
COLOR15		equ	color+$1e
COLOR16		equ	color+$20
COLOR17		equ	color+$22
COLOR18		equ	color+$24
COLOR19		equ	color+$26
COLOR20		equ	color+$28
COLOR21		equ	color+$2a
COLOR22		equ	color+$2c
COLOR23		equ	color+$2e
COLOR24		equ	color+$30
COLOR25		equ	color+$32
COLOR26		equ	color+$34
COLOR27		equ	color+$36
COLOR28		equ	color+$38
COLOR29		equ	color+$3a
COLOR30		equ	color+$3c
COLOR31		equ	color+$3e

*****************************************************************************
**
**
**
		ENDC	; HARDWARE_I