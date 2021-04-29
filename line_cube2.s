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
* x' = x / z + 1
* y' = y / z + 1
***********************************************************

			incdir			"include"
			include			"startup.s"
			include			"line.s"

			section			CODE,code

****************************************************************************
* SETTINGS
*

***********************************************************
* START
*
start:	
			lea				CUSTOM,a6
			move.w			#(DMAF_SETCLR!DMAF_COPPER!DMAF_BLITTER!DMAF_RASTER!DMAF_MASTER),DMACON(a6)
			move.w			#(INTF_SETCLR!INTF_EXTER),INTENA(a6)

			move.l			#bitp1b,buf1
			move.l			#bitp1a,buf2

main:	WAITVB	main

			CLRS			buf1
			bsr				draw_cube

wait:	WAITVB2	wait

			LMOUSE			main
	
			rts

***********************************************************
*
rotate_z:
			;d0=x1, d1=y1, d4=z1, d2=x2, d3=y2, d5=z2
			; 0=x1, 2=y1, 4=x2, 6=y2, 8=z1, 10=z2 
			; x' = x*cos q - y*sin q
			; y' = x*sin q + y*cos q
			lea				coords_t1,a5
			lea				coords_t2,a4
			movem.w			d0-d5,-(a4)
			lea				coords_t2,a4
			; save x
			move.w			d4,(8,a4)
			move.w			d5,(10,a4)

			move.l			#0,d6
			move.w			sinpz,d6
			; word align
			lsl.w			#1,d6

			moveq.l			#0,d1
			moveq.l			#0,d2
			; sin
			move.w			(a3,d6),d1
			; cos
			move.w			(180,a3,d6),d2

			; x' = x*cos q - y*sin q
			moveq.l			#0,d0
			moveq.l			#0,d4
			move.w			(a5),d0
			move.w			(2,a5),d4			
			CosSubSin		d0,d4,d1,d2
			move.w			d4,(a4)
			; y' = x*sin q + y*cos q
			moveq.l			#0,d0
			moveq.l			#0,d4
			move.w			(a5),d0
			move.w			(2,a5),d4
			CosAddSin		d0,d4,d1,d2
			move.w			d4,(2,a4)
			; x' = x*cos q - y*sin q
			moveq.l			#0,d0
			moveq.l			#0,d4
			move.w			(4,a5),d0
			move.w			(6,a5),d4
			CosSubSin		d0,d4,d1,d2
			move.w			d4,(4,a4)
			; y' = x*sin q + y*cos q
			moveq.l			#0,d0
			moveq.l			#0,d4
			move.w			(4,a5),d0
			move.w			(6,a5),d4
			CosAddSin		d0,d4,d1,d2
			move.w			d4,(6,a4)

			movem.w			(a4)+,d0-d5
			rts
***********************************************************
*
rotate_x:
			;d0=x1, d1=y1, d4=z1, d2=x2, d3=y2, d5=z2
			; 0=x1, 2=y1, 4=x2, 6=y2, 8=z1, 10=z2 
			; y' = y*cos q - z*sin q
			; z' = y*sin q + z*cos q
			lea				coords_t1,a5
			lea				coords_t2,a4
			movem.w			d0-d5,-(a4)
			lea				coords_t2,a4
			; save x
			move.w			d0,(0,a4)
			move.w			d2,(4,a4)

			move.l			#0,d6
			move.w			sinpx,d6
			; word align
			lsl.w			#1,d6

			moveq.l			#0,d1
			moveq.l			#0,d2
			; sin
			move.w			(a3,d6),d1
			; cos
			move.w			(180,a3,d6),d2

			; y' = y*cos q - z*sin q
			moveq.l			#0,d0
			moveq.l			#0,d4
			move.w			(2,a5),d0
			move.w			(8,a5),d4			
			CosSubSin		d0,d4,d1,d2
			move.w			d4,(2,a4)
			; z' = y*sin q + z*cos q
			moveq.l			#0,d0
			moveq.l			#0,d4
			move.w			(2,a5),d0
			move.w			(8,a5),d4
			CosAddSin		d0,d4,d1,d2
			move.w			d4,(8,a4)
			; y' = y*cos q - z*sin q
			moveq.l			#0,d0
			moveq.l			#0,d4
			move.w			(6,a5),d0
			move.w			(10,a5),d4
			CosSubSin		d0,d4,d1,d2
			move.w			d4,(6,a4)
			; z' = y*sin q + z*cos q
			moveq.l			#0,d0
			moveq.l			#0,d4
			move.w			(6,a5),d0
			move.w			(10,a5),d4
			CosAddSin		d0,d4,d1,d2
			move.w			d4,(10,a4)

			movem.w			(a4)+,d0-d5
			rts
