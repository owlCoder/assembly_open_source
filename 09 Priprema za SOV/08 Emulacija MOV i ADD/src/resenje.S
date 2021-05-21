#greske
#greska 1 - pogresna cifra i prazan string pri konverziji 
#           ili broj naredbi nije oktalni (ne pocinje sa '0')
#greska 2 - izlazak van opsega pri konverziji
#greska 3 - izlazak van opsega pri racunanju r1 ili r2
#greska 4 - broj naredbi veci od maksimalnog
#moguce naredbe
#MOV, ADD

.section .data
    poruka1:        .ascii "Unesite broj naredbi: \0"
    poruka2:        .ascii "Unesite naredbe (naredba po liniji):\n\0"
    poruka3:        .ascii "Doslo je do greske u izvrsavanju programa!\n\0"
    poruka4:        .ascii "Vrednost u registru R1 nakon operacija: \0"
    poruka5:        .ascii "Vrednost u registru R2 nakon operacija: \0"

    UNOSDUZINA = 5
    NAREDBADUZINA = 51
    OPERANDDUZINA = 41
    unos1:          .fill UNOSDUZINA, 1, 0
    naredba:        .fill NAREDBADUZINA, 1, 0
    operand:        .fill OPERANDDUZINA, 1, 0
    r1:             .long 0
    r2:             .long 0
    r1_str:         .fill OPERANDDUZINA, 1, 0
    r2_str:         .fill OPERANDDUZINA, 1, 0
    brojnaredbi:    .long 0
    greska:         .long 0

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
2:  movl $4, %eax
    movl $1, %ebx
    movl \string,%ecx
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

#unsigned int str_to_inter(char* str, unsigned int* greska, unsigned int baza)
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
    je s2i_greska1
s2i_cifra:
    movb (%ebx), %cl
    andb %cl, %cl
    jz s2i_znak2
    subb $'0', %cl
    js s2i_greska1      #znak manji od '0'?
    cmpb $10, %cl       #cifra '0'-'9'?
    jl s2i_cifra2
    subb $'A'-'9'-1, %cl
    js s2i_greska1      #znak između '9' i 'A'?
    cmpb $36, %cl       #cifra 'A'-'Z'?
    jl s2i_cifra2
    subb $'a'-'A', %cl  #cifra 'a'-'z'?
    js s2i_greska1      #znak između 'Z' i 'a'?
s2i_cifra2:
    cmpl 16(%ebp), %ecx
    jae s2i_greska1     #cifra >= baza?
    mull 16(%ebp)
    jc s2i_greska2
    addl %ecx, %eax
    jc s2i_greska2
    incl %ebx
    jmp s2i_cifra
s2i_znak2:
    jmp s2i_kraj
s2i_greska3:
    incl %edi
s2i_greska2:
    incl %edi
s2i_greska1:
    incl %edi
s2i_kraj:
    movl 12(%ebp), %ecx
    movl %edi, (%ecx)
    popl %edi
    popl %ebx
    movl %ebp, %esp
    popl %ebp
    ret

#unsigned int inter_to_str(int broj, char* str, unsigned int duz, unsigned int baza);
inter_to_str:
    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp
    pushl %ebx
    pushl %esi
    pushl %edi
    movl 8(%ebp), %eax      #broj
    movl 12(%ebp), %edi     #str
    movl 20(%ebp), %ebx     #baza
    movl $0, -4(%ebp)       #greška
i2s_cifra:
    decl 16(%ebp)           #provera preostalog mesta
    cmpl $1, 16(%ebp)       #neophodan je i 1 bajt za NULL
    jl i2s_greska
    xorl %edx, %edx
    divl %ebx
    cmpb $10, %dl
    jb i2s_manje10
    addb $'A'-'9'-1, %dl    #razlika slova i cifara
i2s_manje10:
    addb $'0', %dl
    movb %dl, (%edi)
    incl %edi
    andl %eax, %eax
    jnz i2s_cifra
    movb $10, (%edi)
    movb $0, 1(%edi)
    decl %edi
    movl 12(%ebp), %esi
