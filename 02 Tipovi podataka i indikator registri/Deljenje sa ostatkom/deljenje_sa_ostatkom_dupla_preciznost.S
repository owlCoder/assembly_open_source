# Deljenje pomoću oduzimanja dva (ne)označena broja u dvostrukoj preciznosti
.section .data
    prvi:   .quad  0x1238AA
    drugi:  .quad  0x2
    greska: .byte  0x0
.section .text

.global main

main: 
    movl prvi,  %eax    # prvi broj
    movl drugi, %ebx    # drugi broj
    movl $0,    %ecx    # količnik

provera:
    cmpl %eax,  %ebx    # proveri da li je razlika negativna
    jbe podeli          # ako nije podeli

    movl %eax,  %edx    # u suprotnom drugi broj je veći od prvog
                        # pa je to ujedno i ostatak deljenja
    jmp kraj            # kraj programa

podeli:
    subl %ebx,  %eax    # smanji prvi broj za drugi broj
    addl $1,    %ecx    # količnik uvećaj za 1

    sbbl %eax,  %ecx    # oduzmi ako je došlo do pozajmice

    jmp provera         # proveri da li se može deliti dalje

kraj: 
    movl $1, %eax       # flush registrija %eax
    movl $0, %ebx       # flush registrija %ebx
    int $0x80           # sistemski poziv
