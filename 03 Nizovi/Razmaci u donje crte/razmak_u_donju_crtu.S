# Napisati program koji koji u unetom stringu menja svaki razmak sa donjom crtom.
#  Npr: Unesite string: Asembler je  kul!
#       Posle zamene: Asembler_je__kul!

# prepraviti da prebroji koliko ima razmaka

.section .data
	poruka1: .ascii "Unesite string: \0"
	poruka1_duzina = . - poruka1

	poruka2: .ascii "Posle zamene: \0"
	poruka2_duzina = . - poruka2

	unos_max = 20
	unos: .fill unos_max, 1, 42
	ucitanoZnakova: .long 0
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
	movl $unos_max, %edx
	int $0x80

	movl %eax, ucitanoZnakova

start:
	movl $0, %esi
	movl ucitanoZnakova, %edi

provera:
	cmpl %esi, %edi 	# da li smo stigli do kraja niza
	je ispis

razmak:
	cmpb $' ', unos(, %esi, 1)
	je zameni
	jmp sledeci_element

zameni:
	movb $'_', unos(, %esi, 1)  # uvecaj brojac za 1, movl $0, %eax

sledeci_element:
	incl %esi
	jmp provera

ispis:

	# ispis promenjenog stringa
	movl $4, %eax
	movl $1, %ebx
	movl $poruka2, %ecx
	movl $poruka2_duzina, %edx
	int $0x80
	
	movl $4, %eax
	movl $1, %ebx
	movl $unos, %ecx
	movl ucitanoZnakova, %edx
	int $0x80


kraj:
	movl $1, %eax
	movl $0, %ebx
	int $0x80
	
	
