					;PIC12F675_Registers.asm
					;Date 13th June 2010

					;********** Function Registers ********************************************************************************************
					INDF				equ					00h					;Indirect address

					PC      			equ     			02h             	;Program counter
					PCL      			equ     			02h             	;Program counter
					
    				FSR					equ					04h					;File select register 

    				PCLATH				equ					0Ah					;Page select

					OPTION_REG			equ					81h					;Option register
						#Define			GPPU	    		OPTION_REG,7		;GPIO Pull-up Enable bit
						#Define			INTEDG      		OPTION_REG,6		;Interrupt Edge Select bit
						#Define			T0CS        		OPTION_REG,5		;Clock Source Select bit
						#Define			T0SE        		OPTION_REG,4		;Source Edge Select bit
						#Define			PSA         		OPTION_REG,3		;Prescaler Assignment bit
						#Define			PS2         		OPTION_REG,2		;Prescaler Rate Select bit 2
						#Define			PS1         		OPTION_REG,1		;Prescaler Rate Select bit 1
						#Define			PS0         		OPTION_REG,0		;Prescaler Rate Select bit 0

					Status  			equ     			03h             	;Status Reg.
						;Below are for older programs, kept so as to support these older programs
						Carry   		equ     			00h             	;Carry bit
						Zflag   		equ     			02h             	;Zero bit of status
						RP0				equ					05h					;Reg bank control
						RP1				equ					06h					;Reg bank control
						IRP				equ					07h					;IRP bit
						;Below are the new prefered versions
						#Define			Register_Bank_1 	Status,6			;Register Bank Select bits (used for direct addressing)
						#Define			Register_Bank_0 	Status,5			;Register Bank Select bits (used for direct addressing)
						#Define			Time_Out			Status,4			;Time-out bit
						#Define			Power_Down			Status,3			;Power-down bit
						#Define			Zero_Flag 			Status,2			;Zero bit
						#Define			Digit_Carry			Status,1			;Digit carry/borrow bit (ADDWF, ADDLW,SUBLW,SUBWF instructions)
						#Define			Carry_Flag			Status,0			;Carry/borrow bit (ADDWF, ADDLW,SUBLW,SUBWF instructions)

					;********** I/O Port Registers ********************************************************************************************
					Port_G				equ					05h					;Port Register
						#Define			GP0					Port_G,0			;I/O Pin
						#Define			GP1					Port_G,1			;I/O Pin
						#Define			GP2					Port_G,2			;I/O Pin
						#Define			GP3					Port_G,3			;I/O Pin
						#Define			GP4					Port_G,4			;I/O Pin
						#Define			GP5					Port_G,5			;I/O Pin
						#Define			GP6					Port_G,6			;I/O Pin
						#Define			GP7					Port_G,7			;I/O Pin
					TRISG				equ					85h					;Trisate port
						#Define			TRISG0				TRISG,0				;I/O Pin
						#Define			TRISG1				TRISG,1				;I/O Pin
						#Define			TRISG2				TRISG,2				;I/O Pin
						#Define			TRISG3				TRISG,3				;I/O Pin
						#Define			TRISG4				TRISG,4				;I/O Pin
						#Define			TRISG5				TRISG,5				;I/O Pin
						#Define			TRISG6				TRISG,6				;I/O Pin
						#Define			TRISG7				TRISG,7				;I/O Pin

					;********** Interrupt Control Registers ***********************************************************************************
					INTCON				equ					0Bh					;Interupt control register
						#Define			GIE					INTCON,7			;Global Interrupt Enable bit
						#Define			PEIE				INTCON,6			;Peripheral Interrupt Enable bit
						#Define			T0IE				INTCON,5			;TMR0 Overflow Interrupt Enable bit
						#Define			INTE				INTCON,4			;RB0/INT External Interrupt Enable bit
						#Define			GBIE				INTCON,3			;RB Port Change Interrupt Enable bit
						#Define			T0IF				INTCON,2			;TMR0 Overflow Interrupt Flag bit
						#Define			INTF				INTCON,1			;RB0/INT External Interrupt Flag bit
						#Define			GBIF				INTCON,0			;RB Port Change Interrupt Flag bit

					PIE1				equ					8Ch					;Peripheral Interrupt Enable Register 1
						#Define			EEIE	   			PIE1,7				;EE Write Complete Interrupt Enable bit
						#Define			ADIE     			PIE1,6				;A/D Converter Interrupt Enable bit (PIC12F675 only)
						#Define			CMIE      			PIE1,3				;Comparator Interrupt Enable bit
						#Define			TMR1IE       		PIE1,0				;TMR1 Overflow Interrupt Enable bit

					PIR1				equ					0Ch					;Peripheral Interrupt Register 1
						#Define			EEIF 				PIR1,7				;EEPROM Write Operation Interrupt Flag bit
						#Define			ADIF            	PIR1,6				;A/D Converter Interrupt Flag bit
						#Define			CMIF	           	PIR1,3				;Comparator Interrupt Flag bit
						#Define			TMR1IF          	PIR1,0				;TMR1 Overflow Interrupt Flag bit

					IOC					equ					96h					;Interrupt-on-change GPIO Control Register
						#Define			IOC5				IOC,5				;Interrupt-on-change GPIO Control bits
						#Define			IOC4				IOC,4				;Interrupt-on-change GPIO Control bits
						#Define			IOC3				IOC,3				;Interrupt-on-change GPIO Control bits
						#Define			IOC2				IOC,2				;Interrupt-on-change GPIO Control bits
						#Define			IOC1				IOC,1				;Interrupt-on-change GPIO Control bits
						#Define			IOC0				IOC,0				;Interrupt-on-change GPIO Control bits
						
					;********** A/D Registers *************************************************************************************************
					ADRESH				equ					1Eh					;A/D register results
					ADRESL				equ					9Eh					;A/D register results

					ADCON0				equ					1Fh					;A/D control reg.
						#Define			ADFM				ADCON0,7			;A/D Conversion Result Format Select bit 1 = Right justified 0 = Left justified
						#Define			VCFG				ADCON0,6			;Voltage Reference bit
						#Define			CHS1				ADCON0,3			;Channel select, Bit 1
						#Define			CHS0				ADCON0,2			;Channel select, Bit 0
						#Define			GO_DONE				ADCON0,1			;A/D Conversion Status bit
						#Define			ADON				ADCON0,0			;A/D Conversion Status bit

					ANSEL				equ					9Fh					;Analog select
						#Define			ADCS2				ANSEL,6				;A/D Conversion Clock Select bits
						#Define			ADCS1				ANSEL,5				;A/D Conversion Clock Select bits
						#Define			ADCS0				ANSEL,4				;A/D Conversion Clock Select bits
						#Define			ANS3				ANSEL,3				;Analog Select bits. Analog/Digital
						#Define			ANS2				ANSEL,2				;Analog Select bits. Analog/Digital
						#Define			ANS1				ANSEL,1				;Analog Select bits. Analog/Digital
						#Define			ANS0				ANSEL,0				;Analog Select bits. Analog/Digital

					VRCON				equ					99h					;Voltage Reference Control Register
						#Define			VREN				VRCON,7				;CVREF Enable
						#Define			VRR					VRCON,5				;CVREF Range Selection
						#Define			VR3					VRCON,3				;CVREF Value Selection
						#Define			VR2					VRCON,2				;CVREF Value Selection
						#Define			VR1					VRCON,1				;CVREF Value Selection
						#Define			VR0					VRCON,0				;CVREF Value Selection

					;********** Timer 0 control ***********************************************************************************************
					TMR0				equ					01h					;Timer 0 Register Low

					;********** Timer 1 control ***********************************************************************************************
					T1CON				equ					10h					;T1CON register
						#Define			TMR1GE				T1CON,6				;Timer1 Gate Enable bit
						#Define			T1CKPS1				T1CON,5				;Prescaler selection bit 1
						#Define			T1CKPS0				T1CON,4				;Prescaler selection bit 0
						#Define			T1OSCEN				T1CON,3				;LP Oscillator Enable Control bit
						#Define			T1SYNC				T1CON,2				;External clock input sync. 0=Synchronize 1=Do not syncronize
						#Define			TMR1CS				T1CON,1				;Clock source select. 1=External 0=Internal
						#Define			TMR1ON				T1CON,0				;Timer 1 on. 0=Stop 1=Start

					TMR1L				equ					0Eh					;Timer 1 Register Low
					TMR1H				equ					0Fh					;Timer 1 Register High

					;********** PCON - Power Control Register *********************************************************************************
					PCON				equ					8Eh					;PCON reg
						#Define			Power_On_Reset		PCON,1				;Power-on Reset Status bit
						#Define			Brown_Out			PCON,0				;Brown-out Reset Status bit

					;********** EEPROM Registers **********************************************************************************************
					EEDATA				equ					9Ah					;EEPROM Data Register, Low Byte

					EEADR				equ					9Bh 				;EEPROM Address Register, Low Byte

					EECON1				equ					9Ch					;EEPROM Control Register 1
						#Define			EEPROM_WRERR 		EECON1,3			;EEPROM Error Flag bit
						#Define			EEPROM_WREN  		EECON1,2			;EEPROM Write Enable bit
						#Define			EEPROM_WR    		EECON1,1			;Write Control bit
						#Define			EEPROM_RD    		EECON1,0			;Read Control bit

					EECON2				equ					9Dh					;EEPROM Control Register2 (not a physical register)

					;********** Capture, Compare and PWM Module *******************************************************************************
					CMCON0				equ					19h					;Comarator Configuration Register
						#Define			COUT				CMCON0,6			;Comparator Output bit
						#Define			CINV				CMCON0,4			;Comparator Output Inversion bit
						#Define			CIS					CMCON0,3			;Comparator Input Switch bit
						#Define			CM2					CMCON0,2			;Comparator Mode bits
						#Define			CM1					CMCON0,1			;Comparator Mode bits
						#Define			CM0					CMCON0,0			;Comparator Mode bits
					
					;********** Internal Oscillator Control ***********************************************************************************
					OSCCAL				equ					90h					;Oscillator Calibration Register
						#Define			CAL5				OSCCAL,7			;6-bit Signed Oscillator Calibration bits
						#Define			CAL4				OSCCAL,6			;6-bit Signed Oscillator Calibration bits
						#Define			CAL3				OSCCAL,5			;6-bit Signed Oscillator Calibration bits
						#Define			CAL2				OSCCAL,4			;6-bit Signed Oscillator Calibration bits
						#Define			CAL1				OSCCAL,3			;6-bit Signed Oscillator Calibration bits
						#Define			CAL0				OSCCAL,2			;6-bit Signed Oscillator Calibration bits

					;********** Weak Pull-up *************************************************************************************************
					WPU					equ					95h					;Weak Pull-up Register
						#Define			WPU5				WPU,5				;Weak Pull-up Control bits	
						#Define			WPU4				WPU,4				;Weak Pull-up Control bits	
						#Define			WPU2				WPU,2				;Weak Pull-up Control bits	
						#Define			WPU1				WPU,1				;Weak Pull-up Control bits	
						#Define			WPU0				WPU,0				;Weak Pull-up Control bits	


					;********** End of File **************************************************************************************************
						








