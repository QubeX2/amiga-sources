;APS000000000000000000000000000008C7000000000000000000000000000000000000000000000000
***********************************************************
* Code:	QubeX2
* Date:	2021-04-22
*
***********************************************************

	incdir		"include"
	include		"startup.s"

	section		CODE,code

****************************************************************************
* SETTINGS
*

***********************************************************
* START
*
start:	
	lea		CUSTOM,a6
	move.w		#(DMAF_SETCLR!DMAF_COPPER!DMAF_BLITTER!DMAF_RASTER!DMAF_MASTER),DMACON(a6)
	move.w		#(INTF_SETCLR!INTF_EXTER),INTENA(a6)

	move.l		#bitp1b,buf1
	move.l		#bitp1a,buf2

main:	WAITVB	main

	CLRS		buf1
	bsr		blit_block

wait:	WAITVB2	wait

	LMOUSE		main
	
	rts

***********************************************************
*

w	equ	4
h	equ	24

blit_block:
	movem.l		d0-d7/a0-a6,-(sp)

         ; = DEBUG =======================
         ;
	move.l		#8,d0
	cmp.l		#$f,d0
	ble		.cont1
	lsr.l		#4,d0
.cont1:	and.l		#$f,d0

         ; = END DEBUG ===================
	;addq.l	#1,V_TIMER

	; double buffer
	move.l		buf1,tmp
	move.l		buf2,buf1
	move.l		tmp,buf2

	lea		CUSTOM,a6

	BLTWAIT		bw1	

	move.w		#(DEST!SRCA!$f0),BLTCON0(a6)
	move.w		#$0,BLTCON1(a6)
		 ;    ABCD76543210
	;move.w	#$09f0,BLTCON0(a6)
	move.l		#$ffffffff,BLTAFWM(a6)
	move.w		#0,BLTAMOD(a6)
	move.w		#40-(w*2),BLTDMOD(a6)
	move.l		#bdata,BLTAPTH(a6)

	lea		sin2,a0
	move.l		#0,d5
	move.l		#0,d0
	move.b		sinstp,d5
	move.b		(a0,d5),d0
	move.b		d0,d1
	; move word size
	lsr.l		#3,d1									
	move.b		d0,d2
         ; get shift value
	and.l		#$f,d2
	swap		d2
	lsr.l		#4,d2
	move.w		#%0000100111110000,d3
	or.w		d2,d3
	move.w		d3,BLTCON0(a6)

	; store sin offset
	add.b		#1,d5
	move.b		d5,sinstp

	and.l		#$ffff,d1
	add.l		buf2,d1
	move.l		d1,BLTDPTH(a6)
	move.l		#coplst,COP1LCH(a6)
	move.l		buf1,BPL1PTH(a6)
	;move.l	#bitp2a,BPL2PTH(a6)

	move.w		#(h*64)+w,BLTSIZE(a6)							;4<<6
	move.w		COPJMP1(a6),d0

	; --------------------------------------------------
.exit:
	movem.l		(sp)+,d0-d7/a0-a6
	rts

	section		DATA,data_c
*****************************************************************************
* COPPER
*

debug:	dc.l		0
sinstp:	dc.b		0
	even

coplst:	dc.w		BPLCON0,$1200	
	dc.w		BPLCON1,$0000
	dc.w		BPLCON2,$0024								;sprites have priority over playfields
	dc.w		BPLCON3,$0000
	dc.w		FMODE,$0000
	dc.w		BPL1MOD,$0000
	dc.w		BPL2MOD,$0000
	dc.w		DIWSTRT,$2c81
	dc.w		DIWSTOP,$2cc1								;
	dc.w		DDFSTRT,$0038
	dc.w		DDFSTOP,$00d0	
	dc.w		COLOR00,$0456
	dc.w		COLOR01,$0789
	dc.w		COLOR02,$0f00
	dc.w		COLOR03,$000f
	dc.l		COPPER_HALT

buf1:	dc.l		0
buf2:	dc.l		0
tmp:	dc.l		0
bdata:	
	dc.w		$ffff,$ffff,$0000,$0000
	dc.w		$ffff,$ffff,$0000,$0000
	dc.w		$ffff,$ffff,$0000,$0000
	dc.w		$ffff,$ffff,$0000,$0000
	dc.w		$ffff,$ffff,$0000,$0000
	dc.w		$ffff,$ffff,$0000,$0000
	dc.w		$ffff,$ffff,$0000,$0000
	dc.w		$ffff,$ffff,$0000,$0000
	dc.w		$ffff,$ffff,$0000,$0000
	dc.w		$ffff,$ffff,$0000,$0000
	dc.w		$ffff,$ffff,$0000,$0000
	dc.w		$ffff,$ffff,$0000,$0000
	dc.w		$ffff,$ffff,$0000,$0000
	dc.w		$ffff,$ffff,$0000,$0000
	dc.w		$ffff,$ffff,$0000,$0000
	dc.w		$ffff,$ffff,$0000,$0000
	dc.w		$ffff,$ffff,$0000,$0000
	dc.w		$ffff,$ffff,$0000,$0000
	dc.w		$ffff,$ffff,$0000,$0000
	dc.w		$ffff,$ffff,$0000,$0000
	dc.w		$ffff,$ffff,$0000,$0000
	dc.w		$ffff,$ffff,$0000,$0000
	dc.w		$ffff,$ffff,$0000,$0000
	dc.w		$ffff,$ffff,$0000,$0000
	

	include		"sintables.i"

*****************************************************************************
* SCREEN
*

	section		SCREEN,bss_c
	;bytes per line * lines in playfield * nr of bitplanes

bitp1a:	ds.b		40*256									;40/4 = 10 long words per line
bitp2a:	ds.b		40*256
bitp1b:	ds.b		40*256									;40/4 = 10 long words per line
bitp2b:	ds.b		40*256




