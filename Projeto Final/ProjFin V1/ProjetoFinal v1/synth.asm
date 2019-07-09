; synth.asm
       .cdecls C, LIST, "msp430g2553.h"

smplrt  .equ    38400                   ; Sample rate

       .text
       .global set_tick
       .global get_tick
       .global synth_init
       .global set_note

       .bss    tick, 2
       .bss    phase_inc, 2 * 12       ; Phase increment (from note table)
       .bss    phase_acc, 2 * 12       ; Phase accumulator

set_tick
       mov     R12, &tick
       ret

get_tick
       mov     &tick, R12
       ret

synth_init
       mov     #0x0210, &TACTL         ; Timer A config: SMCLK, count up
       mov     #415, &TACCR0           ; Setup Timer A period for 38400 sps
       mov     #256, &TACCR1           ; Setup Timer A compare
       mov     #0x00E0, &TACCTL1       ; Setup Timer A reset/set output mode
                                       ;
       mov     #phase_inc, R12         ; Clear all phase inc and accum                          ;
       mov     #2 * 12, R14            ; Word count
       clr     0(R12)                  ; Clear word
       incd    R12                     ; Next word
       dec     R14                     ; Dec word count
       jne     $ - 8                   ; Loop until all words done...
                                       ;
       eint                            ; Enable interupts
       bis     #0x0010, &TACCTL1       ; Enable PWM interupt

       ret


synth_isr
       push    R4
       push    R5
       push    R6
       push    R7
       push    R8
       push    R9

       mov     #sine, R4               ; Get wavetable pointer
       mov     #phase_inc, R5          ; Setup phase increment pointer
       mov     #phase_acc, R6          ; Setup phase accumulator pointer
       clr     R7                      ; Clear sample accumulator
       mov     #12, R8                 ; Setup voice count
voice_loop                              ;
       mov     @R6, R9                 ; Get phase acc (MSW)
       swpb    R9                      ; Swap MSB/LSB
       mov.b   R9, R9                  ; Clear MSB
       add     R4, R9                  ; Add wavetable pointer
       mov.b   @R9, R9                 ; Get wave sample
       add     R9, R7                  ; Update sample
       add     @R5+, 0(R6)             ; Update phase acc
       incd    R6                      ; Increment phase acc pointer                       ;
       dec     R8                      ; Dec voice count
       jne     voice_loop              ; Next voice...
                                       ;
       rra     R7                      ;
       rra     R7                      ;
       rra     R7                      ;
       add     #16, R7                 ;
       mov     R7, &TACCR1             ; Output sample
                                       ;
       dec     &tick                   ;
       jc      $ + 6                   ;
       clr     &tick                   ;
                                       ;
       bic     #0x01, &TACCTL1         ;
                                       ;
       pop     R9
       pop     R8
       pop     R7
       pop     R6
       pop     R5
       pop     R4
       reti

set_note
       clr     R14                     ; Clear octave count
       cmp     #128, R12               ;
       jhs     note_off                ;
tst_note                                ;
       cmp     #116, R12               ; Within note table?
       jge     get_pi                  ; Yes...
       inc     R14                     ; Inc octave count
       add     #12, R12                ; Add octave to note
       jmp     tst_note                ; Check again...
get_pi                                  ; Get phase increment
       sub     #116, R12               ; Adjust for first note in table
       rla     R12                      ; MIDI note * 2
       add     #notes, R12             ; Add note table pointer
       mov     @R12, R12               ; Get MSW
       tst     R14                     ; Shifting required?
       jeq     set_phase               ; No...
shift_phase                            ;
       rra     R12                     ; Shift phase inc
       dec     R14                     ; Dec octave count
       jne     shift_phase             ; Repeat until zero...
set_phase                               ;
       rla     R13                     ; Voice * 2
       add     #phase_inc, R13         ; Add phase inc pointer
       mov     R12, 0(R13)             ; Set phase inc
       ret                             ; Return
                                       ;
note_off                                ;
       rla     R13                     ; Voice * 2
       mov     R13, R12                ; Copy
       add     #phase_inc, R12         ; Phase inc pointer
       add     #phase_acc, R13         ; Phase accum pointer
       clr     0(R12)                  ; Clear phase inc
       clr     0(R13)                  ; Clear phase accum
       ret                             ; Return
                                       ;
                                       ;
notes                                   ; MIDI Note  Frequency
       .word      11341                ; 116  G#8   6645.117
       .word      12015                ; 117   A8   7040.039
       .word      12729                ; 118  A#8   7458.398
       .word      13486                ; 119   B8   7901.953
       .word      14288                ; 120   C9   8371.875
       .word      15138                ; 121  C#9   8869.922
       .word      16038                ; 122   D9   9397.266
       .word      16992                ; 123  D#9   9956.250
       .word      18002                ; 124   E9  10548.047
       .word      19073                ; 125   F9  11175.586
       .word      20207                ; 126  F#9  11840.039
       .word      21408                ; 127   G9  12543.750

