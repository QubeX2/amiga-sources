;APS00000000000000000000000000000B12000000000000000000000000000000000000000000000000
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
         move.l     #$ff00ff00,d0
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

.vb:	
         move.l     #sprt0,SPR0PTH(a6)
         move.l     #sprt1,SPR1PTH(a6)
         move.l     #sprt2,SPR2PTH(a6)
         move.l     #sprt3,SPR3PTH(a6)
         move.l     #sprt4,SPR4PTH(a6)
         move.l     #sprt5,SPR5PTH(a6)
         move.l     #sprt6,SPR6PTH(a6)
         move.l     #sprt7,SPR7PTH(a6)
         move.l     #coplst,COP1LCH(a6)
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
         dc.w       COLOR21,$0505
         dc.w       COLOR22,$0909
         dc.w       COLOR23,$0f0f
	;sprite colors
         dc.w       COLOR25,$0550
         dc.w       COLOR26,$0990
         dc.w       COLOR27,$0ff0
	;sprite colors
         dc.w       COLOR29,$0005
         dc.w       COLOR30,$0009
         dc.w       COLOR31,$000f
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





