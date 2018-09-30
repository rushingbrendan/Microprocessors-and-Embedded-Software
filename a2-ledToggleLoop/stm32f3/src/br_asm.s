@
@  FILE          : br_asm.s
@  PROJECT       : PROG1360 - Microprocessors and Emebbeded - Assignment #2
@  PROGRAMMER    : Brendan Rushing
@  FIRST VERSION : 2018-06-13
@  DESCRIPTION   :
@	This assignment takes two inputs from the user: count and delay.
@ The program then flashes the LED lights at the delay specified by the user and the amount of
@ times of the count variable.
@ 



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

    .global br_led_demo        @ Make the symbol name for the function visible to the linker

    .code   16              @ 16bit THUMB code (BOTH .code and .thumb_func are required)
    .thumb_func             @ Specifies that the following symbol is the name of a THUMB
                            @ encoded function. Necessary for interlinking between ARM and THUMB code.

    .type   br_led_demo, %function   @ Declares that the symbol is a function (not strictly required)
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


@ Function Declaration : int busy_delay(int cycles)
@
@ Input: r0 (i.e. r0 holds number of cycles to delay)
@ Returns: r0
@ 

@ Here is the actual function
busy_delay:

    push {r4}

    mov r4, r0

delay_loop:
    subs r4, r4, #1

    bgt delay_loop

    mov r0, #0                      @ Return zero (always successful)

    pop {r4}

    bx lr                           @ Return (Branch eXchange) to the address in the link register (lr)


@ Function Declaration : br_led_demo
@
@ Input: r0, r1 (i.e. r0 holds count, r1 holds delay)
@ Returns: none
@ 

@ Here is the actual function
br_led_demo:

    push {r0,r1,r2,r4-r7, lr}                @ Put aside registers we want to restore later

    mov r4, r0   @move count to r4
    mov r5, r1   @move delay to r5
   

    mov r8, #0  @r8 used for count loop

        count_loop:
        mov r7, #0  @r7 used for LED counter
        cmp r8, r4
        beq out
        add r8, r8, #1


            led_loop:

            mov r0, r5
            bl busy_delay   
 
 
            mov  r0, r7                  @ r0 holds our argument for the LED toggle function
                                    @ So pass it a value
            bl   BSP_LED_Toggle             @ call BSP C function using Branch with Link (bl)

            mov r0, r5
            bl busy_delay

            mov  r0, r7                  @ r0 holds our argument for the LED toggle function
                                    @ So pass it a value
            bl   BSP_LED_Toggle             @ call BSP C function using Branch with Link (bl)


            cmp r7, #7 
            beq count_loop
            add r7, r7, #1
            b led_loop

    out:

    pop  {r0,r1,r2,r4-r7, lr}                @ Bring all the register values back

    bx lr                           @ Return (Branch eXchange) to the address in the link register (lr) 

    .size   br_led_demo, .-br_led_demo    @@ - symbol size (not req)

@ Assembly file ended by single .end directive on its own line
.end

Things past the end directive are not processed, as you can see here.


