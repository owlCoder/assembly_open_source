.section .data
ispis1:     .ascii "Unesite do 10 dekadnih brojeva (niz1): \0"
ispis2:     .ascii "Unesite do 10 dekadnih brojeva (niz2): \0"
ispis3:     .ascii "Transformisan drugi niz: \0"
greska1:    .ascii "Greska1 \0"
greska2:    .ascii "Greska2\n\0"
newlin:     .ascii "\n\0"
UNOSLEN = 151
unos:   .fill UNOSLEN,1,0
lastchar:   .long 0
niz1:    .fill 10,4,0
niz2:    .fill 10,4,0
nizlen1: .long 0
nizlen2: .long 0
greska: .long 0
brojs:  .fill 32,1,0
konstanta_deljenja: 	.long 5

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
    jmp s2i_kraj
s2i_greska3:
    incl %edi
s2i_greska2:
    incl %edi
s2i_greska1:
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
    movb $' ',(%edi)
    incl %edi
    incl 12(%ebp)   #pomeri pokazivač, da se ne bi obrtao razmak
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
    #movb $10, (%edi)
    movb $0, (%edi)
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
    incl -4(%ebp)
i2s_kraj:
    movl -4(%ebp), %eax
    popl %edi
    popl %esi
    popl %ebx
    movl %ebp, %esp
    popl %ebp
    ret

main:

###################################### unosenje i konverzija prvog niza
    print_str $ispis1
    get_str $unos, $UNOSLEN
	
	movl $unos, %esi
	cmpb $0,(%esi)
    je greska1_lab
sledeci_broj1:
	skip_space %esi
    cmpb $0,(%esi)
    je konv_drugi_broj
	pushl $lastchar
    pushl $10
    pushl $greska
    pushl %esi
    call str_to_inter
	addl $16, %esp
    cmpl $0, greska
    jne greska1_lab
	movl nizlen1, %ecx
    movl %eax,niz1(,%ecx,4)
    incl nizlen1
    movl lastchar, %esi
    jmp sledeci_broj1

###################################### unosenje i konverzija drugog niza
konv_drugi_broj:
	movl $0, lastchar
	print_str $ispis2
    get_str $unos, $UNOSLEN

	movl $unos, %esi
	cmpb $0,(%esi)
    je greska1_lab
sledeci_broj2:
	skip_space %esi
    cmpb $0,(%esi)
    je dalje
	pushl $lastchar
    pushl $10
    pushl $greska
    pushl %esi
    call str_to_inter
	addl $16, %esp
    cmpl $0, greska
    jne greska1_lab
	movl nizlen2, %ecx
	movl %eax,niz2(,%ecx,4)
    incl nizlen2
    movl lastchar, %esi
    jmp sledeci_broj2

dalje:

	# proveravam da li elementi prvog niza pripadaju [0,20]
	movl $0, %esi
provera_elemenata:
	cmpl $0, niz1(,%esi,4)
	jb greska2_lab
	cmpl $20, niz1(,%esi,4)
	ja greska2_lab

	incl %esi
	cmpl nizlen1, %esi
	jb provera_elemenata
	
	# prolazi kroz svaki element niza i vrsi transformacije drugog elementa
	movl $0, %esi
transform:
	movl niz1(,%esi,4), %eax
	xorl %edi, %edi
	divl konstanta_deljenja		# u edx se nalazi broj keceva
	xorl %ebx, %ebx				# kecevi

ubaci_keceve:
	andl %edx, %edx
	jz shiftuj_keceve
	shll $1, %ebx
	orl $1, %ebx	

	decl %edx
	jmp ubaci_keceve

shiftuj_keceve:
	movl niz1(,	%esi,4), %ecx
	shll %cl, %ebx				# u ebx se nalai maska 
	orl %ebx, niz2(,%esi,4)
	
	incl %esi
	cmpl nizlen2, %esi
	jb transform
	
	# kad dodje ovde ispise elemente i to je to
    print_str $ispis3
    xorl %esi, %esi
ispiselem:
    pushl $10
    pushl $32
    pushl $brojs
    pushl niz2(,%esi,4)
    call inter_to_str
    addl $16, %esp
    print_str $brojs
    incl %esi
    cmpl nizlen1, %esi
    jb ispiselem
    print_str $newlin
    movl $0, %ebx
    jmp kraj

greska1_lab:
	print_str $greska1
    movl $1, %ebx
	jmp kraj
greska2_lab:
	print_str $greska2
    movl $2, %ebx

kraj:
    movl $1, %eax
    int $0x80
