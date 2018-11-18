;*************************************** Title block ***********************************************
    REVNUM			equ		001h		; revision number
;   Customer:			Mottramlabs
;   Product:			RGB LED Coaster
;   Last update:			23rd October 2018
;   Author:			David Mottram
;   Device:			PIC12F629A
;   Clock:			Int Osc
;   Root file name:			Coaster 1.asm
;   --------------------------------------------------------------------------------------------------
;
; Revision notes:	
;   The board flashes the Red LED's ten times to indicate that the EEPROM data is invalid, this happens with a new chip.
;   Once the new board is initialized with the default values this should not appear again.
;
;   Press and hold the button and the colour change cycling runs faster, release when the desired manual set colour 
;   is found, the light blinks briefly as the new values are set in the EEPROM.
;   When the fixed colour mode is select (above) press and hold the button until the lights go out, the colour changing 
;   mode is now selected and stored.
;
;   Note: Make sure that under programmer settings that "Preserve device EEPROM" is checked, else FF is written to all 
;   addresses during programming.

; processor and board definitions
#define             F_CPU               4000000                                 ; xtal frequency

; device Selection
include				PIC12F675_Config_Bits.asm		; configuration bits
include				PIC12F675_Registers.asm		; PIC registers
;************************************* General purpose registers 20h - 7Fh ************************

; define variable registers
CBLOCK				020h									;Start of Variable space address
Time_1								; used by timers
Time_2								; used by timers
Time_3								; used by timers
Temp_1								; temp Reg.
Red_Value								; PWM value
Green_Value					        		; PWM value
Blue_Value							; PWM value
PWM_Counter							; PWM ramp counter
Mode								; Mode see below for flap defs
Cycle_Timer							; colour cycle timer
SW_Pressed_Timer							; switch debouncer timer
SW_Release_Timer							; switch debouncer timer
; used with EEPROM
EEPROM_Data							; data
EEPROM_Address							; address
Check_Sum								; EEprom checksum
ENDC
														;End if C Block
org		0						; set origin

; setup a few things including turning off comparators and interupts	
bsf		Register_Bank_0					; reg bank select
movlw		b'00001111'					; watchdog control, timer0 to Watchdog and slowest setting
movwf		OPTION_REG					; load option reg
bcf		IOC3						; interrupt-on-change GPIO Control bits
bcf		IOC2						; interrupt-on-change GPIO Control bits
bcf		IOC1						; interrupt-on-change GPIO Control bits
bcf		IOC0						; interrupt-on-change GPIO Control bits
bcf		Register_Bank_0					; reg bank select
bcf		GBIE						; RB Port Change Interrupt Enable bit
bsf		CM0						; comparator off
bsf		CM1						; comparator off
bsf		CM2										;Comparator off

; EEPROM notes, below is a two byte check value used to detect a new board or corrupt EEPROM
#define		EEPROM_Valid_1	0xAB				; test byte value
#define		EEPROM_Valid_2	0x33				; test byte value

; setup I/O
#define		Red_Channel	GP5				; channel output pin
#define		Green_Channel	GP4				; channel output pin
#define		Blue_Channel	GP2				; channel output pin
;#define Test GP1
#define		Switch		GP1				; Switch input

bsf     		Register_Bank_0					; select Register Bank 1
bcf		TRISG5						; port direction
bcf		TRISG4						; port direction
bcf		TRISG2						; port direction				
bsf		TRISG1						; port direction
clrf		ANSEL						; turn off A/D, 12F675 only
	
;bcf TRISG1			
bcf     		Register_Bank_0					; select Register Bank 1

movlw		0x07
movwf		CMCON0

; turn off outputs
bcf     		Red_Channel					; turn off channel
bcf     		Green_Channel					; turn off channel
bcf     		Blue_Channel					; turn off channel
; clear channel PWM register			
clrf		Red_Value						; clear reg	
clrf	          Green_Value					; clear reg
clrf		Blue_Value					; clear reg
clrf		Mode						; clear reg

; Mode register definitions
#define		Red_Green		Mode,0				; flag bit def
#define		Green_Blue	Mode,1				; flag bit def
#define		Blue_Red		Mode,2				; flag bit def
#define		Cycle		Mode,3				; flag bit def
#define		Fixed		Mode,4				; flag bit def
#define		Switch_Flag	Mode,5				; flag bit def
#define		Auto_Select	Mode,6				; flag bit def

; timer values
#define		Cycle_Speed	.075				; inc of 3.5mS*8 bits
#define		Rapid_Cycle_Speed	.005				; rapid version, used when switch pressedinc of 3.5mS*8 bits
#define		SW_Press_Debounce	.080				; delay for switch, inc 3.5mS
#define		SW_Rel_Debounce	.180				; delay for switch, inc 3.5mS

