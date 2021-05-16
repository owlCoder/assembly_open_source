.section .text
.global konvertujBrojUString

# unsigned int konvertujBrojUString(unsigned int broj, char *izrazZaIspis, unsigned int baza);
konvertujBrojUString:
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
    js negativan
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

negativan:
    movl $1,   -4(%ebp) # broj je negativan
    movb $'-',   (%esi) # upisi minus kao predznak
    incl %esi           # predji na sledecu cifru
    incl 12(%ebp)
    negl %eax
    jmp cifraToStr

kraj_konvertujBrojUString:
    popl %ebx
    popl %edi
    popl %esi

    movl %ebp,          %esp
    popl %ebp
    ret
