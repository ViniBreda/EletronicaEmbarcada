// main.c
#include "msp430g2553.h"

//chamada das funções globais em assembly
void set_tick(unsigned);
unsigned get_tick(void);
void synth_init();
void set_note(int, unsigned);

#define STATECHANGER BIT0
#define NOTE1 BIT4
#define NOTE2 BIT5
#define NOTE3 BIT0
#define NOTE4 BIT1
#define TIME 5000

//variáveis
//int loop[16] = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1};    //guarda as notas do loop
int loop[16] = {0x5A,0x5A,0x5A,0x5A,0x5A,0x5A,0x5A,0x5A,0x5A,0x5A,0x5A,0x5A,0x5A,0x5A,0x5A,0x5A,};    //guarda as notas do loop

void singletone();
int looptone(int old);
void playtone(int note, int time);

enum states
{
    oneTone,
    fixedTime
};

enum states state = oneTone;

void main(void)
{

    WDTCTL = WDTPW + WDTHOLD;

    BCSCTL1 = XT2OFF + 15;
    P1DIR = 0xF2;       // I/O assignment
    P1REN = 0x0D;       // Pull up resistor for switch and Rxd
    P1OUT = 0x0F;       // Pull up, serial idle high
    P1SEL = 0x50;       // Enable Timer A output, SMCLK output
    P1DIR &= ~(NOTE1 + NOTE2 + NOTE3 + NOTE4);

    P2IE |= (STATECHANGER);
    P2IES |= (STATECHANGER);
    P2IFG &= ~(STATECHANGER);

    synth_init();

    unsigned int i = 0;

    for(;;)
    {
       switch(state)
       {
       case oneTone:
           singletone();
           break;
       case fixedTime:
           loop[i] = looptone(loop[i]);

           playtone(loop[i], TIME);

           playtone(-1, TIME);

           if(i == 15) i = 0;
           else i++;
           break;
       default:
           i = 0;
       }
    }
}

#pragma vector = PORT2_VECTOR
__interrupt void PORT2_ISR(void)
{
    if((P2IN & STATECHANGER) == 0)
    {
        switch(state)
        {
        case oneTone:
            state = fixedTime;
            break;
        case fixedTime:
            state = oneTone;
            break;
        default:
            state = oneTone;
        }
        P2IFG &= ~STATECHANGER;
    }
}


/*Função
 * Entrada: nota antiga
 * Saída: nota nova
 * A função detecta qual botão foi apertado, caso seja em modo de input, uma nova nota será definida
 * caso contrário, a nota da entrada será retornada (mantida)
 */
int looptone(old)
{
    int new;
    if((P1IN & NOTE1) == 0)
    {
        new = 0x6B;
    }
    else if((P1IN & NOTE2) == 0)
    {
        new = 0x69;
    }
    else if((P1IN & NOTE3) == 0)
    {
        new = 0x67;
    }
    else if((P1IN & NOTE4) == 0)
    {
        new = 0x65;
    }
    else
    {
        new = old;
    }
    return new;
}

void singletone()
{
   if((P1IN & NOTE1) == 0)
   {
       playtone(0x6B, TIME);
   }
   else if((P1IN & NOTE2) == 0)
   {
       playtone(0x69, TIME);
   }
   else if((P1IN & NOTE3) == 0)
   {
       playtone(0x67, TIME);
   }
   else if((P1IN & NOTE4) == 0)
   {
       playtone(0x65, TIME);
   }
   else
   {
       playtone(-1, TIME);
   }
}

void playtone(int note, int time)
{
    set_note(note, 0);
    set_tick(time);
    while(get_tick());
}
