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
	niz: .byte 12, 6, 3, 4, 5
	brElem = 5
.global main

main:
	movb  $0, %dl # promelnjiva sume
	
	movl $0, %esi		# pocetak niza
	movl $brElem, %edi	# kraj niza

petlja:
	cmpl %esi, %edi
	je kraj

sumiraj:
	addb niz(, %esi, 1), %dl 	# uvecaj sumu za trenutni element niza
	jc kraj

sl_element:
	incl %esi
	jmp petlja

kraj:
	movl $1, %eax
	movl $0, %ebx
	int $0x80
