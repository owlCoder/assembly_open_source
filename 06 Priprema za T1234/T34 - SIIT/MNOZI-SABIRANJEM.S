# PR55-2020 Jovanovic Danijel
# Potprogram koji mnozi dva broja pomocu sabiranja

.section .data
.section .text

# unsigned short int pomnozi(unsigned short a, unsigned short b)
.global pomnozi

pomnozi:
	pushl  %ebp
	movl   %esp, 	 %ebp
	pushl  %ebx

	subl  $4,        %esp 		   # prostor za lokalne promenljive

	movl  8(%ebp),	 %ebx	       # prvi broj
	movl    %ebx, -4(%ebp)		   # prvi broj
	movl 12(%ebp),   %ebx		   # drugi broj
	movl  $0,        %eax 		   # proizvod

provera:
	cmpl  $0,     -4(%ebp)		   # da li smo a puta dodali b u sumu ?
	je  kraj			           # sve je okej pomnozeno bez prekoracenja
	jmp dodaj

dodaj:
	addw   %bx,   %ax
	decl -4(%ebp)
	jnc provera			           # nema prekoracenja nastavi dalje
	jc  prekoracenje

prekoracenje:
	movw  $11111,    %ax		   # doslo je do prekoracenja

kraj:
	popl   %ebx
	movl   %ebp,	 %esp
	popl   %ebp
	ret
