.section .data
	ispis1: .ascii "Unesite string: \0"
	ispis1_len = . - ispis1

	maks_unos = 40
	unos: .fill maks_unos, 1, 42
	pojava: .long 0
.section .text
.global main

main:
	# ispis poruke
	movl $4,		  %eax
	movl $1,		  %ebx
	leal ispis1,	  %ecx
	movl $ispis1_len, %edx
	int  $0x80

	# ucitavanje stringa
	movl $3, 		  %eax
	movl $0,		  %ebx
	leal unos,		  %ecx
	movl $maks_unos,  %edx
	int  $0x80

	movl $0,		  %esi   # pocetak niza
	movl %eax,		  %edi	 # kraj niza	
	
provera:
    cmpl %esi,        %edi   # kraj niza ?
    je kraj

da_li_je_samoglasnik:
	movb unos(, %esi, 1),  %dl

    # mala slova
    cmpb $'a',             %dl
    je pronadjenSamoglasnik

    cmpb $'e',             %dl
    je pronadjenSamoglasnik

    cmpb $'i',             %dl
    je pronadjenSamoglasnik

    cmpb $'o',             %dl
    je pronadjenSamoglasnik

    cmpb $'u',             %dl
    je pronadjenSamoglasnik

    # velika slova
    cmpb $'A',             %dl
    je pronadjenSamoglasnik

    cmpb $'E',             %dl
    je pronadjenSamoglasnik

    cmpb $'I',             %dl
    je pronadjenSamoglasnik

    cmpb $'O',             %dl
    je pronadjenSamoglasnik

    cmpb $'U',             %dl
    je pronadjenSamoglasnik

uvecaj_adresu:
    incl                   %esi
    jmp provera

pronadjenSamoglasnik:
    incl                   pojava
    jmp uvecaj_adresu

kraj:
    movl $1,               %eax
    movl pojava,           %ebx
	int $0x80
