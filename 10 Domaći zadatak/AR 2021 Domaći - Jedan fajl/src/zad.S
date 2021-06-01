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
	rezZagrada: .long 0
    operacija: .byte 0
.section .text
.global main
.global konvertujBrojUString
.global konvertujIzrazUInterni
.global izracunajZagradu

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

# void konvertujBrojUString(unsigned int broj, char *izrazZaIspis);
konvertujBrojUString:
    pushl   %ebp
    movl    %esp,       %ebp
    
    # pushovanje na stek registara koji su nam potrebni za rad  
    pushl   %esi
    pushl   %edi
    pushl   %ebx

    movl  8(%ebp),      %eax    # broj za konverziju
    movl 12(%ebp),      %esi    # string u koji smeštamo rezultat
    movl  $16,          %ecx    # baza heksadecimalnog brojnog sistema je 16

    cifraToStr:
        xorl %edx,      %edx    # naredba div zahteva da se u registru %edx nalazi 0 kako bi deljenje bilo uspešno
        divl %ecx               # podeli sa bazom sistema
                                # u %edx se nalazi ostatak deljenja 
        cmpb $10,       %dl     # da li je ostatak deljenja za 16 broj 10 ?
        je hex_A                # onda to treba pretvoriti u slovo A

        cmpb $11,       %dl     # da li je ostatak deljenja za 16 broj 11 ?
        je hex_B                # onda to treba pretvoriti u slovo B

        cmpb $12,       %dl     # da li je ostatak deljenja za 16 broj 12 ?
        je hex_C                # onda to treba pretvoriti u slovo C

        cmpb $13,       %dl     # da li je ostatak deljenja za 16 broj 13 ?
        je hex_D                # onda to treba pretvoriti u slovo D

        cmpb $14,       %dl     # da li je ostatak deljenja za 16 broj 14 ?
        je hex_E                # onda to treba pretvoriti u slovo E

        cmpb $15,       %dl     # da li je ostatak deljenja za 16 broj 15 ?
        je hex_F                # onda to treba pretvoriti u slovo F

        addb $'0',      %dl     # ako je broj manji od 10, onda je cifra od 0-9, pretvaramo ga u znak
        movb %dl,      (%esi)   # upisuje znak u niz

        provera:
            incl %esi           # predji na sledeci element niza
            andl %eax,  %eax    # ceo rezultat smo konvertovali; da li je u %eax nula ?
            jz invertuj         # obrni string jer smo prilikom konverzije išli s desna ulevo !
            jmp cifraToStr

        hex_A:
            movb $'A', (%esi)   # upiši A u rezultanti string za ispis
            jmp provera

        hex_B:
            movb $'B', (%esi)   # upiši B u rezultanti string za ispis
            jmp provera

        hex_C:
            movb $'C', (%esi)   # upiši C u rezultanti string za ispis
            jmp provera

        hex_D:
            movb $'D', (%esi)   # upiši D u rezultanti string za ispis
            jmp provera

        hex_E:
            movb $'E', (%esi)   # upiši E u rezultanti string za ispis
            jmp provera

        hex_F:
            movb $'F', (%esi)   # upiši F u rezultanti string za ispis
            jmp provera

    invertuj:
        movl $0,          %ebx  # brojač lokacija
        movl 12(%ebp),    %esi  # string u koji smeštamo rezultat
            
        nadjiKrajStringa:
            cmpb $0,   (%esi)   # da li je kraj stringa ?
            je _inicijalizuj

            incl %esi
            incl %ebx           # brojač koliko elemenata ima niz
            jmp nadjiKrajStringa
        
        _inicijalizuj:
            movl 12(%ebp),    %esi  # string u koji smeštamo rezultat
            movl 12(%ebp),    %edi  # string u koji smeštamo rezultat
            addl    %ebx,     %edi  # kraj prvog stringa
            decl    %edi            # poslednji znak je '\0' koji ne treba da invertujemo
            
            # idemo samo do polovine stringa, jer ako idemo do kraja stringa, invertovanje će uraditi 2 puta, pa ćemo dobiti početni string
            movl    $2,		  %ecx  # polovina = dužina_stringa / 2
            movl    %ebx,     %eax  # polovina = dužina_stringa / 2
            xorl    %edx,	  %edx  # naredba div zahteva da se u registru %edx nalazi 0 kako bi deljenje bilo uspešno
            divl    %ecx            # podeli ono što se nalazi u %eax sa %ecx
            xorl    %ebx,     %ebx  # anuliraj %ebx

        obrni:
            cmpl    %eax,    %ebx   # kraj stringa?
            je kraj_konvertujBrojUString

            # zameni prvi i poslednji, ...
            cmpb $0,         (%esi)  # da li je prazan string?
            je kraj_konvertujBrojUString

            movb   (%esi),   %dl    # prvi, drugi, ..., srednji - 1
            movb   (%edi),   %dh    # poslednji, pretposlednji, srednji + 1

            movb    %dl,    (%edi)  # prvi upiši u poslednji, ...
            movb    %dh,    (%esi)  # poslednji upiši u prvi, ...

            incl    %esi            # pređi na drugi, treći element, ...
            decl    %edi            # pređi na pretposlednji element, ...
            incl    %ebx            # brojač uvećaj za 1
            jmp obrni

kraj_konvertujBrojUString:
    # restauracija registara sa steka koje više ne koristimo
    popl %ebx
    popl %edi
    popl %esi

    movl %ebp,          %esp
    popl %ebp
    ret

