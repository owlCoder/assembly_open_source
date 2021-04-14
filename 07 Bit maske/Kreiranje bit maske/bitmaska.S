.section .data
.section .text
.global maska
# unsigned int maska(unsigned int n, unsigned int v)
# 4(%ebp)           8(%ebp)         12(%ebp)
maska:
	pushl %ebp
    movl  %esp,   %ebp
	
	movl 8(%ebp), %ecx		# n smesti u registar
    testl $0b11111111111111111111111111100000, %ecx  # ako je n veće od 31 !
    jnz setovanje
	
    movl $1, 	  %eax
    shll %cl,     %eax
    testl $0b11111111111111111111111111111110, 12(%ebp)
    jnz setovanje
	
    testl $1, 12(%ebp)
    jnz kraj
	
    notl          %eax          
    jmp kraj
	
setovanje:
    xorl %eax,    %eax
	
kraj:
    movl %ebp,    %esp
    popl %ebp
    ret
