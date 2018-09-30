@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@
@  FILE          : br_asm.s
@  PROJECT       : PROG1360 - Microprocessors and Emebbeded - Assignment #5
@  PROGRAMMER    : Brendan Rushing
@  FIRST VERSION : 2018-08-07
@  DESCRIPTION   :
@	This assignment takes one inputs from the user: delay
@   The program loops through the LED's in a circle.
@   The watch dog is tickled at the beginning of every loop.
@   If the push button is pressed then all the LED's turn on and off with a delay
@   The program will end by itself because the watchdog will not be tickled so it will end the function.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@ Data section - initialized values
.data

.align 3    @ This alignment is critical - to access our "huge" value, it must
            @ be 64 bit aligned

LED_ADDR:    .word 0x48001014

.equ LED_1_ADDR, 256
.equ LED_2_ADDR, 512
.equ LED_3_ADDR, 1024
.equ LED_4_ADDR, 2048
.equ LED_5_ADDR, 4096
.equ LED_6_ADDR, 8192
.equ LED_7_ADDR, 16384
.equ LED_8_ADDR, 32768
.equ MAX_VALUE, 65536

.equ ALL_LED_OFF_ADDR, 0x00FF
.equ ALL_LED_ON_ADDR, 0xFF00
.equ LED_OFF_MODE, 8

.equ EXIT_DELAY, 500

.equ ASCII_VALUE, 48
.equ ASCII_0, 47
.equ ASCII_7, 56




@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    .code   16              @ This directive selects the instruction set being generated. 
                            @ The value 16 selects Thumb, with the value 32 selecting ARM.

    .text                   @ Tell the assembler that the upcoming section is to be considered
                            @ assembly language instructions - Code section (text -> ROM)

@@ Function Header Block
    .align  2               @ Code alignment - 2^n alignment (n=2)
                            @ This causes the assembler to use 4 byte alignment

    .syntax unified         @ Sets the instruction set to the new unified ARM + THUMB
                            @ instructions. The default is divided (separate instruction sets)

    .global brWatch       @ Make the symbol name for the function visible to the linker

    .code   16              @ 16bit THUMB code (BOTH .code and .thumb_func are required)
    .thumb_func             @ Specifies that the following symbol is the name of a THUMB
                            @ encoded function. Necessary for interlinking between ARM and THUMB code.

    .type   brWatch, %function   @ Declares that the symbol is a function (not strictly required)
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Function Declaration : brWatch
@
@ Input: r0 (i.e. r0 holds delay)
@ Returns: none
@ 
@   r0 = delay
@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

brWatch:
   push {r0,r1,r2,r3, r4-r7, lr}                @ Put aside registers we want to restore later

   mov r9, r0   @move r0 (delay) into r9 to be used
   mov r10, #LED_1_ADDR     @mov #256 into R10


program_loop_brWatch:

@TICKLE WATCHDOG
    push {lr}
    bl mes_IWDGRefresh
    pop {lr}

@TURN ALL LED OFF
    bl all_led_off              @all LED off

@TURN ON LED
    ldr r1, =LED_ADDR           @load register
    ldr r1, [r1]                @dereference to get the value
    ldrh r0, [r1]               @load high value
    orr r0, r0, r10             @or r0 with constant
    strh r0, [r1]               @store high value

@DELAY
    mov r0, r9                  @move r9 DELAY value into r0
    bl HAL_Delay                @ call BSP C function using Branch with Link (bl)

@CHECK PUSHBUTTON
    mov r0, #0                  @call pushbutton #0
    bl BSP_PB_GetState          @ call BSP C function using Branch with Link (bl)
    cmp r0, #1 
                                
    beq exit_success            @if pushbutton = 1 then pressed goto exit_success function

@MOVE TO NEXT LED
    mov r1, #2                  @move #2 into r1
    mul r0, r10, r1             @multiply r10 by 2 and store in r0

    cmp r0, #MAX_VALUE
    bge reset_loop_brWatch              @if value is greater than max_value then reset

    mov r10, r0                 @move value into r10

    b program_loop_brWatch              @go back to program_loop for another iteration
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@




