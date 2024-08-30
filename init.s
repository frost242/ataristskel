
	.text

init:
                move.l  4(sp),a5                        ;address to basepage
                move.l  $0c(a5),d0                      ;length of text segment
                add.l   $14(a5),d0                      ;length of data segment
                add.l   $1c(a5),d0                      ;length of bss segment
                add.l   #$100,d0                        ;length of basepage
                add.l   #$1000,d0                       ;length of stackpointer
                move.l  a5,d1                           ;address to basepage
                add.l   d0,d1                           ;end of program
                and.l   #-2,d1                          ;make address even
                move.l  d1,sp                           ;new stackspace

                move.l  d0,-(sp)                        ;mshrink()
                move.l  a5,-(sp)                        ;
                move.w  d0,-(sp)                        ;
                move.w  #$4a,-(sp)                      ;
                trap    #1                              ;
                lea     12(sp),sp                       ;



		clr.l	-(sp)
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,save_stack

                jsr     cookie_check                    ;Check _MCH and CT60

               cmp.l   #"TT  ",computer_type           ;Check for TT and exit if true
                bne.s   .not_tt                         ;
                bra     exit_super                      ;
.not_tt:                                                ;

                cmp.b   #"F",computer_type              ;
                bne.s   .not_falcon                     ;
                bra     exit_super                      ;
.not_falcon:                                            ;
                cmp.l   #"ST  ",computer_type           ;
                bne.s   .not_st                         ;
                bra     exit_super                      ;

.not_st:                                                ;

                cmp.b   #"F",computer_type              ;
                bne.s   .st_setup                       ;
                jsr     falcon_save_video               ;
                jsr     falcon_set_video                ;
                bra.s   .st_done                        ;

.st_setup:      move.b  $ffff820a.w,save_refresh        ;Save and set refreshrate
                or.b    #%00000010,$ffff820a.w          ;

                bsr     xbios_vsync                     ;Save and set resolution
                move.b  $ffff8260.w,save_res            ;
                clr.b   $ffff8260.w                     ;
.st_done:

                movem.l $ffff8240.w,d0-d7               ;Save palette
                movem.l d0-d7,save_pal                  ;

                lea     save_screenadr,a0               ;Save screenaddress
                move.b  $ffff8201.w,(a0)+               ;
                move.b  $ffff8203.w,(a0)+               ;
                move.b  $ffff820d.w,(a0)+               ;

                move.l  screen_adr,d0                   ;Set screenaddress
                lsr.w   #8,d0                           ;
                move.l  d0,$ffff8200.w                  ;

                move.b  $ffff8265.w,save_hscroll        ;Save hscroll
                move.b  $ffff820f.w,save_lw             ;Save linewidth

                cmp.l   #"MSTe",computer_type           ;Check for Mega STe
                bne.s   .not_mste                       ;
                move.b  $ffff8e21.w,save_mste           ;Save MSTe speed
                clr.b   $ffff8e21.w                     ;Set MSTe to 8 MHz no cache
.not_mste:

                move.b  $484.w,save_keymode             ;Save and turn keyclick off
                bclr    #0,$484                         ;

                move.b  #$12,$fffffc02.w                ;Kill mouse

