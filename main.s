
.include	"init.s"

; corrige les adresses log et phys, aligne sur 256 octets
; se reporter à logbase et phybase qui pointe sur les écrans + 256
		sf.b	logbase+3
		sf.b   phybase+3

effect:
		bsr	black_pal
		cmp.b	#$39,$fffffc02.w
		beq.s	exit_effect

		lea	pi1+2,a1
		movem.l	(a1)+,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.l	logbase,a0
		;lea	pi1+34,a1	; voir au-dessus, déjà fait
		move.w	#8000-1,d0
.copypi1:	move.l	(a1)+,(a0)+
		dbra	d0,.copypi1

		lea	logbase,a0
		move.l  (a0)+,d0                   ;Set screenaddress
		move.l	d0,d1	; logbase
                lsr.w   #8,d0                           ;
                move.l  d0,$ffff8200.w              

		move.l	(a0),d0	; phybase
		move.l	d1,(a0)
		move.l	d0,-(a0)

		move.w	$468.w,d0
.waitvsync:
		cmp.w 	$468.w,d0
		beq.s	.waitvsync

		bra.s	effect

exit_effect:
		rts

.data
	.even
logbase:	dc.l	screen1+256
phybase:	dc.l	screen2+256

pi1:		.incbin "pic.pi1"

.bss
	.even
screen1:		ds.b 32256
screen2:		ds.b 32256

