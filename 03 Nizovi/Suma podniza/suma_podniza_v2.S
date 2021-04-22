#Uraditi program koji nalazi sumu podniza: npr: za niz a = {2, 5, 6, 7, 8}
 #  i interval [0, 2] suma podniza iznosi: 21 (6 + 7 + 8)
.section .data
	niz: .word 2, 5, 6, 7, 8
	brElem = 5
	suma: .word 0
.section .text
.global main

main:
	movw $0, %ax # privremena suma
	
	movl $0, %esi
	movl $3, %edi

provera:
	cmpl %esi, %edi
	je kraj
	
sumiraj:
	addw niz(, %esi, 2), %ax
	incl %esi
	jnc provera
	jc prekoracenje

prekoracenje:
	movw $11111, %ax

kraj:
	movw %ax, suma # eax upisi u sumu
	movl $1, %eax
	movl $0, %ebx
	int $0x80
