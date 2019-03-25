// modo 1

//#include <msp430g2553.h>
//
//
///**
// * main.c
// */
//int main(void)
//{
//	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
//	P1DIR = 0x41;
//	P1OUT = 0x41;
//	for(;;)
//	{
//	}
//}

// modo 2
#include <msp430g2553.h>

/*
 * hw2.c
 *
 *  Created on: 25 de mar de 2019
 *      Author: Vinícius Breda
 */
int main(void){
    WDTCTL = WDTPW | WDTHOLD;
    P1DIR = BIT6 + BIT0;
    P1OUT = BIT6 + BIT0;
    for(;;)
    {
    }
}