# unsigned int konvertujIzrazUInterni(char *izraz, unsigned int *rezultat)
# poziv potprograma za obradu unosa -> konverzija unosa iz znakovnog u interni
# povratna vrednost je potpograma može biti:
# 0 - uneti izraz je korektno unet, nema greške ni u konverziji, ni u prekoračenju opsega
# 1 - desilo se prekoračenje opsega u toku konverzije broja
# 2 - desilo se prekoračenje opsega kada se konvertovani broj dodao na rezultat
# 3 - uneti izraz nije korektno unet
konvertujIzrazUInterni:
    pushl   %ebp
    movl    %esp,    %ebp
    
    subl    $4,	 %esp        # zauzimanje prostora na steku za lokalnu promenljivu
    
    pushl   %esi
    pushl   %edi
    pushl   %ebx

    movl  8(%ebp),   %esi     # izraz koji je unet preko terminala (string)
    movl 12(%ebp),   %edi     # adresa neoznačenog 32-bitnog broja u koji smeštamo rezultat  
    xorl    %eax,    %eax     # anuliraj %eax
    movl  $10,       %ecx     # baza dekadnog brojnog sistema je 10 (cifre 0-9)

    movl  $0,     -4(%ebp)    # prvi  operand/broj   (van zagrade) npr. --> 12 + 8

prviBrojURezultat:
    # prvi razmak posle broja iskačemo iz konverzije
    cmpb $' ',       (%esi)
    je sacuvajURez

    # ako nije nijedna operacija ili zagrada onda je cifra
    cmpb $'0',       (%esi)
    jb greska_unos

    cmpb $'9',       (%esi) 
    ja greska_unos

    # u pitanju je cifra
    movb (%esi),      %bl   # pomeri cifru u niži registar (8-bitni)
    subb $'0',        %bl   # pretvori znak(cifru) u broj

    xorl %edx,        %edx  # isti razlog resetovanja na 0 kao za div naredbu
    mull %ecx               # pomnoži %eax sa %ecx
    addl %ebx,        %eax  # dodaj konvertovanu cifru u broj (%eax)
    jc  prekoracenje        # prekoracenje u konverziji --> carry flag

    incl %esi               # pređi na sledeći element u izrazu
    jmp prviBrojURezultat

sacuvajURez:
    movl %eax,       (%edi) # u eax se nalazi konvertovani broj
    xorl %eax,        %eax

ucitajOperandOperaciju:
    # da li je obrađen ceo uneti izraz
    cmpb $10,        (%esi)
    je nema_greske

    # da li je neka operacija (+, -, *, /, ^)
    # da li je operacija sabiranja
    cmpb  $'+',      (%esi)
    je saberi

    # da li je operacija oduzimanja
    cmpb  $'-',      (%esi)
    je oduzmi

    # da li je operacija množenja
    cmpb  $'*',      (%esi)
    je mnozi

    # da li je operacija sabiranja
    cmpb  $'/',      (%esi)
    je deli

    # da li je operacija sabiranja
    cmpb  $'^',      (%esi)
    je xoruj

    # da li je razmak, ako jeste, preskoči sve razmake i traži sledeći
    # broj, operaciju ili zagradu
    cmpb  $' ',      (%esi)
    je preskakanjeRazmaka

    # ako nije nijedna operacija ili zagrada onda je cifra
    cmpb $'0',       (%esi)
    jb greska_unos

    cmpb $'9',       (%esi) 
    ja greska_unos

    # u pitanju je cifra
    movb (%esi),      %bl   # pomeri cifru u niži registar (8-bitni)
    subb $'0',        %bl   # pretvori znak(cifru) u broj

    xorl %edx,        %edx  # isti razlog resetovanja na 0 kao za div naredbu
    mull %ecx               # pomnoži %eax sa %ecx
    addl %ebx,        %eax  # dodaj konvertovanu cifru u broj (%eax)
    jc  prekoracenje        # prekoracenje u konverziji --> carry flag
    incl %esi               # pređi na sledeći element u izrazu
    jmp ucitajOperandOperaciju

preskakanjeRazmaka:
    cmpb  $' ',      (%esi)
    jne ucitajOperandOperaciju
    incl %esi
    jmp preskakanjeRazmaka

saberi:
    incl %esi # preskaćemo +
    preskociRazmakePoslePlusa:
        cmpb  $' ',      (%esi) # ponovo preskačemo sve razmake do prvog broja ili zagrade
        jne traziZagraduIliBroj

        incl %esi
        jmp preskociRazmakePoslePlusa

        traziZagraduIliBroj:
            movl (%edi),      %eax
            movl  %eax,    -4(%ebp)      # prebaci trenutni rezultat u lokalnu promenljivu
            xorl %eax,        %eax       # anuliramo %eax za novi broj

            movb $'+',        operacija
            cmpb $'(',       (%esi)
            je obradiZagradu

            sab_broj:
                cmpb $' ',       (%esi)  # ako sada naidjemo na razmak potrebno je brojeve sabrati
                je sabiranje

                cmpb $10,        (%esi)  # ako dođemo do kraja izraza, na rezultat dodamo broj na koji smo naišli
                je sabiranje_kraj

                cmpb $'0',       (%esi)
                jb greska_unos

                cmpb $'9',       (%esi) 
                ja greska_unos

                movb (%esi),      %bl   # pomeri cifru u niži registar (8-bitni)
                subb $'0',        %bl   # pretvori znak(cifru) u broj

                xorl %edx,        %edx  # isti razlog resetovanja na 0 kao za div naredbu
                mull %ecx               # pomnoži %eax sa %ecx
                addl %ebx,        %eax  # dodaj konvertovanu cifru u broj (%eax)
                jc  prekoracenje        # prekoracenje u konverziji --> carry flag
                incl %esi               # pređi na sledeći element u izrazu
                jmp sab_broj

                sabiranje:
                    addl %eax,         -4(%ebp)  # broj koji smo konvertovali se nalazi u %eax, dodaj na trenutni rezultat
                    movl -4(%ebp),        %edx   # nemamo 2 pristupa memoriji
                    movl %edx,           (%edi)  # pomeri izračunato na vrednost rezultata
                    jc prekoracenje_dodaj_rezultat
                    incl %esi 
                    jmp ucitajOperandOperaciju

                sabiranje_kraj:
                    addl %eax,         -4(%ebp)  # broj koji smo konvertovali se nalazi u %eax, dodaj na trenutni rezultat
                    movl -4(%ebp),        %edx   # nemamo 2 pristupa memoriji
                    movl %edx,           (%edi)  # pomeri izračunato na vrednost rezultata
                    jc prekoracenje_dodaj_rezultat
                    jmp nema_greske

