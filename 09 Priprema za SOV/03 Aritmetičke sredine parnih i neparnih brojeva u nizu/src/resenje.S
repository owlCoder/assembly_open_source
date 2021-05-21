.section .data
poruka1: .ascii "Unesite niz: \0"
por1_len = . - poruka1
poruka2: .ascii "Rezultat greske je: \0"
por2_len = . - poruka2
poruka3: .ascii "Prekoracenje! \n\0"
por3_len = . - poruka3
poruka4: .ascii "Neodgovarajuci operand! \n\0"
por4_len = . - poruka4
poruka5: .ascii "Veca je aritmeticka sredina parnih brojeva! \n\0"
por5_len = . - poruka5
poruka6: .ascii "Veca je aritmeticka sredina neparnih brojeva! \n\0"
por6_len = . - poruka6
poruka7: .ascii "Iste su aritmeticke sredine parnih i neparnih brojeva! \n\0"
por7_len = . - poruka7
imemax = 50
ime: .fill imemax,1,0
rezultat: .fill 1,1,0
greska: .long 0
n_parni: .long 0
suma_parni: .long 0
ostatak_parni: .long 0
n_neparni: .long 0
suma_neparni: .long 0
ostatak_neparni: .long 0
baza: .long 10

.section .text
.globl main

str_to_inter:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %edi
    movl $0, %edi       #greška
    xorl %eax, %eax
    xorl %ecx, %ecx
    movl 8(%ebp), %ebx
    cmpb $10, (%ebx)     #prazan string?
    je string_greska2
pocetak_broja:
		xorl %eax, %eax
ispitaj_broj:
    movb (%ebx), %cl
    andb %cl, %cl
    jz kraj_broja
    cmpb $'\n', %cl
    je kraj_broja
    cmpb $' ', %cl
    je kraj_broja
    subb $'0', %cl
    js string_greska2      #znak manji od '0'?
ispitaj_cifru:
    cmpl $10, %ecx
    jae string_greska2     #cifra >= baza?
    mull baza
    jc string_greska1
    addl %ecx, %eax
    jc string_greska1
    incl %ebx
    jmp ispitaj_broj
kraj_broja:
    cmpb $0, %cl
    je string_kraj
    incl %ebx
    testl $1, %eax
    jz uvecaj_parni
    addl %eax, suma_neparni
    incl n_neparni
    jmp pocetak_broja
uvecaj_parni:
    addl %eax, suma_parni
    incl n_parni
    jmp pocetak_broja
string_greska2:
    incl %edi
string_greska1:
    incl %edi
    jmp string_zavrsetak
string_kraj:
    movl suma_parni, %eax
    xorl %edx, %edx
    andl %eax, %eax
    jz string_kraj2
    divl n_parni
    movl %eax, suma_parni
    movl %edx, ostatak_parni
string_kraj2:
    movl suma_neparni, %eax
    xorl %edx, %edx
    andl %eax, %eax
    jz string_zavrsetak
    divl n_neparni
    movl %eax, suma_neparni
    movl %edx, ostatak_neparni
string_zavrsetak:
    movl %edi, %eax
    popl %edi
    popl %ebx
    movl %ebp, %esp
    popl %ebp
    ret
   

main:
    movl $4, %eax
    movl $1, %ebx
    movl $poruka1, %ecx
    movl $por1_len, %edx
    int $0x80

    movl $3, %eax
    movl $0, %ebx
    movl $ime, %ecx
    movl $imemax, %edx
    int $0x80

    pushl $greska
    pushl $ime
    call str_to_inter
    addl $8, %esp
		
		movl $rezultat, %edi
		addb $'0', %al
		movb %al, (%edi)
		
    cmpb $'1', %al
    je prekoracenje
    cmpb $'2', %al
    je nepravilni_operand
    
    movl suma_parni, %eax
    movl suma_neparni, %ebx
    movl ostatak_parni, %ecx
    movl ostatak_neparni, %edx
    
    
    cmpl %eax, %ebx
    jb ar_parnih 
    ja ar_neparnih
    cmpl %ecx, %edx
    jb ar_parnih
    ja ar_neparnih
    jmp ar_iste
ar_parnih:
		movl $4, %eax
    movl $1, %ebx
    movl $poruka5, %ecx
    movl $por5_len, %edx
    int $0x80
		jmp kraj
ar_neparnih:
		movl $4, %eax
    movl $1, %ebx
    movl $poruka6, %ecx
    movl $por6_len, %edx
    int $0x80
		jmp kraj
ar_iste:
		movl $4, %eax
    movl $1, %ebx
    movl $poruka7, %ecx
    movl $por7_len, %edx
    int $0x80   
kraj:
		movl $4, %eax
    movl $1, %ebx
    movl $poruka2, %ecx
    movl $por2_len, %edx
    int $0x80
		movl $4, %eax
    movl $1, %ebx
    movl $rezultat, %ecx
    movl $1, %edx
    int $0x80

    movl $1, %eax
    movl $0, %ebx
    int $0x80

nepravilni_operand:
    movl $4, %eax
    movl $1, %ebx
    movl $poruka4, %ecx
    movl $por4_len, %edx
    int $0x80
    jmp kraj

prekoracenje:
    movl $4, %eax
    movl $1, %ebx
    movl $poruka3, %ecx
    movl $por3_len, %edx
    int $0x80
    jmp kraj
