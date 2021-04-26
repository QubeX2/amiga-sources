;APS00000000000000000000000000000000000000000000000000000000000000000000000000000000


start:	movem.l	d0-d7/a0-a6,-(sp)

	move.w	#4,d0
	lsl.w	#6,d0

	;lea	bitple,a6
	;lea	bitpl1,a5
	;add.l	#40*256,a5

	move.l	#$13371337,bitple

	;lea	bitpl1,a5
	;move.l	#$9ff,d7
.loop:	;move.l	#$12271227,(a5)+
	;dbra	d7,.loop

	;lea	bitpl1,a5
	;add.l	#40*256,a5
	;move.l	#$9ff,d7
.loop2:	;move.l	#$11171117,-(a5)
	;dbra	d7,.loop2


	; clear lowres bitpl
	lea	clr2,a0
	lea	bitpl1,a6
	add.l	#40*256,a6
	movem.l	(a0),d0-d6/a0-a4
	move.l	#$d4,d7
.loop3:	movem.l	d0-d6/a0-a4,-(a6)
	dbra	d7,.loop3
	




	movem.l	(sp)+,d0-d7/a0-a6
	rts


clr:	dcb.l	16,$ffffffff
clr2:	dcb.l	16,$0


	section	SCREEN,bss_c
bitpl1:	ds.b	40*256		;40/4 = 10 long words per line
bitple:	ds.l	1