; load switch debounce timers
movlw		SW_Press_Debounce					; load w
movwf		SW_Pressed_Timer					; load timer
movlw		SW_Rel_Debounce					; load w
movwf		SW_Release_Timer					; load timer

; power up delay
call	Del_1S				

; read RGB and mode values, store new ones if this fails
call		Read_RG_Values					; read mode and colour values from EEPROM
; all passed so start
goto		Start						; jump

;--------------------------------------------------------------------------------------------------------------
;*********************************  Start of Sub routines *****************************************************
;--------------------------------------------------------------------------------------------------------------
include		Timer_SUBS.asm					; timer sub routines
include		EEPROM_SUBS.asm					; EEprom subs

Start								; program start, return here

call		PWM_Start						; PWM outputs, approx 3.5mS

; testing the psuh button switch
Switch_Test_1
    btfss		Switch_Flag					; test if the flag is set
    goto		Switch_Test_2					; flag clear, so jump
    ; switch has pressed test the switch
    btfss		Switch						; skip next if switch not pressed
    goto		Switch_Test_2					; flag clear, so jump
    ; flag set and switch was now released

    ; switch not pressed so run the switch released debounce timer
    decfsz	SW_Release_Timer,1					; dec the counter skip, next if zero
    goto		No_Switch						; not timed out so jump
    ; reload ther timer
    movlw		SW_Rel_Debounce					; load w
    movwf		SW_Release_Timer					; load timer
    ; clear the flags
    bcf		Switch_Flag					; clear flag
    bcf		Auto_Select					; clear flag

    ; switch was pressed now released, so change mode and signal it
    btfsc		Fixed						; skip next if not fixed mode (cycle mode)
    goto		Clear_Fixed					; jump

; set fixed colour mode
Set_Fixed	  
    bsf		Fixed						; set flag

    ; ***** store new values and mode in EEPROM **********
    call		Store_Values					; store the new values in the EEPROM
    goto		No_Switch	  					; jump

; clear fixed colour mode, run cycle mode
Clear_Fixed 
    bcf		Fixed						; clear flag

    ; ***** store new values and mode in EEPROM **********
    call		Store_Values					; store the new values in the EEPROM
    goto		Switch_End					; jump

    ; test switch input, only if not yet pressed
Switch_Test_2
    btfsc		Switch_Flag					; skip next if not flagged as pressed
    goto		Switch_End					; jump. already pressed
    btfsc		Switch						; skip next if switch pressed
    goto		Switch_End					; not pressed so jump
    ; switch pressed
    decfsz	SW_Pressed_Timer,1					; dec debounce timer, skip next if zero
    goto		Switch_End					; jump, not timed out
    ; timed out so reload timer for next time
    movlw		SW_Press_Debounce					; load w
    movwf		SW_Pressed_Timer					; high so load reg
    ; switch pressed timer timed out
    bsf		Switch_Flag					; set the switch pressed flag
    goto		Switch_End					; jump

; end of this round of switch testing
Switch_End
    btfss		Switch_Flag					; skip next if flag is set ( switch has been pressed longer than debouce period)
    goto		No_Switch						; jump as switch has been pressed long enough
    ; test push button switch
    btfsc		Switch						; skip next if switch pressed
    goto		No_Switch						; jump as switch not pressed long enough
    btfss		Fixed						; skip next if fixed colour mode selected
    goto		No_Switch						; jump as it must be auto mode

    ; set auto mode to start with red, be predictable!
    bsf		Auto_Select					; set flag
    movlw		0xFF						; load w
    movwf		Red_Value						; load colour reg
    clrf		Green_Value					; clear colour reg
    clrf		Blue_Value					; clear colour reg
    bsf		Red_Green						; set cycle mode flag
    bcf		Green_Blue					; clear cycle mode flag
    bcf		Blue_Red						; clear cycle mode flag

