; Atari ST/e synclock demosystem
; September 1, 2011
;
; sys/vbl.s


		.text


vbl:
		move.l	a0,-(sp)

		move.l	vbl_routine,a0			;vbl_routine
		jsr	(a0)

		;jsr	music_play			;Call music driver

;		cmp.b	#$39,$fffffc02.w
;		bne.s	.nokey
;		move.w	#1,exit_demo
;.nokey:
		addq.l	#1,$466.w
		move.l	(sp)+,a0
		rte


		.data

;--------------	System variables - do not shift order
timera_delay:	dc.l	0
timera_div:	dc.l	0
vbl_routine:	dc.l	dummy
timera_routine:	dc.l	dummy
main_routine:	dc.l	dummy
exit_demo:	dc.w	0

		.text
