.section .data
	n = 9				# idemo do n-tog elementa fib niza
.section .text
.globl main

main:
	movl $0, %eax		# trenutna suma
	movl $1, %ebx		# prethodna suma
	movl $0, %ecx		# brojac

fib:
	addl %ebx, %eax		# dodaj na trenutnu sumu prethodnu sumu
	xchgl %eax, %ebx	# trenutna suma postaje prethodna suma
	addl $1, %ecx		# pomeri brojac za jednu poziciju

	cmpl $n, %ecx		# da li smo stigli do kraja
	je kraj				# ako jesmo, idi na kraj
		
	jmp fib				# racunaj dalje
		
kraj:
	movl $0, %eax		# clean up
	movl $0, %ebx		# clean up
	movl $0, %ecx		# clean up
	int $0x80			# system call