;-------------- Save vectors, MFP and start the demosystem
                move.w  #$2700,sr                       ;Stop interrupts

                move.l  usp,a0                          ;USP
                move.l  a0,save_usp                     ;

                move.l  $68.w,save_hbl                  ;HBL
                move.l  $70.w,save_vbl                  ;VBL
                move.l  $134.w,save_timer_a             ;Timer-A
                move.l  $120.w,save_timer_b             ;Timer-B
                move.l  $114.w,save_timer_c             ;Timer-C
                move.l  $110.w,save_timer_d             ;Timer-D
                move.l  $118.w,save_acia                ;ACIA

                lea     save_mfp,a0                     ;Restore vectors and mfp
                move.b  $fffffa01.w,(a0)+               ;// datareg
                move.b  $fffffa03.w,(a0)+               ;Active edge
                move.b  $fffffa05.w,(a0)+               ;Data direction
                move.b  $fffffa07.w,(a0)+               ;Interrupt enable A
                move.b  $fffffa13.w,(a0)+               ;Interupt Mask A
                move.b  $fffffa09.w,(a0)+               ;Interrupt enable B
                move.b  $fffffa15.w,(a0)+               ;Interrupt mask B
                move.b  $fffffa17.w,(a0)+               ;Automatic/software end of interupt
                move.b  $fffffa19.w,(a0)+               ;Timer A control
                move.b  $fffffa1b.w,(a0)+               ;Timer B control
                move.b  $fffffa1d.w,(a0)+               ;Timer C & D control
                move.b  $fffffa27.w,(a0)+               ;Sync character
                move.b  $fffffa29.w,(a0)+               ;USART control
                move.b  $fffffa2b.w,(a0)+               ;Receiver status
                move.b  $fffffa2d.w,(a0)+               ;Transmitter status
                move.b  $fffffa2f.w,(a0)+               ;USART data

                move.l  #vbl,$70.w                      ;Set VBL

                move.l  #timer_b,$120.w                 ;Set Timer-B
                move.l  #timer_c,$114.w                 ;Set Timer-C
                move.l  #timer_d,$110.w                 ;Set Timer-D
                move.l  #acia,$118.w                    ;Set ACIA

                move.l  #hbl,$68.w                      ;Set HBL

                clr.b   $fffffa07.w                     ;Interrupt enable A (Timer-A & B)
                clr.b   $fffffa13.w                     ;Interrupt mask A (Timer-A & B)
                clr.b   $fffffa09.w                     ;Interrupt enable B (Timer-C & D)
                clr.b   $fffffa15.w                     ;Interrupt mask B (Timer-C & D)

                clr.b   $fffffa19.w                     ;Timer-A control (stop)
                clr.b   $fffffa1b.w                     ;Timer-B control (stop)
                clr.b   $fffffa1d.w                     ;Timer-C & D control (stop)

                bclr    #3,$fffffa17.w                  ;Automatic end of interrupt
                bset    #5,$fffffa07.w                  ;Interrupt enable A (Timer-A)
                bset    #5,$fffffa13.w                  ;Interrupt mask A

                move.w  #$2300,sr                       ;Enable interrupts


		bsr	letswrap

exit:
                bsr.w   black_pal

                move.w  #$2700,sr                       ;Stop interrupts

                move.l  save_usp,a0                     ;USP
                move.l  a0,usp                          ;
                move.l  save_hbl,$68.w                  ;HBL
                move.l  save_vbl,$70.w                  ;VBL
                move.l  save_timer_a,$134.w             ;Timer-A
                move.l  save_timer_b,$120.w             ;Timer-B
                move.l  save_timer_c,$114.w             ;Timer-C
                move.l  save_timer_d,$110.w             ;Timer-D
                move.l  save_acia,$118.w                ;ACIA

                lea     save_mfp,a0                     ;restore vectors and mfp
                move.b  (a0)+,$fffffa01.w               ;// datareg
                move.b  (a0)+,$fffffa03.w               ;Active edge
                move.b  (a0)+,$fffffa05.w               ;Data direction
                move.b  (a0)+,$fffffa07.w               ;Interrupt enable A
                move.b  (a0)+,$fffffa13.w               ;Interupt Mask A
                move.b  (a0)+,$fffffa09.w               ;Interrupt enable B
                move.b  (a0)+,$fffffa15.w               ;Interrupt mask B
                move.b  (a0)+,$fffffa17.w               ;Automatic/software end of interupt
                move.b  (a0)+,$fffffa19.w               ;Timer A control
                move.b  (a0)+,$fffffa1b.w               ;Timer B control
                move.b  (a0)+,$fffffa1d.w               ;Timer C & D control
                move.b  (a0)+,$fffffa27.w               ;Sync character
                move.b  (a0)+,$fffffa29.w               ;USART control
                move.b  (a0)+,$fffffa2b.w               ;Receiver status
                move.b  (a0)+,$fffffa2d.w               ;Transmitter status
                move.b  (a0)+,$fffffa2f.w               ;USART data

                move.w  #$2300,sr                       ;Start interrupts

                cmp.b   #"F",computer_type              ;
                beq.s   .falcon_setup                   ;
                bra.s   .st_restore                     ;
