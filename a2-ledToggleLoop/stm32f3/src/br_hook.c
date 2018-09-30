/*
*  FILE          : br_hook.c
*  PROJECT       : PROG1360 - Microprocessors and Emebbeded - Assignment #2
*  PROGRAMMER    : Brendan Rushing
*  FIRST VERSION : 2018-06-13
*  DESCRIPTION   :
*	This assignment takes two inputs from the user: count and delay.
* The program then flashes the LED lights at the delay specified by the user and the amount of
* times of the count variable.
*/


//CONSTANTS
#define DELAY_DEFAULT 999999
#define COUNT_DEFAULT 1
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
int br_led_demo(int count, int delay);
//eo PROTOTYPES




/*
* FUNCTION : AddTest
*
* DESCRIPTION : This function when called adds the called function
* to the minicom window.
*
* PARAMETERS : int: action
*
*
* RETURNS : none
*/
void bra2(int action)
{

	uint32_t count = COUNT_DEFAULT, delay = DELAY_DEFAULT;

  if(action==CMD_SHORT_HELP) return;
  if(action==CMD_LONG_HELP) { 
    printf("Addition Test\n\n"
	   "This command tests new addition function\n"
	   );

    return;
  }

  //get input variables
  fetch_uint32_arg(&count);
  fetch_uint32_arg(&delay);

  //call led_demo function (assembly)
br_led_demo(count,delay);


}

//Function name in minicom
ADD_CMD("ledloop", bra2,"<count> <delay> Toggles all LED's")
