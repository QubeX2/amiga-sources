
    *** MiniStartup by Photon ***

				INCLUDE		"PhotonsMiniWrapper1.04!.S"

********** Symbols **********

				INCLUDE		"Blitter-Register-List.S"

********** Macros **********

WAITBLIT:MACRO
				tst			(a6)														;A1000 blitwait bug fix
.wb\@:			btst		#6,DMACONR(a6)
				bne.s		.wb\@														;use "bne.s *-4" in incompatible assemblers
				ENDM

SinScale:MACRO
				muls		(a5,\1.w),\2
				add.l		\2,\2
				swap		\2
				ENDM

CosScale:MACRO
				muls		(a6,\1.w),\2
				add.l		\2,\2
				swap		\2
				ENDM

PERSP2D:MACRO			;final projection from world to screen coords
				ext.l		d4
				ext.l		d5
				neg.w		d6															;world +z is forward,screen perspective is away
				asr.w		#8,d6														;this scaling
				add.w		#78,d6														;and eye Z determines Field of View.
				divs		d6,d4
				divs		d6,d5
				add.w		#w/2,d4														;center horizontally on the screen
				add.w		#h/2,d5														;center vertically
				ENDM

********** Demo **********		;Demo-specific non-startup code below.

w			=	208																		;screen width, height, depth
h			=	200
bpls		=	1																		;handy values:
bpl			=	w/16*2																	;byte-width of 1 bitplane line
bwid		=	bpls*bpl																;byte-width of 1 pixel line (all bpls)

MaxVerts	=	12
MaxLines	=	20

Demo:					;a4=VBR, a6=Custom Registers Base addr
    *--- init ---*
				move.l		#VBint,$6c(a4)
				move.w		#$c020,$9a(a6)
				move.w		#$87c0,$96(a6)
    *--- clear screens ---*
				lea			Screen,a1
				bsr.w		ClearScreen
				lea			Screen2,a1
				bsr.w		ClearScreen
				WAITBLIT
    *--- start copper ---*
				lea			Screen,a0
				moveq		#bpl,d0
				lea			BplPtrs+2,a1
				moveq		#bpls-1,d1
				bsr.w		PokePtrs

				move.l		#Copper,$80(a6)

********************  main loop  ********************
MainLoop:
				move.w		#$10c,d0
				bsr.w		WaitRaster

    *--- swap buffers ---*

				movem.l		DrawBuffer(PC),a2-a3
				exg			a2,a3
				movem.l		a2-a3,DrawBuffer											;draw into a2, show a3

    *--- show one... ---*

				move.l		a3,a0
				moveq		#bpl,d0
				lea			BplPtrs+2,a1
				moveq		#bpls-1,d1
				bsr.w		PokePtrs

    *--- ...draw into the other(a2) ---*

				move.l		a2,a1
				bsr			ClearScreen

    *--- add angles ---*

				lea			axspeed(PC),a0
				lea			ax(PC),a1
				move.w		#1023*2,d3													;keep angles within 0..1023 word range
				movem.w		(a1)+,d0-d2
				add.w		(a0)+,d0
				add.w		(a0)+,d1
				add.w		(a0)+,d2
				and.w		d3,d0
				and.w		d3,d1
				and.w		d3,d2
				movem.w		d0-d2,-(a1)

    *--- rotate 3D object ---*

				lea			Vertices(PC),a0												;source vertices
				lea			Coords(PC),a1												;destination rotated vertices
				moveq		#MaxVerts-1,d0
				bsr			RotateObj

				move.l		DrawBuffer(PC),a1
				lea			Lines(PC),a0
				lea			Coords(PC),a2
				moveq		#MaxLines-1,d7
				bsr			DrawObj	

    *--- main loop end ---*

				btst		#6,$bfe001													;Left mouse button not pressed?
				bne.w		MainLoop													;then loop

    *--- exit ---*

				rts

********** Demo Routines **********
PokePtrs:				;Generic, poke ptrs into copper list
.bpll:			move.l		a0,d2
				swap		d2
				move.w		d2,(a1)														;high word of address
				move.w		a0,4(a1)													;low word of address
				addq.w		#8,a1														;skip two copper instructions
				add.l		d0,a0														;next ptr
				dbf			d1,.bpll
				rts

ClearScreen:				;a1=screen destination address to clear
				bsr.w		WaitBlitter
				clr.w		$66(a6)														;destination modulo
				move.l		#$01000000,$40(a6)											;set operation type in BLTCON0/1
				move.l		a1,$54(a6)													;destination address
				move.w		#h*bpls*64+bpl/2,$58(a6)									;blitter operation size
				rts

VBint:					;Blank template VERTB interrupt
				movem.l		d0/a6,-(sp)													;Save used registers
				lea			$dff000,a6
				btst		#5,$1f(a6)													;check if it's our vertb int.
				beq.s		.notvb
    *--- do stuff here ---*
				moveq		#$20,d0														;poll irq bit
				move.w		d0,$9c(a6)
				move.w		d0,$9c(a6)
.notvb:			movem.l		(sp)+,d0/a6													;restore
				rte

    *--- draw object's lines ---*

