/*
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@
@  FILE          : br_asm.s
@  PROJECT       : PROG1360 - Microprocessors and Emebbeded - Assignment #5
@  PROGRAMMER    : Brendan Rushing
@  FIRST VERSION : 2018-08-07
@  DESCRIPTION   :
@
@	  -brWatch
@   This assignment takes one inputs from the user: delay
@   The program loops through the LED's in a circle.
@   The watch dog is tickled at the beginning of every loop.
@   If the push button is pressed then all the LED's turn on and off with a delay
@   The program will end by itself because the watchdog will not be tickled so it will end the function. 
@
@   -brGame
@   This assignment is the same as assignment #3 but it uses direct memory access to illuminate the LED's
@   
@	  This assignment takes three inputs from the user: delay, ledpattern and led winning number.
@   The program loops through the led pattern. The user tries to press the button when the winning number led is illuminated.
@   the program ends when the user presses the button. If the user presses the correct button then all the leds illuminate. 
@ 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

*/ 


//CONSTANTS
#define DELAY_DEFAULT 500
#define WATCHDOG_DEFAULT 5000
#define DELAY_DEFAULT 500
#define WIN_DEFAULT 3
//eo CONSTANTS


//INCLUDE FILES
#include <stdio.h>
#include <stdint.h>
#include <ctype.h>

#include "common.h"

#include "stm32f3xx_hal.h"
#include "stm32f3_discovery.h"
#include "stm32f3_discovery_accelerometer.h"
#include "stm32f3_discovery_gyroscope.h"
//eo INCLUDE FILES


//PROTOTYPES
int brWatch(int delay);
int brGame(int delay, char* lights, int winningSelection);
//eo PROTOTYPES


/*
* FUNCTION : bra3
*
* DESCRIPTION : This function when called adds the called function
* to the minicom window.
*
* PARAMETERS : int: action
*
*
* RETURNS : none
*/
void bra3(int action)
{

	uint32_t winningSelection = WIN_DEFAULT, delay = DELAY_DEFAULT;

  char* lights = "01234567";

  if(action==CMD_SHORT_HELP) return;
  if(action==CMD_LONG_HELP) { 
    printf("Addition Test\n\n"
	   "This command tests new addition function\n"
	   );

    return;
  }

  //get input variables
  fetch_uint32_arg(&delay);
  fetch_string_arg(&lights);
  fetch_uint32_arg(&winningSelection);


  //initialize watchdog with input value
  mes_InitIWDG(WATCHDOG_DEFAULT);

  //start the watchdog
  mes_IWDGStart();


  //call brGame function (assembly)
brGame(delay,lights, winningSelection);



}

//Function name in minicom
ADD_CMD("brGame", bra3,"<Delay> <LED_Pattern>  <Winning_LED>")





/*
* FUNCTION : bra5
*
* DESCRIPTION : This function when called adds the called function
* to the minicom window.
*
* PARAMETERS : int: delay
*
*
* RETURNS : none
*/
void bra5(int action)
{

	uint32_t delay = DELAY_DEFAULT, watchDogValue = WATCHDOG_DEFAULT;

  if(action==CMD_SHORT_HELP) return;
  if(action==CMD_LONG_HELP) { 
    printf("Addition Test\n\n"
	   "This command tests new addition function\n"
	   );

    return;
  }

  //get input variables
  fetch_uint32_arg(&delay);
  fetch_uint32_arg(&watchDogValue);

  //initialize watchdog with input value
  mes_InitIWDG(watchDogValue);

  //start the watchdog
  mes_IWDGStart();


  //call brWatch function (assembly)
  brWatch(delay);



}

//Function name in minicom
ADD_CMD("brWatch", bra5,"<Delay> <Watch Dog Value>")
