.section .data
.section .text
.global potprogram

# void potprogram(unsigned char *s1, unsigned char *s2, char *r);

potprogram:                # naziv potprograma
    pushl %ebp             # početak potprograma
    movl  %esp,     %ebp
    pushl %ebx

    movl $0,        %ebx     # broj pluseva
    movl $0,        %ecx     # broj minusa

init_first_string:
    movl 12(%ebp),  %esi    # početak stringa
    movl 12(%ebp),  %edi    # kraj stringa
    addl $20,       %edi    # kraj stringa

prebroj_S1:
    cmpl %edi, %esi # da li smo stigli do kraja stringa
    jne broj_pluseve
    je init_second_string

broj_pluseve:
    movb (%esi),    %dl # sačuvaj trenutni element u manji registar
    cmpb $'+',      %dl # da li je to znak + ?
    je pronadjenPlus
    jmp uvecaj_adresu_S1

pronadjenPlus:
    incl %ebx

uvecaj_adresu_S1:
    addl $4, %esi
    jmp prebroj_S1

# drugi string
init_second_string:
    movl 16(%ebp),  %esi    # početak stringa
    movl 16(%ebp),  %edi    # kraj stringa
    addl $20,       %edi    # kraj stringa

prebroj_S2:
    cmpl %edi, %esi         # da li smo stigli do kraja stringa
    jne broj_minuse
    je uporedi_broj_pluseva_minusa

broj_minuse:
    movb (%esi),    %dl     # sačuvaj trenutni element u manji registar
    cmpb $'-',      %dl     # da li je to znak - ?
    je pronadjenMinus
    jmp uvecaj_adresu_S2

pronadjenMinus:
    incl %ecx

uvecaj_adresu_S2:
    addl $4, %esi
    jmp prebroj_S2

uporedi_broj_pluseva_minusa:
    cmpl %ecx, %ebx
    jb manjeMinusa
    ja manjePluseva
    je istiBroj

manjeMinusa:
    movl $1, %eax
    jmp kraj

manjePluseva:
    movl $2, %eax
    jmp kraj

istiBroj:
    movl $3, %eax

kraj:
    popl %ebx
    movl %ebp, %esp
    popl %ebp
    ret
