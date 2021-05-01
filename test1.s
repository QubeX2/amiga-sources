		incdir		"include"
		include		"macros.s"
		section		CODE,code

		lea			list,a0
		move.l		#128*4-1,d7
.clr:	move.l		#0,(a0)+
		dbra		d7,.clr

main:	move.l		#4,d6
		jsr			create_list_item
		move.l		#3,d6
		jsr			create_list_item
		move.l		#2,d6
		jsr			create_list_item
		move.l		#1,d6
		jsr			create_list_item

		jsr			sort_list_items

		LMOUSE		main
		rts

sort_list_items:
		rts		

create_list_item:
		;d6 = value
		lea			list,a0
.cnxt:	move.l		(a0)+,d0		
		move.l		(a0)+,d1
		cmp.l		#0,d1
		beq			.cadd
		move.l		d1,a0
		bra			.cnxt
.cadd:	move.l		d6,(-8,a0)
		move.l		a0,(-4,a0)
		rts 
****************************************
* LIST 
*	data -> l
*	next -> l

		dc.l		0
list:	dcb.l		128*4,0