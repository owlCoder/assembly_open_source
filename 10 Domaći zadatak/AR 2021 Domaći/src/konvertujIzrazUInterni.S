.section .data
    rezZagrada: .long 0
    operacija: .byte 0
.section .text
.global konvertujIzrazUInterni

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
        jne traziZagraduIliBroj_Deljenje

        incl %esi
        jmp preskociRazmakePosleDeljenje

        traziZagraduIliBroj_Deljenje:
            movl (%edi),      %eax
            movl  %eax,    -4(%ebp)      # prebaci trenutni rezultat u lokalnu promenljivu
            xorl %eax,        %eax       # anuliramo %eax za novi broj

            movb $'/',        operacija
            cmpb $'(',       (%esi)
            je obradiZagradu

            deli_broj:
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
                jmp deli_broj

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