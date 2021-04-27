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
*
* x' = x * d/z
* y' = y * d/z
***********************************************************

			incdir		"include"
			include		"startup.s"
			include		"line.s"

			section		CODE,code

****************************************************************************
* SETTINGS
*

***********************************************************
* START
*
start:	
			lea			CUSTOM,a6
			move.w		#(DMAF_SETCLR!DMAF_COPPER!DMAF_BLITTER!DMAF_RASTER!DMAF_MASTER),DMACON(a6)
			move.w		#(INTF_SETCLR!INTF_EXTER),INTENA(a6)

			move.l		#bitp1b,buf1
			move.l		#bitp1a,buf2

main:	WAITVB	main

			CLRS		buf1
			bsr			draw_cube

wait:	WAITVB2	wait

			LMOUSE		main
	
			rts

***********************************************************
*
DV	equ	10

draw_cube:
			movem.l		d0-d7/a0-a6,-(sp)

			move.l		buf1,tmp
			move.l		buf2,buf1
			move.l		tmp,buf2

			lea			CUSTOM,a6

; d0=x1, d1=y1, d2=x2, d3=y2, d4=width, a0=aptr
; x' = x * d/z
; y' = y * d/z

			move.l		buf2,a0
			lea			lines,a1
			lea			points,a2
			;vertcount
			moveq.l		#0,d7
			moveq.l		#0,d5
			move.w		(a1)+,d7
			; vert1
dverts		move.w		(a1)+,d5
			mulu		#6,d5
			; cmp.w		#0,d5
			; beq			.dv1
			; add.w		d5,d5
			; add.w		d5,d5
			; add.w		d5,d5
.dv1		move.w		(0,a2,d5.w),d0
			move.w		(2,a2,d5.w),d1
			;move.w		(4,a2,d5.w),d2

			; move.l		#DV,d3
			; divs.w		d2,d3
			; muls.w		d3,d0
			; move.l		#DV,d3
			; divs.w		d1,d3
			; muls.w		d3,d1

			; vert2
			move.w		(a1)+,d5
			mulu		#6,d5
			; cmp.w		#0,d5
			; beq			.dv2
			; add.w		d5,d5
			; add.w		d5,d5
			; add.w		d5,d5
.dv2		move.w		(0,a2,d5.w),d2
			move.w		(2,a2,d5.w),d3
			;move.w		(4,a2,d5.w),d5
			
			; move.l		#DV,d6
			; divs.w		d3,d6
			; muls.w		d6,d3
			; move.l		#DV,d6
			; divs.w		d4,d6
			; muls.w		d6,d4

			asl.w		#2,d0
			asl.w		#2,d1
			asl.w		#2,d2
			asl.w		#2,d3
			and.l		#$0000ffff,d0
			and.l		#$0000ffff,d1
			and.l		#$0000ffff,d2
			and.l		#$0000ffff,d3

			add.w		#320/2,d0
			add.w		#320/2,d2
			add.w		#256/2,d1
			add.w		#256/2,d3

			move.l		#40,d4

			bsr			blit_line

			dbra		d7,dverts																					

			move.l		#coplst,COP1LCH(a6)
			move.l		buf1,BPL1PTH(a6)
			move.w		COPJMP1(a6),d0

	; --------------------------------------------------
.exit:
			movem.l		(sp)+,d0-d7/a0-a6
			rts


			section		DATA,data_c
*****************************************************************************
* COPPER
*

debug:		dc.l		0
sinstp:		dc.b		0
			even

coplst:		dc.w		BPLCON0,$1200	
			dc.w		BPLCON1,$0000
			dc.w		BPLCON2,$0024																	;sprites have priority over playfields
			dc.w		BPLCON3,$0000
			dc.w		FMODE,$0000
			dc.w		BPL1MOD,$0000
			dc.w		BPL2MOD,$0000
			dc.w		DIWSTRT,$2c81
			dc.w		DIWSTOP,$2cc1																	;
			dc.w		DDFSTRT,$0038
			dc.w		DDFSTOP,$00d0	
			dc.w		COLOR00,$0456
			dc.w		COLOR01,$09bf
			dc.w		COLOR02,$0f00
			dc.w		COLOR03,$000f
			dc.l		COPPER_HALT

buf1:		dc.l		0
buf2:		dc.l		0
tmp:		dc.l		0

points:		PointXYZ	-1, -1, -1
			PointXYZ	1, -1, -1
			PointXYZ	1,  1, -1
			PointXYZ	-1,  1, -1
			PointXYZ	-1, -1,  1
			PointXYZ	1, -1,  1
			PointXYZ	1,  1,  1
			PointXYZ	-1,  1,  1

lines:		VertCount	2-1
			VertAB		0,3
			VertAB		3,2
			VertAB		2,1
			VertAB		1,0
			VertAB		5,6
			VertAB		6,7
			VertAB		7,4
			VertAB		4,5
			VertAB		1,5
			VertAB		2,6
			VertAB		3,7
			VertAB		0,4


			include		"sintables.i"

*****************************************************************************
* SCREEN
*

			section		SCREEN,bss_c
	;bytes per line * lines in playfield * nr of bitplanes

bitp1a:		ds.b		40*256																			;40/4 = 10 long words per line
bitp2a:		ds.b		40*256
bitp1b:		ds.b		40*256																			;40/4 = 10 long words per line
bitp2b:		ds.b		40*256