.falcon_setup:  jsr     falcon_restore_video            ;
                bra.s   .res_done                       ;

.st_restore:    move.b  save_refresh,$ffff820a.w        ;Restore refreshrate
               bsr     xbios_vsync                     ;Restore resolution
                move.b  save_res,$ffff8260.w            ;
.res_done:

                cmp.l   #"MSTe",computer_type           ;Check for Mega STe
                bne.s   .not_mste                       ;
                move.b  save_mste,$ffff8e21.w           ;Save MSTe speed
.not_mste:

                clr.w   $ffff8264.w                     ;Reset left border
                move.b  save_hscroll,$ffff8265.w        ;Restore hscroll
                move.b  save_lw,$ffff820f.w             ;Restore linewidth

                move.b  #$8,$fffffc02.w                 ;Enable mouse
                move.b  save_keymode,$484.w             ;Restore keyclick

                lea     save_screenadr,a0               ;Restore screenaddress
                move.b  (a0)+,$ffff8201.w               ;
                move.b  (a0)+,$ffff8203.w               ;
                move.b  (a0)+,$ffff820d.w               ;

                movem.l save_pal,d0-d7                  ;Restore palette
                movem.l d0-d7,$ffff8240.w               ;

                bsr     clear_kbd

exit_super:     move.l  save_stack,-(sp)                ;Exit supervisor
                move.w  #32,-(sp)                       ;
                trap    #1                              ;
                addq.l  #6,sp                           ;

exit_pterm:

                clr.w   -(sp)                           ;pterm()
                trap    #1                              ;

xbios_vsync:    move.w  #37,-(sp)                       ;vsync()
                trap    #14                             ;
                addq.l  #2,sp                           ;
                rts

aitkey:        move.w  #7,-(sp)                        ;crawcin()
                trap    #1                              ;
                addq.l  #2,sp                           ;
                rts
clear_kbd:      move.w  #2,-(sp)                        ;bconstat()
                move.w  #1,-(sp)                        ;
                trap    #13                             ;
                addq.l  #4,sp                           ;
                tst.l   d0                              ;
                beq.s   .ok                             ;
                move.w  #2,-(sp)                        ;bconin()
                move.w  #2,-(sp)                        ;
                trap    #13                             ;
                addq.l  #4,sp                           ;
                bra.s   clear_kbd                       ;
.ok:            rts                      

black_pal:      lea     $ffff8240.w,a0
                moveq   #0,d0
                rept    8
                move.l  d0,(a0)+
                endr
                rts


dummy:
		rts

	.bss

save_hbl:               ds.l    1                       ;HBL vector
save_vbl:               ds.l    1                       ;VBL vector
save_timer_a:           ds.l    1                       ;Timer-A vector
save_timer_b:           ds.l    1                       ;Timer-B vector
save_timer_c:           ds.l    1                       ;Timer-C vector
save_timer_d:           ds.l    1                       ;Timer-D vector
save_acia:              ds.l    1                       ;ACIA vector
save_usp:               ds.l    1                       ;USP
save_mfp:               ds.b    16                      ;MFP
save_res:               ds.w    1                       ;Resolution
save_refresh:           ds.w    1                       ;Refreshrate
save_screenadr:         ds.l    1                       ;Screen address
save_keymode:           ds.w    1                       ;Keyclick
save_stack:             ds.l    1                       ;User stack
save_pal:               ds.w    16                      ;Palette
save_hscroll:           ds.w    1                       ;Hscroll
save_lw:                ds.w    1                       ;Linewidth
save_mste:              ds.w    1                       ;Mega STe speed
screen_adr:             ds.l    1                       ;Screen 1
screen_adr2:            ds.l    1                       ;Screen 2
screen_adr_base:        ds.l    1                       ;Address to both screen buffers


	.text

	.include	"cookie.s"
	.include	"falcon.s"
	.include	"vbl.s"
	.include	"timers.s"

	.text
letswrap:
