@
@  FILE          : br_asm.s
@  PROJECT       : PROG1360 - Microprocessors and Emebbeded - Assignment #3
@  PROGRAMMER    : Brendan Rushing
@  FIRST VERSION : 2018-07-04
@  DESCRIPTION   :
@	This assignment takes three inputs from the user: delay, ledpattern and led winning number.
@   The program loops through the led pattern. The user tries to press the button when the winning number led is illuminated.
@   the program ends when the user presses the button. If the user presses the correct button then all the leds illuminate. 
@ 


@ Data section - initialized values
.data

.align 3    @ This alignment is critical - to access our "huge" value, it must
            @ be 64 bit aligned

huge:   .octa 0xAABBCCDDDDCCBBAA
big:    .word 0xAAAABBBB
num:    .byte 0xAB


str2:   .asciz "Bonjour le Monde"
count:  .word 12345                     @ This is an initialized 32 bit value




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



@ Function Declaration : brGame
@
@ Input: r0, r1, r2 (i.e. r0 holds delay, r1 holds pattern, r2 holds winning number )
@ Returns: none
@ 
@   r4 = winningNUmber
@   r5 = delay
@   r9 = pattern
@   r7 = array counter
@
@ Here is the actual function
brGame:
   push {r0,r1,r2,r3, r4-r7, lr}                @ Put aside registers we want to restore later
      @ mov r10, lr
    mov r7, #0          @set counter to 0
    
    @STORE VALUES
    mov r5, r0          @move r0 value DELAY into r5
    mov r4, r2          @move r2 value WINNING NUMBER into r4
    mov r9, r1          @move r9 with led pattern


program_loop:

    @bkpt

    bl all_led_off              @all LED off

@CHECK DATA

    ldrb r6,[r9]        @load value from led pattern array

    cmp r6, #0
    beq reset_array     @if null terminator (end of array) then reload array with value from r7

    cmp r6, #56         @check to see if value is greater than ASCII 7 for the last LED
    bgt exit_failure    @go to exit_failure function

    cmp r6, #47         @check to see if value is less than ASCII 0 for the first LED
    ble exit_failure    @go to exit_failure function


    sub r6, #48         @strip ASCII value to equal value of LED

@TURN ON LED

    mov  r0, r6                  @ r0 holds our argument for the LED toggle function                    
    bl   BSP_LED_On             @ call BSP C function using Branch with Link (bl)

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


@Function Declaration : reset_array
@
@ Input: none
@ Returns: none
@ 
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
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@Function Declaration : all_led_on
@
@ Input: none
@ Returns: none
@ 
    all_led_on:

    push {r0, r1,r2,r3, r4-r7, lr}  @ Put aside registers we want to restore later

    mov  r0, #0                  @ r0 holds our argument for the LED toggle function                    
    bl   BSP_LED_On             @ call BSP C function using Branch with Link (bl)
    
    mov  r0, #1                  @ r0 holds our argument for the LED toggle function                    
    bl   BSP_LED_On             @ call BSP C function using Branch with Link (bl)

    mov  r0, #2                  @ r0 holds our argument for the LED toggle function                    
    bl   BSP_LED_On             @ call BSP C function using Branch with Link (bl)

    mov  r0, #3                  @ r0 holds our argument for the LED toggle function                    
    bl   BSP_LED_On             @ call BSP C function using Branch with Link (bl)
    
    mov  r0, #4                  @ r0 holds our argument for the LED toggle function                    
    bl   BSP_LED_On             @ call BSP C function using Branch with Link (bl)

    mov  r0, #5                  @ r0 holds our argument for the LED toggle function                    
    bl   BSP_LED_On             @ call BSP C function using Branch with Link (bl)

    mov  r0, #6                  @ r0 holds our argument for the LED toggle function                    
    bl   BSP_LED_On             @ call BSP C function using Branch with Link (bl)
    
    mov  r0, #7                  @ r0 holds our argument for the LED toggle function                    
    bl   BSP_LED_On             @ call BSP C function using Branch with Link (bl)

    pop  {r0, r1,r2,r3,r4-r7, lr}   @ Bring all the register values back
    bx lr                       @return to where we were

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@




@Function Declaration : all_led_off
@
@ Input: none
@ Returns: none
@ 
    all_led_off:

    push {r0, r1,r2,r3, r4-r7, lr}  @ Put aside registers we want to restore later

    mov  r0, #0                  @ r0 holds our argument for the LED toggle function                    
    bl   BSP_LED_Off             @ call BSP C function using Branch with Link (bl)
    
    mov  r0, #1                  @ r0 holds our argument for the LED toggle function                    
    bl   BSP_LED_Off             @ call BSP C function using Branch with Link (bl)

    mov  r0, #2                  @ r0 holds our argument for the LED toggle function                    
    bl   BSP_LED_Off             @ call BSP C function using Branch with Link (bl)

    mov  r0, #3                  @ r0 holds our argument for the LED toggle function                    
    bl   BSP_LED_Off             @ call BSP C function using Branch with Link (bl)
    
    mov  r0, #4                  @ r0 holds our argument for the LED toggle function                    
    bl   BSP_LED_Off             @ call BSP C function using Branch with Link (bl)

    mov  r0, #5                  @ r0 holds our argument for the LED toggle function                    
    bl   BSP_LED_Off             @ call BSP C function using Branch with Link (bl)

    mov  r0, #6                  @ r0 holds our argument for the LED toggle function                    
    bl   BSP_LED_Off             @ call BSP C function using Branch with Link (bl)
    
    mov  r0, #7                  @ r0 holds our argument for the LED toggle function                    
    bl   BSP_LED_Off             @ call BSP C function using Branch with Link (bl)

    pop  {r0, r1,r2,r3,r4-r7, lr}   @ Bring all the register values back
    bx lr                       @return to where we were

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@




@Function Declaration : exit_check
@
@ Input: none
@ Returns: none
@ 
    exit_check:
    
    cmp r4, r6                  @check to see if winner is current LED
    beq exit_success            @if equal then goto exit_success
    bne exit_failure              @else go to exit_failure
    bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



@Function Declaration : int exit_success
@
@ Input: none
@ Returns: none
@ 
    exit_success:

@LED WINNING SEQUENCE

@LED OFF
    push  {r0, r1,r2,r3,r4-r7, lr}   @ Bring all the register values back
    bl all_led_off               @LED off
    
@DELAY
  
    mov r0, #1000                  @move 1000 delay value into r0
    bl HAL_Delay                @ call BSP C function using Branch with Link (bl)
   

@LED ON
  
    bl all_led_on               @LED off

@DELAY
  
    mov r0, #1000                  @move 1000 delay value into r0
    bl HAL_Delay                @ call BSP C function using Branch with Link (bl)
  

@LED Off
  
    bl all_led_off               @LED off
  

 @DELAY
    
    mov r0, #1000                  @move 1000 delay value into r0
    bl HAL_Delay                @ call BSP C function using Branch with Link (bl)
    

@LED On
    
    bl all_led_on               @LED off
    

 @DELAY
    
    mov r0, #1000                  @move 1000 delay value into r0
    bl HAL_Delay                @ call BSP C function using Branch with Link (bl)
    

@LED Off
    
    bl all_led_off               @LED off
    pop  {r0, r1,r2,r3,r4-r7, lr}   @ Bring all the register values back
    b quit
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



@Function Declaration : int exit_failure
@
@ Input: none
@ Returns: none
@ 
    exit_failure:

@LED OFF
    push  {r0, r1,r2,r3,r4-r7, lr}   @ Bring all the register values back
    bl all_led_off               @LED off
   

 @DELAY
   
    mov r0, #1000                  @move 1000 delay value into r0
    bl HAL_Delay                @ call BSP C function using Branch with Link (bl)
   

@LED On
   
    mov r0, r4
    bl BSP_LED_On               @LED off
   

 @DELAY
   
    mov r0, #1000                  @move 1000 delay value into r0
    bl HAL_Delay                @ call BSP C function using Branch with Link (bl)
   

@LED OFF
   
    bl all_led_off               @LED off
   

 @DELAY
   
    mov r0, #1000                  @move 1000 delay value into r0
    bl HAL_Delay                @ call BSP C function using Branch with Link (bl)
   

@LED On
   
    mov r0, r4
    bl BSP_LED_On               @LED off
   


 @DELAY
   
    mov r0, #1000                  @move 1000 delay value into r0
    bl HAL_Delay                @ call BSP C function using Branch with Link (bl)
   

@LED OFF
   
    bl all_led_off               @LED off
    

    pop  {r0,r1,r2,r3,r4-r7, lr}                @ Bring all the register values back 
    b quit

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


quit:
pop  {r0,r1,r2,r3,r4-r7, lr}                @ Bring all the register values back 


bx lr



    .size   brGame, .-brGame    @@ - symbol size (not req)


@ Assembly file ended by single .end directive on its own line
.end 
    
Things past the end directive are not processed, as you can see here.


