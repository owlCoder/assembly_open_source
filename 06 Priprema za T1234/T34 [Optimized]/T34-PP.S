.section .data
.section .text
.global potprogram

# void potprogram(unsigned char *s1, unsigned char *s2, char *r);

potprogram:                # naziv potprograma
    pushl %ebp             # početak potprograma
    movl  %esp,     %ebp

    # registri koji se koriste se šalju na stek
    pushl %ebx
    pushl %esi
    pushl %edi

    movl $0,        %ebx     # broj pluseva
    movl $0,        %ecx     # broj minusa

    # pozivanje potprograma za prebrojavanje znakova
    pushl $'+'
    pushl 8(%ebp)
    call prebroji
    movl %eax,    %ebx
    addl $8,      %esp # oslobadjanje steka

    pushl $'-'
    pushl 12(%ebp)
    call prebroji
    movl %eax,    %ecx
    addl $8,      %esp # oslobadjanje steka

uporedi_broj_pluseva_minusa:
    cmpl %ecx,    %ebx
    ja manjeMinusa
    jb manjePluseva
    je istiBroj

manjeMinusa:
    movl $1,      %edx
    jmp kraj

manjePluseva:
    movl $2,      %edx
    jmp kraj

istiBroj:
    movl $3, %edx

kraj:
    movl 16(%ebp),  %esi
    movl %edx,     (%esi)
    # restauracija registara
    popl %edi
    popl %esi
    popl %ebx

    movl %ebp, %esp
    popl %ebp
    ret