@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@Function Declaration : all_led_on
@
@ Input: none
@ Returns: none
@ 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    all_led_on:

    push {r0, r1,r2,r3, r4-r7, lr}  @ Put aside registers we want to restore later

    ldr r1, =LED_ADDR
    ldr r1, [r1]
    ldrh r0, [r1]
    orr r0, r0, ALL_LED_ON_ADDR @ON
    strh r0, [r1]

    pop  {r0, r1,r2,r3,r4-r7, lr}   @ Bring all the register values back
    bx lr                       @return to where we were

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@Function Declaration : all_led_off
@
@ Input: none
@ Returns: none
@ 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    all_led_off:

    push {r0, r1,r2,r3, r4-r7, lr}  @ Put aside registers we want to restore later

    ldr r1, =LED_ADDR
    ldr r1, [r1]
    ldrh r0, [r1]
    mov r0, #LED_OFF_MODE      
    orr r0, r0, ALL_LED_OFF_ADDR @OFF
    strh r0, [r1]

    pop  {r0, r1,r2,r3,r4-r7, lr}   @ Bring all the register values back
    bx lr                       @return to where we were

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@Function Declaration : reset_loop_brWatch
@
@ Input: none
@ Returns: none
@ 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    reset_loop_brWatch:
    
    mov r10, #LED_1_ADDR        @reset to address led 1
    b program_loop_brWatch

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@Function Declaration : int exit_success
@
@ Input: none
@ Returns: none
@ 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    exit_success:

@LED WINNING SEQUENCE

@ALL LED OFF
    ldr r1, =LED_ADDR
    ldr r1, [r1]
    ldrh r0, [r1]
    mov r0, #LED_OFF_MODE      
    orr r0, r0, ALL_LED_OFF_ADDR @OFF
    strh r0, [r1]

@DELAY
    mov r0, #EXIT_DELAY               @ move 1000 delay value into r0
    bl HAL_Delay                @ call BSP C function using Branch with Link (bl)

@ALL LED ON
    ldr r1, =LED_ADDR
    ldr r1, [r1]
    ldrh r0, [r1]
    orr r0, r0, ALL_LED_ON_ADDR @ON
    strh r0, [r1]

@DELAY
    mov r0, #EXIT_DELAY              @ move 1000 delay value into r0
    bl HAL_Delay                @ call BSP C function using Branch with Link (bl)

    b exit_success              @ back to top of loop

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



    .size   brWatch, .-brWatch    @@ - symbol size (not req)
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@








@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@
@  FILE          : br_asm.s
@  PROJECT       : PROG1360 - Microprocessors and Emebbeded - Assignment #5
@  PROGRAMMER    : Brendan Rushing
@  FIRST VERSION : 2018-07-04
@  DESCRIPTION   :
@   This assignment is the same as assignment #3 but it uses direct memory access to illuminate the LED's
@   
@	This assignment takes three inputs from the user: delay, ledpattern and led winning number.
@   The program loops through the led pattern. The user tries to press the button when the winning number led is illuminated.
@   the program ends when the user presses the button. If the user presses the correct button then all the leds illuminate. 
@ 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    .code   16              @ This directive selects the instruction set being generated. 
                            @ The value 16 selects Thumb, with the value 32 selecting ARM.

    .text                   @ Tell the assembler that the upcoming section is to be considered
                            @ assembly language instructions - Code section (text -> ROM)

@@ Function Header Block
    .align  2               @ Code alignment - 2^n alignment (n=2)
                            @ This causes the assembler to use 4 byte alignment

    .syntax unified         @ Sets the instruction set to the new unified ARM + THUMB
                            @ instructions. The default is divided (separate instruction sets)

    .global brGame       @ Make the symbol name for the function visible to the linker

    .code   16              @ 16bit THUMB code (BOTH .code and .thumb_func are required)
    .thumb_func             @ Specifies that the following symbol is the name of a THUMB
                            @ encoded function. Necessary for interlinking between ARM and THUMB code.

    .type   brGame, %function   @ Declares that the symbol is a function (not strictly required)
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Function Declaration : brGame
@
@ Input: r0, r1, r2 (i.e. r0 holds delay, r1 holds pattern, r2 holds winning number )
@ Returns: none
@ 
@   r4 = winningNUmber
@   r5 = delay
@   r9 = pattern
@   r7 = array counter
@   r10 = LED_1_ADDR
@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