***********************************************************
*
rotate_y:
			;d0=x1, d1=y1, d4=z1, d2=x2, d3=y2, d5=z2
			; 0=x1, 2=y1, 4=x2, 6=y2, 8=z1, 10=z2 
			; z' = z*cos -  x*sin
			; x' = z*sin q + x*cos q
			lea				coords_t1,a5
			lea				coords_t2,a4
			movem.w			d0-d5,-(a4)
			lea				coords_t2,a4
			; save y
			move.w			d1,(2,a4)
			move.w			d3,(6,a4)

			move.l			#0,d6
			move.w			sinpy,d6
			; word align
			lsl.w			#1,d6

			moveq.l			#0,d1
			moveq.l			#0,d2
			; sin
			move.w			(a3,d6),d1
			; cos
			move.w			(180,a3,d6),d2

			; z' = z*cos -  x*sin
			moveq.l			#0,d0
			moveq.l			#0,d4
			move.w			(a5),d0
			move.w			(8,a5),d4			
			CosSubSin		d4,d0,d1,d2
			move.w			d0,(8,a4)
			; x' = z*sin q + x*cos q
			moveq.l			#0,d0
			moveq.l			#0,d4
			move.w			(a5),d0
			move.w			(8,a5),d4
			CosAddSin		d4,d0,d1,d2
			move.w			d0,(a4)
			; z' = z*cos -  x*sin
			moveq.l			#0,d0
			moveq.l			#0,d4
			move.w			(4,a5),d0
			move.w			(10,a5),d4
			CosSubSin		d4,d0,d1,d2
			move.w			d0,(10,a4)
			; x' = z*sin q + x*cos q
			moveq.l			#0,d0
			moveq.l			#0,d4
			move.w			(4,a5),d0
			move.w			(10,a5),d4
			CosAddSin		d4,d0,d1,d2
			move.w			d0,(4,a4)

			movem.w			(a4)+,d0-d5
			rts
***********************************************************
*
MAX		equ	14
ANGLE_X	equ	1
ANGLE_Y	equ	2
ANGLE_Z	equ	1

draw_cube:
			movem.l			d0-d7/a0-a6,-(sp)

			move.l			buf1,tmp
			move.l			buf2,buf1
			move.l			tmp,buf2

			lea				CUSTOM,a6

			lea				lines,a1
			lea				points,a2
			;vertcount
			moveq.l			#0,d7
			moveq.l			#0,d5
			move.w			(a1)+,d7
			; vert1
dverts		move.w			(a1)+,d5
			move.w			(0,a2,d5.w),d0
			move.w			(2,a2,d5.w),d1
			move.w			(4,a2,d5.w),d4

			; vert2
			move.w			(a1)+,d5
			move.w			(0,a2,d5.w),d2
			move.w			(2,a2,d5.w),d3
			move.w			(4,a2,d5.w),d5

			; shift values
			lsl.l			#8,d1
			lsl.l			#8,d3
			lsl.l			#8,d0
			lsl.l			#8,d2
			lsl.l			#8,d4
			lsl.l			#8,d5

			; rotate
			lea				sin,a3
			;bsr				rotate_y
			;bsr				rotate_x
			bsr				rotate_z
			
			; perspective
			PERSP2D			d0,d1,d4
			PERSP2D			d2,d3,d5

			; d0=x1, d1=y1, d2=x2, d3=y2, d4=width, a0=aptr

			move.l			#40,d4
			move.l			buf2,a0

			bsr				blit_line

			dbra			d7,dverts																					

			; add sinpy
			moveq.l			#0,d6
			move.w			sinpy,d6
			add.w			#ANGLE_Y,d6
			cmp.w			#360,d6
			ble				.dca2
			sub.w			#360,d6
.dca2		move.w			d6,sinpy	
			move.w			sinpx,d6
			add.w			#ANGLE_X,d6
			cmp.w			#360,d6
			ble				.dca3
			sub.w			#360,d6
