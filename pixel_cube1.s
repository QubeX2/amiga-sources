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
* x' = x / z + 1
* y' = y / z + 1
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

            ; load buffers
			lea			buffers,a0
			move.l		#bitp1a,(a0)+
			move.l		#bitp1b,(a0)+
			move.l		#bitp2a,(a0)+
			move.l		#bitp2b,(a0)+
			move.l		#bitp3a,(a0)+
			move.l		#bitp3b,(a0)+
			move.l		#bitp4a,(a0)+
			move.l		#bitp4b,(a0)+
			move.l		#bitp5a,(a0)+
			move.l		#bitp5b,(a0)+
			move.l		#bitp6a,(a0)+
			move.l		#bitp6b,(a0)+

main:	WAITVB	main

			CLRS		buffers
			lea			sin,a0
			lea			points,a1
			lea			coords,a2
			bsr			rotate_points
			bsr			inc_angles
			
			lea			lines,a1
			lea			coords,a2
			move.l		buffers,a3
			bsr			draw_cube
			bsr			load_copper
			bsr			swap_buffers


			;move.l		buf2b,a0
			;lea			lines,a1
			;lea			coords,a2
			;bsr			draw_cube

wait:	    WAITVB2	wait

			LMOUSE		main
	
			rts

***********************************************************
*
load_copper:
			move.l		#coplst,COP1LCH(a6)
			move.l		buffers,BPL1PTH(a6)
			move.l		buffers+4,BPL2PTH(a6)
			move.l		buffers+8,BPL3PTH(a6)
			move.l		buffers+12,BPL4PTH(a6)
			move.l		buffers+16,BPL5PTH(a6)
			move.l		buffers+20,BPL6PTH(a6)
			move.w		COPJMP1(a6),d0
			rts
***********************************************************
*
BUF_COUNT	equ	6-1

swap_buffers:
			lea			buffers,a0
			movem.l		(a0)+,d1-d7
			move.l		d7,d0
			movem.l		d0-d6,-(a0)
			rts

***********************************************************
*
ANGLE_X		equ	2
ANGLE_Y		equ	1
ANGLE_Z		equ	3
inc_angles:
			lea			sinpx,a0
			movem.l		(a0)+,d0-d2
			add.l		#ANGLE_X,d0
			add.l		#ANGLE_Y,d1
			add.l		#ANGLE_Z,d2
			cmp.l		#360,d0
			ble			.inc1
			sub.l		#360,d0
.inc1:		cmp.l		#360,d1
			ble			.inc2
			sub.l		#360,d1
.inc2:		cmp.l		#360,d2
			ble			.inc3
			sub.l		#360,d2
.inc3:		movem.l		d0-d2,-(a0)
			rts

***********************************************************
*
rotate_points:
            ;x,y,z
			move.l		#PCOUNT,d7
.rot:		movem.w		(a1)+,d0-d2

			; === ROTZ =====================================
			move.l		sinpz,a3
			add.l		a3,a3
			; d0 = x, d1 = y, d2 = z
			; x' = x*cos q - y*sin q
			; y' = x*sin q + y*cos q
			move.w		d1,d3
			SinMuls		a0,a3,d3
			move.w		d0,d4
			CosMuls		a0,a3,d4
			;d3 = x
			sub.w		d4,d3

			move.w		d0,d4
			SinMuls		a0,a3,d4
			move.w		d1,d5
			CosMuls		a0,a3,d5
			;d4 = y
			add.w		d5,d4

			; === ROTX =====================================
			move.l		sinpx,a3
			add.l		a3,a3
			; d3 = x, d4 = y, d2 = z
			; y' = y*cos q - z*sin q
			; z' = y*sin q + z*cos q
			move.w		d2,d0
			SinMuls		a0,a3,d0
			move.w		d4,d1
			CosMuls		a0,a3,d1
			;d0 = y
			sub.w		d1,d0

			move.w		d4,d5
			SinMuls		a0,a3,d5
			move.w		d2,d1
			CosMuls		a0,a3,d1
			add.w		d5,d1
			;d1 = z

			; === ROTY =====================================
			move.l		sinpy,a3
			add.l		a3,a3
			; d3 = x, d0 = y, d1 = z
			; z' = z*cos q - x*sin q
			; x' = z*sin q + x*cos q
			move.w		d3,d2
			SinMuls		a0,a3,d2
			move.w		d1,d4
			CosMuls		a0,a3,d4
			; d2 = z
			sub.w		d4,d2

			move.w		d1,d5
			SinMuls		a0,a3,d5
			move.w		d3,d4
			CosMuls		a0,a3,d4
			; d4 = x
			add.w		d5,d4

			; d4 = x, d0 = y, d2 = z

			PERSP2D		d4,d0,d2

			move.w		d4,(a2)+
			move.w		d0,(a2)+

			dbra		d7,.rot
			rts