DrawObj:				;d7/a0-a2=count-1,Lines,screen,Coords
				moveq		#-1,d0														;A mask (always -1)
				move.w		#$8000,d1													;line width 1px (others look bad)
				move.w		#$ffff,d2													;line pattern (word)
				move.w		#bwid,d4													;screen width in bytes
				bsr			LineInit													;Initialize blitter and CPU registers
.linel7:
				move.w		(a0)+,d0
				movem.w		(a2,d0.w),d0-d1
				move.w		(a0)+,d2
				movem.w		(a2,d2.w),d2-d3
				bsr			LineDraw
				dbf			d7,.linel7
				rts


LineInit:				;d0-d2/d4=mask,pixel,pattern,bwid
    *--- set up CPU registers for loop ---*
				move.w		#1*64+2,a3													;add-value for BLTSIZE
				move.l		#$bfa0000f,a4												;minterm+mask for quick-rol
    *--- set up blitter registers ---*
				WAITBLIT
				move.l		d0,BLTAFWM(a6)												;line mask
				move.w		d1,BLTADAT(a6)												;line pixel
				move.w		d2,BLTBDAT(a6)												;line pattern
				move.w		d4,BLTCMOD(a6)												;screen width in bytes (not modulo)
				RTS


LineDraw:				;d0-d4/a1=x1,y1,x2,y2,bwid,screen ptr
				move.l		a4,d6														;minterm4 | mask.w
				and.w		d0,d6														;mask x 0..15
				ror.l		#4,d6														;shift it in at top, low word cleared.

    *--- deltas ---*

				sub.w		d1,d3
				bpl.s		.dyplus
				neg.w		d3
				addq.b		#8,d6
.dyplus:
				sub.w		d0,d2
				bgt.s		.dxplus
				neg.w		d2
				addq.b		#4,d6
.dxplus:
				cmp.w		d2,d3
				bge.s		.dylarger
				exg			d2,d3														;d2=Small delta, d3=Large delta
				addq.b		#2,d6
.dylarger:

    *--- blit values ---*

				muls		d4,d1														;d6=bwid. a table can be used here
				asr.w		#3,d0														;bit 0 ignored by Blitter
				add.w		d0,d1														;offset on screen
				add.l		a1,d1														;add current screen buffer ptr

				add.w		d2,d2
				move.w		d2,d5														;2*SDelta
				swap		d2
				sub.w		d3,d5
				smi			d0															;if (2*Sdelta-Ldelta) < 0,
				sub.b		d0,d6														;add 1 (subtract -1) to octant lookup.
				move.b		OctTbl(PC,d6.w),d6											;look up BLTCON bits for octant

				move.w		d5,d2														;2*Sdelta-Ldelta
				sub.w		d3,d2														;2*Sdelta-2*Ldelta
				asl.w		#6,d3
				add.w		a3,d3														;blit size

    *--- blit ---*

				WAITBLIT
				move.l		d6,BLTCON0(a6)												;shift, minterm, octant bits
				move.w		d5,BLTAPTL(a6)												;2*Sdelta-Ldelta
				move.l		d2,BLTBMOD(a6)												;2*Sdelta | 2*Sdelta-2*Ldelta
				move.l		d1,BLTCPTH(a6)												;source
				move.l		d1,BLTDPTH(a6)												;destination
				move.w		d3,BLTSIZE(a6)
				rts

********************  Octant table  ********************

SNG			=	0*2																		;SINGLE blitter control bit
					;$0a=clear, $6a=xor
OctTbl:
				dc.b		0*4+SNG+1,0*4+SNG+1+64										;7
				dc.b		4*4+SNG+1,4*4+SNG+1+64										;6
				dc.b		2*4+SNG+1,2*4+SNG+1+64										;4
				dc.b		5*4+SNG+1,5*4+SNG+1+64										;5
				dc.b		1*4+SNG+1,1*4+SNG+1+64										;0
				dc.b		6*4+SNG+1,6*4+SNG+1+64										;1
				dc.b		3*4+SNG+1,3*4+SNG+1+64										;3
				dc.b		7*4+SNG+1,7*4+SNG+1+64										;2

RotateObj:				;d0/a0-a1=count-1,Vertices,Coords
				MOVEM.L		A2-A6,-(SP)
				movem.w		ax(PC),a2-a4												;ax,ay,az
				lea			Sin(PC),a5
				lea			Cos(PC),a6
