# PR55-2020 Danijel Jovanović

.section .data
    ispis1: .ascii "Unesite izraz: \0"
    ispis1_len = . - ispis1

    ispis2: .ascii "Suma brojeva u opsegu je manja.\n\0"
    ispis2_len = . - ispis2

    ispis3: .ascii "Suma brojeva van opsega je manja.\n\0"
    ispis3_len = . - ispis3

    ispis4: .ascii "Sume su jednake.\n\0"
    ispis4_len = . - ispis4

    ispis5: .ascii "Suma: 0x\0"
    ispis5_len = . - ispis5

    greska1: .ascii "GRESKA: Prekoracenje prilikom racunanja sume.\n\0"
    greska1_len = . - greska1

    greska2: .ascii "GRESKA: Problem prilikom konverzije brojeva.\n\0"
    greska2_len = . - greska2

    maks_stdin = 100 + 1
    unos:    .fill  maks_stdin, 1, 0

    suma_1:  .long 0
    suma_2:  .long 0

    sum_isp:  .fill 20, 1, 0

    greska:  .long 0
.section .text

.global main
.global obradiUnos
.global konvertujUHeksaBroj

main:
    movl $4,          %eax
    movl $1,          %ebx
    leal ispis1,      %ecx
    movl $ispis1_len, %edx
    int $0x80

    # ucitavanje unosa
    movl $3,          %eax
    movl $0,          %ebx
    leal unos,        %ecx
    movl $maks_stdin, %edx
    int $0x80

    # funkcija za obradu unosa
    pushl $suma_2
    pushl $suma_1
    pushl $greska
    pushl $unos
    call obradiUnos
    addl $16,         %esp

    # da li je doslo do greske
    cmpl $0,          greska
    je ispisiManjuSumu

    cmpl $1,          greska
    je printError1

    cmpl $2,          greska
    je printError2

printError1:
    movl $4,           %eax
    movl $1,           %ebx
    leal greska1,      %ecx
    movl $greska1_len, %edx
    int $0x80

    movl $1,           greska

    jmp kraj

printError2:
    movl $4,           %eax
    movl $1,           %ebx
    leal greska2,      %ecx
    movl $greska2_len, %edx
    int $0x80
    
    movl $1,           greska

    jmp kraj    

ispisiManjuSumu:
    movl suma_1,      %eax
    movl suma_2,      %ebx
    
    cmpl %eax,        %ebx
    je jednake
    jb drugaManja
    ja prvaManja

jednake:
    movl $4,          %eax
    movl $1,          %ebx
    leal ispis4,      %ecx
    movl $ispis4_len, %edx
    int $0x80

    # ovde potprogram za konverziju broja u heksa decimalni
    # salje se suma_1 ili suma_2 kao parametar jer su obe sume iste
    pushl $16
    pushl $sum_isp
    pushl suma_1
    call konvertujUHeksaBroj
    addl $12,         %esp
    
    movl $4,          %eax
    movl $1,          %ebx
    leal ispis5,      %ecx
    movl $ispis5_len, %edx
    int $0x80

    # ispis sume
    movl $4,          %eax
    movl $1,          %ebx
    leal sum_isp,      %ecx
    movl $20,         %edx
    int $0x80

    jmp kraj

prvaManja:
    movl $4,          %eax
    movl $1,          %ebx
    leal ispis2,      %ecx
    movl $ispis2_len, %edx
    int $0x80

    # ovde potprogram za konverziju broja u heksa decimalni
    # salje se suma_1 kao parametar
    pushl $16
    pushl $sum_isp
    pushl suma_1
    call konvertujUHeksaBroj
    addl $12,         %esp
    
    movl $4,          %eax
    movl $1,          %ebx
    leal ispis5,      %ecx
    movl $ispis5_len, %edx
    int $0x80

    # ispis sume
    movl $4,          %eax
    movl $1,          %ebx
    leal sum_isp,      %ecx
    movl $20,         %edx
    int $0x80

    jmp kraj

drugaManja:
    movl $4,          %eax
    movl $1,          %ebx
    leal ispis3,      %ecx
    movl $ispis3_len, %edx
    int $0x80

    # ovde potprogram za konverziju broja u heksa decimalni
    # salje se suma_2 kao parametar
    pushl $16
    pushl $sum_isp
    pushl suma_2
    call konvertujUHeksaBroj
    addl $12,         %esp

    movl $4,          %eax
    movl $1,          %ebx
    leal ispis5,      %ecx
    movl $ispis5_len, %edx
    int $0x80

    # ispis sume
    movl $4,          %eax
    movl $1,          %ebx
    leal sum_isp,     %ecx
    movl $20,         %edx
    int $0x80

    jmp kraj

