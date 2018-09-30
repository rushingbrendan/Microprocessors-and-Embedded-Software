/*
@  FILE          : br_asm.s
@  PROJECT       : PROG1360 - Microprocessors and Emebbeded - Assignment #4
@  PROGRAMMER    : Brendan Rushing
@  FIRST VERSION : 2018-07-26
@  DESCRIPTION   :
@   This is a game that illuminates the LED that is on based on the X Y value from accelerometer
@   The game is over after user entered time
@   The game is won if the user holds the LED for the desired time
*/


//CONSTANTS
#define WIN_LENGTH_DEFAULT 500
#define WIN_LED_DEFAULT 7
#define TOTAL_TIME_DEFAULT 30 
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
int brTilt(int win_length, int win_LED, int total_time);
//eo PROTOTYPES




/*
* FUNCTION : bra4
*
* DESCRIPTION : This function when called adds the called function
* to the minicom window.
*
* PARAMETERS : int: action
*
*
* RETURNS : none
*/
void bra4(int action)
{

	uint32_t win_length = WIN_LENGTH_DEFAULT;
  uint32_t win_LED = WIN_LED_DEFAULT;
  uint32_t total_time = TOTAL_TIME_DEFAULT;


  if(action==CMD_SHORT_HELP) return;
  if(action==CMD_LONG_HELP) { 
    printf("Addition Test\n\n"
	   "This command tests new addition function\n"
	   );

    return;
  }

  //get input variables
  fetch_uint32_arg(&win_length);
  fetch_uint32_arg(&win_LED);
  fetch_uint32_arg(&total_time);


  //call brGame function (assembly)
 brTilt(win_length, win_LED, total_time);



}

//Function name in minicom
ADD_CMD("brTilt", bra4,"<Time To Win> <Winning LED>  <Total Game Time>")
