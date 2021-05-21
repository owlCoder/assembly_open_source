# Suma aritmetičke progresije
.section .data
in_max = 12
msg1:   .ascii "Unesite pocetni clan: \0"
msg2:   .ascii "Unesite gornju granicu: \0"
msg3:   .ascii "Suma aritmeticke progresije je: "
sum: 	.fill in_max,1,0
lb:	.fill in_max,1,0
ub:  	.fill in_max,1,0
error: 	.long 0
errop:  .ascii "Nedozvoljena vrednost ulaza!\n\0"
erroflw:.ascii "Prekoracenje opsega!\n\0"

.section .text
.globl main
# makro za ispis stringa na koga pokazuje registar
.macro print_str str
	movl $4,%eax
	movl $1,%ebx
	movl $\str,%ecx
	movl $0,%edx
1:  	cmpb $0,(%ecx)
    	je 2f
    	incl %ecx
    	incl %edx
    	jmp 1b
2:  	movl $\str,%ecx
    	int $0x80
.endm

# unsigned int i2d(int broj, char* str, unsigned int duzina)
i2d:
    	pushl %ebp
    	movl %esp, %ebp
    	subl $4, %esp
    	pushl %ebx
    	pushl %esi
    	pushl %edi
    	movl 8(%ebp), %eax      #broj
    	movl 12(%ebp), %edi     #str
    	movl $10, %ebx          #baza
    	movl $0, -4(%ebp)       #greška
    	andl %eax, %eax         #da li je broj negativan?
    	jns i2d_cifra
    	movb $'-', (%edi)       #ako jeste, ubaci minus
    	incl %edi
    	incl 12(%ebp)           #da se ne bi obrtao minus
    	decl 16(%ebp)           #smanji broj slobodnih mesta
    	negl %eax               #komplement 2
i2d_cifra:
    	decl 16(%ebp)           #provera preostalog mesta
    	cmpl $2, 16(%ebp)       #2 bajta za LINE FEED i NULL
    	jl i2d_greska
    	xorl %edx, %edx
    	divl %ebx
    	addb $'0', %dl
    	movb %dl, (%edi)
    	incl %edi
    	andl %eax, %eax
    	jnz i2d_cifra
    	movb $10, (%edi)	
	incl %edi
	movb $0, (%edi)
	decl %edi
    	decl %edi
    	movl 12(%ebp), %esi
i2d_obrni:
    	cmpl %edi, %esi
    	jae i2d_kraj
    	movb (%esi), %ah
    	movb (%edi), %al
    	movb %al, (%esi)
    	movb %ah, (%edi)
    	decl %edi
    	incl %esi
    	jmp i2d_obrni
i2d_greska:
    	incl -4(%ebp)
i2d_kraj:
    	movl -4(%ebp), %eax
    	popl %edi
    	popl %esi
    	popl %ebx
    	movl %ebp, %esp
    	popl %ebp
    	ret

# int d2i(char* str, unsigned int* greska)
d2i:
    	pushl %ebp
    	movl %esp, %ebp
    	subl $8, %esp
    	pushl %ebx
    	pushl %edi
    	movl $10, -4(%ebp)   	#baza
    	movl $1, -8(%ebp)   	#negacija
    	movl $0, %edi       	#greška
    	xorl %eax, %eax
    	xorl %ecx, %ecx
    	movl 8(%ebp), %ebx
    	cmpb $0, (%ebx)     	#prazan string?
    	je d2i_greska2
    	cmpb $'+', (%ebx)   	#predznak?
    	je d2i_znak1
    	cmpb $'-', (%ebx)   	#predznak?
    	jne d2i_cifra
    	negl -8(%ebp)
d2i_znak1:
    	incl %ebx           	#preskoči predznak
d2i_cifra:
    	movb (%ebx), %cl
    	andb %cl, %cl
    	jz d2i_znak2
    	subb $'0', %cl
    	js d2i_greska2
    	cmpl -4(%ebp), %ecx  	#cifra van dozvoljenog opsega 
    	jae d2i_greska2
    	mull -4(%ebp)	 	#neoznaceno mnozimo rezultat bazom
    	jc d2i_greska1
    	addl %ecx, %eax	 	#dodajemo tekucu cifru
    	jc d2i_greska1
    	incl %ebx		#prelazimo na sledecu cifru
    	jmp d2i_cifra
d2i_znak2:
    	andl %eax, %eax
    	js d2i_greska1  	#ako je neoznačeni broj veći od 0x7fffffff
    	imull -8(%ebp)		#oznaceno mnozimo rezultat bazom
    	jmp d2i_kraj
d2i_greska2:
    	incl %edi
d2i_greska1:
	incl %edi
d2i_kraj:
	movl 12(%ebp), %ebx
	movl %edi, (%ebx)
	popl %edi
	popl %ebx
	movl %ebp, %esp
	popl %ebp
	ret

main:
	print_str msg1
    	movl $3,%eax
    	movl $0,%ebx
    	movl $lb,%ecx
    	movl $in_max,%edx
    	int $0x80
    	movb $0,-1(%ecx,%eax,1) 
    	
	movl $lb, %ebx
    	pushl $error        
    	pushl %ebx
    	call d2i		#konverzija pocetnog clana
    	addl $8,%esp
	movl error, %ecx
	cmpl $1, %ecx
	je err_overflow 
    	cmpl $2, %ecx
    	je err_op
    	pushl %eax          	#čuvanje rezultata prve konverzije na steku

	print_str msg2    	
	movl $3,%eax
    	movl $0,%ebx
    	movl $ub,%ecx
    	movl $in_max,%edx
    	int $0x80
    	movb $0,-1(%ecx,%eax,1) 

    	movl $ub, %ebx	
    	pushl $error        	
    	pushl %ebx
    	call d2i		#konverzija gornje granice
    	addl $8,%esp
	movl error, %ecx
    	cmpl $1, %ecx
	je err_overflow 
    	cmpl $2, %ecx
    	je err_op
	pushl %eax          	#čuvanje rezultata druge konverzije na steku	

	popl %eax		#skidamo gornju granicu sa steka
	popl %ebx		#skidamo pocetni clan sa steka
	xorl %esi, %esi		#akumulator

summ:	addl %ebx, %esi
        jo err_overflow
	incl %ebx
        jo err_overflow
        cmpl %eax, %ebx  
	jle summ

	pushl $in_max
    	pushl $sum        
    	pushl %esi
    	call i2d		#konverzija sume u string
    	addl $12,%esp
	cmp $0, %eax
	jne err_overflow
	print_str msg3		#prikaz sume
	movl $0, %ebx

end_program:
   	movl $1, %eax
	int $0x80

err_op:
	print_str errop
	movl $1, %ebx
    	jmp end_program

err_overflow:
	print_str erroflw
	movl $2, %ebx	
	jmp end_program

