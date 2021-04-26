;APS000000000000000000000000000014F4000000000000000000000000000000000000000000000000
***********************************************************
* Code:	QubeX2
* Date:	2021-04-22
*
***********************************************************

         incdir     "include"
         include    "startup.s"

         section    CODE,code

****************************************************************************
* SETTINGS
*
BARCNT equ 8-1
BARDST equ 7

***********************************************************
* START
*
start:	
         lea        CUSTOM,a6
         move.w     #(DMAF_SETCLR!DMAF_COPPER!DMAF_SPRITE!DMAF_RASTER!DMAF_MASTER),DMACON(a6)
         move.w     #(INTF_SETCLR!INTF_EXTER),INTENA(a6)


	; save sprite addresses to list
         lea        sprites,a0
         move.l     #sprt0,(a0)+
         move.l     #sprt1,(a0)+
         move.l     #sprt2,(a0)+
         move.l     #sprt3,(a0)+
         move.l     #sprt4,(a0)+
         move.l     #sprt5,(a0)+
         move.l     #sprt6,(a0)+
         move.l     #sprt7,(a0)+

	; clear bit plane
         lea        bitpl1,a1
         move.l     #$0,d0
         move.l     #$09ff,d1                                                                    ;10*256-1=$9ff (40 bytes / 4 (longword))
.clear:  move.l     d0,(a1)+
         dbra       d1,.clear

         lea        bitpl2,a1
         move.l     #$0,d0
         move.l     #$09ff,d1
.clr2    move.l     d0,(a1)+
         dbra       d1,.clr2


main:	WAITVB	main

         bsr        draw_sprites

wait:	WAITVB2	wait

         LMOUSE     main
	
         rts
***********************************************************
*
draw_sprites:
         movem.l    d0-d7/a0-a6,-(sp)

         addq.l     #1,V_TIMER

         lea        CUSTOM,a6

	;======================================================
	; swap copper lists
	; -------------------------------------------------
         move.l     #cop1,d0
         move.l     #cop2,d1
         move.l     copper,d2
         cmp.l      d2,d0
         beq        .sw1
         move.l     d0,copper
         bra        .cnt_w
.sw1:    move.l     d1,copper
         exg        d0,d1
.cnt_w:  move.l     copper,COP1LCH(a6)
         move.l     d0,a4                                                                        ;other copper
         move.l     #coplst,a2                                                                   ;defaults for copper

	; write defaults values to copper 
.defc:   move.w     (a2)+,(a4)+
         cmp.l      #COPPER_HALT,(a2)
         bne        .defc

	; --------------------------------------------------
         move.l     #0,d2                                                                        ;
         lea        sin2,a1                                                                      ;address to sin2
         lea        rowtbl,a3                                                                    ;
	

	; CLEAR ROWTBL
	; ======================
         move.l     #$ff,d7
.clr1    add.b      #$1,d7
         move.l     #$0,(a3)+
         cmp.b      #$ff,d7
         bne        .clr1
	

         move.l     #BARCNT,d6
         move.l     #0,d5
         move.b     sinstp,d5
         move.l     d5,d4
         lea        barclr,a2
.bl1:    lea        rowtbl,a3


	; STORE COLORS AND ROWID
	; TO ROWTBL
	; ======================
         move.w     (a2)+,d1                                                                     ;bar clr count	
         move.l     #0,d2
         move.b     (a1,d4),d2                                                                   ;sin


         lsl.w      #2,d2
.lop1:   move.l     #0,d3
         move.w     (a2)+,d3
         swap       d3
         move.w     #$1,d3
         cmp.l      #$0,(a3,d2)
         bne        .nxt
         move.l     d3,(a3,d2)                                                                   ;move to rowtbl(n) if empty
.nxt:    add.l      #4,d2
         dbra       d1,.lop1

	
         add.b      #BARDST,d4
         dbra       d6,.bl1


         lea        rowtbl,a3


	; GET VALUES FROM ROWTBL
	; AND WRITE TO COPPER
	; =======================
         move.l     #$ff,d7
.lop2:   add.b      #$1,d7
         move.l     (a3)+,d0
         cmp.w      #$1,d0                                                                       ;is 1 has colors
         bne        .cnt1
         move.l     d7,d2                                                                        ;wait line
         lsl.l      #8,d2
         add.w      #$1801,d2                                                                    ;move down a bit
         move.w     d2,(a4)+
         move.w     #$fffe,(a4)+
         move.w     #COLOR00,(a4)+
         swap       d0
         move.w     d0,(a4)+
.cnt1:   cmp.b      #$ff,d7
         bne        .lop2

         move.l     #COPPER_HALT,(a4)+
	;=======================================================	

         move.l     #sprt0,SPR0PTH(a6)
         move.l     #sprt1,SPR1PTH(a6)
         move.l     #sprt2,SPR2PTH(a6)
         move.l     #sprt3,SPR3PTH(a6)
         move.l     #sprt4,SPR4PTH(a6)
         move.l     #sprt5,SPR5PTH(a6)
         move.l     #sprt6,SPR6PTH(a6)
         move.l     #sprt7,SPR7PTH(a6)
         move.l     #bitpl1,BPL1PTH(a6)
         move.l     #bitpl2,BPL2PTH(a6)
         move.w     COPJMP1(a6),d0

         lea        sin2,a1
         move.l     #0,d5
         move.b     sinstp,d5
         move.l     d5,d4

         move.l     #7,d7
         lea        sprites,a0
