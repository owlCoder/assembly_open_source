# Napisati program koji oduzima 2 broja (uzeti u obzir carry i overflow flagove)
.section .data
	prvi:  .long  65
	drugi: .long  55
.section .text
.global main

main:
	movl prvi,  %eax
	subl drugi, %eax
	jc prekoracenje # ako je ocekivani rezultat oznaceni broj, onda ide overflow flag, u suprotnom carry

prekoracenje:
	movl $-1, %eax

kraj:
	movl $1, %eax
	movl $0, %ebx
	int $0x80
