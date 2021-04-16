# PR-55 Jovanovic Danijel
# Napraviti asemblerski program koji za uneti string menja svaka dva susedna karaktera.
# Ako je broj karaktera u stringu neparan, poslednji karakter ostaje nepromenjen.

# Primer interakcije sa programom:
# Unesite string: ftn1980
# tf1n890

.section .data
	max_str = 50

	poruka: .ascii "Unesite string: \0"
	poruka_len = . - poruka

	unos: .fill max_str, 1, 42

	uneto_char: .long 0

	paran: .byte -1
.section .text
.global main

main:
	# ispis poruke za unos
	movl $4,	  	  %eax
	movl $1,	      %ebx
	leal poruka,  	  %ecx
	movl $poruka_len, %edx
	int  $0x80

	# ucitavanje stringa
	movl $3,	   %eax
	movl $0,	   %ebx
	leal unos,     %ecx
	movl $max_str, %edx
	int  $0x80

	# broj ucitanih karaktera se nalazi u registru %eax
	movl %eax,     uneto_char
	decl uneto_char		# potrebni su samo korisni znaci
    movl uneto_char, %eax

da_li_je_paran_broj_karaktera:
	subl $2, 	   %eax   # u %eax se vec nalazi broj ucitanih karaktera
	cmpl $1,	   %eax   # da li ostatak 1 ili 0
	je neparno
	jb parno
	jmp da_li_je_paran_broj_karaktera

parno:
	movl $1, 	   paran
	jmp set_registers

neparno:
	movl $0, 	   paran

set_registers:
	movl $unos,	      %esi   # pocetak stringa
    movl $unos,       %edi
	
	cmpb $1, paran   # da li je broj karaktera paran?
	je do_kraja
	jb manje_jedan

do_kraja:
	addl uneto_char,  %edi
	jmp swap_chars

manje_jedan:
	movl uneto_char,  %eax	# nema 2 pristupa memoriji
	decl %eax			    # neparan broj karaktera
	addl %eax,        %edi	# ne ide se do kraja stringa

provera:
	cmpl %esi, %edi  		# da li smo stigli do kraja stringa ?
	je ispisi_modifikovanog_stringa
	jne swap_chars

swap_chars:
	movl  %esi,	  %eax      # sacuvaj adresu trenutnog karaktera
	movb (%eax),  %cl		# cuvaj vrednost prvog karaktera
	incl  %esi				# predji na sledeci element
	movl  %esi,	  %ebx      # sacuvaj adresu trenutnog karaktera
	movb (%ebx),  %dl

	xchgb  %dl,  (%eax)		# prepisi vrednost drugog na vrednost prvog
	xchgb  %cl,  (%ebx)		# prepisi vrednost prvog na vrednost drugog

	incl %esi				# predji na sledeci element
	jmp provera

ispisi_modifikovanog_stringa:
	# ispis modifikovanog stringa
	incl uneto_char			# vracanje na prvobitnu vrednost
	movl $4,	 	  %eax
	movl $1,	 	  %ebx
	leal unos,   	  %ecx
	movl uneto_char,  %edx
	int  $0x80

kraj:
	movl $1, 	   %eax
	movl $0, 	   %ebx
	int  $0x80