oduzmi:
    incl %esi # preskaćemo -
    preskociRazmakePosleMinusa:
        cmpb  $' ',      (%esi)          # ponovo preskačemo sve razmake do prvog broja ili zagrade
        jne traziZagraduIliBroj_Minus

        incl %esi
        jmp preskociRazmakePosleMinusa

        traziZagraduIliBroj_Minus:
            movl (%edi),      %eax
            movl  %eax,    -4(%ebp)      # prebaci trenutni rezultat u lokalnu promenljivu
            xorl %eax,        %eax       # anuliramo %eax za novi broj

            movb $'-',        operacija
            cmpb $'(',       (%esi)
            je obradiZagradu

            oduz_broj:
                cmpb $' ',       (%esi)  # ako sada naidjemo na razmak potrebno je brojeve oduzeti
                je oduzimanje

                cmpb $10,        (%esi)  # ako dođemo do kraja izraza, oduzimamo od rezultata broj na koji smo naišli
                je oduzimanje_kraj

                cmpb $'0',       (%esi)
                jb greska_unos

                cmpb $'9',       (%esi) 
                ja greska_unos

                movb (%esi),      %bl   # pomeri cifru u niži registar (8-bitni)
                subb $'0',        %bl   # pretvori znak(cifru) u broj

                xorl %edx,        %edx  # isti razlog resetovanja na 0 kao za div naredbu
                mull %ecx               # pomnoži %eax sa %ecx
                addl %ebx,        %eax  # dodaj konvertovanu cifru u broj (%eax)
                jc prekoracenje         # prekoracenje u konverziji --> carry flag

                incl %esi               # pređi na sledeći element u izrazu
                jmp oduz_broj

                oduzimanje:
                    subl %eax,         -4(%ebp)  # broj koji smo konvertovali se nalazi u %eax, oduzmi od trenutnog rezultata
                    movl -4(%ebp),        %edx   # nemamo 2 pristupa memoriji
                    movl    %edx,        (%edi)  # pomeri izračunato na vrednost rezultata
                    jc prekoracenje_dodaj_rezultat
                    incl %esi 
                    jmp ucitajOperandOperaciju

                oduzimanje_kraj:
                    subl %eax,         -4(%ebp)  # broj koji smo konvertovali se nalazi u %eax, oduzmi od trenutnog rezultata
                    movl -4(%ebp),        %edx   # nemamo 2 pristupa memoriji
                    movl %edx,           (%edi)  # pomeri izračunato na vrednost rezultata
                    jc prekoracenje_dodaj_rezultat
                    jmp nema_greske

mnozi:
            incl %esi # preskaćemo *
    preskociRazmakePosleZvezdice:
        cmpb  $' ',      (%esi) # ponovo preskačemo sve razmake do prvog broja ili zagrade
        jne traziZagraduIliBroj_Zvezdica

        incl %esi
        jmp preskociRazmakePosleZvezdice

        traziZagraduIliBroj_Zvezdica:
            movl (%edi),      %eax
            movl  %eax,    -4(%ebp)      # prebaci trenutni rezultat u lokalnu promenljivu
            xorl %eax,        %eax       # anuliramo %eax za novi broj
           
            movb $'*',        operacija
            cmpb $'(',       (%esi)
            je obradiZagradu

            mnoz_broj:
                cmpb $' ',       (%esi)  # ako sada naidjemo na razmak potrebno je brojeve pomnožiti
                je mnozenje

                cmpb $10,        (%esi)  # ako dođemo do kraja izraza, pomnožimo rezultat i trenutni broj
                je mnozenje_kraj

                cmpb $'0',       (%esi)
                jb greska_unos

                cmpb $'9',       (%esi) 
                ja greska_unos

                movb (%esi),      %bl   # pomeri cifru u niži registar (8-bitni)
                subb $'0',        %bl   # pretvori znak(cifru) u broj

                xorl %edx,        %edx  # isti razlog resetovanja na 0 kao za div naredbu
                mull %ecx               # pomnoži %eax sa %ecx
                addl %ebx,        %eax  # dodaj konvertovanu cifru u broj (%eax)
                jc prekoracenje         # prekoracenje u konverziji --> carry flag

                incl %esi               # pređi na sledeći element u izrazu
                jmp mnoz_broj

                mnozenje:
                    movl -4(%ebp), %ebx          # rezultat koji množimo
                    mull %ebx                    # broj koji smo konvertovali se nalazi u %eax, množimo %eax sa %ebx
                    movl    %eax,        (%edi)  # pomeri izračunato na vrednost rezultata
                    jc prekoracenje_dodaj_rezultat
                    incl %esi 
                    jmp ucitajOperandOperaciju

                mnozenje_kraj:
                    movl -4(%ebp), %ebx          # rezultat koji množimo
                    mull %ebx                    # broj koji smo konvertovali se nalazi u %eax, množimo %eax sa %ebx
                    movl %eax,           (%edi)  # pomeri izračunato na vrednost rezultata
                    jc prekoracenje_dodaj_rezultat
                    jmp nema_greske

