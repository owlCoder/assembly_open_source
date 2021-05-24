# Napisati program koji će sve cifre heksadecimalnog celog broja koje su zadate malim
# slovima pretvoriti u velika slova.

.section .data
    por1:    .ascii "Unesite heksadecimalni broj: \0"
    p1_len = . - por1

    greska1: .ascii "GRESKA: Problem prilikom konverzije.\n\0"
    g1_len = . - greska1

    greska2: .ascii "GRESKA: Prekoracenje odredista.\n\0"
    g2_len = . - greska2

    m_in = 50 + 1
    unos:    .fill  m_in, 1, 0
    greska:  .long 0
.section .text
.global main

main:
    # ispis poruke
    movl $4,        %eax
    movl $1,        %ebx
    leal por1,      %ecx
    movl $p1_len,   %edx
    int $0x80

    # unos stringa
    movl $3,        %eax
    movl $0,        %ebx
    leal unos,      %ecx
    movl $m_in,     %edx
    int $0x80

    # da li je uneti broj veći od 8 mesta ?
    decl %eax
    cmpl $10,        %eax
    ja greskaOdredista

    movl $unos,     %esi
    cmpb $10,      (%esi)
    je greskaKonverzija

    cmpb $'0',     (%esi)
    jne greskaKonverzija

    cmpb $'X',    1(%esi)
    jb greskaKonverzija

    cmpb $'x',    1(%esi)
    ja greskaKonverzija

    addl $2,        %esi # preskacemo 0x sekvencu

proveriUnos:
    cmpb $10,      (%esi)
    je ispisBroja

    cmpb $'0',     (%esi)
    jb greskaKonverzija

    cmpb $'9',     (%esi)
    ja daLiJeSlovo

dalje:
    incl            %esi
    jmp proveriUnos

daLiJeSlovo:
    cmpb $'A',     (%esi)
    jb greskaKonverzija

    cmpb $'F',     (%esi)
    ja maloSlovo

    jmp dalje

maloSlovo:
    cmpb $'a',     (%esi)
    jb greskaKonverzija

    cmpb $'f',     (%esi)
    ja greskaKonverzija

    movb (%esi),    %bl
    subb  $32,      %bl
    movb  %bl,     (%esi)

    jmp dalje

greskaKonverzija:
    # ispis greske
    movl $4,        %eax
    movl $1,        %ebx
    leal greska1,   %ecx
    movl $g1_len,   %edx
    int $0x80
    
    incl            greska
    jmp kraj

greskaOdredista:
    # ispis greske
    movl $4,        %eax
    movl $1,        %ebx
    leal greska2,   %ecx
    movl $g2_len,   %edx
    int $0x80
    
    incl            greska
    jmp kraj

ispisBroja:
    # ispis greske
    movl $4,        %eax
    movl $1,        %ebx
    leal unos,      %ecx
    movl $m_in,     %edx
    int $0x80

kraj:
    movl $1,        %eax
    movl greska,    %ebx
    int $0x80