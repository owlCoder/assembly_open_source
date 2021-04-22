# Napisati program koji nalazi minimum niza (uraditi za niz long-ova i word-ova)

.section .data
	n = 6
	niz_w:  .word   5,   1,   8, 66,  22, 2
.section .text
.global main

# u %ax  se nalazi minimum prvog  niza

main:
	jmp pocetne_vrednosti

pocetne_vrednosti:
	movl $0, %esi				  # pocetak niza
	movl $n, %edi   	          # kraj niza

	movw niz_w(, %esi, 2), %ax    # pretpostavka da je prvi najmanji u nizu
	incl %esi

kraj_niza:
	cmpl %esi, %edi		          # da li smo stigli do kraja niza
	je kraj

poredi:
	movw  niz_w(, %esi, 2), %bx
	cmpw  %ax,  %bx               # da li je trenutni element manji od trenutnog minimuma	
	jb promeni_minimum
	jmp predji_na_sledeci_element

promeni_minimum:
	movw %bx, %ax	              # promeni minimum

predji_na_sledeci_element:
	incl         %esi             # predji na sledeci indeks
	jmp kraj_niza

kraj:
	movl $1,   %eax
	movl $0,   %ebx
	int $0x80
