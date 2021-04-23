# PR55-2020 Jovanovic Danijel

# Napisati asemblerski program koji na ekran ispisuje sadržaj stringa poruka1, zatim od korisnika traži da
# unese string maksimalne dužine od 40 znakova. Nakon toga, ispisuje na ekran sadržaj stringa poruka2 i
# od korisnika traži da unese drugi string maksimalne dužine od 40 znakova. Program treba da prebroji
# mala slova u oba stringa i kao izlazni kod programa vrati koliko više malih slova ima u jednom stringu
# u odnosu na drugi. Takođe, program treba da ispiše jedan od zadatih stringova ispis1, ispis2 ili ispis3 u
# zavisnosti od odnosa broja malih slova u unetim stringovima. Program ispisuje string ispis1 ako prvi
# string ima više malih slova u odnosu na drugi, ispisuje string ispis2 ako drugi string ima više malih slova
# od prvog, odnosno ispisuje string ispis3 ako je u oba stringa podjednak broj malih slova.
# Napomene:
# • Uneti stringovi mogu biti prazni, a neće biti duži od maksimalne dozvoljene dužine.
# • Izlazni kod programa je uvek nenegativan broj.

# Primer interakcije:
# Unesite prvi string: Ovo je DEVET MALIH slova
# Unesite drugi string: Ovo je CETIRI
# Ispis: Prvi string ima vise malih slova nego drugi.
# Izlazni kod programa: 5
# Unesite prvi string: Ovo je CETIRI
# Unesite drugi string: Ovo je DEVET MALIH slova
# Ispis: Drugi string ima vise malih slova nego prvi.
# Izlazni kod programa: 5

.section .data
	ispis1: .ascii "Prvi string ima vise malih slova nego drugi.\n\0"
	ispis1_len = . - ispis1

	ispis2: .ascii "Drugi string ima vise malih slova od prvog.\n\0"
	ispis2_len = . - ispis2

	ispis3: .ascii "Oba stringa imaju isti broj malih slova.\n\0"
	ispis3_len = . - ispis3

	maks_in = 41

	unos1: .fill maks_in, 1, 42
	unos2: .fill maks_in, 1, 42

	poruka2: .ascii "Unesite drugi string: \0"
	poruka2_len = . - poruka2

	poruka1: .ascii "Unesite prvi string: \0"
	poruka1_len = . - poruka1	

	razlika:		  .long 0
	povratnaVrednost: .long 0
.section .text
.global main

main:
	# ispis prve poruke
	movl $4, 			   %eax
	movl $1,			   %ebx
	leal poruka1,		   %ecx
	movl $poruka1,   	   %edx
	int  $0x80
	
	# unos prvog stringa
	movl $3,			   %eax
	movl $0, 			   %ebx
	leal unos1,		       %ecx
	movl $maks_in,		   %edx
	int  $0x80

	# ispis druge poruke
	movl $4, 			   %eax
	movl $1,			   %ebx
	leal poruka2,		   %ecx
	movl $poruka2_len,	   %edx
	int  $0x80
	
	# unos drugog stringa
	movl $3,			   %eax
	movl $0, 			   %ebx
	leal unos2,		       %ecx
	movl $maks_in,		   %edx
	int  $0x80

	# unsigned int prebroj(char *s1, char *s2, short int *razlika)
	pushl $razlika
	pushl $unos2
	pushl $unos1
	call modifikuj
	addl $12,			   %esp  				# oslobadjanje steka

	movl %eax,			   povratnaVrednost		# cuvanje povratne vrednosti

staIspisati:
	cmpl $2,			   razlika
	jl ispisiPrvu
	je ispisiDrugu
	jg ispisiTrecu

ispisiPrvu:
	# ispis prve poruke
	movl $4, 			   %eax
	movl $1,			   %ebx
	leal ispis1,		   %ecx
	movl $ispis1_len,	   %edx
	int  $0x80

	jmp kraj

ispisiDrugu:
	# ispis druge poruke
	movl $4, 			   %eax
	movl $1,			   %ebx
	leal ispis2,		   %ecx
	movl $ispis2_len,	   %edx
	int  $0x80

	jmp kraj

ispisiTrecu:
	# ispis prve poruke
	movl $4, 			   %eax
	movl $1,			   %ebx
	leal ispis3,		   %ecx
	movl $ispis3_len,	   %edx
	int  $0x80

	jmp kraj

kraj:
	movl $1, 			   %eax
	movl povratnaVrednost, %ebx	
	int $0x80
