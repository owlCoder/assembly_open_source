.section .text
.globl zameni
.globl mnoziSumiraj
.globl konvertuj

# unsigned int zameni(char* znakovi, int* brojevi);
zameni:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx

    
    movl 8(%ebp), %ecx
    movl $0, %eax
    movl 12(%ebp), %edx
zameni_petlja:
    cmpb $0, (%ecx)
    je zameni_kraj

    cmpb $'A', (%ecx)
    jb zameni_dalje
    cmpb $'Z', (%ecx)
    ja zameni_malo
    xorl %ebx, %ebx
    movb (%ecx), %bl
    subl $80, %ebx
    movl %ebx, (%edx, %eax, 4)
    incl %eax
    jmp zameni_dalje

zameni_malo:
    cmpb $'a', (%ecx)
    jb zameni_dalje
    cmpb $'z', (%ecx)
    ja zameni_dalje
    xorl %ebx, %ebx
    movb (%ecx), %bl
    subl $112, %ebx
    movl %ebx, (%edx, %eax, 4)
    incl %eax

zameni_dalje:
    incl %ecx
    jmp zameni_petlja

zameni_kraj:
    popl %ebx
    movl %ebp, %esp
    popl %ebp
    ret

# int mnoziSumiraj(int* brojevi, unsigned int broj_elemenata, int* greska);
mnoziSumiraj:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %esi
    pushl %edi

    movl 16(%ebp), %edx
    movl $0, (%edx)

    movl 8(%ebp), %ecx
    movl $0, %ebx
    movl $0, %esi
mnoziSumiraj_petlja:
    cmpl 12(%ebp), %ebx
    je mnoziSumiraj_kraj

    testl $1, %ebx
    jnz mnoziSumiraj_neparan
    movl $10, %edi
    movl (%ecx, %ebx, 4), %eax
    imull %edi
    jo mnoziSumiraj_greska
    addl %eax, %esi
    jo mnoziSumiraj_greska
    jmp mnoziSumiraj_dalje
mnoziSumiraj_neparan:
    movl $-5, %edi
    xorl %edx, %edx
    movl (%ecx, %ebx, 4), %eax
    cmpl $0, %eax
    jge mnoziSumiraj_deli
    notl %edx
mnoziSumiraj_deli:
    idiv %edi
    addl %eax, %esi
    jo mnoziSumiraj_greska
mnoziSumiraj_dalje:
    incl %ebx
    jmp mnoziSumiraj_petlja

mnoziSumiraj_greska:
    movl 16(%ebp), %edx
    movl $1, (%edx)

mnoziSumiraj_kraj:
    movl %esi, %eax
    popl %edi
    popl %esi
    popl %ebx
    movl %ebp, %esp
    popl %ebp
    ret

# int konvertuj(char* znakovi, unsigned int duzina, int broj);
konvertuj:
    pushl %ebp
    movl %esp, %ebp

    movl $1, %eax
    cmpl $4, 12(%ebp)
    jb konvertuj_kraj

    movl 8(%ebp), %eax
    movb $'0', (%eax)
    movb $'b', 1(%eax)
    addl $2, 8(%ebp)
    subl $2, 12(%ebp)

    pushl 12(%ebp)
    pushl 8(%ebp)
    pushl $2
    pushl 16(%ebp)
    call itos
    addl $16, %esp

    cmpl $1, %eax               # greska
    je konvertuj_kraj
    
    movl 8(%ebp), %ebx
    cmpb $'-', (%ebx)
    jne konvertuj_kraj
    movb $'-', -2(%ebx)
    movb $'0', -1(%ebx)
    movb $'b', (%ebx)
    
konvertuj_kraj:
    movl %ebp, %esp
    popl %ebp
    ret



# pomocna
# int itos(int number, unsigned int base, char* buffer, unsigned int length);
itos:
    pushl %ebp
    movl %esp, %ebp
    movl 8(%ebp), %eax
    movl 16(%ebp), %ecx

    cmpl $2, 20(%ebp)
    jb greska

    cmpl $0, %eax
    jg konverzija

    movb $'-', (%ecx)
    negl %eax
    incl %ecx
    incl 16(%ebp)
    decl 20(%ebp)
    cmpl $2, 20(%ebp)
    jb greska

konverzija:
    cmpl $1, 20(%ebp)
    je greska
    movl $0, %edx
    divl 12(%ebp)
    addb $'0', %dl
    movb %dl, (%ecx)
    incl %ecx
    decl 20(%ebp)
    testl %eax, %eax
    jnz konverzija

    movb $0, (%ecx)
    decl %ecx
    movl 16(%ebp), %edx
obrni:
    cmpl %ecx, %edx
    jae bez_greske
    movb (%edx), %al
    xchgb %al, (%ecx)
    xchgb %al, (%edx)
    incl %edx
    decl %ecx
    jmp obrni

greska:
    movl $1, %eax
    jmp kraj
bez_greske:
    movl $0, %eax
kraj:
    movl %ebp, %esp
    popl %ebp
    ret