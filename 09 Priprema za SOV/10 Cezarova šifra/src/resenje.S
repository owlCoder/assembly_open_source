.macro ispis adresa, duzina
	movl $4, %eax
	movl $1, %ebx
	leal \adresa, %ecx
	movl $\duzina, %edx
	int $0x80
.endm
.macro upis adresa, duzina
	movl $3, %eax
	movl $0, %ebx
	leal \adresa, %ecx
	movl $\duzina, %edx
	int $0x80
.endm

.section .data
  MAX = 101
  MAXBR = 16
  tekst: .fill MAX
  baza_str: .fill MAXBR
  baza: .long 0
  kod_str: .fill MAXBR
  kod: .long 0
  BRSLOVA = 26
  unesi_tekst: .ascii "Unesite tekst: "
  unesi_tekst_duzina = . - unesi_tekst
  unesi_kod: .ascii "Unesite kod: "
  unesi_kod_duzina = . - unesi_kod
  unesi_bazu: .ascii "Unesite bazu: "
  unesi_bazu_duzina = . - unesi_bazu
  RES = 8
  resenje_ucifrano: .fill RES
  resenje: .byte 0
  sifrovano_poruka: .ascii "Sifrovan tekst: "
  sifrovano_poruka_duzina = . - sifrovano_poruka
  resenje_poruka: .ascii "Broj sifrovanih karaktera je: "
  resenje_poruka_duzina = . - resenje_poruka
  enter_znak: .ascii "\n"
  greska: .byte 0
.section .text
.globl main

main:
    ispis unesi_tekst, unesi_tekst_duzina
    upis tekst, MAX
    decl %eax
    movb $0, tekst(,%eax,1)
    ispis unesi_bazu, unesi_bazu_duzina
    upis baza_str, MAXBR
		pushl $baza_str
    call procif
    addl $4, %esp
    andl %eax, %eax
    jne jeste_g8
    pushl $10
    pushl $baza_str
    call str2int
    addl $8, %esp
    andl %edx, %edx
    je nije_g8
	jeste_g8:
    movb $1, greska
    jmp kraj

  nije_g8:
    movl %eax, baza
    cmpl $2, baza
    jb jeste_g10
    cmpl $10, baza
    jbe nije_g10
  jeste_g10:
    movb $2, greska
    jmp kraj

  nije_g10:
    ispis unesi_kod, unesi_kod_duzina
    upis kod_str, MAXBR
    pushl $kod_str
    call procif
    addl $4, %esp
    andl %eax, %eax
    jne jeste_g8
    pushl $10
    pushl $kod_str
    call str2int
    addl $8, %esp
    andl %edx, %edx
    jne jeste_g8

    movl %eax, kod
    ispis sifrovano_poruka, sifrovano_poruka_duzina
    xorl %edx, %edx
    movl kod, %eax
    movl $BRSLOVA, %ecx
    divl %ecx
    movl %edx, kod
    movb kod, %bh
    xorl %esi, %esi
  naredni_karakter:
    movb tekst(,%esi,1), %bl
    andb %bl, %bl
    jz pred_ispis_rezultata
    cmpb $'A', %bl
    jb ispisi_karakter
    cmpb $'Z', %bl
    ja malo
    addb %bh, %bl
		incb resenje
    cmpb $'Z', %bl
    jbe ispisi_karakter
    subb $BRSLOVA, %bl
    jmp ispisi_karakter
  malo:
    cmpb $'a', %bl
    jb ispisi_karakter
    cmpb $'z', %bl
    ja ispisi_karakter
    addb %bh, %bl
		incb resenje
    cmpb $'z', %bl
    jbe ispisi_karakter
    subb $BRSLOVA, %bl
  ispisi_karakter:
    movb %bl, resenje_ucifrano
    pushl %ebx
    ispis resenje_ucifrano, 1
    popl %ebx
    incl %esi
    jmp naredni_karakter

  pred_ispis_rezultata:
    ispis enter_znak, 1

  ispis_rezultata:
    xorl %esi, %esi
    xorl %edx, %edx
		xorl %eax, %eax
    movb resenje, %al
    movl baza, %ebx
  naredna_cifra:
    divl %ebx
    cmpb $10, %dl
    jae slova
    addb $'0', %dl
    jmp smesti_cifru
  slova:
    subb $10, %dl
    add $'a', %dl
  smesti_cifru:
    movb %dl, resenje_ucifrano(,%esi,1)
    incl %esi
    xorl %edx, %edx
    andl %eax, %eax
    jnz naredna_cifra
    movb $0, resenje_ucifrano(,%esi,1)
    pushl %esi
    xorl %edi, %edi
    decl %esi
  obrni:
    cmpl %esi, %edi
    jae ispis_broja_karaktera
    movb resenje_ucifrano(,%esi,1), %dh
    xchgb %dh, resenje_ucifrano(,%edi,1)
    movb %dh, resenje_ucifrano(,%esi,1)
    decl %esi
    incl %edi
    jmp obrni

  ispis_broja_karaktera:
    ispis resenje_poruka, resenje_poruka_duzina
  	movl $4, %eax
  	movl $1, %ebx
  	leal resenje_ucifrano, %ecx
    popl %edx
  	int $0x80
    ispis enter_znak, 1
  kraj:
    movl $1, %eax
		xorl %ebx, %ebx
    movb greska, %bl
    int $0x80

# konverzija iz stringa u interni oblik
# int:int str2int(char* string )
# rezultat:greska
str2int:
    pushl %ebp
    movl %esp, %ebp
    pushl %esi
    pushl %ebx
    movl 8(%ebp), %esi   # adresa stringa
    movl 12(%ebp), %ecx  # baza
    xorl %edx, %edx
    xorl %eax, %eax      # rezultat
    xorl %ebx, %ebx
  str2int_sledeci:
    movb (%esi), %bl
    cmpb $10, %bl
    je str2int_kraj
    mull %ecx
    andl %edx, %edx
    jnz str2int_greska
    subb $'0', %bl
    addl %ebx, %eax
    jc str2int_greska
    incl %esi
    jmp str2int_sledeci
  str2int_greska:
    notl %edx
  str2int_kraj:
    popl %ebx
    popl %esi
    movl %ebp, %esp
    popl %ebp
    ret


# provera da li su svi karakteri cifre.
procif:
    pushl %ebp
    movl %esp, %ebp
    pushl %esi
    pushl %ebx
    movl 8(%ebp), %esi   # adresa stringa
    xorl %eax, %eax      # rezultat
  procif_sledeci:
    movb (%esi), %bl
    cmpb $10, %bl
    je procif_kraj
    cmpb $'0', %bl
    jb procif_greska
    cmpb $'9', %bl
    ja procif_greska
    incl %esi
    jmp procif_sledeci
  procif_greska:
    notl %eax
  procif_kraj:
    popl %ebx
    popl %esi
    movl %ebp, %esp
    popl %ebp
    ret
