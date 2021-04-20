# PR55-2020 Jovanovic Danijel

# Povratna vrednost neka bude broj izmena napravljenih u datom stringu
.section .text
.global Rot13

# int Rot13(unsigned char *s1)
Rot13:
    pushl   %ebp
    movl    %esp,       %ebp
    pushl   %esi

    movl  8(%ebp),      %esi        # unsigned char *s1
    movl  $0,           %eax        # broj izmena

krajStringa:
    movb (%esi),        %dl         # na greskama se uci ;)
    cmpb  $10,          %dl
    je kraj

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
    incl                %eax
    jmp uvecajAdresu

minus_13:
    subb $13,          (%esi)
    incl                %eax
    jmp uvecajAdresu

kraj:
    popl    %esi
    movl    %ebp,       %esp
    popl    %ebp
    ret