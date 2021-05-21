.section .text
.globl oduzimaj
.globl srednjaVrednost
.globl konvertuj

# int oduzimaj(int* brojevi, unsigned int broj_elemenata, int oduzimac);
oduzimaj:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %eax
    movl $0, %ecx
    movl 16(%ebp), %edx
oduzimaj_petlja:
    cmpl 12(%ebp), %ecx
    je oduzimaj_kraj
    cmpl (%eax, %ecx, 4), %edx
    jl oduzimac_manji
    xchgl (%eax, %ecx, 4), %edx
oduzimac_manji:
    subl %edx, (%eax, %ecx, 4)
    movl 16(%ebp), %edx
    incl %ecx
    jmp oduzimaj_petlja

oduzimaj_kraj:
    movl $0, %eax
    movl %ebp, %esp
    popl %ebp
    ret

# int srednjaVrednost(int* brojevi, unsigned int broj_elemenata, unsigned int* greska);
srednjaVrednost:
    pushl %ebp
    movl %esp, %ebp

    cmpl $0, 12(%ebp)
    je srednjaVrednost_greska

    movl 8(%ebp), %edx
    movl $0, %eax
    movl $0, %ecx
srednjaVrednost_petlja:
    cmpl 12(%ebp), %ecx
    je srednjaVrednost_proveri
    addl (%edx, %ecx, 4), %eax
    jo srednjaVrednost_greska
    incl %ecx
    jmp srednjaVrednost_petlja

srednjaVrednost_proveri:
    xorl %edx, %edx
    cmpl $0, %eax
    jge srednjaVrednost_deli
    notl %edx
srednjaVrednost_deli:
    idivl 12(%ebp)
    movl 16(%ebp), %edx
    movl $0, (%edx)
    jmp srednjaVrednost_kraj

srednjaVrednost_greska:
    movl 16(%ebp), %edx
    movl $1, (%edx)

srednjaVrednost_kraj:
    movl %ebp, %esp
    popl %ebp
    ret

# int konvertuj(char* znakovi, unsigned int duzina, int prviBroj, int drugiBroj);
konvertuj:
    pushl %ebp
    movl %esp, %ebp    

    pushl 12(%ebp)
    pushl 8(%ebp)
    pushl $10
    pushl 16(%ebp)
    call itos
    addl $16, %esp

    cmpl $1, %eax               # greska
    je konvertuj_kraj

    movl 8(%ebp), %eax
konvertuj_null:
    cmpb $0, (%eax)
    je konvertuj_dalje
    incl %eax
    incl 8(%ebp)
    decl 12(%ebp)
    jmp konvertuj_null

konvertuj_dalje:
    movb $' ', (%eax)
    incl 8(%ebp)
    decl 12(%ebp)

    pushl 12(%ebp)
    pushl 8(%ebp)
    pushl $10
    pushl 20(%ebp)
    call itos
    addl $16, %esp

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