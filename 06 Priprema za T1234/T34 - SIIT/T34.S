# PR55-2020 Jovanovic Danijel

# Napisati potprogram za sabiranje i mnozenje dva niza.
# Dati su nizovi a i b koji sadrze 16-bitne neoznacene brojeve,
# duzine n elemenata.
# Svaki element niza a sa NEPARNIM BROJEM INDEKSA (1, 3, 5, ...)
# sabrati sa odgovarajucim elementom niza b i smestiti rezultat
# u odgovarajuci element 16-bitnog niza resenje.
# Svaki element niza a sa PARNIM BROJEM INDEKSA (0, 2, 4, ...)
# potrebno je pomnoziti sa odgovarajucim elementom niza b i 
# smestiti rezultat u odgovaracuji element niza resenje.
# Ukoliko je rezultat nekorektan za neku poziciju, u niz 
# resenje za tu poziciju upisati vrednost 11111.
# Povratna vrednost potprograma je broj elemenata niza resenje 
# sa nekorektnim rezultatom.

# Primer:
# Za nizove a = {1, 2, 3, 4, 5, 6} i b = {0, 0, 2, 2, 10, 10}
# niz resenje = {0, 2, 6, 6, 50, 16}, povratna vrednost 0.

.section .data
	n = 6

	a: 		 .word 1, 2, 3, 4,  5,  6
	b: 		 .word 0, 0, 2, 2, 10, 10
	resenje: .fill n, 2, 0

	pov_vre: .byte 0
.section .text
.global main

main:
	pushl $resenje			# stavljanje na stek
	pushl $b				# stavljanje na stek
	pushl $a				# stavljanje na stek
	pushl $n				# stavljanje na stek
	call SaberiMnozi		# poziv potprograma
	addl  $16,  	%esp	# oslobadjanje steka
	
	movl %eax,  pov_vre 	# povratna vrednost je broj prekoracenja koji se desio
							# u potprogramu
kraj:
	movl $1,	    %eax
	movl pov_vre,	%ebx
	int  $0x80