kraj:
    movl $1,          %eax
    movl greska,      %ebx
    int $0x80

# void obradiUnos(char *unos, unsigned *greska, unsigned *suma1, unsigned *suma2)
obradiUnos:
    pushl %ebp
    movl  %esp,       %ebp

    subl  $16,        %esp

    pushl %esi
    pushl %ebx

    movl  8(%ebp),    %esi     # uneti string
    xorl    %eax,     %eax     # anuliraj %eax
    movl  $0,     -12(%ebp)    # anuliraj prvu sumu
    movl  $0,     -16(%ebp)    # anuliraj drugu sumu
    incl  %esi                 # prvi unos je svakako [
    
ucitajInterval:
    cmpb  $']',      (%esi)    # da li je gotov trenutni broj ?
    je ucitavanjeNizaBrojeva

    # da li je razmak, ako jeste ignoriši ga
    cmpb $' ',       (%esi)
    je uvecajAdresu_interval

    # da li je zarez, onda ide sledeci broj
    cmpb $',',       (%esi)
    je sledeciBroj_interval

    cmpb $'0',       (%esi)
    jb greska_unos

    cmpb $'9',       (%esi) 
    ja greska_unos

    # u pitanju je cifra
    xorl  %edx,       %edx
    movb (%esi),      %bl
    subb $'0',        %bl
    movl $10,         %ecx
    mull %ecx
    addl %ebx,        %eax
    jc  prekoracenje           # prekoracenje --> carry flag

    andl %eax,        %eax
    js  prekoracenje           # ako je doslo do prekoracenja, znak se promenio
    jmp uvecajAdresu_interval

sledeciBroj_interval:
    movl %eax,     -4(%ebp)    # donja granica
    xorl %eax,        %eax     # anuliranje
    incl %esi                  # pomeri se na sledeci broj od zareza

ucitavanje_gornje_granice:    
    cmpb  $']',      (%esi)    # da li je gotov trenutni broj ?
    je ucitavanjeNizaBrojeva

    # da li je razmak, ako jeste ignoriši ga
    cmpb $' ',       (%esi)
    je uvecajAdresu_ucitavanje_gornje_granice

    # ako je zapeta posle gornje granice, sledeci ], uvecaj adresu, pa iskoci
    cmpb $',',       (%esi)
    je uvecajAdresu_ucitavanje_gornje_granice

    cmpb $'0',       (%esi)
    jb greska_unos

    cmpb $'9',       (%esi) 
    ja greska_unos

    # u pitanju je cifra
    xorl  %edx,       %edx
    movb (%esi),      %bl
    subb $'0',        %bl
    movl $10,         %ecx
    mull %ecx
    addl %ebx,        %eax
    jc  prekoracenje           # prekoracenje --> carry flag

    andl %eax,        %eax
    js  prekoracenje           # ako je doslo do prekoracenja, znak se promenio
    jmp uvecajAdresu_ucitavanje_gornje_granice

ucitavanjeNizaBrojeva:
    movl %eax,     -8(%ebp)    # gornja granica
    xorl %eax,        %eax     # anuliranje

    addl $2,          %esi     # prelazimo dalje

brojevniNiz:
    # da li je kraj niza brojeva ?
    cmpb $'}',       (%esi)
    je setZeroError            # sve je prošlo okej, greške nema

    # ucitaj broj i proveri da li je u intervalu
    # ako je u intervalu pozovi sumiraj i dodaj na sumu_1
     # da li je razmak, ako jeste ignoriši ga
    cmpb $' ',       (%esi)
    je broj_niz_uvecaj_adresu

    # ako je zarez i-ti broj je obradjen, proveri da li je u intervalu
    # i sumiraj u odgovarajucu sumu
    cmpb $',',       (%esi)
    je proveriAnulirajSumiraj

    cmpb $'0',       (%esi)
    jb greska_unos

    cmpb $'9',       (%esi) 
    ja greska_unos

    # u pitanju je cifra
    xorl  %edx,       %edx
    movb (%esi),      %bl
    subb $'0',        %bl
    movl $10,         %ecx
    mull %ecx
    addl %ebx,        %eax
    jc  greska_unos           # prekoracenje --> carry flag

    andl %eax,        %eax
    js  prekoracenje           # ako je doslo do prekoracenja, znak se promenio

broj_niz_uvecaj_adresu:
    incl %esi
    jmp brojevniNiz

proveriAnulirajSumiraj:
    # u %eax se nalazi trenutni broj
    # donja granica je u -4(%ebp)
    # gornja granica je u -8(%ebp)
    cmpl -4(%ebp),    %eax
    jb sumiraj_u_2

    cmpl -8(%ebp),    %eax
    ja sumiraj_u_2