brGame:
   push {r0,r1,r2,r3, r4-r7, lr}                @ Put aside registers we want to restore later
      @ mov r10, lr
    mov r7, #0          @set counter to 0
    
    @STORE VALUES
    mov r5, r0          @move r0 value DELAY into r5
    mov r4, r2          @move r2 value WINNING NUMBER into r4
    mov r9, r1          @move r9 with led pattern
    mov r10, #LED_1_ADDR     @mov #256 into R10


program_loop:

    @TICKLE WATCHDOG
    push {lr}
    bl mes_IWDGRefresh
    pop {lr}

    bl all_led_off              @all LED off

@CHECK DATA

    ldrb r6,[r9]        @load value from led pattern array

    cmp r6, #0
    beq reset_array     @if null terminator (end of array) then reload array with value from r7

    cmp r6, #ASCII_7         @check to see if value is greater than ASCII 7 for the last LED
    bgt exit_failure    @go to exit_failure function

    cmp r6, #ASCII_0         @check to see if value is less than ASCII 0 for the first LED
    ble exit_failure    @go to exit_failure function


    sub r6, #ASCII_VALUE         @strip ASCII value to equal value of LED
    
@TURN ON LED

    b LED_SWITCH

    DONE_LED_SWITCH:
@DELAY

    mov r0, r5                  @move r5 DELAY value into r0
    bl HAL_Delay                @ call BSP C function using Branch with Link (bl)

@CHECK PUSHBUTTON

    mov r0, #0                  @call pushbutton #0
    bl BSP_PB_GetState          @ call BSP C function using Branch with Link (bl)
    cmp r0, #1 
                                
    beq exit_check               @if pushbutton = 1 then pressed goto exit_check function

    add r9, #1                  @increment array
    add r7, #1                  @incrememnt array counter

    b program_loop              @go back to program_loop for another iteration
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@Function Declaration : reset_array
@
@ Input: none
@ Returns: none
@ 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
reset_array:
push {r0, r1,r2,r3, r4-r7, lr}  @ Put aside registers we want to restore later

decrement_array_loop:
sub r9, #1                      @decrement array
sub r7, #1                      @sub 1 from array counter  
cmp r7, #0                      @return when array counter is back to 0
bne decrement_array_loop        @if counter is not 0, decrement again
beq program_loop                @if counter is 0, go back to program


pop {r0, r1,r2,r3,r4-r7, lr}   @ Bring all the register values back
bx lr                       @return to where we were
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@Function Declaration : LED_SWITCH
@
@ Input: none
@ Returns: none
@ 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

LED_SWITCH:

@branch to specific led call based on address and led value

cmp r6, #0
beq TURN_ON_LED_1

cmp r6, #1
beq TURN_ON_LED_2

cmp r6, #2
beq TURN_ON_LED_3

cmp r6, #3
beq TURN_ON_LED_4

cmp r6, #4
beq TURN_ON_LED_5

cmp r6, #5
beq TURN_ON_LED_6

cmp r6, #6
beq TURN_ON_LED_7

cmp r6, #7
beq TURN_ON_LED_8

