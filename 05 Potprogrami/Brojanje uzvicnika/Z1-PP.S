# unsigned short prebroji(char *string, char znak);

.section .text
.global prebroji

prebroji:
	pushl %ebp
	movl %esp, %ebp
	
	pushl %esi	

	movl 8(%ebp), %esi # adresa stringa
	movb 12(%ebp), %dl # znak
	movl $0, %eax # brojac

krajNiza:
	# movb (%esi), %cl
	cmpb $10, (%esi)		# 10 -> ascii --> '\n'
	je povratnaVrednosti 

brojUzvicnike:
	cmpb $'!', (%esi)		# da li je taj znak '!' ?
	je uvecajBrojac

uvecajAdresu:
	incl %esi
	jmp krajNiza

uvecajBrojac:
	incl %eax
	jmp uvecajAdresu

povratnaVrednosti:
	cmpl $9, %eax
	jge vrati_3	
	
	cmpl $4, %eax
	jge vrati_2

	cmpl $3, %eax
	jle vrati_1

vrati_1:
	movl $1, %eax
	jmp kraj

vrati_2:
	movl $2, %eax
	jmp kraj

vrati_3:
	movl $3, %eax

kraj:
	popl %esi
	movl %ebp, %esp
	popl %ebp
	ret
