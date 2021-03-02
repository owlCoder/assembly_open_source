# Množenje pomoću sabiranja
.section .data
.section .text
.globl main

main: 
    movl $1,  %eax      # prvi broj
    movl $27, %ebx      # drugi broj
    movl $0,  %ecx      # količnik
    movl $0,  %edx      # ostatak
    jmp provera;        # izvrši petlju (mislim da radi i bez ovoga)

provera:
    cmpl %eax, %ebx     # proveri da li je razlika negativna
    jbe podeli          # ako nije podeli

    movl %eax, %edx     # u suprotnom drugi broj je veći od prvog
                        # pa je to ujedno i ostatak deljenja
    jmp kraj            # kraj programa

podeli:
    subl %ebx, %eax     # smanji prvi broj za drugi broj
    addl $1, %ecx       # količnik uvećaj za 1

    jmp provera         # proveri da li se može deliti dalje

kraj: 
    movl $1, %eax       # flush registrija %eax
    movl $0, %ebx       # flush registrija %ebx
    int $0x80           # sistemski poziv