i2s_obrni:
    cmpl %edi, %esi
    jae i2s_kraj
    movb (%esi), %ah
    movb (%edi), %al
    movb %al, (%esi)
    movb %ah, (%edi)
    decl %edi
    incl %esi
    jmp i2s_obrni
i2s_greska:
    movl $4, -4(%ebp)
i2s_kraj:
    movl -4(%ebp), %eax
    popl %edi
    popl %esi
    popl %ebx
    movl %ebp, %esp
    popl %ebp
    ret

main:
    print_str $poruka1
    get_str $unos1 $UNOSDUZINA

    leal unos1, %esi
    cmpb $'0', (%esi)
    jne nije_oktalni

    # konverzija broja naredbi iz znakonvnog u interni oblik (oktalni brojni sistem)
    pushl $8
    pushl $greska
    pushl $unos1+1               #oktalni broj pocinje karakterom '0'
    call str_to_inter
    addl $12, %esp
    movl %eax, brojnaredbi       #pv je konvertovani broj
    cmpl $0, greska              #desila se greska pri konverziji?
    jne gkraj
    cmpl $012, brojnaredbi       #broj naredbi veci od maksimalnog?
    ja maxnaredbi_prekoracenje

    print_str $poruka2
unos_naredbi:
    cmpl $0, brojnaredbi
    je ispis_vrednosti_registara
    decl brojnaredbi
    get_str $naredba $NAREDBADUZINA

    #izdvajanje izvornog operanda iz naredbe
    leal naredba+5, %esi        #len(mnemonik)=3+len(' ')=1+len('$')=1 = 5
    leal operand, %edi          #adresa operanda
izdvoj_operand:
    movb (%esi), %bl
    cmpb $',', %bl
    je izdvoj_registar
    movb %bl, (%edi)
    incl %edi
    incl %esi
    jmp izdvoj_operand
izdvoj_registar:
    movb $0, (%edi)
    addl $3, %esi               #preskace ",%R"
    cmpb $'1', (%esi)
    jne r2_adresa
r1_adresa:
    leal r1, %edi               #adresa registra nad kojim se vrsi operacija -> edi
    jmp provera_mnenonika
r2_adresa:
    leal r2, %edi
provera_mnenonika:
    pushl $10                   #kovnerzija operanda u interni oblik
    pushl $greska
    pushl $operand
    call str_to_inter
    addl $12, %esp              #operand -> eax
    cmpl $0, greska
    jne gkraj
    leal naredba, %esi
provera_mov:
    #zabeleziti adresu registra r1 u neki registar
    cmpb $'M', (%esi)
    jne provera_add
    movl %eax, (%edi)
    jmp unos_naredbi
provera_add:
    cmpb $'A', (%esi)
    jne unos_naredbi
    addl %eax, (%edi)
    jc r_prekoracenje
    jmp unos_naredbi
ispis_vrednosti_registara:
    # r1 konverzija
    pushl $10
    pushl $OPERANDDUZINA
    pushl $r1_str
    pushl r1
    call inter_to_str
    addl $16, %esp
    movl %eax, greska
    cmpl $0, greska             #desila se greska?
    jne gkraj
    print_str $poruka4
    print_str $r1_str

    # r2 konverzija
    pushl $10
    pushl $OPERANDDUZINA
    pushl $r2_str
    pushl r2
    call inter_to_str
    addl $16, %esp
    movl %eax, greska
    cmpl $0, greska             #desila se greska
    jne gkraj
    print_str $poruka5
    print_str $r2_str
    jmp kraj
nije_oktalni:
    movl $1, greska
    jmp gkraj
r_prekoracenje:
    movl $3, greska
    jmp gkraj
maxnaredbi_prekoracenje:
    movl $4, greska
gkraj:
    print_str $poruka3
kraj:
    movl $1, %eax
    movl greska, %ebx
    int $0x80
