# SOV: Poljska notacija
# "1 2 3 + + 3 4 + +"
# Izračunati rezultat i ispisati vrednost na ekran.
# IDEJA: Push brojeve na stek sve dok se ne naidje na +
# kad se naidje na + dva broja se skidaju sa vrha steka
# saberu se i rezultat se push na stek, tako dok na kraju
# ne ostane samo jedan broj i taj jedan broj je rezultat izraza

.section .data
    poruka1: .ascii "Unesite izraz u formatu poljske notacije: \0"
    poruka1_len = . - poruka1

    poruka2: .ascii "Rezultat izraza je: \0"
    poruka2_len = . - poruka2

    rezultat_ispis: .fill 20, 1, 0
    izraz:          .fill 20, 1, 0

    porukaGreska:   .ascii "Izraz nije unet u validnom formatu!\n\0"
    pg_len = . - porukaGreska

    newLine:        .ascii "\n\0"

    greskaB:        .long 0
.section .text

.global poljska_notacija
.global konvertujBrojUString
.global main

main:
    movl $4,             %eax
    movl $1,             %ebx
    leal poruka1,        %ecx
    movl $poruka1_len,   %edx
    int $0x80

    # ucitavanje izraza
    movl $3,             %eax
    movl $0,             %ebx
    leal izraz,          %ecx
    movl $20,            %edx
    int $0x80

    # poljska notacija racunanje
    # unsigned int poljska_notacija(char *izraz);
    # u %eax se nalazi rezultat ili 0 ako je nevalidan izraz
    pushl $izraz
    call poljska_notacija
    addl $4,             %esp

    cmpl $0,             %eax
    je greska
    
    # void konvertujBrojUString(unsigned int broj, char *izrazZaIspis);
    pushl $rezultat_ispis
    pushl %eax
    call konvertujBrojUString
    addl $8,             %esp

    # ispis rezultata
    movl $4,             %eax
    movl $1,             %ebx
    leal poruka2,        %ecx
    movl $poruka2_len,   %edx
    int $0x80

    movl $4,             %eax
    movl $1,             %ebx
    leal rezultat_ispis, %ecx
    movl $20,            %edx
    int $0x80 

    # novi red
    movl $4,             %eax
    movl $1,             %ebx
    leal newLine,        %ecx
    movl $2,             %edx
    int $0x80 

    jmp kraj

greska:
    movl $4,             %eax
    movl $1,             %ebx
    leal porukaGreska,   %ecx
    movl $pg_len,        %edx
    int $0x80 

    incb greskaB

kraj:
    movl $1,            %eax
    movl greskaB,       %ebx
    int $0x80

# unsigned int poljska_notacija(char *izraz)
poljska_notacija:
    pushl %ebp
    movl  %esp,         %ebp
    pushl %esi
    pushl %edi
    pushl %ebx


    movl 8(%ebp),       %esi
    movl $0,            %ecx      # privremeni rezultat
    movl $0,            %ebx      # koliko je brojeva na steku, ako je brojač < 2, a sledeći znak +
                                  # prekinuti rad programa i vratiti poruku o nevalidnom izrazu.
    provera:
        cmpb $10,          (%esi)  # kraj stringa ?
        je validanIzraz

        movb (%esi),        %dl
        
        cmpb $'+',          %dl
        je saberi

        cmpb $' ',          %dl
        je uvecajAdresu

        # onda je broj u pitanju, dodaj na stek
        subb $'0',          %dl
        pushl %edx
        incl %esi
        incl %ebx
    
        jmp provera

    uvecajAdresu:
        incl %esi
        jmp provera

    saberi:
        cmpl $2,      %ebx   # da li su barem 2 broja na steku ?
        jl nevalidanIzraz

        popl          %eax
        movl  $0,     %edx
        addl  %eax,   %edx   # saberi 2 broja sa vrha steka

        popl  %eax
        addl  %eax,   %edx

        pushl %edx           # rezultat postavi na stek
	    incl %esi
        decl %ebx            # imamo broj manje na steku

        jmp provera

    validanIzraz:
        cmpl $1,      %ebx   # da li je preostao samo jedan broj na steku ?
        jg nevalidanIzraz

        popl %eax
        jmp kraj_poljska_notacija

    nevalidanIzraz:
        movl $0,         %eax  # došlo je do greške

kraj_poljska_notacija:
    popl %edi
    popl %esi

    movl %ebp,           %esp
    popl %ebp
    ret

# void konvertujBrojUString(unsigned int broj, char *izrazZaIspis);
konvertujBrojUString:
    pushl   %ebp
    movl    %esp,         %ebp
    pushl   %esi
    pushl   %edi
    pushl   %ebx

    movl  8(%ebp),        %eax  # broj za konverziju
    movl 12(%ebp),        %esi  # string u koji smeštamo rezultat
    movl $10,             %ecx  # baza

    cifraToStr:
        xorl %edx,        %edx
        divl %ecx
                                # u %edx se nalazi ostatak deljenja
        addb $'0',        %dl
        movb %dl,        (%esi)
        incl %esi               # predji na sledeci element niza

        andl %eax,        %eax  # ceo rezultat smo konvertovali ?
        jz invertuj
        jmp cifraToStr

    invertuj:
        movl $0,          %ebx  # brojač lokacija povećaj za 1
        movl 12(%ebp),    %esi  # string u koji smeštamo rezultat
            
        nadjiKrajStringa:
            cmpb $0,   (%esi)
            je _inicijalizuj

            incl %esi
            incl %ebx
            jmp nadjiKrajStringa
        
        _inicijalizuj:
            movl 12(%ebp),    %esi  # string u koji smeštamo rezultat
            movl 12(%ebp),    %edi  # string u koji smeštamo rezultat
            addl    %ebx,     %edi  # kraj prvog stringa

        obrni:
            cmpl    %esi,    %edi   # kraj stringa?
            je kraj_konvertujBrojUString

            # zameni prvi i poslednji, ...
            movb   (%esi),   %bl
            movb   (%edi),   %dl

            movb    %bl,    (%edi)
            movb    %dl,    (%esi)

            incl    %esi
            decl    %edi
            jmp obrni
    
kraj_konvertujBrojUString:
    popl %ebx
    popl %edi
    popl %esi

    movl %ebp,          %esp
    popl %ebp
    ret
