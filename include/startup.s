***********************************************************
* Code:	QubeX2
* Date:	2021-04-22
*
***********************************************************

			include		"hardware/dmabits.i"
			include		"hardware/blit.i"
			include		"hardware/intbits.i"
			include		"system.i"
			include		"hardware.i"			

			section		CODE,code

***********************************************************
* MACROS
*
WAITVB		MACRO
			move.l		CUSTOM+VPOSR,d0
			and.l		#$0001ff00,d0
			cmp.l		#303<<8,d0
			bne.s		\1
			ENDM

WAITVB2		MACRO
			move.l		CUSTOM+VPOSR,d0
			and.l		#$0001ff00,d0
			cmp.l		#303<<8,d0
			beq.s		\1
			ENDM

LMOUSE		MACRO
			btst		#6,$bfe001
			bne.s		\1
			ENDM

BLTWAIT		MACRO
			btst		#DMAB_BLTDONE-8,DMACONR(a6)
\1
			btst		#DMAB_BLTDONE-8,DMACONR(a6)
			bne.s		\1
			ENDM

CLRS		MACRO
			lea			S_CLR,a0
			move.l		\1,a6
			add.l		#40*256,a6
			movem.l		(a0),d0-d4/a0-a2
			move.l		#$13f,d7
.s_l\@:		movem.l		d0-d4/a0-a2,-(a6)
			dbra		d7,.s_l\@
			ENDM

PERSP2D:MACRO			
			;final projection from world to screen coords
			ext.l		\1
			ext.l		\2
			neg.w		\3																	;world +z is forward,screen perspective is away
			asr.w		#8,\3																;this scaling
			add.w		#78,\3																;and eye Z determines Field of View.
			divs		\3,\1
			divs		\3,\2
			add.w		#320/2,\1															;center horizontally on the screen
			add.w		#256/2,\2															;center vertically
			ENDM


PointXYZ	MACRO
			dc.w		\1, \2, \3
			ENDM

VertAB		MACRO
			dc.w		\1*6, \2*6
			ENDM

VertCount	MACRO
			dc.w		\1
			ENDM


***********************************************************
* START
*
			movem.l		d0-d7/a0-a6,-(sp)
			movea.l		$4.w,a6
			lea			V_GFXNAME(pc),a1
			moveq		#33,d0																;kickstart 1.2+
			jsr			_OpenLibrary(a6)
			tst.l		d0
			beq			.s_er1
			move.l		d0,V_GFXBASE

			bsr			s_stp
			bsr			start

			bsr			s_rest
.s_er1:		movem.l		(sp)+,d0-d7/a0-a6
			moveq		#0,d0
			rts

***********************************************************
* SETUP
*

s_stp:		bsr			s_gvbr																;save vector base register
			move.l		V_GFXBASE,a6
			jsr			_WaitBlit(a6)
			jsr			_OwnBlit(a6)
			move.l		ActiView(a6),V_VIEW
			suba.l		a1,a1
			jsr			_LoadView(a6)
			jsr			_WaitTOF(a6)
			jsr			_WaitTOF(a6)
			movea.l		$4.w,a6

	; super priority
			sub.l		a1,a1
			jsr			_FindTask(a6)
			move.l		d0,a1
			moveq		#127,d0
			jsr			_SetTaskPri(a6)

			jsr			_Forbid(a6)															;no multitasking
			jsr			_Disable(a6)														;stop interrupts
	
.s_wb
			WAITVB		.s_wb

			lea			CUSTOM,a6
			move.w		DMACONR(a6),d0
			ori.w		#(DMAF_SETCLR!DMAF_MASTER),d0
			move.w		d0,V_DMACON
			move.w		INTENAR(a6),d0
			ori.w		#(INTF_SETCLR!INTF_INTEN),d0
			move.w		d0,V_INTENA
			move.w		ADKCONR(a6),V_ADKCON
			movea.l		V_VBR,a1
			move.l		$6c(a1),V_INTER

	; disable DMA and interrupts
			move.w		#$7fff,d0
			move.w		d0,DMACON(a6)
			move.w		d0,INTENA(a6)
			move.w		d0,INTREQ(a6)
	;setup interrupts
	;lea	interrupt(pc),a0
	;move.l	a0,$6c(a1)
			move.w		#(DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),DMACON(a6)
			move.w		#(INTF_SETCLR!INTF_EXTER),INTENA(a6)
			rts

***********************************************************
* RESTORE
*

s_rest:
			lea			CUSTOM,a6
			move.w		#$7fff,d0
			move.w		d0,DMACON(a6)
			move.w		d0,INTENA(a6)
			move.w		d0,INTREQ(a6)

			movea.l		V_VBR,a1
			move.l		V_INTER,$6c(a1)
			move.w		V_ADKCON,ADKCON(a6)
			move.w		V_DMACON,DMACON(a6)
			move.w		V_INTENA,INTENA(a6)

			movea.l		$4.w,a6
			jsr			_Enable(a6)															;multitasking
			jsr			_Permit(a6)															;start interupts

			movea.l		V_GFXBASE,a6
			movea.l		V_VIEW,a1
			jsr			_LoadView(a6)
			jsr			_WaitTOF(a6)
			jsr			_WaitTOF(a6)
			move.l		SysCop1(a6),COP1LC
			move.l		SysCop2(a6),COP2LC
			move.w		#0,COPJMP1

			jsr			_DisownBlit(a6)
			movea.l		a6,a1
			movea.l		$4.w,a6
			jsr			_CloseLibrary(a6)	
			rts


***********************************************************
* STORE VECTOR BASE REGISTERS 
*
s_gvbr:
			movea.l		$4.w,a6
			btst		#0,AttnFlags+1(a6)
			beq.s		.s_getn

			lea			.s_getsc(pc),a5
			jsr			_Supervisor(a6)
			move.l		d0,V_VBR
.s_getn:	
			rts
			CNOP		0,4
.s_getsc:	
			movec		vbr,d0
			rte
	
	
***********************************************************
* DATA
*

V_GFXNAME	dc.b		"graphics.library",0
			even

		
V_DMACON	dc.w		0
V_INTENA	dc.w		0
V_ADKCON	dc.w		0
V_GFXBASE	dc.l		0
V_VIEW		dc.l		0
V_VBR		dc.l		0
V_TIMER		dc.l		0
V_INTER		dc.l		0
	
S_CLR:		dcb.l		16,0
