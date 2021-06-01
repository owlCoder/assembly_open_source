.section .data
	unos: .ascii "Unesite izraz: \0"
	unos_duzina = . - unos
	
	ispis: .ascii "Rezultat: 0x\0"
	ispis_duzina = . - ispis

	poruka1: .ascii "Prekoracenje prilikom konverzije!\n\0" 
	poruka1_duzina = . - poruka1

	poruka2: .ascii "Prekoracenje prilikom racunanja rezultata!\n\0"
	poruka2_duzina = . - poruka2

	poruka3: .ascii "Nedozvoljeni karakter u unosu!\n\0"
	poruka3_duzina = . - poruka3

	novi_red: .ascii "\n\0"

	maks_unos = 100 + 1

	rezultat: .long 0
	uneti_izraz: .fill maks_unos, 1, 0
	rezultat_ispis: .fill maks_unos, 1, 0
	greska:	.long 0
.section .text
.global main

main:
	# ispis poruke za unos izraza
	movl $4,			%eax
	movl $1,			%ebx
	movl $unos,			%ecx
	movl $unos_duzina,	%edx
	int $0x80

	# učitavanje izraza sa terminala
	movl $3,			%eax
	movl $0,			%ebx
	movl $uneti_izraz,	%ecx
	movl $maks_unos,	%edx
	int $0x80

	# pozicioniranje na početak stringa koji je unet preko terminala
	movl $uneti_izraz,	%esi

	# ako je prazan string, karakter nije ni cifra ni operacija, ni razmak/zagrada
	cmpb $10,		   (%esi)
	je ispis_poruka3

preskoci_razmake_sa_pocetka:
	cmpb $' ',		   (%esi)	# ako se na početku unosa nalaze razmaci
	jne obradaUnosa				# ako nije razmak, prelazimo na obradu unosa da li je cifra/operacija/zagrada
	incl 				%esi	# preskačemo ih sve dok ne naiđemo na cifru
	jmp preskoci_razmake_sa_pocetka

obradaUnosa:
	# unsigned int konvertujIzrazUInterni(char *izraz, unsigned int *rezultat)
	# poziv potprograma za obradu unosa -> konverzija unosa iz znakovnog u interni
	# povratna vrednost je potpograma može biti:
	# 0 - uneti izraz je korektno unet, nema greške ni u konverziji, ni u prekoračenju opsega
	# 1 - desilo se prekoračenje opsega u toku konverzije broja
	# 2 - desilo se prekoračenje opsega kada se konvertovani broj dodao na rezultat
	# 3 - uneti izraz nije korektno unet
	pushl 			   $rezultat   # promenljive se na stek šalju u obrnutom redosledu
	pushl 		       $uneti_izraz	# cdecl !
	call konvertujIzrazUInterni	   # poziv potprograma za konverziju iz znakovnog u interni
	addl $8,		   %esp        # oslobađa se prostor na steku koji smo zauzeli

	movl %eax,	       greska	   # povratna vrednost potprograma se nalazi u registru opšte namene %eax

	# greska == 3 - uneti izraz nije korektno unet
	cmpl $3,		   greska
	je ispis_poruka3

	# greska == 2 - desilo se prekoračenje opsega kada se konvertovani broj dodao na rezultat
	cmpl $2,		   greska
	je ispis_poruka2

	# greska == 1 - desilo se prekoračenje opsega u toku konverzije broja
	cmpl $1,		   greska
	je ispis_poruka1

	# ako greška nije nijedna od navedenih, onda je konverzija prošla korektno
	# sada je potrebno da rezultat koji je u internom obliku (broj),
	# pretvorimo u znakovni, kako bi ga mogli ispisati na terminal
	# void konvertujBrojUString(unsigned int broj, char *hex_broj)
	pushl 		       $rezultat_ispis # cdecl !
	pushl 			    rezultat   # promenljive se na stek šalju u obrnutom redosledu
								   # kako nećemo menjati razultat, već ga samo konvertovani, šaljemo vrednost, ne adresu na stek.
	call konvertujBrojUString	   # poziv potprograma za konverziju iz znakovnog u interni
	addl $8,		   %esp        # oslobađa se prostor na steku koji smo zauzeli

	# ispis poruke za rezultat na terminal
	movl $4,			  %eax
	movl $1,			  %ebx
	movl $ispis,		  %ecx
	movl $ispis_duzina,   %edx
	int $0x80

	# ispis rezultata u heksadecimalnom obliku na terminal
	movl $4,			  %eax
	movl $1,			  %ebx
	movl $rezultat_ispis, %ecx
	movl $maks_unos,      %edx
	int $0x80

	# ispis novog reda na terminal
	movl $4,			  %eax
	movl $1,			  %ebx
	movl $novi_red,       %ecx
	movl $2,     		  %edx
	int $0x80

	# sve konverzije su korektno odrađene, skoči na kraj
	# kao povratna vrednost vraća se dobijeni rezultat
	jmp kraj

ispis_poruka1:
	movl $4,			  %eax
	movl $1,			  %ebx
	movl $poruka1,		  %ecx
	movl $poruka1_duzina, %edx
	int $0x80

	# pošto je došlo do greške rezultat postaviti na 0
	movl $0,			  rezultat 
	jmp kraj

ispis_poruka2:
	movl $4,			  %eax
	movl $1,			  %ebx
	movl $poruka2,		  %ecx
	movl $poruka2_duzina, %edx
	int $0x80

	# pošto je došlo do greške rezultat postaviti na 0
	movl $0,			rezultat 
	jmp kraj

ispis_poruka3:
	movl $4,			  %eax
	movl $1,			  %ebx
	movl $poruka3,		  %ecx
	movl $poruka3_duzina, %edx
	int $0x80

	# pošto je došlo do greške rezultat postaviti na 0
	movl $0,			rezultat 
	jmp kraj

kraj:
	movl $1,			%eax
	movl rezultat, 		%ebx
	int $0x80