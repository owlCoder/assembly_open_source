.section .data
    krajnjaPoruka:  .ascii "String posle ciscenja razmaka:\n"    # ova poruka mora na vrhu, izaziva cudan overflow
    KPlen =         . - krajnjaPoruka                            # bafera ako nije na vrhu data sekcije? gcc powered

    max_u = 50
    str:            .fill max_u, 1, 0

    #str:            .ascii "                                         mnogo razmaka\0"
    msg =           . - str

    noviRed:        .ascii "\n"
    nl = . - noviRed

    pocetnaPoruka: .ascii "\nString pre ciscenja razmaka:\n"
    pRlen =        . - pocetnaPoruka

    unos:          .ascii "\nUnesite jedan string sa razmacima na pocetku:\n"
    unosLen =      . - unos

    first:         .byte 0
    razmaka:       .long 0
    prom:          .long 0
.section .text
.global main

main:
    cmpb $0,             first
    je pocetakPoruka

    movl $str,           %eax         # adresa stringa
    movl $0,             %ebx         # broj razmaka
    movl $str,           %esi         # odakle se kopira element niza
    movl $str,           %edi         # u sta se kopira element niza
    movl $0,             %edx         # pomocni registar, za cuvanje trenutnog elementa

razmaci:
    cmpb $' ',          (%eax)       # da li je razmak?  
    								 # KOMENTAR: mora b na kraju, 
    								 # jer bi se inace poredilo vise lokacija
    								 # kad se radi sa stringovima, uvek se poredi samo jedna lokacija
    								 # inace moze da se pokupi jos nesto i da uslov ne bude tacan
    je uvecajBrRazm
    jne shiftNizaPocetak	         # KOMENTAR NA LABELI

uvecajBrRazm:
    incl                 %ebx        # broj razmaka za 1 veci
    incl                 %eax        # predji na sled. elem
    jmp razmaci

shiftNizaPocetak:
	 addl %ebx,          %esi       # prvi korisni podatak posle razmaka
	 								# KOMENTAR: ovo ne treba da bude u petlji, zato je izdvojeno
     movl %ebx,          razmaka    # zbog korekcije ispisa sačuvaj podatak o broju razmaka
shiftNiza:
    movb (%esi),         %dl        # sacuvaj trenutni element za kopiranje
    								# KOMENTAR: moze i %edx, ali posto kod stringova se radi sa bajtovima, 
    								# ovako se izbegavaju problemi posle
    								
    movb %dl,           (%edi)      # upisi ga na pocetak niza, drugi indeks, itd 
    								# KOMENTAR: mora da se radi upisivanje na nivou bajtova

    cmpl $0,           1(%esi)      # da li smo sve razmake uklonili?
    								# KOMENTAR: kraj je kad %esi dodje do poslednjeg elementa
    								# -1 ispred je da bi se i 0 upisala u string
    jne povecajAdrese
    je krajPoruka   			    # svi razmaci potroseni, prebaci sve do kraja '\0'
									# KOMENTAR: ovde se skace na kraj
povecajAdrese:
    addl $1,             %esi       # predji na sledeci element
    								# KOMENTAR: radi se sa bajtovima, slicno je i u narednoj liniji
    addl $1,             %edi       # predji na sledeci element
    decl                 %ebx       # smanji broj preostalih razmaka za 1 
    jmp shiftNiza                   # vrati se na shift niza     

shiftujDoKrajaNiza:			
    cmpl $str+max_u,        %esi
    je krajStringa
    jne pomerajElementa             # nije kraj niza, pomeri element

pomerajElementa:
    movl (%esi),         %edx       # sacuvaj trenutni element za kopiranje
    movl %edx,           %edi       # upisi ga na pocetak niza, drugi indeks, itd
    addl $4,             %esi       # predji na sledeci element
    addl $4,             %edi       # predji na sledeci element
    jmp shiftujDoKrajaNiza          # pokusaj dalji pomeraj elementa

krajStringa:
    addl $4,             %esi       # predji na sledeci element (koji nije koristan nakon pomeranja)
    movl $0,             %esi       # dodaj '\0'

    jmp krajPoruka

pocetakPoruka:
    movl $4,             %eax       # poruka za unos stringa
    movl $1,             %ebx
    movl $unos,          %ecx
    movl $unosLen,       %edx   
    int $0x80 

    movl $3,             %eax       # unos stringa prepustamo korisniku
    movl $0,             %ebx
    movl $str,           %ecx
    movl $max_u,         %edx   
    int $0x80 

    movl %eax,           prom       # sacuvaj koliko je uneto karaktera

    movl $4,             %eax       # ispis pocetnog stringa, pre ciscenja razmaka
    movl $1,             %ebx
    movl $pocetnaPoruka, %ecx
    movl $pRlen,         %edx   
    int $0x80 
    
    movl $4,             %eax
    movl $1,             %ebx
    movl $str,           %ecx
    movl $msg,           %edx   
    int $0x80 
    
    movl $4,             %eax      # ispis novog reda
    movl $1,             %ebx
    movl $noviRed,       %ecx
    movl $nl,            %edx   
    int $0x80 

    incb                 first     # ne ispisuj vise pocetnu poruku
    jmp main

krajPoruka:
    movl $4,             %eax     # ispis pocetnog stringa, posle ciscenja razmaka
    movl $1,             %ebx
    movl $krajnjaPoruka, %ecx
    movl $KPlen,         %edx   
    int $0x80 

    movl prom,            %edi
    subl razmaka,         %edi     # samo zbog ispisa se oduzima (broj razmaka - 1)
    #incl                 %edi

    movl $4,             %eax
    movl $1,             %ebx
    movl $str,           %ecx
    movl %edi,           %edx   
    int $0x80 

kraj:
    movl $1,             %eax
    movl $0,             %ebx
    int $0x80
