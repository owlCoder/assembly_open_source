# Napisati potprogram koji za uneti string, za elemente ciji su indeksi deljivi brojem 3
# pretvara u VELIKO slovo. (Optimizacija: Ako je slovo vec veliko preci na sledeci element u #stringu).
#   String unosi korisnik.
#  Primer interakcije sa programom:
#	Unesite string: Samo jE obican program dobar program.
#	Nakon konverzije: SamO jE oBicAn ProGraM dObaR pRogRam.
#   Dobijena vrednost nakon izvrsavanja programa naredbom echo $? je broj promenjenih 
# karaktera. U ovom primeru je to: 10
# unsigned pretvori(char *string);

.section .data
.section .text
.global pretvori

pretvori:
	pushl %ebp
	movl %esp, %ebp
	
	pushl %esi
	pushl %edi
	pushl %ebx
	
	movl 8(%ebp), %esi
	movl $1, %ebx	# brojac indeksa
	movl $0, %eax	# povratna vrednost

prazan_string:
	cmpb $10, (%esi)
	je kraj
	incl %esi # onda string ima makar 1 char

krajNiza:
	cmpb $10, (%esi)
	je kraj

da_li_je_3:
	cmpl $3, %ebx
	jl uvecajAdresu

manje_od_z:
	cmpb $'z', (%esi)
	je minus32

vece_jednako_a:
	cmpb $'a', (%esi)
	jge minus32

uvecajAdresu:
	cmpl $3, %ebx
	je setujNa1

	incl %esi
	incl %ebx
	jmp krajNiza

setujNa1:
	movl $1, %ebx
	incl %esi
	jmp krajNiza

minus32:
	subb $32, (%esi)
	incl %eax # desila se izmena uvecaj %eax za 1
	movl $1, %ebx
	incl %esi
	jmp krajNiza

kraj:
	popl %ebx
	popl %edi
	popl %esi
	movl %ebp, %esp
	popl %ebp
	ret
