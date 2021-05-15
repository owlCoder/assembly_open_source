.section .text
.global konvertujBrojUString

# void konvertujBrojUString(unsigned int broj, char *izrazZaIspis);
konvertujBrojUString:
    pushl   %ebp
    movl    %esp,         %ebp
    pushl   %esi
    pushl   %edi
    pushl   %ebx

    movl  8(%ebp),        %eax  # broj za konverziju
    movl 12(%ebp),        %esi  # string u koji smeštamo rezultat
    movl $10,             %ecx  # baza
    
    movl     %eax,        %ebx
    incl     %ebx
    movl     %ebx,        %eax
    # proveriti za incl %eax

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
        movl $0,          %ebx  # brojač lokacija povećaj za 1
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
