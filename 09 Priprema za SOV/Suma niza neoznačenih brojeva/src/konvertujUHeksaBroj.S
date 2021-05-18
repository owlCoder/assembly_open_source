.section .text
.global konvertujUHeksaBroj

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
    movb (%esi),          %bl

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
        cmpb $10,       (%esi)
        je hex_A

        cmpb $11,       (%esi)
        je hex_B

        cmpb $12,       (%esi)
        je hex_C

        cmpb $13,       (%esi)
        je hex_D

        cmpb $14,       (%esi)
        je hex_E

        cmpb $15,       (%esi)
        je hex_F

        addb $'0',        %dl
        movb %dl,        (%esi)

        provera:
            incl %esi               # predji na sledeci element niza
            andl %eax,        %eax  # ceo rezultat smo konvertovali ?
            jz invertuj
            jmp cifraToStr

        hex_A:
            movb $'A',           (%esi)
            jmp provera

        hex_B:
            movb $'B',           (%esi)
            jmp provera

        hex_C:
            movb $'C',           (%esi)
            jmp provera

        hex_D:
            movb $'D',           (%esi)
            jmp provera

        hex_E:
            movb $'E',           (%esi)
            jmp provera

        hex_F:
            movb $'F',           (%esi)
            jmp provera

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
            je kraj_konvertujUHeksaBroj

            # zameni prvi i poslednji, ...
            cmpb $0,         (%esi)   # da li je prazan string?
            je kraj_konvertujUHeksaBroj

            movb   (%esi),   %dl
            movb   (%edi),   %dh

            movb    %dl,    (%edi)
            movb    %dh,    (%esi)

            incl    %esi
            decl    %edi
            incl    %ebx
            jmp obrni

kraj_konvertujUHeksaBroj:
    popl %ebx
    popl %edi
    popl %esi

    movl %ebp,          %esp
    popl %ebp
    ret