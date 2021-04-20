# autor: Danijel Jovanović PR55-2020
.section .data
    maks_unos = 50 + 1

    prompt_1: .ascii "Unesite string: \0"
    prompt_1_len  = . - prompt_1

    prompt_2: .ascii "Enkodovan string: \0"
    prompt_2_len = . - prompt_2

    unos: .fill maks_unos, 1, 42

    unetoZnakova: .long 0
.section .text
.global main

main:
    # ispis poruke za unos
    movl $4,            %eax
    movl $1,            %ebx
    leal prompt_1,      %ecx
    movl $prompt_1_len, %edx
    int $0x80

    # ucitavanje stringa
    movl $3,            %eax
    movl $0,            %ebx
    leal unos,          %ecx
    movl $maks_unos,    %edx
    int $0x80 

    movl %eax,          unetoZnakova # optimizacije radi se cuva broj unetih char

_start:
    movl $unos,         %esi    # pocetak stringa
    movl $unos,         %edi
    addl unetoZnakova,  %edi    # kraj stringa
    decl                %edi    # '\n' ne menjamo!

krajStringa:
    cmpl %esi,          %edi
    je enkodovan_ispis

# (*s1 >= 'a' && *s1 <= 'm')
od_a_do_m:
    cmpb $'a',         (%esi)
    je plus_13
    jg manje_jednako_m
    jl od_A_do_M

manje_jednako_m:
    cmpb $'m',         (%esi)
    jle plus_13

# (*s1 >= 'n' && *s1 <= 'z')
od_n_do_z:
    cmpb $'n',         (%esi)
    je minus_13
    jg manje_jednako_z

manje_jednako_z:
    cmpb $'z',         (%esi)
    jle minus_13

# (*s1 >= 'A' && *s1 <= 'M')
od_A_do_M:
    cmpb $'A',         (%esi)
    je plus_13
    jg manje_jednako_M
    jl uvecajAdresu             # velika verovatnoca da znak nije slovo! (silne crtice umesto space dodate...)

manje_jednako_M:
    cmpb $'M',         (%esi)
    jle plus_13

# (*s1 >= 'N' && *s1 <= 'Z')
od_N_do_Z:
    cmpb $'N',         (%esi)
    je minus_13
    jg manje_jednako_Z

manje_jednako_Z:
    cmpb $'Z',         (%esi)
    jle minus_13

uvecajAdresu:
    incl %esi
    jmp krajStringa

plus_13:
    addb $13,          (%esi)
    jmp uvecajAdresu

minus_13:
    subb $13,          (%esi)
    jmp uvecajAdresu

enkodovan_ispis:
    # ispis poruke za enkodovano
    movl $4,            %eax
    movl $1,            %ebx
    leal prompt_2,      %ecx
    movl $prompt_2_len, %edx
    int $0x80

    # enkodovan string
    movl $4,            %eax
    movl $1,            %ebx
    leal unos,          %ecx
    movl unetoZnakova,  %edx
    int $0x80

kraj:
    movl $1,            %eax
    movl $0,            %ebx
    int $0x80