deli:
    incl %esi # preskaćemo /
    preskociRazmakePosleDeljenje:
        cmpb  $' ',      (%esi)          # ponovo preskačemo sve razmake do prvog broja ili zagrade
        jne broj_zagrada_d

        incl %esi
        jmp preskociRazmakePosleDeljenje

        broj_zagrada_d:
            movl (%edi),      %eax
            movl  %eax,    -4(%ebp)      # prebaci trenutni rezultat u lokalnu promenljivu
            xorl %eax,        %eax       # anuliramo %eax za novi broj

            movb $'/',        operacija
            cmpb $'(',       (%esi)
            je obradiZagradu

            deljenje_brojeva:
                cmpb $' ',       (%esi)   # ako sada naidjemo na razmak potrebno je brojeve podeliti
                je deljenje

                cmpb $10,        (%esi)   # ako dođemo do kraja izraza, podelimo rezultat sa brojem na koji smo naišli
                je deljenje_kraj

                cmpb $'0',       (%esi)
                jb greska_unos

                cmpb $'9',       (%esi) 
                ja greska_unos

                movb (%esi),      %bl   # pomeri cifru u niži registar (8-bitni)
                subb $'0',        %bl   # pretvori znak(cifru) u broj

                xorl %edx,        %edx  # isti razlog resetovanja na 0 kao za div naredbu
                mull %ecx               # pomnoži %eax sa %ecx
                addl %ebx,        %eax  # dodaj konvertovanu cifru u broj (%eax)
                jc prekoracenje         # prekoracenje u konverziji --> carry flag
                incl %esi               # pređi na sledeći element u izrazu
                jmp deljenje_brojeva

                deljenje:
                    xorl %edx,      %edx  # divl zahteva da %edx registar anulira !
                    movl -4(%ebp), %eax   # rezultat koji delimo
                    movl %eax,     %ebx
                    divl %ebx             # broj koji smo konvertovali se nalazi u %eax, podeli %eax sa %ebx
                    movl    %eax,        (%edi)  # pomeri izračunato na vrednost rezultata
                    jc prekoracenje_dodaj_rezultat
                    incl %esi 
                    jmp ucitajOperandOperaciju

                deljenje_kraj:
                    xorl %edx,      %edx  # divl zahteva da %edx registar anulira !
                    movl %eax,     %ebx
                    movl -4(%ebp), %eax   # rezultat koji delimo
                    divl %ebx             # broj koji smo konvertovali se nalazi u %eax, podeli %eax sa %ebx
                    movl %eax,           (%edi)  # pomeri izračunato na vrednost rezultata
                    jc prekoracenje_dodaj_rezultat
                    jmp nema_greske

xoruj:
            incl %esi # preskaćemo ^
    preskociRazmakePosleKapice:
        cmpb  $' ',      (%esi)     # ponovo preskačemo sve razmake do prvog broja ili zagrade
        jne traziBrojZagradu_Kapice

        incl %esi
        jmp preskociRazmakePosleKapice

        traziBrojZagradu_Kapice:
            movl (%edi),      %eax
            movl  %eax,    -4(%ebp)  # prebaci trenutni rezultat u lokalnu promenljivu
            xorl %eax,        %eax   # anuliramo %eax za novi broj

            movb $'^',        operacija
            cmpb $'(',       (%esi)
            je obradiZagradu

            xor_broj:
                cmpb $' ',       (%esi) # ako sada naidjemo na razmak potrebno je brojeve xorlovati
                je exili

                cmpb $10,        (%esi) # ako dođemo do kraja izraza, xorujemo rezultat sa brojem na koji smo naišli
                je exili_kraj

                cmpb $'0',       (%esi)
                jb greska_unos

                cmpb $'9',       (%esi) 
                ja greska_unos

                movb (%esi),      %bl   # pomeri cifru u niži registar (8-bitni)
                subb $'0',        %bl   # pretvori znak(cifru) u broj

                xorl %edx,        %edx  # isti razlog resetovanja na 0 kao za div naredbu
                mull %ecx               # pomnoži %eax sa %ecx
                addl %ebx,        %eax  # dodaj konvertovanu cifru u broj (%eax)
                jc prekoracenje         # prekoracenje u konverziji --> carry flag

                incl %esi               # pređi na sledeći element u izrazu
                jmp xor_broj

                exili:
                    movl -4(%ebp), %ebx  # rezultat koji množimo
                    xorl %eax,  %ebx     # broj koji smo konvertovali se nalazi u %eax, xorlujemo %eax sa %ebc
                    movl    %eax,        (%edi)  # pomeri izračunato na vrednost rezultata
                    jc prekoracenje_dodaj_rezultat
                    incl %esi 
                    jmp ucitajOperandOperaciju

                exili_kraj:
                    movl -4(%ebp), %ebx  # rezultat koji množimo
                    xorl %eax,  %ebx     # broj koji smo konvertovali se nalazi u %eax, xorlujemo %eax sa %ebc
                    movl %eax,           (%edi)  #  pomeri izračunato na vrednost rezultata
                    jc prekoracenje_dodaj_rezultat
                    jmp nema_greske

