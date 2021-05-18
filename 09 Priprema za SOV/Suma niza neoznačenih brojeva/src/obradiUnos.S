.section .text
.global obradiUnos

# void obradiUnos(char *unos, unsigned *greska, unsigned *suma1, unsigned *suma2)
obradiUnos:
    pushl %ebp
    movl  %esp,       %ebp

    subl  $16,        %esp

    pushl %esi
    pushl %ebx

    movl  8(%ebp),    %esi     # uneti string
    xorl    %eax,     %eax     # anuliraj %eax
    movl  $0,     -12(%ebp)    # anuliraj prvu sumu
    movl  $0,     -16(%ebp)    # anuliraj drugu sumu
    incl  %esi                 # prvi unos je svakako [
    
ucitajInterval:
    cmpb  $']',      (%esi)    # da li je gotov trenutni broj ?
    je ucitavanjeNizaBrojeva

    # da li je razmak, ako jeste ignoriši ga
    cmpb $' ',       (%esi)
    je uvecajAdresu_interval

    # da li je zarez, onda ide sledeci broj
    cmpb $',',       (%esi)
    je sledeciBroj_interval

    cmpb $'0',       (%esi)
    jb greska_unos

    cmpb $'9',       (%esi) 
    ja greska_unos

    # u pitanju je cifra
    xorl  %edx,       %edx
    movb (%esi),      %bl
    subb $'0',        %bl
    movl $10,         %ecx
    mull %ecx
    addl %ebx,        %eax
    jc  prekoracenje           # prekoracenje --> carry flag

    jmp uvecajAdresu_interval

sledeciBroj_interval:
    movl %eax,     -4(%ebp)    # donja granica
    xorl %eax,        %eax     # anuliranje
    incl %esi                  # pomeri se na sledeci broj od zareza

ucitavanje_gornje_granice:    
    cmpb  $']',      (%esi)    # da li je gotov trenutni broj ?
    je ucitavanjeNizaBrojeva

    # da li je razmak, ako jeste ignoriši ga
    cmpb $' ',       (%esi)
    je uvecajAdresu_ucitavanje_gornje_granice

    # ako je zapeta posle gornje granice, sledeci ], uvecaj adresu, pa iskoci
    cmpb $',',       (%esi)
    je uvecajAdresu_ucitavanje_gornje_granice

    cmpb $'0',       (%esi)
    jb greska_unos

    cmpb $'9',       (%esi) 
    ja greska_unos

    # u pitanju je cifra
    xorl  %edx,       %edx
    movb (%esi),      %bl
    subb $'0',        %bl
    movl $10,         %ecx
    mull %ecx
    addl %ebx,        %eax
    jc  prekoracenje           # prekoracenje --> carry flag
    jmp uvecajAdresu_ucitavanje_gornje_granice

ucitavanjeNizaBrojeva:
    movl %eax,     -8(%ebp)    # gornja granica
    xorl %eax,        %eax     # anuliranje

    addl $2,          %esi     # prelazimo dalje

brojevniNiz:
    # da li je kraj niza brojeva ?
    cmpb $'}',       (%esi)
    je setZeroError            # sve je prošlo okej, greške nema

    # ucitaj broj i proveri da li je u intervalu
    # ako je u intervalu pozovi sumiraj i dodaj na sumu_1
     # da li je razmak, ako jeste ignoriši ga
    cmpb $' ',       (%esi)
    je broj_niz_uvecaj_adresu

    # ako je zarez i-ti broj je obradjen, proveri da li je u intervalu
    # i sumiraj u odgovarajucu sumu
    cmpb $',',       (%esi)
    je proveriAnulirajSumiraj

    cmpb $'0',       (%esi)
    jb greska_unos

    cmpb $'9',       (%esi) 
    ja greska_unos

    # u pitanju je cifra
    xorl  %edx,       %edx
    movb (%esi),      %bl
    subb $'0',        %bl
    movl $10,         %ecx
    mull %ecx
    addl %ebx,        %eax
    jc  greska_unos           # prekoracenje --> carry flag

broj_niz_uvecaj_adresu:
    incl %esi
    jmp brojevniNiz

proveriAnulirajSumiraj:
    # u %eax se nalazi trenutni broj
    # donja granica je u -4(%ebp)
    # gornja granica je u -8(%ebp)
    cmpl -4(%ebp),    %eax
    jb sumiraj_u_2

    cmpl -8(%ebp),    %eax
    ja sumiraj_u_2

sumiraj_u_1:
    addl %eax,    -12(%ebp)   # prva suma
    jc prekoracenje_sume

    xorl %eax,        %eax    # anuliraj %eax
    jmp broj_niz_uvecaj_adresu

sumiraj_u_2:
    addl %eax,    -16(%ebp)   # druga suma
    jc prekoracenje_sume

    xorl %eax,        %eax    # anuliraj %eax
    jmp broj_niz_uvecaj_adresu

uvecajAdresu_ucitavanje_gornje_granice:
    incl %esi
    jmp ucitavanje_gornje_granice

uvecajAdresu_interval:
    incl %esi
    jmp ucitajInterval

prekoracenje:
    movl 12(%ebp),    %ebx     # greška 
    movl $1,         (%ebx)
    jmp obradiUnos_kraj

prekoracenje_sume:
    movl 12(%ebp),    %ebx     # greška 
    movl $1,         (%ebx)
    jmp obradiUnos_kraj

setZeroError:
    movl 12(%ebp),    %ebx     # greška 
    movl $0,         (%ebx)

    movl 16(%ebp),    %ecx     # prva suma
    movl 20(%ebp),    %edx     # druga suma

    movl -12(%ebp),   %eax     # prva suma
    movl    %eax,    (%ecx)    # prva suma

    movl -16(%ebp),   %eax     # druga suma
    movl    %eax,    (%edx)    # druga suma

    movl 12(%ebp),    %ebx     # greška 
    movl $0,         (%ebx)

    jmp obradiUnos_kraj

greska_unos:
    movl 12(%ebp),    %ebx     # greška 
    movl $2,         (%ebx)

obradiUnos_kraj:
    popl %esi
    movl %ebp,        %esp
    popl %ebp
    ret