.vertexl:
				movem.w		(a0)+,d1-d3													;x0,y0,z0

    *--- rotation az ---*

				move.w		d1,d4														;x1 = x0*cos(az) - y0*sin(az)
				CosScale	a4,d4
				move.w		d2,d5
				SinScale	a4,d5
				sub.w		d5,d4														;d4=x1

				move.w		d1,d5														;y1 = x0*sin(az) + y0*cos(az)
				SinScale	a4,d5
				CosScale	a4,d2
				add.w		d5,d2														;d2=y1; z1 = z0 = d3 = nop :)

    *--- rotation ax ---*

				move.w		d2,d5														;y2 = y1*cos(ax) - z1*sin(ax)
				CosScale	a2,d5
				move.w		d3,d6
				SinScale	a2,d6
				sub.w		d6,d5														;d5=y2

				move.w		d2,d6														;z2 = y1*sin(ax) + z1*cos(ax)
				SinScale	a2,d6
				CosScale	a2,d3
				add.w		d6,d3														;d3=z2; x2 = x1 = d4 = nop :)

    *--- rotation ay ---*

				move.w		d3,d6														;z3 = z2*cos(ay) - x2*sin(ay)
				CosScale	a3,d6
				move.w		d4,d7
				SinScale	a3,d7
				sub.w		d7,d6														;d6=z3

				SinScale	a3,d3														;x3 = z2*sin(ay) + x2*cos(ay)
				CosScale	a3,d4
				add.w		d3,d4														;d4=x3; y3 = y2 = d5 = nop :)

				PERSP2D																	;if final stage,save direct screen crds
				move.w		d4,(a1)+
				move.w		d5,(a1)+
				move.w		d6,(a1)+
				dbf			d0,.vertexl
				MOVEM.L		(SP)+,A2-A6
				RTS

    *--- vector data ---*

max			=	4095																	;+x,y,z rightward, upward, forward
max2		=	max*2/3

Vertices:
				dc.w		max,max,max													;back surface, counter-clockwise
				dc.w		-max,max,max
				dc.w		-max,-max,max
				dc.w		max,-max,max

				dc.w		max2,max2,0													;middle ring, counter-clockwise
				dc.w		-max2,max2,0
				dc.w		-max2,-max2,0
				dc.w		max2,-max2,0

				dc.w		max,max,-max												;front surface, counter-clockwise
				dc.w		-max,max,-max
				dc.w		-max,-max,-max
				dc.w		max,-max,-max
VerticesE:

Coords:
				ds.b		VerticesE-Vertices

CoordPtrs:
				dc.l		Coords+0*6+4,Coords+1*6+4,Coords+2*6+4,Coords+3*6+4
				dc.l		Coords+4*6+4,Coords+5*6+4,Coords+6*6+4,Coords+7*6+4
				dc.l		Coords+8*6+4,Coords+9*6+4,Coords+10*6+4,Coords+11*6+4

Lines:
				dc.w		0*6,1*6, 1*6,2*6, 2*6,3*6, 3*6, 0*6							;back surface
				dc.w		0*6,4*6, 1*6,5*6, 2*6,6*6, 3*6, 7*6							;connect corners to...

				dc.w		4*6,5*6, 5*6,6*6, 6*6,7*6, 7*6, 4*6							;middle ring

				dc.w		4*6,8*6, 5*6,9*6, 6*6,10*6, 7*6, 11*6						;connect corners to...
				dc.w		8*6,9*6, 9*6,10*6, 10*6,11*6, 11*6, 8*6						;front surface

********** Fastmem Data **********

    *--- double buffering base ptrs ---*

DrawBuffer:		dc.l		Screen2
ViewBuffer:		dc.l		Screen

    *--- angle speeds and angles for rotation ---*

axspeed:		dc.w		-4*2
ayspeed:		dc.w		-5*2
azspeed:		dc.w		3*2

ax:				dc.w		0
ay:				dc.w		0
az:				dc.w		0

Sin:
				INCBIN		"SinCos1024w-ampl32767"										;Hybrid (1024+256 words for 360+90 degs)
SinEnd:

Cos			=	Sin+((SinEnd-Sin)/5)&$fffffffe											;quarter turn offset

*******************************************************************************
				SECTION		ChipData,DATA_C												;declared data that must be in chipmem
*******************************************************************************

Copper:
				dc.w		$1fc,0														;Slow fetch mode, remove if AGA demo.
				dc.w		$8e,$4481													;200h display window top, left
				dc.w		$90,$0cc1													;and bottom, right.
				dc.w		$92,$58														;bitplane dma fetch start
				dc.w		$94,$b8														;and stop for smaller screen.

				dc.w		$108,bwid-bpl												;modulos
				dc.w		$10a,bwid-bpl

				dc.w		$102,0														;Scroll register (and playfield pri)

Palette:
				dc.w		$180,$264,$182,$7fc
BplPtrs:
				dc.w		$e0,0
				dc.w		$e2,0
				dc.w		$100,bpls*$1000+$200										;enable bitplanes

				dc.w		$ffdf,$fffe													;allow VPOS>$ff

				dc.w		$0007,$fffe													;just some stripes. any impression of
				dc.w		$180,$532													;"ground" is just imagination. :)
				dc.w		$0407,$fffe
				dc.w		$180,$643
				dc.w		$0c07,$fffe
				dc.w		$180,$532
				dc.w		$1c07,$fffe
				dc.w		$180,$643
				dc.w		$ffff,$fffe													;magic value to end copperlist
CopperE:

*******************************************************************************
				SECTION		ChipBuffers,BSS_C											;BSS doesn't count toward exe size
*******************************************************************************

Screen:			ds.b		h*bwid														;Define storage for buffer 1
Screen2:ds.b h*bwid			;and buffer 2

				END