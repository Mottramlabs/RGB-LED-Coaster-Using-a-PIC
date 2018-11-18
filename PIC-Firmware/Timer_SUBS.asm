; -------------------------------------------------------------------------------------------------------
; Title:		General purpose timer
; Revision:	1.0
; Date:		2nd July 2010
; -------------------------------------------------------------------------------------------------------

 #if F_CPU == 4000000                                                           ;Calibrated for 4MHz clock
    CLK_100uS	equ                 .032                                    ;Cal figure.
    CLK_10uS	equ		.002				;Cal figure.
    CLK_5uS	equ		.001				;Cal figure.
 #endif
 #if F_CPU == 8000000						;Calibrated for 8MHz clock
    CLK_100uS	equ		.064				;Cal figure.
    CLK_10uS	equ		.004				;Cal figure.
    CLK_5uS	equ		.001				;Cal figure.
 #endif
 #if ( (F_CPU == 16000000) || (F_CPU==16257000) )                               ;Calibrated for 16MHz clock
    CLK_100uS	equ		.131				;Cal figure.
    CLK_10uS	equ		.010				;Cal figure.
    CLK_5uS	equ		.004				;Cal figure.
 #endif
 #if F_CPU == 20000000						;Calibrated for 20MHz clock
    CLK_100uS	equ		.165				;Cal figure.
    CLK_10uS	equ		.013				;Cal figure.
    CLK_5uS	equ		.006				;Cal figure.
#endif

Del_1uS                                                                         ;1uS delay, only correct with a 20MHz clock
    retlw           0               					;Return

Del_5uS                                                                         ;5uS delay
    movlw           CLK_5uS  				  		;Load w
    goto		DL_X1						;Jump

Del_10uS                                                                        ;10uS delay
    movlw           CLK_10uS				  		;Load w
    nop								;Delay added to 16MHz only
    nop								;Delay added to 16MHz only
    goto		DL_X1						;Jump
DL_X1				
    movwf   	Time_1  						;Load reg
DL_X2
    decfsz 	Time_1,1   					;Skip next if zero
    goto		DL_X2						;Loop
    retlw           0        						;Return

Del_100uS                                                                       ;100uS delay, with clear watchdog. Uses Timer_1
    clrwdt							;Reset Watchdog timer
    movlw           CLK_100uS       	    				;Load w
    movwf   	Time_1    					;Load reg
DL_01
    decfsz          Time_1,1 						;Skip next if zero
    goto		DL_01						;Loop
    retlw           0        						;Return

Del_500uS                                                                       ;500uS delay, uses Del_100uS and has clear watchdog. Uses Timer_2 + Timer_1
    movlw           .005	    		   			;Load w
    movwf   	Time_2       					;Load reg
    goto		DL_02						;Jump

Del_1mS                                                     		;1mS delay, uses Del_100uS and has clear watchdog. Uses Timer_2 + Timer_1
    movlw           .010	    		   			;Load w
    movwf   	Time_2       					;Load reg
    goto		DL_02						;Jump

Del_10mS                                                                        ;10mS delay, uses Del_100uS and has clear watchdog. Uses Timer_2 + Timer_1
DL_02Q
    movlw 	.100	        	    				;Load w
    movwf           Time_2          					;Load reg
    goto		DL_02						;Jump
DL_02		
    call		Del_100uS						;Call 100uS delay
    decfsz  	Time_2,1        					;Skip next if zero
    goto		DL_02						;Loop
    retlw   	0               					;Return
    
Del_50mS                                                                	;50mS delay, uses Del_100uS and has clear watchdog. Uses Timer_2 + Second + Timer_1
    movlw           .010	        	   	 			;Load w
    movwf   	Time_3          					;Load reg
    goto		DL_03						;Jump

Del_100mS                                                               	;100mS delay, uses Del_100uS and has clear watchdog. Uses Timer_2 + Second + Timer_1
    movlw   	.020	        	   	 			;Load w
    movwf   	Time_3          					;Load reg
    goto		DL_03						;Jump
					
Del_250mS                                                                       ;250mS delay, uses Del_100uS and has clear watchdog. Uses Timer_2 + Second + Timer_1
    movlw   	.050	        	    				;Load w
    movwf   	Time_3          					;Load reg
    goto		DL_03						;Jump
					
Del_500mS                                                                       ;500mS delay, uses Del_100uS and has clear watchdog. Uses Timer_2 + Second + Timer_1
    movlw   	.100	        	    				;Load w
    movwf   	Time_3          					;Load reg
    goto		DL_03						;Jump
					
Del_1S                                                                          ;1S delay, uses Del_100uS and has clear watchdog. Uses Timer_2 + Second + Timer_1
    movlw   	.200	        	    				;Load w
    movwf   	Time_3          					;Load reg
    goto		DL_03						;Jump
DL_03		
    movlw   	.050	        	    				;Load w
    movwf   	Time_2          					;Load reg
DL_04		
    call		Del_100uS						;Call 100uS delay
    decfsz  	Time_2,1        					;Skip next if zero
    goto		DL_04						;Loop
    decfsz  	Time_3,1        					;Skip next if zero
    goto		DL_03						;Loop
    retlw   	0               					;Return
