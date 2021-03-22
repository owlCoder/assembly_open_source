# Pronalazenje maksimuma niza
.section .data
    maximum: .long 0
    niz_l: .long 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
    N = 10

.section .text
.global main

main:
    movl $niz_l,    %esi    # indeks od kog počinjemo
    movl niz_l,     %eax    # najveci element u nizu

provera:
    cmpl %eax, (%esi)
    jb promeni_max
    jmp uvecaj_adresu

promeni_max:
    movl (%esi), %eax

uvecaj_adresu:
    movl $4, %esi
    jmp provera

kraj:
    movl %eax, maximum         # iz registra u maximum
    movl $1, %eax
    movl $0, %ebx
    int $0x80
