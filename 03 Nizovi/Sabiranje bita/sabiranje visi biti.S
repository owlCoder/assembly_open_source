.section .data
	br = 6
	niz: .word 12, 2048, 2049,18, 1025,1023
	S: .long 0

.section .text
.global main

main:
	movl $0, %esi
	movl $0, %ebx

petlja: 
	cmpl $br, %esi
	je kraj
	jne poredi

poredi:	
	movb niz  (, %esi, 2),   %al
	cmpb niz+1(, %esi, 2),   %al
	
	jae sumiraj

	incl %esi
	jmp petlja

	
sumiraj:
	addw niz(, %esi, 2), %bx	# sabiraju se reci na long-ovi!
	incl %esi                   # mora se svakako preci na sledeci element
	jmp petlja
	
kraj:
   	movl %ebx, S
	movl $1, %eax
	movl $0, %ebx
	int $0x80
