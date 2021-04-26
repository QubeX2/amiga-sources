;APS000000000000000000000000000008C7000000000000000000000000000000000000000000000000
***********************************************************
* Code:	QubeX2
* Date:	2021-04-22
*
* Z-axis
* x' = x*cos q - y*sin q
* y' = x*sin q + y*cos q
* z' = z
* 
* X-axis
* y' = y*cos q - z*sin q
* z' = y*sin q + z*cos q
* x' = x
*
* Y-axis
* z' = z*cos q - x*sin q
* x' = z*sin q + x*cos q
* y' = y
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
	lea	CUSTOM,a6
	move.w	#(DMAF_SETCLR!DMAF_COPPER!DMAF_BLITTER!DMAF_RASTER!DMAF_MASTER),DMACON(a6)
	move.w	#(INTF_SETCLR!INTF_EXTER),INTENA(a6)

	move.l	#bitp1b,buf1
	move.l	#bitp1a,buf2

main:	WAITVB	main

	CLRS	buf1
	bsr	draw_line

wait:	WAITVB2	wait

	LMOUSE	main
	
	rts

***********************************************************
*

draw_line:
	movem.l	d0-d7/a0-a6,-(sp)

	move.l	buf1,tmp
	move.l	buf2,buf1
	move.l	tmp,buf2


         move.l   #1,d0
         move.l   #1,d1
         move.l   #200,d2
         move.l   #100,d3
         move.l   #40,d4
         move.l   buf2,a0

         lea      CUSTOM,a6
	BLTWAIT	bw1	

         bsr      blit_line

	lea	CUSTOM,a6
	move.l	#coplst,COP1LCH(a6)
	move.l	buf1,BPL1PTH(a6)
	move.w	COPJMP1(a6),d0

	; --------------------------------------------------
.exit:
	movem.l	(sp)+,d0-d7/a0-a6
	rts

; d0=x1, d1=y1, d2=x2, d3=y2, d4=width, a0=aptr
blit_line:
	lea	CUSTOM,a6
	sub.w	d0,d2    ;calc dx
	bmi	.lxneg    ;if neg [3,4,5,6]
         sub.w    d1,d3    ;calc dy
         bmi      .lyneg    ;if neg [7,8]
         cmp.w    d3,d2    ;is one of [1,2]
         bmi      .lygtx    ;if y>x is [2]
         moveq.l  #OCTANT1+LINEMODE,d5       ;octant is 1
         bra      .lfactory

.lygtx:  exg      d2,d3    ;x is gt than y
         moveq.l  #OCTANT2+LINEMODE,d5       ;2
         bra      .lfactory

.lyneg:  neg.w    d3       ;abs(dy)
         cmp.w    d3,d2    ;[7,8]
         bmi      .lynygtx ;if y>x is [7]
         moveq.l  #OCTANT8+LINEMODE,d5       ;ix [8]
         bra      .lfactory

.lynygtx:
         exg      d2,d3    ;x>y
         moveq.l  #OCTANT7+LINEMODE,d5       ;is [7]
         bra      .lfactory

.lxneg:  neg.w    d2       ;dx<0 [3,4,5,6]
         sub.w    d1,d3    ;dy
         bmi      .lxyneg  ;if < 0 [5,6]
         cmp.w    d3,d2    ;is [3,4]
         bmi      .lxnygtx ;if y>x is [3]
         moveq.l  #OCTANT4+LINEMODE,d5       ;is [4]
         bra      .lfactory

.lxnygtx:
         exg      d2,d3    ;x>y
         moveq.l  #OCTANT3+LINEMODE,d5      ;is [3]
         bra      .lfactory

.lxyneg: neg.w    d3       ;y<0 [5,6]
         cmp.w    d3,d2    ;y>x?
         bmi      .lxynygtx         ;is [6]
         moveq.l  #OCTANT5+LINEMODE,d5
         bra      .lfactory

.lxynygtx:
         exg      d2,d3
         moveq.l  #OCTANT6+LINEMODE,d5

.lfactory:
         mulu     d4,d1    ;y1 * width
         ror.l    #4,d0    ;into hi word
         add.w    d0,d0    ;d0 * 2
         add.l    d1,a0    ;ptr += (x1 >> 3)
         add.w    d0,a0    ;ptr += (y1 * width)
         swap     d0       ;4 bits of x1
         or.w     #$bfa,d0 ;
         lsl.w    #2,d3    ;y = 4 * y
         add.w    d2,d2    ;x = 2 * x
         move.w   d2,d1 
         lsl.w    #5,d1 
         add.w    #$42,d1 

         move.w   d3,BLTBMOD(a6)
         sub.w    d2,d3 
         ext.l    d3
         move.l   d3,BLTAPT(a6)
         bpl      .lover
         or.w     #SIGNFLAG,d5
.lover         
         move.w   d0,BLTCON0(a6)
         move.w   d5,BLTCON1(a6)
         move.w   d4,BLTCMOD(a6)
         move.w   d4,BLTDMOD(a6)
         sub.w    d2,d3 
         move.w   d3,BLTAMOD(a6)
         move.w   #$8000,BLTADAT(a6)
         moveq.l  #-1,d5
         move.l   d5,BLTAFWM(a6)
         move.l   a0,BLTCPT(a6)
         move.l   a0,BLTDPT(a6) 
         move.w   d1,BLTSIZE(a6)
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
	dc.w		COLOR01,$09bf
	dc.w		COLOR02,$0f00
	dc.w		COLOR03,$000f
	dc.l		COPPER_HALT

buf1:	dc.l		0
buf2:	dc.l		0
tmp:	dc.l		0
	
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