.dca3:		move.w			d6,sinpx
			move.w			sinpz,d6
			add.w			#ANGLE_Z,d6
			cmp.w			#360,d6
			ble				.dca4
			sub.w			#360,d6
.dca4		move.w			d6,sinpz


			move.l			#coplst,COP1LCH(a6)
			move.l			buf1,BPL1PTH(a6)
			move.w			COPJMP1(a6),d0

	; --------------------------------------------------
.exit:
			movem.l			(sp)+,d0-d7/a0-a6
			rts


			section			DATA,data_c
*****************************************************************************
* COPPER
*

debug:		dc.l			0
sinpx:		dc.w			0
sinpy:		dc.w			0
sinpz:		dc.w			0

coplst:		dc.w			BPLCON0,$1200	
			dc.w			BPLCON1,$0000
			dc.w			BPLCON2,$0024																	;sprites have priority over playfields
			dc.w			BPLCON3,$0000
			dc.w			FMODE,$0000
			dc.w			BPL1MOD,$0000
			dc.w			BPL2MOD,$0000
			dc.w			DIWSTRT,$2c81
			dc.w			DIWSTOP,$2cc1																	;
			dc.w			DDFSTRT,$0038
			dc.w			DDFSTOP,$00d0	
			dc.w			COLOR00,$0654
			dc.w			COLOR01,$0fb9
			dc.w			COLOR02,$0f00
			dc.w			COLOR03,$0fff
			dc.l			COPPER_HALT

buf1:		dc.l			0
buf2:		dc.l			0
tmp:		dc.l			0

coords_t1:	dc.w			0,0,0,0,0,0
coords_t2:	dc.w			0,0,0,0,0,0

points:		PointXYZ	-MAX, -MAX, -MAX
			PointXYZ		MAX, -MAX, -MAX
			PointXYZ		MAX,  MAX, -MAX
			PointXYZ		-MAX,  MAX, -MAX
			PointXYZ		-MAX, -MAX,  MAX
			PointXYZ		MAX, -MAX,  MAX
			PointXYZ		MAX,  MAX,  MAX
			PointXYZ		-MAX,  MAX,  MAX