sumiraj_u_1:
    addl %eax,    -12(%ebp)   # prva suma
    jc prekoracenje_sume

    andl %eax,        %eax
    js  prekoracenje_sume     # ako je doslo do prekoracenja, znak se promenio

    xorl %eax,        %eax    # anuliraj %eax

    jmp broj_niz_uvecaj_adresu

sumiraj_u_2:
    addl %eax,    -16(%ebp)   # druga suma
    jc prekoracenje_sume

    andl %eax,        %eax
    js  prekoracenje_sume     # ako je doslo do prekoracenja, znak se promenio

    xorl %eax,        %eax    # anuliraj %eax

    jmp broj_niz_uvecaj_adresu

uvecajAdresu_ucitavanje_gornje_granice:
    incl %esi
    jmp ucitavanje_gornje_granice

uvecajAdresu_interval:
    incl %esi
    jmp ucitajInterval

prekoracenje:
    movl 12(%ebp),    %ebx     # greška 
    movl $1,         (%ebx)
    jmp obradiUnos_kraj

prekoracenje_sume:
    movl 12(%ebp),    %ebx     # greška 
    movl $1,         (%ebx)
    jmp obradiUnos_kraj

setZeroError:
    movl 12(%ebp),    %ebx     # greška 
    movl $0,         (%ebx)

    movl 16(%ebp),    %ecx     # prva suma
    movl 20(%ebp),    %edx     # druga suma

    movl -12(%ebp),   %eax     # prva suma
    movl    %eax,    (%ecx)    # prva suma

    movl -16(%ebp),   %eax     # druga suma
    movl    %eax,    (%edx)    # druga suma

    movl 12(%ebp),    %ebx     # greška 
    movl $0,         (%ebx)

    jmp obradiUnos_kraj

greska_unos:
    movl 12(%ebp),    %ebx     # greška 
    movl $2,         (%ebx)

obradiUnos_kraj:
    popl %esi
    movl %ebp,        %esp
    popl %ebp
    ret

# unsigned int konvertujUHeksaBroj(unsigned int broj, char *izrazZaIspis, unsigned int baza);
konvertujUHeksaBroj:
    pushl   %ebp
    movl    %esp,         %ebp
    
    subl    $4,			  %esp
    
    pushl   %esi
    pushl   %edi
    pushl   %ebx

    movl  8(%ebp),        %eax  # broj za konverziju
    movl 12(%ebp),        %esi  # string u koji smeštamo rezultat
    movl 16(%ebp),        %ecx  # baza

proveriPredznak:
    movb (%esi), %bl

    andl  %eax,           %eax
    jns cifraToStr

    movb $'-',   (%esi) # upisi minus kao predznak
    incl %esi           # predji na sledecu cifru
    incl 12(%ebp)
    negl %eax
    # ako nema predznaka onda je pozitivan broj svakako

    cifraToStr:
        xorl %edx,        %edx
        divl %ecx
                                # u %edx se nalazi ostatak deljenja
        
        addb $'0',        %dl
        movb %dl,        (%esi)
        incl %esi               # predji na sledeci element niza

        andl %eax,        %eax  # ceo rezultat smo konvertovali ?
        jz invertuj
        jmp cifraToStr

    invertuj:
        movl $0,          %ebx  # brojač lokacija
        movl 12(%ebp),    %esi  # string u koji smeštamo rezultat
            
        nadjiKrajStringa:
            cmpb $0,   (%esi)
            je _inicijalizuj

            incl %esi
            incl %ebx
            jmp nadjiKrajStringa
        
        _inicijalizuj:
            movl 12(%ebp),    %esi  # string u koji smeštamo rezultat
            movl 12(%ebp),    %edi  # string u koji smeštamo rezultat
            addl    %ebx,     %edi  # kraj prvog stringa
            decl    %edi
            
            # idemo samo do polovine stringa
            movl    $2,		  %ecx
            movl    %ebx,     %eax
            xorl    %edx,	  %edx
            divl    %ecx
            xorl    %ebx,     %ebx

        obrni:
            cmpl    %eax,    %ebx   # kraj stringa?
            je kraj_konvertujBrojUString

            # zameni prvi i poslednji, ...
            cmpb $0,         (%esi)   # da li je prazan string?
            je kraj_konvertujBrojUString

            movb   (%esi),   %dl
            movb   (%edi),   %dh

            movb    %dl,    (%edi)
            movb    %dh,    (%esi)

            incl    %esi
            decl    %edi
            incl    %ebx
            jmp obrni

kraj_konvertujBrojUString:
    popl %ebx
    popl %edi
    popl %esi

    movl %ebp,          %esp
    popl %ebp
    ret