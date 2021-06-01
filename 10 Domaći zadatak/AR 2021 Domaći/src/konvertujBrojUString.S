.section .text
.global konvertujBrojUString

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