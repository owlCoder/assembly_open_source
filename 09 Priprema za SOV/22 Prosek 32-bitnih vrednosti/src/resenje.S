# PR55-2020 Danijel Jovanovic
# Program koji trazi srednju vrednost niza 32-bitnih neoznacenih brojeva

.section .data
	suma: .long 0
	
	m_in = 50 + 1
	unos:   .fill m_in, 1, 0
	
	por1: .ascii "Unesite 10 elemenata niza: \0"
	p1_len = . - por1
	
	por2: .ascii "Doslo je do prekoracenja!\n\0"
	p2_len = . - por2
	
	por3: .ascii "Greska u konverziji!\n\0"
	p3_len = . - por3
	
	p_sum: .ascii "Prosecna vrednost niza iznosi: \0"
	ps_len = . - p_sum
	
	nl:    .ascii "\n\0"
	
	str_s: .fill 10, 1, 0
	
	greska: .long 0
	brojac: .long 0
.section .text
.global main

main:
	# ispis poruke
	movl $4,		%eax
	movl $1,		%ebx
	leal por1,		%ecx
	movl $p1_len,	%edx
	int $0x80
	
	# unos stringa
	movl $3,		%eax
	movl $0,		%ebx
	leal unos,		%ecx
	movl $m_in,		%edx
	int $0x80
	
	movl $unos,		%esi
	# da li je unet prazan string ?
	cmpb $10,	   (%esi)
	je greskaKonverzija
	
	# pocetne vrednosti promenljivih
	xorl %eax,		%eax
	movl $10,		%ecx
	
stringUBroj:
	cmpb $10,	   (%esi)
	je srednjaVrednost
	
	cmpb $' ',	   (%esi)
	je dodajNaSumu
	
	# da li je cifra od 0-9
	cmpb $'0',	   (%esi)
	jb greskaKonverzija
	
	cmpb $'9',	   (%esi)
	ja greskaKonverzija
	
	movb (%esi),    %bl
	subb $'0',		%bl
	xorl %edx,		%edx
	mull %ecx
	addb %bl,		%al
	jc greskaPrekoracenje
	
	incl %esi
	jmp stringUBroj
	
dodajNaSumu:
	addl %eax,		suma
	jc greskaPrekoracenje
	
	# uvecajBrojac
	incl 			brojac	
	
	# anuliraj eax
	xorl %eax,		%eax
	incl %esi
	jmp stringUBroj
	
srednjaVrednost:
	addl %eax,		suma
	jc greskaPrekoracenje
	
	# uvecajBrojac
	incl 			brojac	
	
	# srednja vrednost je suma / broj elemenata
	movl brojac,	%ecx
	movl suma,		%eax
	xorl %edx,		%edx
	divl %ecx
	
	# u eax se nalazi srednja vrednost niza
	# broj u string
	# baza sistema je 10
	movl $10,		%ecx
	movl $str_s,	%esi 	# string u koji smestamo sumu
	movl $str_s,	%edi 	# string u koji smestamo sumu
	
brojUString:
	andl %eax,		%eax
	je pre_invert
	
	xorl %edx,		%edx
	divl %ecx
	
	addb $'0',		%dl
	movb %dl,	   (%esi)
	incl %esi
	jmp brojUString
	
	
pre_invert:
	decl %esi
	
obrni:
	# edi nam pokazuje na pocetak stringa
	# dok esi pokazuje na kraj stringa
	cmpl %esi,	    %edi
	jae ispisSume

	movb (%esi),	%al
	movb (%edi),	%ah
	
	movb  %ah,     (%esi)
	movb  %al,	   (%edi)
	
	incl %edi
	decl %esi

	jmp obrni
	
greskaKonverzija:
	movl $1,		greska
	
	# ispis poruke
	movl $4,		%eax
	movl $1,		%ebx
	leal por3,		%ecx
	movl $p3_len,	%edx
	int $0x80
	jmp kraj

greskaPrekoracenje:
	movl $2,		greska
	
	# ispis poruke
	movl $4,		%eax
	movl $1,		%ebx
	leal por2,		%ecx
	movl $p2_len,	%edx
	int $0x80
	jmp kraj
	
ispisSume:
	# ispis poruke
	movl $4,		%eax
	movl $1,		%ebx
	leal p_sum,		%ecx
	movl $ps_len,	%edx
	int $0x80
	
	# ispis sume
	movl $4,		%eax
	movl $1,		%ebx
	leal str_s,		%ecx
	movl $10,    	%edx
	int $0x80
	
	# ispis novi red
	movl $4,		%eax
	movl $1,		%ebx
	leal nl,		%ecx
	movl $2,    	%edx
	int $0x80
	
	jmp kraj	
		
kraj:
	movl $1,		%eax
	movl greska,	%ebx
	int $0x80
