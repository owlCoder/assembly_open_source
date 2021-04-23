# PR55-2020 Jovanovic Danijel
.section .text
.global modifikuj

# unsigned int modifikuj(char *string, char *znakovi)
modifikuj:
    pushl %ebp
    movl  %esp, 	%ebp

    pushl %esi
    pushl %edi
    pushl %ebx

    movl  8(%ebp),      %esi     # prvi string
    movl 12(%ebp),   	%edi     # znakovi za izmenu
    movl $0,            %eax     # povratna vrednost potprograma
    movl $0, 	        %ebx     # maloSlovo = 0 (nije malo slovo), u suprotnom jeste malo slovo

krajStringa:
    cmpb $10,	       (%esi)    # da li smo obradili sve znakove u stringu ?
    je kraj

malo_ili_veliko_slovo:
    movb (%esi),	%dl      # trenutni znak iz prvog stringa cuvamo
    veliko_slovo:
        cmpb $'A',      %dl
        jl resetuj  	         # ako je manji od 'A' verovatno nije ni slovo
        
        cmpb $'Z',      %dl
        jg malo_slovo	         # mozda je malo slovo

        movl $0,        %ebx     # slovo je veliko tj nije malo
                                 # ako je veliko slovo odmah dodaj 32
        jmp pretrazi_drugi_string_za_trazenim_znakom  
    
    malo_slovo:
        cmpb $'z',      %dl
        jg resetuj	             # nije ni malo ni veliko slovo
        
        cmpb $'a',      %dl
        jl resetuj
        
        movl $1,        %ebx     # slovo je malo

pretrazi_drugi_string_za_trazenim_znakom:
    cmpb $10,          (%edi)    # da li smo prosli ceo niz zadatakih karaktera
    je resetuj                   # ako jesmo ponovo krecemo otpocetka drugog stringa, i pomeramo se za 1 adresu
                                 # u prvom stringu
    cmpb (%edi),	%dl      # uporedi da li je trenutni znak iz drugog stringa jednak znaku iz prvog stringa (%dl)
    je promeniSlovo              # ako su jednaki +/- 32
    
    incl %edi                    # ako nisu, predji na sledeci trazeni znak iz drugog stringa
    jmp pretrazi_drugi_string_za_trazenim_znakom

promeniSlovo:
    cmpl $1,            %ebx     # ako je malo slovo oduzmi 32, ako je veliko dodaj 32
    je oduzmi32
    jl dodaj32

oduzmi32:
    subb $32,          (%esi)
    incl 		%eax      # desila se izmena, uvecaj povratnu vrednost za 1
    jmp resetuj

dodaj32:
    addb $32, 	       (%esi)
    incl                %eax	  # desila se izmena, uvecaj povratnu vrednost za 1
    jmp resetuj
        
resetuj:
    movl  12(%ebp),     %edi      # nismo nasli znak koji smo trazili u drugom stringu
    incl     %esi	              # prelazimo na sledeci znak u prvom stringu, a drugi gledamo ponovo otpocetka
    jmp krajStringa

kraj:
    popl %ebx			          # restauracija registara
    popl %edi
    popl %esi

    movl %ebp,		%esp
    popl %ebp
    ret
