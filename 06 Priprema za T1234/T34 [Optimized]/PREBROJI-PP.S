# PR55-2020 Jovanović Danijel
.section .data
.section .text
.global prebroji

# unsigned int prebroji(char *str, char c);

prebroji:
    pushl %ebp              # početak potprograma
    movl  %esp,     %ebp

    # registri koji se koriste
    pushl %ebx
    pushl %esi
    pushl %edi
    subl  $4,       %esp    # prostor za lokalnu promenljivu
   
    movl 12(%ebp),  %ebx    # znak koji trazimo
    movl  8(%ebp),  %esi    # početak stringa
    movl  8(%ebp),  %edi    # kraj stringa
    addl $20,       %edi    # kraj stringa
    movl $0,     -4(%ebp)   # brojac pojava

petlja:
    cmpl %esi, %edi         # da li smo stigli do kraja stringa?
    je kraj
    jne provera

provera:
    movb  (%esi),   %dl     # sačuvaj trenutni element u manji registar
    cmpb  %bl,      %dl     # da li je to znak koji se traži ?
    je pronadjen_znak
    jmp uvecaj_adresu

pronadjen_znak:
    addl $1, -4(%ebp)       # broj pronadjenih znakova uvecaj za 1

uvecaj_adresu:
    addl $1, %esi           # predji na sledeci element
    jmp petlja              # nastavi dalje pretragu

kraj:
    movl -4(%ebp),  %eax    # broj pojava je povr. vrednost f-je

    # restauracija registara
    popl %edi
    popl %esi
    popl %ebx

    movl %ebp, %esp
    popl %ebp
    ret
