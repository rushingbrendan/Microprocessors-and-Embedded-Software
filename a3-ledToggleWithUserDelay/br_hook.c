/*
*  FILE          : br_hook.c
*  PROJECT       : PROG1360 - Microprocessors and Emebbeded - Assignment #3
*  PROGRAMMER    : Brendan Rushing
*  FIRST VERSION : 2018-07-04
*  DESCRIPTION   :
*	  This assignment takes three inputs from the user: delay, ledpattern and led winning number.
*   The program loops through the led pattern. The user tries to press the button when the winning number led is illuminated.
*   the program ends when the user presses the button. If the user presses the correct button then all the leds illuminate. 
*/ 


//CONSTANTS
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

  char* lights = "123";

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



  //call brGa,e function (assembly)
brGame(delay,lights, winningSelection);



}

//Function name in minicom
ADD_CMD("brGame", bra3,"<Delay> <LED_Pattern>  <Winning_LED>")
