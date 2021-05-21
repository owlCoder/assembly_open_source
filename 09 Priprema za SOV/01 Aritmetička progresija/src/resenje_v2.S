.section .data
in_max = 12
msg1:   .ascii "Unesite pocetni clan: \0"
msg1_duz= .-msg1 
msg2:   .ascii "Unesite gornju granicu: \0"
msg2_duz= .-msg2
msg3:   .ascii "Suma aritmeticke progresije je: "
msg3_duz= .-msg3
sum: 	.fill in_max,1,0
lb:	.fill in_max,1,0
ub:  	.fill in_max,1,0
error: 	.long 0
errop:  .ascii "Nedozvoljena vrednost ulaza!\n\0"
errop_duz= .-errop
erroflw:.ascii "Prekoracenje opsega!\n\0"
erroflw_duz= .-erroflw
.section .text
.global main
main:
	movl $4,%eax             
	movl $1,%ebx
	movl $msg1,%ecx
	movl $msg1_duz,%edx
	int $0x80

	movl $3,%eax
	movl $0,%ebx
	movl $lb,%ecx  
	movl $in_max,%edx
	int $0x80	
	
	movl %ecx,%esi 
	movl $0,%eax #rezultat
	movl $10,%ecx #baza
	movl $0,%ebx
petlja:
	movb (%esi),%bl
	cmpb $10,%bl
	je kraj_prve_konverzije
	subb $'0',%bl	
	cmpb $0,%bl
	jl greska_unos
	cmpb $10,%bl
	jge greska_unos
	movl $0,%edx 
	mull %ecx
	addl %ebx,%eax
	jc greska_prekoracenje
	incl %esi
	jmp petlja
	
kraj_prve_konverzije:
	movl %eax,%edi	#sacuvali vrednost u edi
	
	movl $4,%eax             #prvi ispis
	movl $1,%ebx
	movl $msg2,%ecx
	movl $msg2_duz,%edx
	int $0x80

	movl $3,%eax
	movl $0,%ebx
	movl $ub,%ecx  
	movl $in_max,%edx
	int $0x80	#string se nalazi u ecx
	
	movl %ecx,%esi 
	movl $0,%eax #rezultat
	movl $10,%ecx #baza
	movl $0,%ebx

petlja_2:
	movb (%esi),%bl
	cmpb $10,%bl
	je kraj_konverzija
	subb $'0',%bl	
	cmpb $0,%bl
	jl greska_unos
	cmpb $10,%bl
	jge greska_unos
	movl $0,%edx 
	mull %ecx
	addl %ebx,%eax
	jc greska_prekoracenje
	incl %esi
	jmp petlja_2

kraj_konverzija:
	movl $0,%ecx
petlja_progresija:
	addl %edi,%ecx
	jc greska_prekoracenje
	incl %edi
	cmpl %edi,%eax
	jge petlja_progresija
	
	#rezultat u ecx
	movl $sum,%esi
	movl %ecx,%eax #broj za konverziju
	movl $10, %ecx	#baza
	movl $0,%ebx
petlja_num2str:
	movl $0,%edx
	divl %ecx
	addb $'0',%dl
	movb %dl,(%esi)
	incl %esi
	incl %ebx
	cmpl $in_max,%ebx
	je greska_prekoracenje
	cmpl $0,%eax
	jne petlja_num2str
	
	movl $10,(%esi)	#postavljanje 
	decl %esi	#kraj stringa
	movl $sum,%edi
obrtanje:
	movb (%edi),%cl
	movb (%esi),%bl
	movb %bl,(%edi)
	movb %cl,(%esi)
	incl %edi
	decl %esi
	cmpl %esi,%edi
	jb obrtanje
	
	movl $4,%eax             
	movl $1,%ebx
	movl $msg3,%ecx
	movl $msg3_duz,%edx
	int $0x80
	
	movl $4,%eax             
	movl $1,%ebx
	movl $sum,%ecx
	movl $in_max,%edx
	int $0x80
	movl $0,%ebx
kraj:
	movl $1,%eax
	int $0x80

greska_unos:
	movl $4,%eax             
	movl $1,%ebx
	movl $errop,%ecx
	movl $errop_duz,%edx
	int $0x80
	movl $1,%ebx
	jmp kraj
	
greska_prekoracenje:
	movl $4,%eax            
	movl $1,%ebx
	movl $erroflw,%ecx
	movl $erroflw_duz,%edx
	int $0x80
	movl $2,%ebx
	jmp kraj	
	
	
	
	
	
	
	
