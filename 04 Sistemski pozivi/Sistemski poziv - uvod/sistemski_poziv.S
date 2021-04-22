.section .data
	duzina = 50

	poruka: .ascii "Ja sam: \0"
	poruka_duzina = . - poruka

	unos: .fill duzina, 1, 42
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
	movl $unos, %ecx
	movl $duzina, %edx
	int $0x80

kraj:
	movl $1, %eax
	movl $0, %ebx
	int $0x80
