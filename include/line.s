***********************************************************
* Code:	QubeX2
* Date:	2021-04-22
* Line Routine
***********************************************************
; d0=x1, d1=y1, d2=x2, d3=y2, d4=width, a0=aptr
blit_line:
			lea			CUSTOM,a6
			sub.w		d0,d2					;calc dx
			bmi			.lxneg					;if neg [3,4,5,6]
			sub.w		d1,d3					;calc dy
			bmi			.lyneg					;if neg [7,8]
			cmp.w		d3,d2					;is one of [1,2]
			bmi			.lygtx					;if y>x is [2]
			moveq.l		#OCTANT1+LINEMODE,d5	;octant is 1
			bra			.lfactory

.lygtx:		exg			d2,d3					;x is gt than y
			moveq.l		#OCTANT2+LINEMODE,d5	;2
			bra			.lfactory

.lyneg:		neg.w		d3						;abs(dy)
			cmp.w		d3,d2					;[7,8]
			bmi			.lynygtx				;if y>x is [7]
			moveq.l		#OCTANT8+LINEMODE,d5	;ix [8]
			bra			.lfactory

.lynygtx:
			exg			d2,d3					;x>y
			moveq.l		#OCTANT7+LINEMODE,d5	;is [7]
			bra			.lfactory

.lxneg:		neg.w		d2						;dx<0 [3,4,5,6]
			sub.w		d1,d3					;dy
			bmi			.lxyneg					;if < 0 [5,6]
			cmp.w		d3,d2					;is [3,4]
			bmi			.lxnygtx				;if y>x is [3]
			moveq.l		#OCTANT4+LINEMODE,d5	;is [4]
			bra			.lfactory

.lxnygtx:
			exg			d2,d3					;x>y
			moveq.l		#OCTANT3+LINEMODE,d5	;is [3]
			bra			.lfactory

.lxyneg:	neg.w		d3						;y<0 [5,6]
			cmp.w		d3,d2					;y>x?
			bmi			.lxynygtx				;is [6]
			moveq.l		#OCTANT5+LINEMODE,d5
			bra			.lfactory

.lxynygtx:
			exg			d2,d3
			moveq.l		#OCTANT6+LINEMODE,d5

.lfactory:
			mulu		d4,d1					;y1 * width
			ror.l		#4,d0					;into hi word
			add.w		d0,d0					;d0 * 2
			add.l		d1,a0					;ptr += (x1 >> 3)
			add.w		d0,a0					;ptr += (y1 * width)
			swap		d0						;4 bits of x1
			or.w		#$bfa,d0				;
			lsl.w		#2,d3					;y = 4 * y
			add.w		d2,d2					;x = 2 * x
			move.w		d2,d1 
			lsl.w		#5,d1 
			add.w		#$42,d1 

			move.w		d3,BLTBMOD(a6)
			sub.w		d2,d3 
			ext.l		d3
			move.l		d3,BLTAPT(a6)
			bpl			.lover
			or.w		#SIGNFLAG,d5
.lover         
			BLTWAIT		bw1	
			move.w		d0,BLTCON0(a6)
			move.w		d5,BLTCON1(a6)
			move.w		d4,BLTCMOD(a6)
			move.w		d4,BLTDMOD(a6)
			sub.w		d2,d3 
			move.w		d3,BLTAMOD(a6)
			move.w		#$8000,BLTADAT(a6)
			moveq.l		#-1,d5
			move.l		d5,BLTAFWM(a6)
			move.l		a0,BLTCPT(a6)
			move.l		a0,BLTDPT(a6) 
			move.w		d1,BLTSIZE(a6)
			rts
         