b DONE_LED_SWITCH

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
TURN_ON_LED_1:
ldr r1, =LED_ADDR           @load register
ldr r1, [r1]                @dereference to get the value
ldrh r0, [r1]               @load high value
orr r0, r0, LED_1_ADDR      @or r0 with constant
strh r0, [r1]               @store high value
b DONE_LED_SWITCH           @go back to where we were

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
TURN_ON_LED_2:
ldr r1, =LED_ADDR           @load register
ldr r1, [r1]                @dereference to get the value
ldrh r0, [r1]               @load high value
orr r0, r0, LED_2_ADDR      @or r0 with constant
strh r0, [r1]               @store high value
b DONE_LED_SWITCH           @go back to where we were

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
TURN_ON_LED_3:
ldr r1, =LED_ADDR           @load register
ldr r1, [r1]                @dereference to get the value
ldrh r0, [r1]               @load high value
orr r0, r0, LED_3_ADDR      @or r0 with constant
strh r0, [r1]               @store high value
b DONE_LED_SWITCH           @go back to where we were

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
TURN_ON_LED_4:
ldr r1, =LED_ADDR           @load register
ldr r1, [r1]                @dereference to get the value
ldrh r0, [r1]               @load high value
orr r0, r0, LED_4_ADDR      @or r0 with constant
strh r0, [r1]               @store high value
b DONE_LED_SWITCH           @go back to where we were


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
TURN_ON_LED_5:
ldr r1, =LED_ADDR           @load register
ldr r1, [r1]                @dereference to get the value
ldrh r0, [r1]               @load high value
orr r0, r0, LED_5_ADDR      @or r0 with constant
strh r0, [r1]               @store high value
b DONE_LED_SWITCH           @go back to where we were

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
TURN_ON_LED_6:
ldr r1, =LED_ADDR           @load register
ldr r1, [r1]                @dereference to get the value
ldrh r0, [r1]               @load high value
orr r0, r0, LED_6_ADDR      @or r0 with constant
strh r0, [r1]               @store high value
b DONE_LED_SWITCH           @go back to where we were

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
TURN_ON_LED_7:
ldr r1, =LED_ADDR           @load register
ldr r1, [r1]                @dereference to get the value
ldrh r0, [r1]               @load high value
orr r0, r0, LED_7_ADDR      @or r0 with constant
strh r0, [r1]               @store high value
b DONE_LED_SWITCH           @go back to where we were

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
TURN_ON_LED_8:
ldr r1, =LED_ADDR           @load register
ldr r1, [r1]                @dereference to get the value
ldrh r0, [r1]               @load high value
orr r0, r0, LED_8_ADDR      @or r0 with constant
strh r0, [r1]               @store high value
b DONE_LED_SWITCH           @go back to where we were
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@Function Declaration : exit_check
@
@ Input: none
@ Returns: none
@ 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    exit_check:
    
                                @tickle the watchdog
    cmp r4, r6                  @check to see if winner is current LED
    beq exit_success            @if equal then goto exit_success
    bne exit_failure              @else go to exit_failure
    bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@




@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@Function Declaration : int exit_failure
@
@ Input: none
@ Returns: none
@ 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    exit_failure:

@LED OFF
    push  {r0, r1,r2,r3,r4-r7, lr}   @ Bring all the register values back
    bl all_led_off               @LED off
   
@DELAY
    mov r0, #EXIT_DELAY                  @move 1000 delay value into r0
    bl HAL_Delay                @ call BSP C function using Branch with Link (bl)

@LED On 
    mov r0, r4
    bl BSP_LED_On               @LED off
   
@DELAY
    mov r0, #EXIT_DELAY                  @move 1000 delay value into r0
    bl HAL_Delay                @ call BSP C function using Branch with Link (bl)
   
@LED OFF
    bl all_led_off               @LED off
   

@DELAY
   
    mov r0, #EXIT_DELAY                  @move 1000 delay value into r0
    bl HAL_Delay                @ call BSP C function using Branch with Link (bl)
   

@LED On 
   
    mov r0, r4
    bl BSP_LED_On               @LED off
   


 @DELAY
   
    mov r0, #EXIT_DELAY                  @move 1000 delay value into r0
    bl HAL_Delay                @ call BSP C function using Branch with Link (bl)
   

@LED OFF
   
    bl all_led_off               @LED off
    
    b exit_failure

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

quit:
pop  {r0,r1,r2,r3,r4-r7, lr}                @ Bring all the register values back 


bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


    .size   brGame, .-brGame    @@ - symbol size (not req)


@ Assembly file ended by single .end directive on its own line
.end 
    
Things past the end directive are not processed, as you can see here.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
