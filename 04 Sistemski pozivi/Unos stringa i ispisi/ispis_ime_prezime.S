.section .data
    # ne definisati ovde nijedan string, program neće raditi
    str_max = 40

    unos:    .ascii "Unesite ime i prezime: \0"
    len = . - unos

    str:     .fill str_max, 1, 42  # 42 - ascii '*'
    # program radi sasvim korektno

    ispis:   .ascii "Vi ste: \0"
    len2 = . - ispis
    # takođe ni ovde ne definisati nijedan string, program neće raditi
.section .text

.global main

main:
    # ispis poruke
    movl $4,        %eax
    movl $1,        %ebx
    movl $unos,     %ecx
    movl $len,      %edx
    int $0x80

    movl $3,       %eax         # stdin
    movl $0,       %ebx         # tastatura
    leal str,      %ecx         # efektivna adresa
    movl $str_max, %edx         # adresa u registar
    int $0x80   

    movl %eax,     %esi         # broj unetih karaktera
    movl $unos,    %eax         # adresa stringa

upcase:
    cmpb $'a', (%eax)           # provera da li je malo slovo
    jb dalje
    cmpb $'z', (%eax)
    ja dalje
    addb $'A'-'a', (%eax)       # ako jeste malo slovo, UPCASE
                                # 'A'-'a' je razlika između ASCII kodova za veliko i malo A
dalje:
    incl %eax
    cmpb $10, (%eax)            # kod read poziva, string se završava sa 10
    jne upcase

    # ispis
    movl $4,        %eax
    movl $1,        %ebx
    movl $ispis,    %ecx
    movl $len2,     %edx
    int $0x80
    
    # ispis
    movl $4,        %eax
    movl $1,        %ebx
    movl $str,      %ecx
    movl %esi,      %edx   # može i veličina
    int $0x80

kraj:
    movl $1, %eax
    movl $0, %ebx
    int $0x80
