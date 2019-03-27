#include <msp430g2553.h>
#define BTN BIT3
#define LED1 BIT0
#define LED2 BIT6

void main(void){
    WDTCTL = WDTPW | WDTHOLD;
    P1OUT = 0;
    P1DIR = LED1 + LED2;
    for(;;)
    {
        if((P1IN & BTN) == 0)
        {
            P1OUT &= ~(LED1 + LED2);
        }
        else
        {
            P1OUT |= LED1 + LED2;
        }
    }
}
