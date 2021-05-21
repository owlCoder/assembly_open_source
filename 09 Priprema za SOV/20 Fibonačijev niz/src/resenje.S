.section .data
ispis1:     .ascii "Unesite brojeve: \0"
ispis2:     .ascii "Brojevi su fibonacijava sekvenca.\n\0"
ispis3:     .ascii "Brojevi nisu fibonacijava sekvenca.\n\0"
greska1:    .ascii "Greska: pogresna cifra.\n\0"
greska2:    .ascii "Greska: prekoracenje.\n\0"
newlin:     .ascii "\n\0"
UNOSLEN = 101
unos:   .fill UNOSLEN,1,0
lastchar:   .long 0
greska: .long 0
fib1:   .word 1
fib2:   .word 0

.section .text
.globl main

# ispis stringa na koga pokazuje promenljiva/registar
# (prethodno se računa dužina stringa na osnovu \0)
# makro menja indikatore i registre eax, ebx, ecx i edx
.macro print_str string
    movl $4,%eax
    movl $1,%ebx
    movl \string,%ecx
    movl $0,%edx
1:  cmpb $0,(%ecx)
    je 2f
    incl %ecx
    incl %edx
    jmp 1b
2:  movl \string,%ecx
    int $0x80
.endm

# unos stringa na koga pokazuje promenljiva/registar
# umesto entera, na kraj se stavlja NULL
# makro menja indikatore i registre eax, ebx, ecx i edx
.macro get_str string, length
    movl $3,%eax
    movl $0,%ebx
    movl \string,%ecx
    movl \length,%edx
    int $0x80
    movb $0, -1(%ecx, %eax, 1)
.endm

# preskakanje razmaka u stringu na koga pokazuje registar
# makro menja indikatore i vrednost registra koji je prosleđen
.macro skip_space reg
1:  cmpb $0,(\reg)
    je 3f
    cmpb $' ',(\reg)
    je 2f
    jne 3f
2:
    incl \reg
    jmp 1b
3:
.endm

#int str_to_inter(char* str, unsigned int* greska, unsigned int baza, char* last)
str_to_inter:
    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp
    pushl %ebx
    pushl %edi
    movl $1, -4(%ebp)   #negacija
    movl $0, %edi       #greška
    cmpl $2, 16(%ebp)   #provera validnosti baze
    jl s2i_greska3
    cmpl $36, 16(%ebp)
    jg s2i_greska3
    xorl %eax, %eax
    xorl %ecx, %ecx
    movl 8(%ebp), %ebx
    cmpb $0, (%ebx)     #prazan string?
    je s2i_greska2
    cmpb $'0', (%ebx)   #hex broj?
    jne s2i_cifra
    cmpb $'x', 1(%ebx)   #hex broj?
    je s2i_hex
    cmpb $'X', 1(%ebx)   #hex broj?
    jne s2i_cifra
s2i_hex:
    movl $16, 16(%ebp)  # jeste hex
    addl $2, %ebx
#    cmpb $'+', (%ebx)   #predznak?
#    je s2i_znak1
#    cmpb $'-', (%ebx)   #predznak?
#    jne s2i_cifra
#    negl -4(%ebp)
#s2i_znak1:
#    incl %ebx           #preskoči predznak
s2i_cifra:
    movb (%ebx), %cl
    andb %cl, %cl
    jz s2i_znak2
    cmpb $' ', %cl
    je s2i_znak2
    subb $'0', %cl
    js s2i_greska2      #znak manji od '0'?
    cmpb $10, %cl       #cifra '0'-'9'?
    jl s2i_cifra2
    subb $'A'-'9'-1, %cl
    js s2i_greska2      #znak između '9' i 'A'?
    cmpb $36, %cl       #cifra 'A'-'Z'?
    jl s2i_cifra2
    subb $'a'-'A', %cl  #cifra 'a'-'z'?
    js s2i_greska2      #znak između 'Z' i 'a'?
s2i_cifra2:
    cmpl 16(%ebp), %ecx
    jae s2i_greska2     #cifra >= baza?
    mull 16(%ebp)
    jc s2i_greska1
    addl %ecx, %eax
    jc s2i_greska1
    incl %ebx
    jmp s2i_cifra
s2i_znak2:
#    andl %eax, %eax
#    js s2i_greska1  #ako je neoznačeni broj veći od 0x7fffffff
#    imull -4(%ebp)
    jmp s2i_kraj
s2i_greska3:    # losa baza
    incl %edi
s2i_greska2:    # pogresna cifra
    incl %edi
s2i_greska1:    # prekoracenje
    incl %edi
s2i_kraj:
    movl 20(%ebp), %ecx
    movl %ebx, (%ecx)
    movl 12(%ebp), %ecx
    movl %edi, (%ecx)
    popl %edi
    popl %ebx
    movl %ebp, %esp
    popl %ebp
    ret

main:
    print_str $ispis1
    get_str $unos, $UNOSLEN
    movl $unos, %esi
#int str_to_inter(char* str, unsigned int* greska, unsigned int baza, char* last)
petlja:
    pushl $lastchar
    pushl $8
    pushl $greska
    pushl %esi
    call str_to_inter
    addl $16, %esp
    cmpl $1, greska
    je gr_prekoracenje
    cmpl $2, greska
    je gr_cifra
    cmpl $0xFFFF, %eax
    ja gr_prekoracenje
    cmpw %ax, fib1
    jne izlaz_nije
    movw %ax, %cx
    addw fib2, %ax
    movw %cx, fib2
    movw %ax, fib1
    movl lastchar, %esi
    skip_space %esi
    cmpb $0,(%esi)
    je izlaz_jeste
    jmp petlja

izlaz_jeste:
    print_str $ispis2
    movl $0, %ebx
    jmp kraj

izlaz_nije:
    print_str $ispis3
    movl $0, %ebx
    jmp kraj

gr_cifra:
    print_str $greska1
    movl $1, %ebx
    jmp kraj

gr_prekoracenje:
    print_str $greska2
    movl $1, %ebx

kraj:
    movl $1, %eax
    int $0x80

