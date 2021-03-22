# Pronalazenje maksimuma niza
.section .data
    maximum: .long 0
    niz_l: .long 1, 2, 3, 40, 5, 6, 7, 8, 9, 10
    N = 10
.section .text
.global main

main:
    movl $niz_l,    %esi    # indeks od kog počinjemo
    movl  niz_l,    %eax    # najveci element u nizu

provera:
    cmpl $niz_l+N*10, %esi  # da li smo stigli do kraja?  
    je kraj

    cmpl %eax, (%esi)       # da li ima veci od trenutnog?
    ja promeni_max          # promeni trenutni na max
    jmp uvecaj_adresu       # sledeci element

promeni_max:
    movl (%esi), %eax       # zamena trenutnog na mesto max

uvecaj_adresu:
    addl $4, %esi
    jmp provera

kraj:
    movl %eax, maximum         # iz registra u maximum
    movl $1, %eax
    movl $0, %ebx
    int $0x80
