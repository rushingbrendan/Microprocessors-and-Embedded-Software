@
@  FILE          : br_asm.s
@  PROJECT       : PROG1360 - Microprocessors and Emebbeded - Assignment #4
@  PROGRAMMER    : Brendan Rushing
@  FIRST VERSION : 2018-07-26
@  DESCRIPTION   :
@   This is a game that illuminates the LED that is on based on the X Y value from accelerometer
@   The game is over after user entered time
@   The game is won if the user holds the LED for the desired time
@ 


@ Data section - initialized values
.data

.align 3    @ This alignment is critical - to access our "huge" value, it must
            @ be 64 bit aligned




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

    .global brTilt       @ Make the symbol name for the function visible to the linker

    .code   16              @ 16bit THUMB code (BOTH .code and .thumb_func are required)
    .thumb_func             @ Specifies that the following symbol is the name of a THUMB
                            @ encoded function. Necessary for interlinking between ARM and THUMB code.

    .type   brTilt, %function   @ Declares that the symbol is a function (not strictly required)
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



@ Function Declaration : brTilt
@
@ Input: r0, r1, r2 (i.e. r0 holds Winning Time, r1 Winning LED, r2 Total Time )
@ Returns: none
@
@   r4 = Y_axis
@   r5 = X_Axis
@   r6 = win_length
@   r7 = win_LED
@   r8 = total_time
@   r9 = initial_sys_tick
@   r10 = current_sys_tick
@   r11 = init_count_second
@   r12 = winning_led_count
@
@
@
@ Here is the actual function
brTilt:
   push {lr}                @ Put aside registers we want to restore later


@STORE VALUES

    mov r6, r0                      @store win_length
    mov r7, r1                      @store win_led
    mov r8, r2                      @store total_game_time
    mov r9, #0                      @init initial_sys_tick
    mov r10, #0                      @init current_sys_tick
    mov r11, #0                      @init count_second
    mov r12, #0                      @init winning_led_count
    mov r5, #0                      @init   X AXIS
    mov r4, #0                      @init   Y AXIS
    

@READ INITIAL VALUE FROM SYS TICKS

    bl HAL_GetTick      @get current tick
    mov r9, r0          @store init_sys_Tick



program_loop:

   @ bkpt



@DELAY
    mov r0, #50                  @move 100 delay value into r0
    bl HAL_Delay                @ call BSP C function using Branch with Link (bl)


@READ VALUE FROM SYS TICKS
    bl HAL_GetTick
    mov r10, r0                     @store current sys tick


@CHECK IF 1 SECOND HAS PASSED
    mov r1, r10     @get current_systick_value
    mov r2, r9      @get intial_systick_value

    sub r0, r1,r2             @subtract current value from initial value
    cmp r0, #1000               @check to see if 1000ms has passed
    bge one_second              @branch if it has

    done_second_increment:

@ READ X FROM ACCELEROMETER

    mov r0, 0x32                @high value
    mov r1, 0x29                @X axis

    bl COMPASSACCELERO_IO_Read      @read accelerometer

    sxtb r0, r0                 @sxtb it

    mov r3, #32                 @store 32 for dividing
    sdiv r1, r0, r3             @divide by 32

    mov r5, r1              @store x axis in r5


@DELAY
    mov r0, #50                  @move 100 delay value into r0
    bl HAL_Delay                @ call BSP C function using Branch with Link (bl)



@ READ Y FROM ACCELEROMETER

    mov r0, 0x32                @high value
    mov r1, 0x2B                @Y axis

    bl COMPASSACCELERO_IO_Read      @read accelerometer

    sxtb r0, r0                 @sxtb it

    mov r3, #32                 @move 32 to be used for divie
    sdiv r1, r0, r3             @divide by 32
    mov r4, r1              @store y axis in r4



@TURN ON LED

    b DETERMINE_LED             @determine what LED should be on


    done_winning_LED_check:     @label used when above function is done

    mov r0, #50                 @50 ms delay
    bl HAL_Delay                @call delay


    b program_loop              @go back to program_loop for another iteration



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@Function Declaration : DETERMINE_LED
@
@ Input: none
@ Returns: none
@ 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    DETERMINE_LED:
    @the values in the function are based off a x y graph with -1, 0, +1

    LED_0:
    cmp r5, #1
    bne LED_1
    cmp r4, #0
    bne LED_1
    mov r0, #0          @LED 0 ON
    b LED_ON


    LED_1:
    cmp r5, #1
    bne LED_2
    cmp r4, #1
    bne LED_2
    mov r0, #1          @LED 1 ON
    b LED_ON


    LED_2:
    cmp r5, #1
    bne LED_3
    cmp r4, #-1
    bne LED_3
    mov r0, #2          @LED 2 ON
    b LED_ON



    LED_3:
    cmp r5, #0
    bne LED_4
    cmp r4, #1
    bne LED_4
    mov r0, #3          @LED 3 ON
    b LED_ON



    LED_4:
    cmp r5, #0
    bne LED_5
    cmp r4, #-1
    bne LED_5
    mov r0, #4          @LED 4 ON
    b LED_ON




    LED_5:
    cmp r5, #-1
    bne LED_6
    cmp r4, #1
    bne LED_6
    mov r0, #5          @LED 5 ON
    b LED_ON




    LED_6:
    cmp r5, #-1
    bne LED_7
    cmp r4, #-1
    bne LED_7
    mov r0, #6          @LED 6 ON
    b LED_ON




    LED_7:
    cmp r5, #-1
    bne done_winning_LED_check
    cmp r4, #0
    bne done_winning_LED_check
    mov r0, #7          @LED 7 ON
    b LED_ON


    b done_winning_LED_check
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@