***********************************************************
*
draw_cube:
			lea			CUSTOM,a6

			;vertcount
			moveq.l		#0,d7
			moveq.l		#0,d5
			move.w		#LCOUNT,d7
			; d0=x1, d1=y1, d2=x2, d3=y2, d4=width, a0=aptr
			; line 1
dverts:		move.w		(a1)+,d5
			and.l		#$ffff,d5
			move.w		(0,a2,d5.w),d0
			move.w		(2,a2,d5.w),d1

			; line 2
			move.w		(a1)+,d5
			and.l		#$ffff,d5
			move.w		(0,a2,d5.w),d2
			move.w		(2,a2,d5.w),d3

			and.l		#$ffff,d0
			and.l		#$ffff,d1
			and.l		#$ffff,d2
			and.l		#$ffff,d3

			move.l		#40,d4
			move.l		buffers,a0

			bsr			blit_line

			dbra		d7,dverts																					
			rts

*****************************************************************************
* DATA
*
			section		DATA,data_c

debug:		dc.l		0
sinpx:		dc.l		0
sinpy:		dc.l		0
sinpz:		dc.l		0

coplst:		dc.w		BPLCON0,$6200	
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
			dc.w		COLOR00,$0006
			dc.w		COLOR01,$0eef
			dc.w		COLOR02,$0ddf
			dc.w		COLOR03,$0ccf
			dc.w		COLOR04,$0bbf
			dc.w		COLOR05,$0aaf
			dc.w		COLOR06,$099f
			dc.w		COLOR07,$088f
			dc.w		COLOR08,$077f
			dc.w		COLOR09,$066f
			dc.w		COLOR10,$055f
			dc.w		COLOR11,$044f
			dc.w		COLOR12,$033f
			dc.w		COLOR13,$022f
			dc.w		COLOR14,$011f
			dc.w		COLOR15,$000f
			dc.w		COLOR16,$000e
			dc.w		COLOR17,$000d
			dc.w		COLOR18,$000c
			dc.w		COLOR19,$000b
			dc.w		COLOR20,$000a
			dc.w		COLOR21,$0009
			dc.w		COLOR22,$0008
			dc.w		COLOR23,$0007
			dc.w		COLOR24,$0006
			dc.w		COLOR25,$0005
			dc.w		COLOR26,$0004
			dc.w		COLOR27,$0003
			dc.w		COLOR28,$0002
			dc.w		COLOR29,$0001
			dc.w		COLOR30,$0000
			dc.w		COLOR31,$0fff
			dc.l		COPPER_HALT

buffers:	dcb.l		6*2,0
tmp:		dc.l		0

MAX			equ	18<<8
PCOUNT		equ	8-1
points:		PointXYZ	-MAX, -MAX, -MAX
			PointXYZ	MAX, -MAX, -MAX
			PointXYZ	MAX,  MAX, -MAX
			PointXYZ	-MAX,  MAX, -MAX
			PointXYZ	-MAX, -MAX,  MAX
			PointXYZ	MAX, -MAX,  MAX
			PointXYZ	MAX,  MAX,  MAX
			PointXYZ	-MAX,  MAX,  MAX

