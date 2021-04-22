# Napisati potprogram koji za uneti string broji koliko on sadrzi znakova '!'.
#  Ako je broj znakova '!':
#          - manji od 3 ili jednak nuli, kao povratna vrednost sistemu vratiti 1
#          - izmedju 4 i 8, kao povratnu vrednost sistemu vratiti 2
#          - veci ili jednak 9, kao povratnu vrednost sistemu vratiti 3
#   String unosi korisnik.
#   Primer interakcije sa programom:
#	Unesite string: Ov!o! nije!!! samo!! String! v!e!c!!, samo!!.
#	user@ubuntu: echo $?
#	3
#  Dobijena vrednost nakon izvrsavanja programa naredbom echo $? je 3.
# unsigned short prebroji(char *string, char znak);

.section .data
	poruka: .ascii "Unesite string: \0"
	poruka_duzina = . - poruka
	
	maks = 50
	unos: .fill maks, 1, 42

	R: .byte 0 
.section .text
.global main

main:
	movl $4, %eax
	movl $1, %ebx
	movl $poruka, %ecx
	movl $poruka_duzina, %edx
	int $0x80

	movl $3, %eax
	movl $0, %ebx
	leal unos, %ecx
	movl $maks, %edx
	int $0x80

	pushl $'!'
	pushl $unos
	call prebroji
	addl $8, %esp
	
	movl %eax, R

kraj:
	movl $1, 	%eax
	movl R,	%ebx
	int $0x80
