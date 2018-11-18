EEPROM_Write	; write data to EEPROM, registers EEPROM_Data and EEPROM_Address used
		; note: Make sure that under programmer settings that "Preserve device EEPROM" is checked, 
		; else FF is written to all addresses during programming
    movf		EEPROM_Data,w					; load w
    bsf		Register_Bank_0					; select Register Bank 1
    movwf   	EEDATA      					; copy to eedata, EEPROM Data
    bcf     	Register_Bank_0					; select Register Bank 1
    movf		EEPROM_Address,w					; load w
    bsf     	Register_Bank_0					; select Register Bank 1
    movwf   	EEADR       					; copy to eeadr, EEPROM Address
    bsf 		EEPROM_WREN  					; enable eeprom write

    ;Special write sequence
    movlw		055h						; load w
    movwf   	EECON2						; write to indirect address
    movlw   	0AAh						; load w
    movwf   	EECON2						; write to indirect address

    bsf 		EEPROM_WR   					; write data to eeprom
    btfsc   	EEPROM_WR   					; loop till write process is finish
    goto    	$-1						; up one program position
    bcf 		EEPROM_WREN  					; enable eeprom write
    bcf     	Register_Bank_0					; select Register Bank 1    
    retlw   	0               					; return

EEPROM_Read	; read data from EEPROM, registers EEPROM_Data and EEPROM_Address used
		; note: Make sure that under programmer settings that "Preserve device EEPROM" is checked, 
		; else FF is written to all addresses during programming
    movf		EEPROM_Address,w		  			; load w
    bsf     	Register_Bank_0					; select Register Bank 1
    movwf   	EEADR       					; copy to eeadr, EEPROM Address
    bsf		EEPROM_RD						; set read flag
    movf		EEDATA,w						; load w 
    bcf     	Register_Bank_0					; select Register Bank 1
    return		  					; return with the data in w

Store_Values	; store values in EEprom

    clrf    	Check_Sum						; clear reg.
    clrf		EEPROM_Address					; clear reg
    movlw		EEPROM_Valid_1					; test byte
    subwf   	Check_Sum,1        					; sub w from reg, data in reg
    movwf		EEPROM_Data					; load reg
    call		EEPROM_Write					; write data to EEprom

    incf		EEPROM_Address					; next address
    movlw		EEPROM_Valid_2					; test byte
    subwf   	Check_Sum,1        					; sub w from reg, data in reg
    movwf		EEPROM_Data					; load reg
    call		EEPROM_Write					; write data to EEprom

    incf		EEPROM_Address					; next address
    movf		Mode,w						; load w
    subwf   	Check_Sum,1        					; sub w from reg, data in reg
    movwf		EEPROM_Data					; load reg
    call		EEPROM_Write					; wWrite data to EEprom

    incf		EEPROM_Address					; next address
    movf		Red_Value,w					; lLoad w
    subwf   	Check_Sum,1        					; sub w from reg, data in reg
    movwf		EEPROM_Data					; lLoad reg
    call		EEPROM_Write					; write data to EEprom
					
    incf		EEPROM_Address					; next address
    movf		Green_Value,w					; lLoad w
    subwf   	Check_Sum,1        					; sub w from reg, data in reg
    movwf		EEPROM_Data					; load reg
    call		EEPROM_Write					; wWrite data to EEprom

    incf		EEPROM_Address					; next address
    movf		Blue_Value,w					; load w
    subwf   	Check_Sum,1        					; sub w from reg, data in reg
    movwf		EEPROM_Data					; lLoad reg
    call		EEPROM_Write					; write data to EEprom

    ; store checksum
    incf		EEPROM_Address					; next address
    movf    	Check_Sum,w        					; load check sum
    movwf		EEPROM_Data					; load reg
    call		EEPROM_Write					; write data to EEprom
    retlw   	0               					; return



Read_RG_Values	; read RGB and mode values, store new ones if this fails

    ;Read test bytes
    clrf    	Check_Sum						; clear reg.
    clrf		EEPROM_Address					; clear reg
    call		EEPROM_Read					; read EEprom data
    subwf   	Check_Sum,1        					; sub w from reg, data in reg
    movwf		Temp_1						; load reg
    movlw		EEPROM_Valid_1									;Test byte
    subwf		Temp_1,0						; sub from reg
    btfss		Zero_Flag						; skip next if the same
    goto		Trash_EEprom					; restore EEprom
    ;That byte passed OK
    incf		EEPROM_Address					; next reg
    call		EEPROM_Read					; read EEprom data
    subwf   	Check_Sum,1        					; sub w from reg, data in reg
    movwf		Temp_1						; load reg
    movlw		EEPROM_Valid_2					; test byte
    subwf		Temp_1,0						; sub from reg
    btfss		Zero_Flag						; skip next if the same
    goto		Trash_EEprom					; restore EEprom
    ;Read byte
    incf		EEPROM_Address					; next reg
    call		EEPROM_Read					; read EEprom data
    subwf   	Check_Sum,1        					; sub w from reg, data in reg
    movwf		Mode						; load reg
    ;Read byte
    incf		EEPROM_Address					; next reg
    call		EEPROM_Read					; read EEprom data
    subwf   	Check_Sum,1        					; sub w from reg, data in reg
    movwf		Red_Value						; load reg
    ;Read byte
    incf		EEPROM_Address					; next reg
    call		EEPROM_Read					; read EEprom data
    subwf   	Check_Sum,1        					; sub w from reg, data in reg
    movwf		Green_Value					; load reg
    ;Read byte
    incf		EEPROM_Address					; next reg
    call		EEPROM_Read					; read EEprom data
    subwf   	Check_Sum,1        					; sub w from reg, data in reg
    movwf		Blue_Value					; load reg
    ;Read and test checksum byte
    incf		EEPROM_Address					; next reg
    call		EEPROM_Read					; read EEprom data
    subwf   	Check_Sum,0        					; sub w from reg


    btfss		Zero_Flag						; skip next if the same
    goto		Trash_EEprom					; restore EEprom
    ; all passed
    retlw   	0               					; return


Trash_EEprom	;Restore EEprom

    ; signal an error and the trashing of the EEPROM
    bcf		Green_Channel					; clear output
    bcf		Blue_Channel					; clear output
    movlw		.010						; number of flashes
    movwf		Temp_1						; load reg
Error_Loop
    bsf		Red_Channel					; set output
    call		Del_100mS						; delay
    bcf		Red_Channel					; clear output
    call		Del_100mS						; delay
    decfsz	Temp_1,1						; dec counter, skip next if zero
    goto		Error_Loop					; loop
    call		Del_1S						; delay
    ; data to load in EEPROM
    clrf		Red_Value						; clear reg	
    clrf	          Green_Value					; clear reg
    clrf		Blue_Value					; clear reg
    clrf		Mode						; clear reg
    call		Store_Values					; store the default values
    ;Loop till it's working!
    goto		Read_RG_Values		  			; read values, store new ones if this fails