sine    .byte   128
       .byte   131
       .byte   134
       .byte   137
       .byte   140
       .byte   144
       .byte   147
       .byte   150
       .byte   153
       .byte   156
       .byte   159
       .byte   162
       .byte   165
       .byte   168
       .byte   171
       .byte   174
       .byte   177
       .byte   179
       .byte   182
       .byte   185
       .byte   188
       .byte   191
       .byte   193
       .byte   196
       .byte   199
       .byte   201
       .byte   204
       .byte   206
       .byte   209
       .byte   211
       .byte   213
       .byte   216
       .byte   218
       .byte   220
       .byte   222
       .byte   224
       .byte   226
       .byte   228
       .byte   230
       .byte   232
       .byte   234
       .byte   235
       .byte   237
       .byte   239
       .byte   240
       .byte   241
       .byte   243
       .byte   244
       .byte   245
       .byte   246
       .byte   248
       .byte   249
       .byte   250
       .byte   250
       .byte   251
       .byte   252
       .byte   253
       .byte   253
       .byte   254
       .byte   254
       .byte   254
       .byte   255
       .byte   255
       .byte   255
       .byte   255
       .byte   255
       .byte   255
       .byte   255
       .byte   254
       .byte   254
       .byte   254
       .byte   253
       .byte   253
       .byte   252
       .byte   251
       .byte   250
       .byte   250
       .byte   249
       .byte   248
       .byte   246
       .byte   245
       .byte   244
       .byte   243
       .byte   241
       .byte   240
       .byte   239
       .byte   237
       .byte   235
       .byte   234
       .byte   232
       .byte   230
       .byte   228
       .byte   226
       .byte   224
       .byte   222
       .byte   220
       .byte   218
       .byte   216
       .byte   213
       .byte   211
       .byte   209
       .byte   206
       .byte   204
       .byte   201
       .byte   199
       .byte   196
       .byte   193
       .byte   191
       .byte   188
       .byte   185
       .byte   182
       .byte   179
       .byte   177
       .byte   174
       .byte   171
       .byte   168
       .byte   165
       .byte   162
       .byte   159
       .byte   156
       .byte   153
       .byte   150
       .byte   147
       .byte   144
       .byte   140
       .byte   137
       .byte   134
       .byte   131
       .byte   128
       .byte   125
       .byte   122
       .byte   119
       .byte   116
       .byte   112
       .byte   109
       .byte   106
       .byte   103
       .byte   100
       .byte   97
       .byte   94
       .byte   91
       .byte   88
       .byte   85
       .byte   82
       .byte   79
       .byte   77
       .byte   74
       .byte   71
       .byte   68
       .byte   65
       .byte   63
       .byte   60
       .byte   57
       .byte   55
       .byte   52
       .byte   50
       .byte   47
       .byte   45
       .byte   43
       .byte   40
       .byte   38
       .byte   36
       .byte   34
       .byte   32
       .byte   30
       .byte   28
       .byte   26
       .byte   24
       .byte   22
       .byte   21
       .byte   19
       .byte   17
       .byte   16
       .byte   15
       .byte   13
       .byte   12
       .byte   11
       .byte   10
       .byte   8
       .byte   7
       .byte   6
       .byte   6
       .byte   5
       .byte   4
       .byte   3
       .byte   3
       .byte   2
       .byte   2
       .byte   2
       .byte   1
       .byte   1
       .byte   1
       .byte   1
       .byte   1
       .byte   1
       .byte   1
       .byte   2
       .byte   2
       .byte   2
       .byte   3
       .byte   3
       .byte   4
       .byte   5
       .byte   6
       .byte   6
       .byte   7
       .byte   8
       .byte   10
       .byte   11
       .byte   12
       .byte   13
       .byte   15
       .byte   16
       .byte   17
       .byte   19
       .byte   21
       .byte   22
       .byte   24
       .byte   26
       .byte   28
       .byte   30
       .byte   32
       .byte   34
       .byte   36
       .byte   38
       .byte   40
       .byte   43
       .byte   45
       .byte   47
       .byte   50
       .byte   52
       .byte   55
       .byte   57
       .byte   60
       .byte   63
       .byte   65
       .byte   68
       .byte   71
       .byte   74
       .byte   77
       .byte   79
       .byte   82
       .byte   85
       .byte   88
       .byte   91
       .byte   94
       .byte   97
       .byte   100
       .byte   103
       .byte   106
       .byte   109
       .byte   112
       .byte   116
       .byte   119
       .byte   122
       .byte   125

                                   ; Interrupt Vectors
       .sect   ".int08"            ; TACCR1 CCIFG, TAIFG
       .short  synth_isr           ;
                                   ;
       .end                        ;
