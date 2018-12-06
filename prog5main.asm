 ; Main.asm
; Name: Aditya Gupta
; UTEid: AG68834
; Continuously reads from x4600 making sure its not reading duplicate
; symbols. Processes the symbol based on the program description
; of mRNA processing.
               .ORIG x4000

; initialize the stack pointer
	LD R6, Stack


; set up the keyboard interrupt vector table entry
	LD R5, addressOfISR
	STI R5, startOfKBIVT



; enable keyboard interrupts
	;xfe00 gets x4000
	LD R5, KBSRval
	LDI R4, KBSRval ;R4 gets whole KBSR
	LD R3, myMask
	NOT R3, R3
	NOT R4, R4
	AND R4, R3, R4 ; R4 <- x4000 AND R4. this sets bits 15&14 of KBSR to 1
	NOT R4, R4 ;demorgan's law
	STR R4, R5, #0 



; start of actual program
	LEA R1, S1 ;set up inital state of the FSM 
	top LDI R0, Buffer
	BRz top ;therefore loops until a new character is at x4600 (in which case R0 = ascii value of that character)
	;TRAP x21 ; OUT ... this prints the character (because ascii value is in R0) on to the screen
	ST R0, Storage
	AND R3, R3, #0
	STI R3, Buffer
	;for R = A, C, G, or U
	;Decode R2 based on R0: 
	doA LD R3, asciiA ;A
	NOT R3, R3
	ADD R3, R3, #1
	ADD R3, R3, R0
	BRnp doC
	AND R2, R2, #0
	ADD R2, R2, #1 ;corresponding
	BRnzp state_machine_loop
	
	doC LD R3, asciiC ;C
	NOT R3, R3
	ADD R3, R3, #1
	ADD R3, R3, R0
	BRnp doG
	AND R2, R2, #0
	ADD R2, R2, #2 ;corresponding
	BRnzp state_machine_loop

	doG LD R3, asciiG ;G
	NOT R3, R3
	ADD R3, R3, #1
	ADD R3, R3, R0
	BRnp doU
	AND R2, R2, #0
	ADD R2, R2, #3 ;corresponding
	BRnzp state_machine_loop

	doU LD R3, asciiU ;U
	NOT R3, R3
	ADD R3, R3, #1
	ADD R3, R3, R0
	BRnp notu
	AND R2, R2, #0
	ADD R2, R2, #4 ;corresponding
	notu BRnzp state_machine_loop

	state_machine_loop ;R1 = Current State
		ADD R0, R1, #0 ;R0 = R1 = state this works for this case b/c only 1 custom output for us to deal with
		TRAP x22
		LD R0, Storage ;Storage backed up R0
		TRAP x21 ;display char
		ADD R2, R2, #1 ;new
		ADD R1, R1, R2 ;R2 alpha input
		LDR R1, R1, #0 ;go to next state
		LEA R3, S9
		NOT R3, R3
		ADD R3, R3, #1
		ADD R3, R3, R1
		BRz itsover
		BRnzp belowthefsm ;so go

	; TEMPLATE:
	;	State .FILL OUTPUT
	;	.FILL NEXT_STATEA
	;	.FILL NEXT_STATEC
	;	.FILL NEXT_STATEG
	;	.FILL NEXT_STATEU

	S1	.STRINGZ ""
		.BLKW #1
		.FILL S2
		.FILL S1
		.FILL S1
		.FILL S1

	S2 .STRINGZ ""
		.BLKW #1
		.FILL S2
		.FILL S1
		.FILL S1
		.FILL S3

	S3 .STRINGZ "" ;put below the .fills
		.BLKW #1
		.FILL S2
		.FILL S1
		.FILL S4
		.FILL S1

	S4 .STRINGZ "|"
		.FILL S5
		.FILL S5
		.FILL S5
		.FILL S6

	S5  .STRINGZ ""
		.BLKW #1
		.FILL S5
		.FILL S5
		.FILL S5
		.FILL S6

	S6 .STRINGZ ""
		.BLKW #1
		.FILL S7
		.FILL S5
		.FILL S8
		.FILL S6

	S7 .STRINGZ ""
		.BLKW #1
		.FILL S9
		.FILL S5 ;? ;UAG UAA UGA
		.FILL S9
		.FILL S6

	S8 .STRINGZ ""
		.BLKW #1
		.FILL S9 
		.FILL S5
		.FILL S5
		.FILL S6

	S9 .STRINGZ ""
		.BLKW #1
		.FILL S9
		.FILL S9
		.FILL S9
		.FILL S9

	belowthefsm AND R0, R0, #0; Clear R0 so no spammie 
	LD R5, KBSRval
	LD R4, myMask ;R4 = xC000
	STR R4, R5, #0; Set back interrupts because KBSR = xC000
	;Clear KBDR here?
	AND R5, R5, #0
	LD R4, KBDRval
	STR R5, R4, #0
	BRnzp top
	itsover TRAP x25
		
		;AND R1, R1, #0
		;STI R1, Buffer ;because we're gonna process the char, better set x4600 back to zero
		; F S M
		; F S M
		
		;LD R5, KBSRval
		;LD R4, myMask ;R4 = x4000
		;STR R4, R5, #0; Set back interrupts because KBSR = x4000
	        ;AND R1, R1, #0
                ;LD R4, KBDRval
                ;STR R1, R4, #0
		;BRNZP top ;back to looking for a user-typed character 

		;TRAP x25

	;.Fills
	Storage .BLKW #1
	KBSRval .FILL xFE00
        KBDRval .FILL xFE02
	startOfKBIVT .FILL x0180
	addressOfISR .FILL x2600
	Stack .FILL x4000
	Buffer .FILL x4600
	myMask .FILL x4000
	asciiA .FILL x41
	asciiC .FILL x43
	asciiG .FILL x47
	asciiU .FILL x55

	.END
