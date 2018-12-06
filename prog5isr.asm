; ISR.asm
; Name: Aditya Gupta
; UTEid: AG68834
; Keyboard ISR runs when a key is struck
; Checks for a valid RNA symbol and places it at x4600
               .ORIG x2600
               ST R0, saver0 ;save registers
               ST R1, saver1
               ST R2, saver2
               ST R3, saver3
               LDI R0, KBDR ; R0 gets ascii value of char typed from KBDR

               LD R3, asciiA;R3 as a temp
               NOT R3, R3
               ADD R3, R3, #1
               ADD R3, R3, R0 ; R3 = R0 + R3
               BRZ match 

               LD R3, asciiC;R3 as a temp
               NOT R3, R3
               ADD R3, R3, #1
               ADD R3, R3, R0 ; R3 = R0 + R3
               BRZ match 

               LD R3, asciiG;R3 as a temp
               NOT R3, R3
               ADD R3, R3, #1
               ADD R3, R3, R0 ; R3 = R0 + R3
               BRZ match 

               LD R3, asciiU;R3 as a temp
               NOT R3, R3
               ADD R3, R3, #1
               ADD R3, R3, R0 ; R3 = R0 + R3
               BRZ match 
               BRNZP done ;so if here it is not a match

               match LD R2, location ; R2 = x4600
	       STR R0, R2, #0 ;if it is a match do this then finish by storing R0 (=asciival of kb input) into x4600
	       ;LD R2, masktwo
	       ;STI R2, KBSR ;NO MORE INTERRUPTS
	       AND R3, R3, #0  
	       STI R3, KBDR ;CLEAR KBDR
               BRnzp end ;time to stop interrupting

               done LD R2, mask
               LDI R3, KBSR ;this is so that it will re interrupt, so it will produce interrupt on a keystroke and be ready to read.(R3 equals the whole of KBSR)
               NOT R2, R2
               NOT R3, R3
               AND R3, R2, R3 ;This sets R3's 14th bit equal to one
               NOT R3, R3 ;demorgan's law
               STI R3, KBSR ;thus that means that now IEN = 1 and bit 15 = 1 too

               end LD R0, saver0
               LD R1, saver1
               LD R2, saver2
               LD R3, saver3
               RTI

        saver0 .BLKW #1 ;for saving registers
        saver1 .BLKW #1
        saver2 .BLKW #1
        saver3 .BLKW #1
		asciiA .FILL x0041
		asciiC .FILL x0043
		asciiG .FILL x0047
		asciiU .FILL x0055
		KBDR .FILL xFE02
		KBSR .FILL xFE00
		mask .FILL x8000 ;for setting the kbsr. This is a bug fix yay.
		location .FILL x4600
                masktwo .FILL x8000
.END
