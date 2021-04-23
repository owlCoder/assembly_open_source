# PR55-2020 Jovanovic Danijel
.section .data
	prompt1: .ascii "Unesite string: \0"
	p1_l = . - prompt1

	prompt2: .ascii "Unesite znake: \0"
	p2_l = . - prompt2

	prompt3: .ascii "Modifikovani string: \0"
	p3_l = . - prompt3

	maks_in = 50 + 1

	unos1: .fill maks_in, 1, 42
	unos2: .fill maks_in, 1, 42

	unetoZnakova_u1: .long 0
	unetoZnakova_u2: .long 0

	povratnaVrednost: .long 0
.section .text
.global main

main:
	# ispis prve poruke
	movl $4, 			   %eax
	movl $1,			   %ebx
	leal prompt1,		   %ecx
	movl $p1_l,			   %edx
	int  $0x80
	
	# unos prvog stringa
	movl $3,			   %eax
	movl $0, 			   %ebx
	leal unos1,		       %ecx
	movl $maks_in,		   %edx
	int  $0x80

	movl %eax, 			   unetoZnakova_u1 		# optimizacija ispisa

	# ispis druge poruke
	movl $4, 			   %eax
	movl $1,			   %ebx
	leal prompt2,		   %ecx
	movl $p2_l,			   %edx
	int  $0x80
	
	# unos drugog stringa
	movl $3,			   %eax
	movl $0, 			   %ebx
	leal unos2,		       %ecx
	movl $maks_in,		   %edx
	int  $0x80

	movl %eax, 			   unetoZnakova_u2 		# optimizacija ispisa

	# unsigned int modifikuj(char *string, char *znakovi)
	pushl $unos2
	pushl $unos1
	call modifikuj
	addl $8,			  %esp  				# oslobadjanje steka

	movl %eax,			   povratnaVrednost		# cuvanje povratne vrednosti

	# ispis nakon modifikacije
	# ispis trece poruke
	movl $4, 			   %eax
	movl $1,			   %ebx
	leal prompt3,		   %ecx
	movl $p3_l,			   %edx
	int  $0x80
	
	# unos prvog (izmenjenog) stringa
	movl $4,			   %eax
	movl $1, 			   %ebx
	leal unos1,		       %ecx
	movl unetoZnakova_u1,  %edx
	int  $0x80

kraj:
	movl $1, 			   %eax
	movl povratnaVrednost, %ebx	
	int $0x80
