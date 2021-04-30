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

***********************************************************************************
* x' = x / z + 1
* y' = y / z + 1
PERSP2D     MACRO			
			;final projection from world to screen coords
			ext.l		\1
			ext.l		\2
			neg.w		\3								;world +z is forward,screen perspective is away
			asr.w		#8,\3
			add.w		#78,\3							;and eye Z determines Field of View.
			divs		\3,\1
			divs		\3,\2
			add.w		#320/2,\1						;center horizontally on the screen
			add.w		#256/2,\2						;center vertically
			and.l		#$0000ffff,\1
			and.l		#$0000ffff,\2
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