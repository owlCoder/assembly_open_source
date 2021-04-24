.section .text
.section .data
	niz: .quad 12, -4, 5, 7, 14, 2
	NELEM = 6
 
	najblizi: .quad -1     # pretpostavka da najblizeg nuli nema
	najmanji: .quad  0
	greska:   .byte  0 
.global main

main:
	movl $NELEM, %eax
	cmpl $0, 	 %eax      # da li je niz prazan ?
	je prazno

pocetneVrednosti:
	 # niz nije prazan, pronadji element najblizi nuli
	 movl $niz,		%esi   # prvi element
	 movl $niz,     %edi   # kraj niza
	 addl $NELEM,   %edi

krajNiza:
	 cmpl %esi,     %edi   # da li je kraj niza
	 je resetujPokazivace

absolutnaVrednost:
	movl (%esi),    %edx   # trenutni element niza
	cmpl $0, 	    %edx
	jl negativan
	jge uvecajAdresu

negativan:
	movl %edx,  %ecx
	addl %edx,  %ecx
	subl %ecx,  %edx	
	movl %edx, (%esi)

uvecajAdresu:
	incl  %esi
	jmp krajNiza

resetujPokazivace:
	movl $niz,		%esi   # prvi element
	movl (%esi),    %edx
	movl  %edx,     najmanji
	movl $0,		%edx   # trenutni indeks

krajNizaApsolutnih:
	cmpl %esi,      %edi   # da li je kraj niza
	je kraj

nadjiMinimum:
	movl (%esi),    %ecx   # nema 2 pristupa memoriji
	cmpl  %ecx,     najmanji
	je dalje
	jg promeniMin

dalje:
	incl  %esi
	jmp  krajNizaApsolutnih

promeniMin:
	movl  %ecx,     najmanji 	
	jmp dalje   

prazno:
	incb   greska

kraj:
	movl $1, 	 %eax
	movl greska, %ebx
	int  $0x80