obradiZagradu:
    # preskačemo zagradu
    incl %esi

    # potprogram koji računa rezultat u okviru zagrada ()
    pushl $rezZagrada   # rezultat iz zagrade koji smeštamo
    pushl %esi          # u esi je trenutna adresa unosa
    call izracunajZagradu
    addl $8,          %esp   # vrati stek u prethodno stanje
    
    # greska == 3 - uneti izraz nije korektno unet
	cmpl $3,		   %eax
	je greska_unos

	# greska == 2 - desilo se prekoračenje opsega kada se konvertovani broj dodao na rezultat
	cmpl $2,		   %eax
	je prekoracenje_dodaj_rezultat

	# greska == 1 - desilo se prekoračenje opsega u toku konverzije broja
	cmpl $1,		   %eax
	je prekoracenje

    # koja operacija se radi sa rezultatom i rezultatom iz zagrade ? 
    cmpb $'+',         operacija
    je dodaj

    cmpb $'-',         operacija
    je oduzimaj

    cmpb $'*',         operacija
    je mnozim

    cmpb $'/',         operacija
    je delim

    cmpb $'^',         operacija
    je eksluzivnoIli

    incl %esi
    jmp ucitajOperandOperaciju

    # dodaj na rezultat onaj rezultat iz zagrade
    dodaj:
        movl rezZagrada,        %eax   # nemamo 2 pristupa memoriji
        addl %eax,             (%edi)  # dodaj na rezultat izraz iz zagrade
        jc prekoracenje_dodaj_rezultat # došlo je do prekoračenja
        xorl %eax,              %eax   # anuliraj %eax

        pomeriEsi_dodaj:    # pređi na sledeći element u izrazu nakon prolaska kroz izraz u zagradi
            cmpb $')',             (%esi)
            je dalje_d 
            incl %esi
            jmp pomeriEsi_dodaj

        dalje_d:
            incl %esi       # preskoči )
            jmp ucitajOperandOperaciju

    # oduzmi od rezultata onaj rezultat iz zagrade
    oduzimaj:
        movl rezZagrada,        %eax   # nemamo 2 pristupa memoriji
        subl %eax,             (%edi)  # oduzmi od rezultata izraz iz zagrade
        jc prekoracenje_dodaj_rezultat # došlo je do prekoračenja
        xorl %eax,              %eax   # anuliraj %eax
        
         pomeriEsi_oduzimaj:    # pređi na sledeći element u izrazu nakon prolaska kroz izraz u zagradi
            cmpb $')',             (%esi)
            je dalje_d 
            incl %esi
            jmp pomeriEsi_oduzimaj

    # deli sa rezultatom onaj rezultat iz zagrade
    delim:
        movl rezZagrada,        %ebx   # rezultat iz zagrade
        xorl %edx,              %edx   # zbog deljenja div potrebno je anulirati %edx registar
        movl (%edi),            %eax   # trenutni rezultat u eax sačuvaj
        divl %ebx                      # podeli %eax sa %ebx
        movl %eax,             (%edi)  # upiši podeljeno u rezultat
        jc prekoracenje_dodaj_rezultat # došlo je do prekoračenja
        xorl %eax,              %eax   # anuliraj %eax
        
         pomeriEsi_deli:    # pređi na sledeći element u izrazu nakon prolaska kroz izraz u zagradi
            cmpb $')',             (%esi)
            je dalje_d 
            incl %esi
            jmp pomeriEsi_deli

    # mnozi sa rezultatom onaj rezultat iz zagrade
    mnozim:
        movl rezZagrada,        %ebx   # rezultat iz zagrade
        xorl %edx,              %edx   # zbog deljenja div potrebno je anulirati %edx registar
        movl (%edi),            %eax   # trenutni rezultat u eax sačuvaj
        mull %ebx                      # pomnoži %eax sa %ebx
        movl %eax,             (%edi)  # upiši pomnoženo u rezultat
        jc prekoracenje_dodaj_rezultat # došlo je do prekoračenja
        xorl %eax,              %eax   # anuliraj %eax
        
         pomeriEsi_mnozim:    # pređi na sledeći element u izrazu nakon prolaska kroz izraz u zagradi
            cmpb $')',             (%esi)
            je dalje_d 
            incl %esi
            jmp pomeriEsi_mnozim

    # xorluj sa rezultatom onaj rezultat iz zagrade
    eksluzivnoIli:
        movl rezZagrada,        %ebx   # rezultat iz zagrade
        movl (%edi),            %eax   # trenutni rezultat u eax sačuvaj
        xorl  %eax,             %ebx   # xorluj %eax sa %ebx
        movl %ebx,             (%edi)  # upiši xorlovano u rezultat
        jc prekoracenje_dodaj_rezultat # došlo je do prekoračenja
        xorl %eax,              %eax   # anuliraj %eax
        
         pomeriEsi_xorl:    # pređi na sledeći element u izrazu nakon prolaska kroz izraz u zagradi
            cmpb $')',             (%esi)
            je dalje_d 
            incl %esi
            jmp pomeriEsi_xorl

prekoracenje:
    movl $1,    %eax      # izašlo se van opsega kada se broj pretvarao iz stringa u interni oblik
    jmp kraj_konvertujIzrazUInterni

prekoracenje_dodaj_rezultat:
    movl $2,    %eax      # izašlo se van opsega kada se broj dodavao na rezultat
    jmp kraj_konvertujIzrazUInterni

greska_unos:
    movl $3,    %eax      # nije unet validan izraz
    jmp kraj_konvertujIzrazUInterni

nema_greske:
    movl $0,    %eax      # validan izraz, nije se desilo prekoračenje
    jmp kraj_konvertujIzrazUInterni

kraj_konvertujIzrazUInterni:
    popl %ebx
    popl %edi
    popl %esi

    movl %ebp,          %esp
    popl %ebp
    ret

# unsigned int izracunajZagradu(char *izraz, unsigned int *rezultat)
izracunajZagradu:
    pushl   %ebp
    movl    %esp,    %ebp
    
    subl    $4,	     %esp     # zauzimanje prostora na steku za lokalnu promenljivu
    
    pushl   %esi
    pushl   %edi
    pushl   %ebx

    movl  8(%ebp),   %esi     # izraz koji je unet preko terminala (string)
    movl 12(%ebp),   %edi     # adresa neoznačenog 32-bitnog broja u koji smeštamo rezultat  
    xorl    %eax,    %eax     # anuliraj %eax
    movl  $10,       %ecx     # baza dekadnog brojnog sistema je 10 (cifre 0-9)

    movl  $0,     -4(%ebp)    # privremeni rezultat 

preskoci_razmake_sa_pocetka_zagrade:
	cmpb $' ',		   (%esi)	# ako se na početku unosa nalaze razmaci
	jne prviBrojURezultat_zagrade # ako nije razmak, prelazimo na obradu unosa da li je cifra/operacija/zagrada
	incl 				%esi	# preskačemo ih sve dok ne naiđemo na cifru
	jmp preskoci_razmake_sa_pocetka_zagrade