.lsp:    move.l     (a0)+,a2
         move.l     #0,d0
         move.b     (a1,d4),d0                                                                   ;sin value
         add.b      #$0a,d4                                                                      ;distance between bars
         asr.l      #1,d0
         add.w      #$46,d0                                                                      ;add to x offset

         move.b     d0,1(a2)
         dbra       d7,.lsp

         add.b      #1,d5
         move.b     d5,sinstp

	; --------------------------------------------------
.exit:
         movem.l    (sp)+,d0-d7/a0-a6
	;nop
	;rte
         rts

         section    DATA,data_c
*****************************************************************************
* COPPER
*

debug:   dc.l       0
sinstp:  dc.b       0
         even
rowtbl:  dcb.l      256,0

copper:  dc.l       0

cop1:    dcb.l      1024,0

cop2:    dcb.l      1024,0

barclr:	
         dc.w       12-1
         dc.w       $0234,$0007,$0009,$000f
         dc.w       $000f,$000f,$0009,$0007
         dc.w       $0006,$0005,$0005,$0234
         dc.w       12-1
         dc.w       $0234,$0007,$0009,$000f
         dc.w       $000f,$000f,$0009,$0007
         dc.w       $0006,$0005,$0005,$0234
         dc.w       12-1
         dc.w       $0234,$0007,$0009,$000f
         dc.w       $000f,$000f,$0009,$0007
         dc.w       $0006,$0005,$0005,$0234
         dc.w       12-1
         dc.w       $0234,$0007,$0009,$000f
         dc.w       $000f,$000f,$0009,$0007
         dc.w       $0006,$0005,$0005,$0234
         dc.w       12-1
         dc.w       $0234,$0007,$0009,$000f
         dc.w       $000f,$000f,$0009,$0007
         dc.w       $0006,$0005,$0005,$0234
         dc.w       12-1
         dc.w       $0234,$0007,$0009,$000f
         dc.w       $000f,$000f,$0009,$0007
         dc.w       $0006,$0005,$0005,$0234
         dc.w       12-1
         dc.w       $0234,$0007,$0009,$000f
         dc.w       $000f,$000f,$0009,$0007
         dc.w       $0006,$0005,$0005,$0234
         dc.w       12-1
         dc.w       $0234,$0007,$0009,$000f
         dc.w       $000f,$000f,$0009,$0007
         dc.w       $0006,$0005,$0005,$0234


coplst:  dc.w       BPLCON0,$2200	
         dc.w       BPLCON1,$0000
         dc.w       BPLCON2,$0024                                                                ;sprites have priority over playfields
         dc.w       BPLCON3,$0c00
         dc.w       FMODE,$0000
         dc.w       BPL1MOD,$0000
         dc.w       BPL2MOD,$0000
         dc.w       DIWSTRT,$2c81
         dc.w       DIWSTOP,$2cc1                                                                ;
         dc.w       DDFSTRT,$0038
         dc.w       DDFSTOP,$00d0	
         dc.w       COLOR00,$0234
         dc.w       COLOR01,$00f0
         dc.w       COLOR02,$0f00
         dc.w       COLOR03,$000f
	;sprite colors
         dc.w       COLOR17,$0500
         dc.w       COLOR18,$0900
         dc.w       COLOR19,$0f00
	;sprite colors
         dc.w       COLOR21,$0500
         dc.w       COLOR22,$0900
         dc.w       COLOR23,$0f00
	;sprite colors
         dc.w       COLOR25,$0500
         dc.w       COLOR26,$0900
         dc.w       COLOR27,$0f00
	;sprite colors
         dc.w       COLOR29,$0500
         dc.w       COLOR30,$0900
         dc.w       COLOR31,$0f00
         dc.l       COPPER_HALT

sprites:
         dcb.l      8,0

sprt0:   dc.w       $6a40,$2c02
         dcb.l      256,$ff0f0ff0
         dc.w       $0000,$0000

sprt1:   dc.w       $6640,$2c02
         dcb.l      256,$ff0f0ff0
         dc.w       $0000,$0000

sprt2:   dc.w       $6240,$2c02
         dcb.l      256,$ff0f0ff0
         dc.w       $0000,$0000

sprt3:   dc.w       $5e40,$2c02
         dcb.l      256,$ff0f0ff0
         dc.w       $0000,$0000

sprt4:   dc.w       $5a40,$2c02
         dcb.l      256,$ff0f0ff0
         dc.w       $0000,$0000

sprt5:   dc.w       $5640,$2c02
         dcb.l      256,$ff0f0ff0
         dc.w       $0000,$0000

sprt6:   dc.w       $5240,$2c02
         dcb.l      256,$ff0f0ff0
         dc.w       $0000,$0000

sprt7:   dc.w       $5040,$2c02
         dcb.l      256,$ff0f0ff0
         dc.w       $0000,$0000

sprtx:   dc.w       $0000,$0000


         include    "sintables.i"

*****************************************************************************
* SCREEN
*

         section    SCREEN,bss_c
	;bytes per line * lines in playfield * nr of bitplanes

bitpl1:  ds.b       40*256                                                                       ;40/4 = 10 long words per line
bitpl2:  ds.b       40*256





