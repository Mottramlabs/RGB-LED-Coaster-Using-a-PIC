
;=======================================
;  Configuration (FUSE) BIT Definitions 
;=======================================
_CPD_ON                      EQU     H'3EFF'
_CPD_OFF                     EQU     H'3FFF'
_CP_ON                       EQU     H'3F7F'
_CP_OFF                      EQU     H'3FFF'
_BODEN_ON                    EQU     H'3FFF'
_BODEN_OFF                   EQU     H'3FBF'
_MCLRE_ON                    EQU     H'3FFF'
_MCLRE_OFF                   EQU     H'3FDF'
_PWRTE_OFF                   EQU     H'3FFF'
_PWRTE_ON                    EQU     H'3FEF'
_WDT_ON                      EQU     H'3FFF'
_WDT_OFF                     EQU     H'3FF7'
_LP_OSC                      EQU     H'3FF8'
_XT_OSC                      EQU     H'3FF9'
_HS_OSC                      EQU     H'3FFA'
_EC_OSC                      EQU     H'3FFB'
_INTRC_OSC_NOCLKOUT          EQU     H'3FFC'
_INTRC_OSC_CLKOUT            EQU     H'3FFD'
_EXTRC_OSC_NOCLKOUT          EQU     H'3FFE'
_EXTRC_OSC_CLKOUT            EQU     H'3FFF'

;__CONFIG _CPD_OFF & _CP_OFF & _BODEN_OFF & _MCLRE_OFF & _PWRTE_ON & _WDT_OFF  & _INTRC_OSC_NOCLKOUT
__CONFIG _CPD_OFF & _CP_OFF & _BODEN_ON & _MCLRE_OFF & _PWRTE_ON & _WDT_ON  & _INTRC_OSC_NOCLKOUT