coords:		dcb.w		8*2,0

LCOUNT		equ	12-1
lines:		VertAB		0,3
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

sin:
;@generated-datagen-start----------------
; This code was generated by Amiga Assembly extension
;
;----- parameters : modify ------
;expression(x as variable): round(sin(x*pi/180)*pow(2,8))
;variable:
;   name:x
;   startValue:1
;   endValue:720
;   step:1
;outputType(B,W,L): W
;outputInHex: true
;valuesPerLine: 10
;--------------------------------
;- DO NOT MODIFY following lines -
 ; -> SIGNED values <-
			dc.w		$0004, $0009, $000d, $0012, $0016, $001b, $001f, $0024, $0028, $002c
			dc.w		$0031, $0035, $003a, $003e, $0042, $0047, $004b, $004f, $0053, $0058
			dc.w		$005c, $0060, $0064, $0068, $006c, $0070, $0074, $0078, $007c, $0080
			dc.w		$0084, $0088, $008b, $008f, $0093, $0096, $009a, $009e, $00a1, $00a5
			dc.w		$00a8, $00ab, $00af, $00b2, $00b5, $00b8, $00bb, $00be, $00c1, $00c4
			dc.w		$00c7, $00ca, $00cc, $00cf, $00d2, $00d4, $00d7, $00d9, $00db, $00de
			dc.w		$00e0, $00e2, $00e4, $00e6, $00e8, $00ea, $00ec, $00ed, $00ef, $00f1
			dc.w		$00f2, $00f3, $00f5, $00f6, $00f7, $00f8, $00f9, $00fa, $00fb, $00fc
			dc.w		$00fd, $00fe, $00fe, $00ff, $00ff, $00ff, $0100, $0100, $0100, $0100
			dc.w		$0100, $0100, $0100, $00ff, $00ff, $00ff, $00fe, $00fe, $00fd, $00fc
			dc.w		$00fb, $00fa, $00f9, $00f8, $00f7, $00f6, $00f5, $00f3, $00f2, $00f1
			dc.w		$00ef, $00ed, $00ec, $00ea, $00e8, $00e6, $00e4, $00e2, $00e0, $00de
			dc.w		$00db, $00d9, $00d7, $00d4, $00d2, $00cf, $00cc, $00ca, $00c7, $00c4
			dc.w		$00c1, $00be, $00bb, $00b8, $00b5, $00b2, $00af, $00ab, $00a8, $00a5
			dc.w		$00a1, $009e, $009a, $0096, $0093, $008f, $008b, $0088, $0084, $0080
			dc.w		$007c, $0078, $0074, $0070, $006c, $0068, $0064, $0060, $005c, $0058
			dc.w		$0053, $004f, $004b, $0047, $0042, $003e, $003a, $0035, $0031, $002c
			dc.w		$0028, $0024, $001f, $001b, $0016, $0012, $000d, $0009, $0004, $0000
			dc.w		$fffc, $fff7, $fff3, $ffee, $ffea, $ffe5, $ffe1, $ffdc, $ffd8, $ffd4
			dc.w		$ffcf, $ffcb, $ffc6, $ffc2, $ffbe, $ffb9, $ffb5, $ffb1, $ffad, $ffa8
			dc.w		$ffa4, $ffa0, $ff9c, $ff98, $ff94, $ff90, $ff8c, $ff88, $ff84, $ff80
			dc.w		$ff7c, $ff78, $ff75, $ff71, $ff6d, $ff6a, $ff66, $ff62, $ff5f, $ff5b
			dc.w		$ff58, $ff55, $ff51, $ff4e, $ff4b, $ff48, $ff45, $ff42, $ff3f, $ff3c
			dc.w		$ff39, $ff36, $ff34, $ff31, $ff2e, $ff2c, $ff29, $ff27, $ff25, $ff22
			dc.w		$ff20, $ff1e, $ff1c, $ff1a, $ff18, $ff16, $ff14, $ff13, $ff11, $ff0f
			dc.w		$ff0e, $ff0d, $ff0b, $ff0a, $ff09, $ff08, $ff07, $ff06, $ff05, $ff04
			dc.w		$ff03, $ff02, $ff02, $ff01, $ff01, $ff01, $ff00, $ff00, $ff00, $ff00
			dc.w		$ff00, $ff00, $ff00, $ff01, $ff01, $ff01, $ff02, $ff02, $ff03, $ff04
			dc.w		$ff05, $ff06, $ff07, $ff08, $ff09, $ff0a, $ff0b, $ff0d, $ff0e, $ff0f
			dc.w		$ff11, $ff13, $ff14, $ff16, $ff18, $ff1a, $ff1c, $ff1e, $ff20, $ff22
			dc.w		$ff25, $ff27, $ff29, $ff2c, $ff2e, $ff31, $ff34, $ff36, $ff39, $ff3c
			dc.w		$ff3f, $ff42, $ff45, $ff48, $ff4b, $ff4e, $ff51, $ff55, $ff58, $ff5b
			dc.w		$ff5f, $ff62, $ff66, $ff6a, $ff6d, $ff71, $ff75, $ff78, $ff7c, $ff80
			dc.w		$ff84, $ff88, $ff8c, $ff90, $ff94, $ff98, $ff9c, $ffa0, $ffa4, $ffa8
			dc.w		$ffad, $ffb1, $ffb5, $ffb9, $ffbe, $ffc2, $ffc6, $ffcb, $ffcf, $ffd4
			dc.w		$ffd8, $ffdc, $ffe1, $ffe5, $ffea, $ffee, $fff3, $fff7, $fffc, $0000
			dc.w		$0004, $0009, $000d, $0012, $0016, $001b, $001f, $0024, $0028, $002c
			dc.w		$0031, $0035, $003a, $003e, $0042, $0047, $004b, $004f, $0053, $0058
			dc.w		$005c, $0060, $0064, $0068, $006c, $0070, $0074, $0078, $007c, $0080
			dc.w		$0084, $0088, $008b, $008f, $0093, $0096, $009a, $009e, $00a1, $00a5
			dc.w		$00a8, $00ab, $00af, $00b2, $00b5, $00b8, $00bb, $00be, $00c1, $00c4
			dc.w		$00c7, $00ca, $00cc, $00cf, $00d2, $00d4, $00d7, $00d9, $00db, $00de
			dc.w		$00e0, $00e2, $00e4, $00e6, $00e8, $00ea, $00ec, $00ed, $00ef, $00f1
			dc.w		$00f2, $00f3, $00f5, $00f6, $00f7, $00f8, $00f9, $00fa, $00fb, $00fc
			dc.w		$00fd, $00fe, $00fe, $00ff, $00ff, $00ff, $0100, $0100, $0100, $0100
			dc.w		$0100, $0100, $0100, $00ff, $00ff, $00ff, $00fe, $00fe, $00fd, $00fc
			dc.w		$00fb, $00fa, $00f9, $00f8, $00f7, $00f6, $00f5, $00f3, $00f2, $00f1
			dc.w		$00ef, $00ed, $00ec, $00ea, $00e8, $00e6, $00e4, $00e2, $00e0, $00de
			dc.w		$00db, $00d9, $00d7, $00d4, $00d2, $00cf, $00cc, $00ca, $00c7, $00c4
			dc.w		$00c1, $00be, $00bb, $00b8, $00b5, $00b2, $00af, $00ab, $00a8, $00a5
			dc.w		$00a1, $009e, $009a, $0096, $0093, $008f, $008b, $0088, $0084, $0080
			dc.w		$007c, $0078, $0074, $0070, $006c, $0068, $0064, $0060, $005c, $0058
			dc.w		$0053, $004f, $004b, $0047, $0042, $003e, $003a, $0035, $0031, $002c
			dc.w		$0028, $0024, $001f, $001b, $0016, $0012, $000d, $0009, $0004, $0000
			dc.w		$fffc, $fff7, $fff3, $ffee, $ffea, $ffe5, $ffe1, $ffdc, $ffd8, $ffd4
			dc.w		$ffcf, $ffcb, $ffc6, $ffc2, $ffbe, $ffb9, $ffb5, $ffb1, $ffad, $ffa8
			dc.w		$ffa4, $ffa0, $ff9c, $ff98, $ff94, $ff90, $ff8c, $ff88, $ff84, $ff80
			dc.w		$ff7c, $ff78, $ff75, $ff71, $ff6d, $ff6a, $ff66, $ff62, $ff5f, $ff5b
			dc.w		$ff58, $ff55, $ff51, $ff4e, $ff4b, $ff48, $ff45, $ff42, $ff3f, $ff3c
			dc.w		$ff39, $ff36, $ff34, $ff31, $ff2e, $ff2c, $ff29, $ff27, $ff25, $ff22
			dc.w		$ff20, $ff1e, $ff1c, $ff1a, $ff18, $ff16, $ff14, $ff13, $ff11, $ff0f
			dc.w		$ff0e, $ff0d, $ff0b, $ff0a, $ff09, $ff08, $ff07, $ff06, $ff05, $ff04
			dc.w		$ff03, $ff02, $ff02, $ff01, $ff01, $ff01, $ff00, $ff00, $ff00, $ff00
			dc.w		$ff00, $ff00, $ff00, $ff01, $ff01, $ff01, $ff02, $ff02, $ff03, $ff04
			dc.w		$ff05, $ff06, $ff07, $ff08, $ff09, $ff0a, $ff0b, $ff0d, $ff0e, $ff0f
			dc.w		$ff11, $ff13, $ff14, $ff16, $ff18, $ff1a, $ff1c, $ff1e, $ff20, $ff22
			dc.w		$ff25, $ff27, $ff29, $ff2c, $ff2e, $ff31, $ff34, $ff36, $ff39, $ff3c
			dc.w		$ff3f, $ff42, $ff45, $ff48, $ff4b, $ff4e, $ff51, $ff55, $ff58, $ff5b
			dc.w		$ff5f, $ff62, $ff66, $ff6a, $ff6d, $ff71, $ff75, $ff78, $ff7c, $ff80
			dc.w		$ff84, $ff88, $ff8c, $ff90, $ff94, $ff98, $ff9c, $ffa0, $ffa4, $ffa8
			dc.w		$ffad, $ffb1, $ffb5, $ffb9, $ffbe, $ffc2, $ffc6, $ffcb, $ffcf, $ffd4
			dc.w		$ffd8, $ffdc, $ffe1, $ffe5, $ffea, $ffee, $fff3, $fff7, $fffc, $0000
;@generated-datagen-end----------------











*****************************************************************************
* SCREEN
*

			section		SCREEN,bss_c
	;bytes per line * lines in playfield * nr of bitplanes

bitp1a:		ds.b		40*256																			;40/4 = 10 long words per line
bitp1b:		ds.b		40*256																			;40/4 = 10 long words per line
bitp2a:		ds.b		40*256
bitp2b:		ds.b		40*256
bitp3a:		ds.b		40*256																			;40/4 = 10 long words per line
bitp3b:		ds.b		40*256																			;40/4 = 10 long words per line
bitp4a:		ds.b		40*256
bitp4b:		ds.b		40*256
bitp5a:		ds.b		40*256
bitp5b:		ds.b		40*256
bitp6a:		ds.b		40*256
bitp6b:		ds.b		40*256