; no switch pressed or switch testing ended
No_Switch

    ; fixed colour or cycle mode
    btfsc		Fixed						; skip next if not fixed mode (cycle mode)
    goto		Start						; jump, not zero

    ; cycle mode, run the cycle delay timer. freeze the counter if button pressed and returning to auto
    btfsc		Auto_Select					; skip if flag not set
    goto		Start						; jump, not zero

    decfsz	Cycle_Timer,1					; dec the timer, skip next if zero
    goto		Start						; jump, not zero

    movlw		Cycle_Speed					; load w
    btfss		Switch						; test switch skip if not pressed
    movlw		Rapid_Cycle_Speed					; load w
    movwf		Cycle_Timer					; load timer

    ; test which colour cycle
    btfsc		Red_Green						; skip next if not this mode
    goto		Red_To_Green					; mode found, jump

    btfsc		Green_Blue					; skip next if not this mode
    goto		Green_To_Blue					; mode found, jump

    btfsc		Blue_Red						; skip next if not this mode
    goto		Blue_To_Red					; mode found, jump

    ; no cycle mode yet set, set up first run
    movlw		0xFF						; load w
    movwf		Red_Value						; load colour reg
    clrf		Green_Value					; clear colour reg
    clrf		Blue_Value					; clear colour reg
    bsf		Red_Green						; set cycle mode flag
    bcf		Green_Blue					; clear cycle mode flag
    bcf		Blue_Red						; clear cycle mode flag
    goto		Start						; jump

Red_To_Green	; shift the colour from Red to Green
    incf		Green_Value					; inc the Green
    decfsz	Red_Value,1					; dec the Red, skip next if zero
    goto		Start						; jump
    ; setup for the next colour shift mode
    movlw		0xFF						; load w
    movwf		Green_Value					; load colour reg
    clrf		Red_Value						; clear colour reg
    clrf		Blue_Value					; clear colour reg
    bsf		Green_Blue					; set cycle mode flag
    bcf		Red_Green						; clear cycle mode flag
    bcf		Blue_Red						; clear cycle mode flag
    goto		Start						; jump

Green_To_Blue	; shift the colour from Green to Blue
    incf		Blue_Value					; inc the Blue
    decfsz	Green_Value,1					; dec the Green, skip next if zero
    goto		Start						; jump
    ; setup for the next colour shift mode
    movlw		0xFF						; load w
    movwf		Blue_Value					; load colour reg
    clrf		Green_Value					; clear colour reg
    clrf		Red_Value					  	; clear colour reg
    bsf		Blue_Red						; set cycle mode flag
    bcf		Red_Green						; clear cycle mode flag
    bcf		Green_Blue					; clear cycle mode flag
    goto		Start						; jump

Blue_To_Red	; shift the colour from Blue to Red
    incf		Red_Value						; inc the Red
    decfsz	Blue_Value,1					; dec the Blue, skip next if zero
    goto		Start						; jump
    ; setup for the next colour shift mode
    movlw		0xFF						; load w
    movwf		Red_Value						; load colour reg
    clrf		Green_Value					; clear colour reg
    clrf		Blue_Value					; clear colour reg
    bsf		Red_Green						; set cycle mode flag
    bcf		Green_Blue					; clear cycle mode flag
    bcf		Blue_Red						; clear cycle mode flag
    goto		Start						; jump


; the PWM counter starts at FF (255) and counts down to zero.
; when the counter value falls below an LED value register the LED output is turned on.
; at the end the LED is turned off again.
PWM_Start		; setup the LED outputs and load the PWM counter
    bcf     	Red_Channel					; turn off channel
    bcf     	Green_Channel					; turn off channel
    bcf     	Blue_Channel					; turn off channel
    movlw		0xFF						; load w
    movwf		PWM_Counter					; load PWM counter
    clrwdt							; reset Watchdog timer
    btfsc		Auto_Select					; skip if flag not set
    goto		PWM_End						; jump

PWM_Loop		; PWM loop, for all channels. No delays or NOP's, run as fast as the chip can, measured at 3.5mS per loop
    movf		PWM_Counter,w					; load the PWM counter value into w
    subwf		Red_Value,0					; subtract from LED value and place result in w
    btfsc		Carry_Flag					; test the carry flag, if low skip next
    bsf		Red_Channel					; PWM counter value is less than LED value so turn LED on

    movf		PWM_Counter,w					; load the PWM counter value into w
    subwf		Green_Value,0					; subtract from LED value and place result in w
    btfsc		Carry_Flag					; test the carry flag, if low skip next
    bsf		Green_Channel					; PWM counter value is less than LED value so turn LED on

    movf		PWM_Counter,w					; load the PWM counter value into w
    subwf		Blue_Value,0					; subtract from LED value and place result in w
    btfsc		Carry_Flag					; test the carry flag, if low skip next
    bsf		Blue_Channel					; PWM counter value is less than LED value so turn LED on

    decfsz	PWM_Counter,1					; decrument the PWM counter, skip next if now zero
    goto		PWM_Loop						; not zero yet so loop

PWM_End		; PWM finished turn off LED outputs
    bcf     	Red_Channel					; turn off channel
    bcf     	Green_Channel					; turn off channel
    bcf     	Blue_Channel					; turn off channel
    retlw   	0						; return
	
end					
