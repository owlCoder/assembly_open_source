# Napisati potprogram koji za uneti string, za elemente ciji su indeksi deljivi brojem 3
# pretvara u VELIKO slovo. (Optimizacija: Ako je slovo vec veliko preci na sledeci element u #stringu).
#   String unosi korisnik.
#  Primer interakcije sa programom:
#	Unesite string: Samo jE obican program dobar program.
#	Nakon konverzije: SamO jE oBicAn ProGraM dObaR pRogRam.
#   Dobijena vrednost nakon izvrsavanja programa naredbom echo $? je broj promenjenih 
# karaktera. U ovom primeru je to: 10

.section .data
	poruka1: .ascii "Unesite string: \0"
	poruka1_duzina = . - poruka1

	poruka2: .ascii "Nakon konverzije: \0"
	poruka2_duzina = . - poruka2

	maks = 50
	unos: .fill maks, 1, 42

	R: .long 0
	uneto: .long 0
.section .text
.global main

main:
	movl $4, %eax
	movl $1, %ebx
	movl $poruka1, %ecx
	movl $poruka1_duzina, %edx
	int $0x80

	movl $3, %eax
	movl $0, %ebx
	movl $unos, %ecx
	movl $maks, %edx
	int $0x80

	movl %eax, uneto # samo ako ispisujes string na ekran ako je sve u ddd
					 # nije pod obavezno!

	pushl $unos
	call pretvori
	addl $4     , %esp

	movl %eax, R

	
	# ispis nakon modifikacije stringa
	movl $4, %eax
	movl $1, %ebx
	movl $poruka2, %ecx
	movl $poruka2_duzina, %edx
	int $0x80

	movl $4, %eax
	movl $1, %ebx
	movl $unos, %ecx
	movl uneto, %edx
	int $0x80

kraj:
	movl $1, %eax
	movl R, %ebx
	int $0x80
