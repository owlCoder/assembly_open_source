.section .text
.global izracunajZagradu

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

            deli_broj_zagrade:
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
                jmp deli_broj_zagrade

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