@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@Function Declaration : LED_ON
@
@ Input: none
@ Returns: none
@ 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    LED_ON:
    @TURN OFF ALL LED'S

    push {r0}                   @push r0

    bl all_led_off              @all LED off


    bl   BSP_LED_On             @turn on led
    pop {r0}                    @pop r0



    @CHECK TO SEE IF WINNING LED IS ON
    mov r1, r7          @get winning_LED
    cmp r0, r1          @check if winning_LEd is same as current
    beq winning_LED_on  @branch if it is
    b winning_LED_off   @go back to loop if not


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@







@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@Function Declaration : winning_LED_on
@
@ Input: none
@ Returns: none
@ 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    winning_LED_on:
    mov r0, r12                             @check to see if this is the first time we have been in the label
    cmp r0, #1                              @check if empty
    blt winning_LED_on_first_time           @branch if it is empty


    bl HAL_GetTick
    mov r1, r0                              @move current tick value
    mov r2, r12                             @get winning_led_counter
    
    sub r0, r1,r2                           @subtract current value from initial value

    cmp r6, r0                              @check to see if winning LED has been on for desired time
    ble exit_success
    b done_winning_LED_check



    winning_LED_on_first_time:


    bl HAL_GetTick                           @get new value for systick

    mov r12, r0                              @store winning_LED_count

    b done_winning_LED_check                 @go back to where we were
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@







@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@Function Declaration : winning_LED_off
@
@ Input: none
@ Returns: none
@ 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    winning_LED_off:

    mov r12, #0         @clear winning_LED_Count


    b done_winning_LED_check
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@








@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@Function Declaration : all_led_on
@
@ Input: none
@ Returns: none
@ 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    all_led_on:

    push {r0-r12,lr}                @ Put aside registers we want to restore later

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

    pop {r0-r12,lr}                @ Put aside registers we want to restore later
    bx lr                       @return to where we were

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@Function Declaration : all_led_off
@
@ Input: none
@ Returns: none
@ 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    all_led_off:

    push {r0-r12,lr}                @ Put aside registers we want to restore later

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

    pop {r0-r12,lr}                @ Put aside registers we want to restore later
    bx lr                       @return to where we were

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@




@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@Function Declaration : one_second
@
@ Input: none
@ Returns: none
@ 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
one_second:
    @mov initial_systick_value,r10      @move value of current systick into intial systick

    mov r9, r10         @move current value into initial
    
    
    mov r0, r11         @pull second counter
    add r0, #1          @increment by 1
    mov r11, r0         @store value
   
    mov r1, r8           @get total game time

    cmp r0, r1
    @cmp second_counter, total_game_time     @compare total_time with second_count
    beq exit_failure
    b done_second_increment
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@










@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@Function Declaration : int exit_success
@
@ Input: none
@ Returns: none
@ 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    exit_success:

@LED WINNING SEQUENCE

@LED OFF
  
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
    b quit
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@Function Declaration : int exit_failure
@
@ Input: none
@ Returns: none
@ 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    exit_failure:

@LED OFF
    bl all_led_off               @LED off
   

 @DELAY
   
    mov r0, #1000                  @move 1000 delay value into r0
    bl HAL_Delay                @ call BSP C function using Branch with Link (bl)
   

@LED On
   
    mov r0, r7
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
   
    mov r0, r7
    bl BSP_LED_On               @LED off
   


 @DELAY
   
    mov r0, #1000                  @move 1000 delay value into r0
    bl HAL_Delay                @ call BSP C function using Branch with Link (bl)
   

@LED OFF
   
    bl all_led_off               @LED off
    

    @pop {r0-r12,lr}                @ Put aside registers we want to restore later
    b quit

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@





@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@Function Declaration : int quit
@
@ Input: none
@ Returns: none
@ 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
quit:
 pop {lr}                @ Put aside registers we want to restore later 


bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

    .size   brTilt, .-brTilt    @@ - symbol size (not req)


@ Assembly file ended by single .end directive on its own line
.end 
    
Things past the end directive are not processed, as you can see here.


