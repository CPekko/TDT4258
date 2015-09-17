.syntax unified

.include "efm32gg.s"

/////////////////////////////////////////////////////////////////////////////
//
// Exception vector table
// This table contains addresses for all exception handlers
//
/////////////////////////////////////////////////////////////////////////////

.section .vectors

.long   stack_top               /* Top of Stack                 */
.long   _reset                  /* Reset Handler                */
.long   dummy_handler           /* NMI Handler                  */
.long   dummy_handler           /* Hard Fault Handler           */
.long   dummy_handler           /* MPU Fault Handler            */
.long   dummy_handler           /* Bus Fault Handler            */
.long   dummy_handler           /* Usage Fault Handler          */
.long   dummy_handler           /* Reserved                     */
.long   dummy_handler           /* Reserved                     */
.long   dummy_handler           /* Reserved                     */
.long   dummy_handler           /* Reserved                     */
.long   dummy_handler           /* SVCall Handler               */
.long   dummy_handler           /* Debug Monitor Handler        */
.long   dummy_handler           /* Reserved                     */
.long   dummy_handler           /* PendSV Handler               */
.long   dummy_handler           /* SysTick Handler              */

/* External Interrupts */
.long   dummy_handler
.long   gpio_handler            /* GPIO even handler */
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   gpio_handler            /* GPIO odd handler */
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler
.long   dummy_handler

.section .text 

.globl  _reset
.type   _reset, %function
.thumb_func


_reset: 
	//Branch to different setups, then 
	BL register_clock
	BL register_led_lights
	BL register_buttons
	BL register_interrupts
	BL deep_sleep
	WFI

register_clock:
	LDR R0, =CMU_BASE
	LDR R1, [R0, #CMU_HFPERCLKEN0]
	MOV R2, #1
	LSL R2, R2, #CMU_HFPERCLKEN0_GPIO
	ORR R1, R1, R2
	STR R1, [R0, #CMU_HFPERCLKEN0]

	BX LR

register_led_lights:

	LDR R0, =GPIO_PA_BASE
	MOV R2, #0x2
	STR R2, [R0, #GPIO_CTRL]

	MOV R2, #0x55555555
	STR R2, [R0, #GPIO_MODEH]

	BX LR

register_buttons:
	LDR R0, =GPIO_PC_BASE

	MOV R2, #0x33333333
	STR R2, [R0, #GPIO_MODEL]

	MOV R2, #0xff
	STR R2, [R0, #GPIO_DOUT]

	BX LR

register_interrupts:
	LDR R0, =GPIO_BASE
	MOV R1, #0x22222222
	STR R1, [R0, #GPIO_EXTIPSELL]

	MOV R1, #0xff
	STR R1, [R0, #GPIO_EXTIFALL]
	STR R1, [R0, #GPIO_EXTIRISE]
	STR R1, [R0, #GPIO_IEN]

	LDR R0, =ISER0
	LDR R1, =#0x802
	STR R1, [R0, #0x0]

	BX LR

deep_sleep:

	LDR R0, =SCR //System control block
	MOV R1, #6
	STR R1, [R0]

	BX LR


.thumb_func
gpio_handler:
	LDR R0, =GPIO_PC_BASE
	LDR R1, [R0, #GPIO_DIN]
	LSL R1, R1, #8
	LDR R0, =GPIO_PA_BASE
	STR R1, [R0, #GPIO_DOUT]

	LDR R0, =GPIO_BASE
	LDR R1, [R0, #GPIO_IF]
	STR R1, [R0, #GPIO_IFC]

	BX LR
/////////////////////////////////////////////////////////////////////////////

.thumb_func
dummy_handler:  
	b .  // do nothing