prviBrojURezultat_zagrade:
    # prvi razmak posle broja iskačemo iz konverzije
    cmpb $' ',       (%esi)
    je sacuvajURez_zagrade

    # ako nije nijedna operacija ili zagrada onda je cifra
    cmpb $'0',       (%esi)
    jb greska_unos_zagrade

    cmpb $'9',       (%esi) 
    ja greska_unos_zagrade

    # u pitanju je cifra
    movb (%esi),      %bl   # pomeri cifru u niži registar (8-bitni)
    subb $'0',        %bl   # pretvori znak(cifru) u broj

    xorl %edx,        %edx  # isti razlog resetovanja na 0 kao za div naredbu
    mull %ecx               # pomnoži %eax sa %ecx
    addl %ebx,        %eax  # dodaj konvertovanu cifru u broj (%eax)
    jc  prekoracenje_zagrade        # prekoracenje u konverziji --> carry flag

    incl %esi               # pređi na sledeći element u izrazu
    jmp prviBrojURezultat_zagrade

sacuvajURez_zagrade:
    movl %eax,       (%edi) # u eax se nalazi konvertovani broj
    xorl %eax,        %eax  # anuliraj eax za sledeći broj

ucitajOperandOperaciju_zagrade:
    # da li je obrađen ceo uneti izraz
    cmpb $')',        (%esi)
    je nema_greske_zagrade

    # da li je neka operacija (+, -, *, /, ^)
    # da li je operacija sabiranja
    cmpb  $'+',      (%esi)
    je saberi_zagrade

    # da li je operacija oduzimanja
    cmpb  $'-',      (%esi)
    je oduzmi_zagrade

    # da li je operacija množenja
    cmpb  $'*',      (%esi)
    je mnozi_zagrade

    # da li je operacija sabiranja
    cmpb  $'/',      (%esi)
    je deli_zagrade

    # da li je operacija sabiranja
    cmpb  $'^',      (%esi)
    je xoruj_zagrade

    # da li je razmak, ako jeste, preskoči sve razmake i traži sledeći
    # broj, operaciju ili zagradu
    cmpb  $' ',      (%esi)
    je preskakanjeRazmaka_zagrade

    # ako nije nijedna operacija ili zagrada onda je cifra
    cmpb $'0',       (%esi)
    jb greska_unos_zagrade

    cmpb $'9',       (%esi) 
    ja greska_unos_zagrade

    # u pitanju je cifra
    movb (%esi),      %bl   # pomeri cifru u niži registar (8-bitni)
    subb $'0',        %bl   # pretvori znak(cifru) u broj

    xorl %edx,        %edx  # isti razlog resetovanja na 0 kao za div naredbu
    mull %ecx               # pomnoži %eax sa %ecx
    addl %ebx,        %eax  # dodaj konvertovanu cifru u broj (%eax)
    jc  prekoracenje_zagrade # prekoracenje u konverziji --> carry flag

    incl %esi               # pređi na sledeći element u izrazu
    jmp ucitajOperandOperaciju_zagrade

preskakanjeRazmaka_zagrade:
    cmpb  $' ',      (%esi)
    jne ucitajOperandOperaciju_zagrade
    incl %esi
    jmp preskakanjeRazmaka_zagrade

saberi_zagrade:
    incl %esi # preskaćemo +
        
    preskociRazmakePoslePlusa_zagrade:
        cmpb  $' ',      (%esi)         # ponovo preskačemo sve razmake do prvog broja
        jne traziBroj_zagrade_sabiranje
        incl %esi
        jmp preskociRazmakePoslePlusa_zagrade

        traziBroj_zagrade_sabiranje:
            movl (%edi),      %eax       # prebaci trenutni rezultat u %eax
            movl  %eax,    -4(%ebp)      # prebaci trenutni rezultat u lokalnu promenljivu
            xorl %eax,        %eax       # anuliramo %eax za novi broj

            sab_broj_zagrade:
                cmpb $' ',       (%esi)  # ako sada naidjemo na razmak potrebno je brojeve sabrati
                je sabiranje_zagrade

                cmpb $')',        (%esi) # ako dođemo do kraja izraza, saberemo ta 2 broja na koja smo naišli
                je sabiranje_kraj_zagrade

                cmpb $'0',       (%esi)
                jb greska_unos_zagrade

                cmpb $'9',       (%esi) 
                ja greska_unos_zagrade

                movb (%esi),      %bl   # pomeri cifru u niži registar (8-bitni)
                subb $'0',        %bl   # pretvori znak(cifru) u broj

                xorl %edx,        %edx  # isti razlog resetovanja na 0 kao za div naredbu
                mull %ecx               # pomnoži %eax sa %ecx
                addl %ebx,        %eax  # dodaj konvertovanu cifru u broj (%eax)
                jc  prekoracenje_zagrade # prekoracenje u konverziji --> carry flag

                incl %esi               # pređi na sledeći element u izrazu
                
                jmp sab_broj_zagrade

                sabiranje_zagrade:
                    addl %eax,         -4(%ebp)  # broj koji smo konvertovali se nalazi u %eax
                    movl -4(%ebp),        %edx   # nemamo 2 pristupa memoriji
                    movl %edx,           (%edi)  # na vrednost rezultata
                    jc prekoracenje_dodaj_rezultat_zagrade
                    incl %esi 
                    
                    jmp ucitajOperandOperaciju_zagrade

                sabiranje_kraj_zagrade:
                    addl %eax,         -4(%ebp)  # broj koji smo konvertovali se nalazi u %eax
                    movl -4(%ebp),        %edx   # nemamo 2 pristupa memoriji
                    movl %edx,           (%edi)  # na vrednost rezultata
                    jc prekoracenje_dodaj_rezultat_zagrade
                    jmp nema_greske_zagrade

