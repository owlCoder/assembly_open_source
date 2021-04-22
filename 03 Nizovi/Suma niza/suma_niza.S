.section .data
.section .text
	# 64 bitni niz -> .quad
	# 32 bitni niz -> .long
	# 16 bitni niz -> .word
	# 8 bitni niz/podatak -> .byte
	# str: .ascii "fsffdsf\0"
	# str: .fill strmax, 1, 42
	# n = 6
	# carry -> neoznaceni brojevi
	# overflow -> oznacene
	# jc -> prekoracenje kod neoznacenih
	# jo -> prekoracenje kod oznacenih
	# %eax, %ebx, %ecx, %edx, %esi, $edi, %esp, %ebp -> 32 bitni
	# %ax, %bx... -> 16 bitni
	# %al, %ah, ... -> nizih 16 bita, visiih 16 bita
	niz: .word 12, 6, 65535, 4, 5
	brElem = 5
.global main

main:
	movw  $0, %ax # promelnjiva sume
	
	movl $niz, %esi	# pocetak niza
	movl $niz, %edi
	addl $10, %edi	# kraj niza

petlja:
	cmpl %esi, %edi
	je kraj

sumiraj:
	addw (%esi), %ax 	# uvecaj sumu za trenutni element niza
	jc kraj

sl_element:
	addl $2, %esi       # sledeca adresa elementa, 2 jer je word, 4 za long, 1 za byte
	jmp petlja

kraj:
	movl $1, %eax
	movl $0, %ebx
	int $0x80
