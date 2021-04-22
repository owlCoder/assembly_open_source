#Uraditi program koji nalazi sumu podniza: npr: za niz a = {2, 5, 6, 7, 8}
 #  i interval [2, 4] suma podniza iznosi: 21 (6 + 7 + 8)
.section .data
	niz: .long 2, 5, 6, 7, 8
	brElem = 5
	suma: .long 0
.section .text
.global main

main:
	movl $0, %eax # privremena suma
	
	movl $2, %esi
	movl $5, %edi

provera:
	cmpl %esi, %edi
	je kraj
	
sumiraj:
	addl niz(, %esi, 4), %eax
	incl %esi
	jnc provera
	jc prekoracenje

prekoracenje:
	movl $11111, %eax

kraj:
	movl %eax, suma # eax upisi u sumu
	movl $1, %eax
	movl $0, %ebx
	int $0x80