oduzmi_zagrade:
    incl %esi # preskaćemo -
            
    preskociRazmakePosleMinusa_zagrade:
        cmpb  $' ',      (%esi)                 # ponovo preskačemo sve razmake do prvog broja ili zagrade
        jne traziBroj_zagrade_oduzimanje

        incl %esi
        
        jmp preskociRazmakePosleMinusa_zagrade

        traziBroj_zagrade_oduzimanje:
            movl (%edi),      %eax
            movl  %eax,    -4(%ebp)             # prebaci trenutni rezultat u lokalnu promenljivu
            xorl %eax,        %eax              # anuliramo %eax za novi broj

            oduz_broj_zagrade:
                cmpb $' ',       (%esi)         # ako sada naidjemo na razmak potrebno je od rezultat oduzeti broj koji smo konvertovali
                je oduzimanje_zagrade

                cmpb $')',        (%esi)        # ako dođemo do kraja izraza, oduzmemo ta 2 broja na koja smo naišli
                je oduzimanje_kraj_zagrade

                cmpb $'0',       (%esi)
                jb greska_unos_zagrade

                cmpb $'9',       (%esi) 
                ja greska_unos_zagrade

                movb (%esi),      %bl           # pomeri cifru u niži registar (8-bitni)
                subb $'0',        %bl           # pretvori znak(cifru) u broj
                xorl %edx,        %edx          # isti razlog resetovanja na 0 kao za div naredbu
                mull %ecx                       # pomnoži %eax sa %ecx
                addl %ebx,        %eax          # dodaj konvertovanu cifru u broj (%eax)
                jc prekoracenje_zagrade         # prekoracenje u konverziji --> carry flag
                incl %esi                       # pređi na sledeći element u izrazu
                jmp oduz_broj_zagrade

                oduzimanje_zagrade:
                    subl %eax,         -4(%ebp) # broj koji smo konvertovali se nalazi u %eax, oduzimamo od trenutnog rezultata
                    movl -4(%ebp),        %edx  # nemamo 2 pristupa memoriji
                    movl    %edx,        (%edi) # pomeri izračunato na vrednost rezultata
                    jc prekoracenje_dodaj_rezultat_zagrade
                    incl %esi 
                    jmp ucitajOperandOperaciju_zagrade

                oduzimanje_kraj_zagrade:
                    subl %eax,         -4(%ebp) # broj koji smo konvertovali se nalazi u %eax, oduzimamo od trenutnog rezultata
                    movl -4(%ebp),        %edx  # nemamo 2 pristupa memoriji
                    movl %edx,           (%edi) # pomeri izračunato na vrednost rezultata
                    jc prekoracenje_dodaj_rezultat_zagrade
                    jmp nema_greske_zagrade

mnozi_zagrade:
    incl %esi                                   # preskaćemo *
            
    preskociRazmakePosleZvezdice_zagrade:
        cmpb  $' ',      (%esi)                 # ponovo preskačemo sve razmake do prvog broja ili zagrade
        jne traziBroj_zagrade_mnozenje

        incl %esi
        
        jmp preskociRazmakePosleZvezdice_zagrade

        traziBroj_zagrade_mnozenje:
            movl (%edi),      %eax
            movl  %eax,    -4(%ebp)             # prebaci trenutni rezultat u lokalnu promenljivu
            xorl %eax,        %eax              # anuliramo %eax za novi broj

            mnoz_broj_zagrade:
                cmpb $' ',       (%esi)         # ako sada naidjemo na razmak potrebno je brojeve pomnožiti
                je mnozenje_zagrade

                cmpb $')',        (%esi)        # ako dođemo do kraja izraza, pomnožimo ta 2 broja na koja smo naišli
                je mnozenje_kraj_zagrade

                cmpb $'0',       (%esi)
                jb greska_unos_zagrade

                cmpb $'9',       (%esi) 
                ja greska_unos_zagrade

                movb (%esi),      %bl           # pomeri cifru u niži registar (8-bitni)
                subb $'0',        %bl           # pretvori znak(cifru) u broj

                xorl %edx,        %edx          # isti razlog resetovanja na 0 kao za div naredbu
                mull %ecx                       # pomnoži %eax sa %ecx
                addl %ebx,        %eax          # dodaj konvertovanu cifru u broj (%eax)
                jc prekoracenje_zagrade         # prekoracenje u konverziji --> carry flag
                incl %esi                       # pređi na sledeći element u izrazu
                jmp mnoz_broj_zagrade

                mnozenje_zagrade:
                    movl -4(%ebp), %ebx         # rezultat koji množimo
                    mull %ebx                   # broj koji smo konvertovali se nalazi u %eax, množimo %eax sa %ebx
                    movl    %eax,        (%edi) # pomeri izračanato vrednost rezultata
                    jc prekoracenje_dodaj_rezultat_zagrade
                    incl %esi 
                    jmp ucitajOperandOperaciju_zagrade

                mnozenje_kraj_zagrade:
                    movl -4(%ebp), %ebx         # rezultat koji množimo
                    mull %ebx                   # broj koji smo konvertovali se nalazi u %eax, množimo %eax sa %ebx
                    movl %eax,           (%edi) # pomeri izračunato na vrednost rezultata
                    jc prekoracenje_dodaj_rezultat_zagrade
                    jmp nema_greske_zagrade

