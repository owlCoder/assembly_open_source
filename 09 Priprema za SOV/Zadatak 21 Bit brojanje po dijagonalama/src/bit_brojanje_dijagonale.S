# PR55-2020 Danijel Jovanović

.section .data
	por1: .ascii "Unesite 8 elemenata niza: \0"
	por1_l = . - por1
	
	nep: .ascii "NEPARAN broj jedinica.\n\0"
	nep_l = . - nep
	
	par: .ascii "PARAN broj jedinica.\n\0"
	par_l = . - par
	
	m_in = 50 + 1
	unos: .fill m_in, 1, 0
	
	niz:  .fill 9, 1, 0
	
	brJedinica: .long 0
	shiftNo: 	.long 0
.section .text
.global main

main:
	# ispis poruke
	movl $4,		%eax
	movl $1,		%ebx
	leal por1,		%ecx
	movl $por1_l,	%edx
	int $0x80
	
	# ucitavanje niza
	movl $3,		%eax
	movl $0,		%ebx
	leal unos,		%ecx
	movl $m_in,		%edx
	int  $0x80
	
inicijalizuj:
	# string koji smo uneli
	leal unos,		%esi
	
	# niz u koji smeštamo konvertovane brojeve
	leal niz,  		%edi
	
	xorl %eax,		%eax
	xorl %edx,		%edx
	
	movl $16,		%ecx
	
	# preskačemo 0x sekvencu
	addl $2,		%esi
	
string_u_dec:
	# da li je kraj stringa ?
	cmpb $10,	   (%esi)
	je pomeriUNiz
	
	# da li je razmak
	cmpb $' ',	   (%esi)
	je pomeriUNiz
	
cifraUBroj:
	movb (%esi),	%bl
	
	# da li je u %bl cifra ?
	cmpb $'0', 		%bl
	jb kraj
	
	cmpb $'9',		%bl
	ja slovoAdoF
	
	# ako je prošlo oba uslova u %bl je cifra
	subb $'0',		%bl
	xorl %edx,		%edx
	mull %ecx
	addl %ebx,		%eax
		
	jmp dalje
	
slovoAdoF:
	subb $87,		%bl
	xorl %edx,		%edx
	mull %ecx
	addl %ebx,		%eax

	jmp dalje

pomeriUNiz:
	movb %al,       (%edi)
	xorl %eax,		 %eax
	
	cmpb $10,		(%esi)
	je prebrojJedinice
	
	# preskačemo 0x sekvencu
	addl $3,		 %esi
	addl $1,         %edi
	jmp string_u_dec

dalje:
	incl %esi
	jmp string_u_dec
	
prebrojJedinice:
	# niz u koji smeštamo konvertovane brojeve
	leal niz,  		%edi
	
init:
	movl shiftNo,	%ebx
	movl (%edi),	%eax
	
levo:
	cmpl $0,		%ebx
	je proveriCarryLevo
	shlb			%al
	decl %ebx
	jmp levo
	
proveriCarryLevo:
	shlb 			%al
	adcl $0,		brJedinica
	movl (%edi),	%eax
	movl shiftNo,	%ebx
	
desno:
	cmpl $0,		%ebx
	je proveriCarryDesno
	shrb			%al
	decl %ebx
	jmp desno
	
proveriCarryDesno:
	shrb 			%al
	adcl $0,		brJedinica
	incl			shiftNo
	xorl %eax,		%eax
	
	incl %edi
	# kraj niza brojeva ?
	cmpb $0,	   (%edi)
	jne init
	
ispisiBrojJedinca:
	movl $2,		%ecx
	xorl %edx,		%edx
	
	# sačuvaj broj jedinica
	movl brJedinica, %eax
	
	divl %ecx
	
	# da li paran broj jedinica
	cmpl $0,		%edx
	je paran
	jmp neparan
	
paran:
	# ispis poruke
	movl $4,		%eax
	movl $1,		%ebx
	leal par,		%ecx
	movl $par_l,	%edx
	int $0x80
	jmp kraj
	
neparan:
	# ispis poruke
	movl $4,		%eax
	movl $1,		%ebx
	leal nep,		%ecx
	movl $nep_l,	%edx
	int $0x80
	
kraj:
	movl $1,		%eax
	movl brJedinica,%ebx
	int  $0x80
