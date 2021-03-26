.section .data
    str:     .ascii "     razmaci\0"
    razm:    .long 0
.section .text
.global main

main:
    movl $str, %eax         # adresa stringa
    movl $0,   %ebx         # broj razmaka
    movl $str, %esi         # odakle se kopira element niza
    movl $str, %edi         # u sta se kopira element niza
    movl $0,   %edx         # pomocni registar, za cuvanje trenutnog elementa

razmaci:
    cmpl $' ',   (%eax)     # da li je razmak?
    je uvecajBrRazm
    jne shiftNiza

uvecajBrRazm:
    incl %ebx               # broj razmaka za 1 veci
    incl %eax               # predji na sled. elem
    jmp razmaci

shiftNiza:
    addl %ebx,    %esi      # prvi korisni podatak posle razmaka
    movl (%esi),  %edx      # sacuvaj trenutni element za kopiranje
    movl %edx,    %edi      # upisi ga na pocetak niza, drugi indeks, itd

    cmpl $0, %ebx           # da li smo sve razmake uklonili?
    jne povecajAdrese
    je shiftujDoKrajaNiza   # svi razmaci potroseni, prebaci sve do kraja '\0'

povecajAdrese:
    addl $4, %esi           # predji na sledeci element
    addl $4, %edi           # predji na sledeci element
    decl     %ebx           # smanji broj preostalih razmaka za 1 
    jmp shiftNiza           # vrati se na shift niza     

shiftujDoKrajaNiza:
    cmpl $str+12, %esi
    je krajStringa
    jne pomerajElementa     # nije kraj niza, pomeri element

pomerajElementa:
    movl (%esi),  %edx      # sacuvaj trenutni element za kopiranje
    movl %edx,    %edi      # upisi ga na pocetak niza, drugi indeks, itd
    addl $4, %esi           # predji na sledeci element
    addl $4, %edi           # predji na sledeci element
    jmp shiftujDoKrajaNiza  # pokusaj dalji pomeraj elementa

krajStringa:
    addl $4, %esi           # predji na sledeci element (koji nije koristan nakon pomeranja)
    movl $0, %esi           # dodaj '\0'

kraj:
    movl $1, %eax
    movl $0, %ebx
    int $0x80