deli_zagrade:
            incl %esi                           # preskaćemo /
            
    preskociRazmakePosleDeljenje_zagrade:
        cmpb  $' ',      (%esi)                 # ponovo preskačemo sve razmake do prvog broja ili zagrade
        jne traziBroj_zagrade_deljenje
        incl %esi
        jmp preskociRazmakePosleDeljenje_zagrade

        traziBroj_zagrade_deljenje:
            movl (%edi),      %eax
            movl  %eax,    -4(%ebp)             # prebaci trenutni rezultat u lokalnu promenljivu
            xorl %eax,        %eax              # anuliramo %eax za novi broj

            deljenje_brojeva_zagrade:
                cmpb $' ',       (%esi)         # ako sada naidjemo na razmak potrebno je brojeve podeliti
                je deljenje_zagrade

                cmpb $')',        (%esi)        # ako dođemo do kraja izraza, podelimo ta 2 broja na koja smo naišli
                je deljenje_kraj_zagrade

                cmpb $'0',       (%esi)
                jb greska_unos_zagrade

                cmpb $'9',       (%esi) 
                ja greska_unos_zagrade

                movb (%esi),      %bl           # pomeri cifru u niži registar (8-bitni)
                subb $'0',        %bl           # pretvori znak(cifru) u broj
                xorl %edx,        %edx          # isti razlog resetovanja na 0 kao za div naredbu
                mull %ecx                       # pomnoži %eax sa %ecx
                addl %ebx,        %eax          # dodaj konvertovanu cifru u broj (%eax)
                jc prekoracenje_zagrade         # prekoracenje u konverziji --> carry flag
                incl %esi                       # pređi na sledeći element u izrazu
                jmp deljenje_brojeva_zagrade

                deljenje_zagrade:
                    xorl %edx,      %edx        # divl zahteva da %edx registar anulira !
                    movl -4(%ebp),  %eax        # rezultat koji delimo prebacujemo u %eax
                    movl %eax,      %ebx
                    divl %ebx                   # broj koji smo konvertovali se nalazi u %eax, delimo %eax sa %ebx
                    movl %eax,     (%edi)       # pomeri izračunato na vrednost rezultata
                    jc prekoracenje_dodaj_rezultat_zagrade
                    incl %esi 
                    jmp ucitajOperandOperaciju_zagrade

                deljenje_kraj_zagrade:
                    xorl %edx,      %edx        # divl zahteva da %edx registar anulira !
                    movl %eax,     %ebx
                    movl -4(%ebp), %eax         # rezultat koji množimo
                    divl %ebx                   # broj koji smo konvertovali se nalazi u %eax,  delimo %eax sa %ebx
                    movl %eax,           (%edi) # pomeri izračunato  na vrednost rezultata
                    jc prekoracenje_dodaj_rezultat_zagrade
                    jmp nema_greske_zagrade

xoruj_zagrade:
    incl %esi                                   # preskaćemo ^    
    preskociRazmakePosleKapice_zagrade:
        cmpb  $' ',      (%esi)                 # ponovo preskačemo sve razmake do prvog broja ili zagrade
        jne traziBroj_zagrade_kapice
        incl %esi
        jmp preskociRazmakePosleKapice_zagrade

        traziBroj_zagrade_kapice:
            movl (%edi),      %eax
            movl  %eax,    -4(%ebp)             # prebaci trenutni rezultat u lokalnu promenljivu
            xorl %eax,        %eax              # anuliramo %eax za novi broj

            xor_broj_zagrade:
                cmpb $' ',       (%esi)         # ako sada naidjemo na razmak potrebno je brojeve xorovati
                je exili_zagrade

                cmpb $')',        (%esi)        # ako dođemo do kraja izraza, xorujemo ta 2 broja na koja smo naišli
                je exili_kraj_zagrade

                cmpb $'0',       (%esi)
                jb greska_unos_zagrade

                cmpb $'9',       (%esi) 
                ja greska_unos_zagrade

                movb (%esi),      %bl           # pomeri cifru u niži registar (8-bitni)
                subb $'0',        %bl           # pretvori znak(cifru) u broj

                xorl %edx,        %edx          # isti razlog resetovanja na 0 kao za div naredbu
                mull %ecx                       # pomnoži %eax sa %ecx
                addl %ebx,        %eax          # dodaj konvertovanu cifru u broj (%eax)
                jc prekoracenje_zagrade         # prekoracenje u konverziji --> carry flag
                incl %esi                       # pređi na sledeći element u izrazu
                jmp xor_broj_zagrade

                exili_zagrade:
                    movl -4(%ebp), %ebx         # rezultat koji xorujemo
                    xorl %eax,  %ebx            # broj koji smo konvertovali se nalazi u %eax, xorlovanje %eax sa %ebx
                    movl    %eax,        (%edi) # pomeri izračunato na vrednost rezultata
                    jc prekoracenje_dodaj_rezultat_zagrade
                    incl %esi 
                    jmp ucitajOperandOperaciju_zagrade

                exili_kraj_zagrade:
                    movl -4(%ebp), %ebx         # rezultat koji xorujemo
                    xorl %eax,  %ebx            # broj koji smo konvertovali se nalazi u %eax, xorlovanje %eax sa %ebx
                    movl %eax,           (%edi) # pomeri izračunato na vrednost rezultata
                    jc prekoracenje_dodaj_rezultat_zagrade
                    jmp nema_greske_zagrade

prekoracenje_zagrade:
    movl $1,    %eax                            # izašlo se van opsega kada se broj pretvarao iz stringa u interni oblik
    jmp kraj_izracunajZagradu

prekoracenje_dodaj_rezultat_zagrade:
    movl $2,    %eax                            # izašlo se van opsega kada se broj dodavao na rezultat
    jmp kraj_izracunajZagradu

greska_unos_zagrade:
    movl $3,    %eax                            # nije unet validan izraz
    jmp kraj_izracunajZagradu

nema_greske_zagrade:
    movl $0,    %eax                            # validan izraz, nije se desilo prekoračenje
    jmp kraj_izracunajZagradu

kraj_izracunajZagradu:
    popl %ebx
    popl %edi
    popl %esi

    movl %ebp,          %esp
    popl %ebp
    ret