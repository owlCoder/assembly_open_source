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

init_first_string:
    movl 8(%ebp),  %esi    # početak stringa
    movl 8(%ebp),  %edi    # kraj stringa
    addl $20,      %edi    # kraj stringa

prebroj_S1:
    cmpl %esi, %edi        # da li smo stigli do kraja stringa
    jne broj_pluseve
    je init_second_string

broj_pluseve:
    movb (%esi),   %dl     # sačuvaj trenutni element u manji registar
    cmpb $'+',     %dl     # da li je to znak + ?
    je pronadjenPlus
    jmp uvecaj_adresu_S1

pronadjenPlus:
    addl $1,  %ebx         # broj pluseva uvecaj za 1

uvecaj_adresu_S1:
    addl $1, %esi
    jmp prebroj_S1

# drugi string
init_second_string:
    movl 12(%ebp),  %esi    # početak stringa
    movl 12(%ebp),  %edi    # kraj stringa
    addl $20,       %edi    # kraj stringa

prebroj_S2:
    cmpl %esi, %edi         # da li smo stigli do kraja stringa
    jne broj_minuse
    je uporedi_broj_pluseva_minusa

broj_minuse:
    movb (%esi),    %dl     # sačuvaj trenutni element u manji registar
    cmpb  $'-',     %dl     # da li je to znak - ?
    je pronadjenMinus
    jmp uvecaj_adresu_S2

pronadjenMinus:
    addl $1,  %ecx         # broj minusa uvecaj za 1

uvecaj_adresu_S2:
    addl $1, %esi
    jmp prebroj_S2

uporedi_broj_pluseva_minusa:
    cmpl %ecx, %ebx
    ja manjeMinusa
    jb manjePluseva
    je istiBroj

manjeMinusa:
    movl $1, %edx
    jmp kraj

manjePluseva:
    movl $2, %edx
    jmp kraj

istiBroj:
    movl $3, %edx

kraj:
    movl 16(%ebp), %esi
    movl %edx,     (%esi)
    # restauracija registara
    popl %edi
    popl %esi
    popl %ebx

    movl %ebp, %esp
    popl %ebp
    ret