lines:		VertCount	12-1
			VertAB			0,3
			VertAB			3,2
			VertAB			2,1
			VertAB			1,0
			VertAB			5,6
			VertAB			6,7
			VertAB			7,4
			VertAB			4,5
			VertAB			1,5
			VertAB			2,6
			VertAB			3,7
			VertAB			0,4

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
			dc.w			$0004, $0009, $000d, $0012, $0016, $001b, $001f, $0024, $0028, $002c
			dc.w			$0031, $0035, $003a, $003e, $0042, $0047, $004b, $004f, $0053, $0058
			dc.w			$005c, $0060, $0064, $0068, $006c, $0070, $0074, $0078, $007c, $0080
			dc.w			$0084, $0088, $008b, $008f, $0093, $0096, $009a, $009e, $00a1, $00a5
			dc.w			$00a8, $00ab, $00af, $00b2, $00b5, $00b8, $00bb, $00be, $00c1, $00c4
			dc.w			$00c7, $00ca, $00cc, $00cf, $00d2, $00d4, $00d7, $00d9, $00db, $00de
			dc.w			$00e0, $00e2, $00e4, $00e6, $00e8, $00ea, $00ec, $00ed, $00ef, $00f1
			dc.w			$00f2, $00f3, $00f5, $00f6, $00f7, $00f8, $00f9, $00fa, $00fb, $00fc
			dc.w			$00fd, $00fe, $00fe, $00ff, $00ff, $00ff, $0100, $0100, $0100, $0100
			dc.w			$0100, $0100, $0100, $00ff, $00ff, $00ff, $00fe, $00fe, $00fd, $00fc
			dc.w			$00fb, $00fa, $00f9, $00f8, $00f7, $00f6, $00f5, $00f3, $00f2, $00f1
			dc.w			$00ef, $00ed, $00ec, $00ea, $00e8, $00e6, $00e4, $00e2, $00e0, $00de
			dc.w			$00db, $00d9, $00d7, $00d4, $00d2, $00cf, $00cc, $00ca, $00c7, $00c4
			dc.w			$00c1, $00be, $00bb, $00b8, $00b5, $00b2, $00af, $00ab, $00a8, $00a5
			dc.w			$00a1, $009e, $009a, $0096, $0093, $008f, $008b, $0088, $0084, $0080
			dc.w			$007c, $0078, $0074, $0070, $006c, $0068, $0064, $0060, $005c, $0058
			dc.w			$0053, $004f, $004b, $0047, $0042, $003e, $003a, $0035, $0031, $002c
			dc.w			$0028, $0024, $001f, $001b, $0016, $0012, $000d, $0009, $0004, $0000
			dc.w			$fffc, $fff7, $fff3, $ffee, $ffea, $ffe5, $ffe1, $ffdc, $ffd8, $ffd4
			dc.w			$ffcf, $ffcb, $ffc6, $ffc2, $ffbe, $ffb9, $ffb5, $ffb1, $ffad, $ffa8
			dc.w			$ffa4, $ffa0, $ff9c, $ff98, $ff94, $ff90, $ff8c, $ff88, $ff84, $ff80
			dc.w			$ff7c, $ff78, $ff75, $ff71, $ff6d, $ff6a, $ff66, $ff62, $ff5f, $ff5b
			dc.w			$ff58, $ff55, $ff51, $ff4e, $ff4b, $ff48, $ff45, $ff42, $ff3f, $ff3c
			dc.w			$ff39, $ff36, $ff34, $ff31, $ff2e, $ff2c, $ff29, $ff27, $ff25, $ff22
			dc.w			$ff20, $ff1e, $ff1c, $ff1a, $ff18, $ff16, $ff14, $ff13, $ff11, $ff0f
			dc.w			$ff0e, $ff0d, $ff0b, $ff0a, $ff09, $ff08, $ff07, $ff06, $ff05, $ff04
			dc.w			$ff03, $ff02, $ff02, $ff01, $ff01, $ff01, $ff00, $ff00, $ff00, $ff00
			dc.w			$ff00, $ff00, $ff00, $ff01, $ff01, $ff01, $ff02, $ff02, $ff03, $ff04
			dc.w			$ff05, $ff06, $ff07, $ff08, $ff09, $ff0a, $ff0b, $ff0d, $ff0e, $ff0f
			dc.w			$ff11, $ff13, $ff14, $ff16, $ff18, $ff1a, $ff1c, $ff1e, $ff20, $ff22
			dc.w			$ff25, $ff27, $ff29, $ff2c, $ff2e, $ff31, $ff34, $ff36, $ff39, $ff3c
			dc.w			$ff3f, $ff42, $ff45, $ff48, $ff4b, $ff4e, $ff51, $ff55, $ff58, $ff5b
			dc.w			$ff5f, $ff62, $ff66, $ff6a, $ff6d, $ff71, $ff75, $ff78, $ff7c, $ff80
			dc.w			$ff84, $ff88, $ff8c, $ff90, $ff94, $ff98, $ff9c, $ffa0, $ffa4, $ffa8
			dc.w			$ffad, $ffb1, $ffb5, $ffb9, $ffbe, $ffc2, $ffc6, $ffcb, $ffcf, $ffd4
			dc.w			$ffd8, $ffdc, $ffe1, $ffe5, $ffea, $ffee, $fff3, $fff7, $fffc, $0000
			dc.w			$0004, $0009, $000d, $0012, $0016, $001b, $001f, $0024, $0028, $002c
			dc.w			$0031, $0035, $003a, $003e, $0042, $0047, $004b, $004f, $0053, $0058
			dc.w			$005c, $0060, $0064, $0068, $006c, $0070, $0074, $0078, $007c, $0080
			dc.w			$0084, $0088, $008b, $008f, $0093, $0096, $009a, $009e, $00a1, $00a5
			dc.w			$00a8, $00ab, $00af, $00b2, $00b5, $00b8, $00bb, $00be, $00c1, $00c4
			dc.w			$00c7, $00ca, $00cc, $00cf, $00d2, $00d4, $00d7, $00d9, $00db, $00de
			dc.w			$00e0, $00e2, $00e4, $00e6, $00e8, $00ea, $00ec, $00ed, $00ef, $00f1
			dc.w			$00f2, $00f3, $00f5, $00f6, $00f7, $00f8, $00f9, $00fa, $00fb, $00fc
			dc.w			$00fd, $00fe, $00fe, $00ff, $00ff, $00ff, $0100, $0100, $0100, $0100
			dc.w			$0100, $0100, $0100, $00ff, $00ff, $00ff, $00fe, $00fe, $00fd, $00fc
			dc.w			$00fb, $00fa, $00f9, $00f8, $00f7, $00f6, $00f5, $00f3, $00f2, $00f1
			dc.w			$00ef, $00ed, $00ec, $00ea, $00e8, $00e6, $00e4, $00e2, $00e0, $00de
			dc.w			$00db, $00d9, $00d7, $00d4, $00d2, $00cf, $00cc, $00ca, $00c7, $00c4
			dc.w			$00c1, $00be, $00bb, $00b8, $00b5, $00b2, $00af, $00ab, $00a8, $00a5
			dc.w			$00a1, $009e, $009a, $0096, $0093, $008f, $008b, $0088, $0084, $0080
			dc.w			$007c, $0078, $0074, $0070, $006c, $0068, $0064, $0060, $005c, $0058
			dc.w			$0053, $004f, $004b, $0047, $0042, $003e, $003a, $0035, $0031, $002c
			dc.w			$0028, $0024, $001f, $001b, $0016, $0012, $000d, $0009, $0004, $0000
			dc.w			$fffc, $fff7, $fff3, $ffee, $ffea, $ffe5, $ffe1, $ffdc, $ffd8, $ffd4
			dc.w			$ffcf, $ffcb, $ffc6, $ffc2, $ffbe, $ffb9, $ffb5, $ffb1, $ffad, $ffa8
			dc.w			$ffa4, $ffa0, $ff9c, $ff98, $ff94, $ff90, $ff8c, $ff88, $ff84, $ff80
			dc.w			$ff7c, $ff78, $ff75, $ff71, $ff6d, $ff6a, $ff66, $ff62, $ff5f, $ff5b
			dc.w			$ff58, $ff55, $ff51, $ff4e, $ff4b, $ff48, $ff45, $ff42, $ff3f, $ff3c
			dc.w			$ff39, $ff36, $ff34, $ff31, $ff2e, $ff2c, $ff29, $ff27, $ff25, $ff22
			dc.w			$ff20, $ff1e, $ff1c, $ff1a, $ff18, $ff16, $ff14, $ff13, $ff11, $ff0f
			dc.w			$ff0e, $ff0d, $ff0b, $ff0a, $ff09, $ff08, $ff07, $ff06, $ff05, $ff04
			dc.w			$ff03, $ff02, $ff02, $ff01, $ff01, $ff01, $ff00, $ff00, $ff00, $ff00
			dc.w			$ff00, $ff00, $ff00, $ff01, $ff01, $ff01, $ff02, $ff02, $ff03, $ff04
			dc.w			$ff05, $ff06, $ff07, $ff08, $ff09, $ff0a, $ff0b, $ff0d, $ff0e, $ff0f
			dc.w			$ff11, $ff13, $ff14, $ff16, $ff18, $ff1a, $ff1c, $ff1e, $ff20, $ff22
			dc.w			$ff25, $ff27, $ff29, $ff2c, $ff2e, $ff31, $ff34, $ff36, $ff39, $ff3c
			dc.w			$ff3f, $ff42, $ff45, $ff48, $ff4b, $ff4e, $ff51, $ff55, $ff58, $ff5b
			dc.w			$ff5f, $ff62, $ff66, $ff6a, $ff6d, $ff71, $ff75, $ff78, $ff7c, $ff80
			dc.w			$ff84, $ff88, $ff8c, $ff90, $ff94, $ff98, $ff9c, $ffa0, $ffa4, $ffa8
			dc.w			$ffad, $ffb1, $ffb5, $ffb9, $ffbe, $ffc2, $ffc6, $ffcb, $ffcf, $ffd4
			dc.w			$ffd8, $ffdc, $ffe1, $ffe5, $ffea, $ffee, $fff3, $fff7, $fffc, $0000
;@generated-datagen-end----------------











*****************************************************************************
* SCREEN
*

			section			SCREEN,bss_c
	;bytes per line * lines in playfield * nr of bitplanes

bitp1a:		ds.b			40*256																			;40/4 = 10 long words per line
bitp2a:		ds.b			40*256
bitp1b:		ds.b			40*256																			;40/4 = 10 long words per line
bitp2b:		ds.b			40*256




