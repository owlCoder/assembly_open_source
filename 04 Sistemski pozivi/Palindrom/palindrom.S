# Zadatak: proveriti da li je uneti string sa tastature Palindrom! 
# Koraci:
# Ispisati poruku na ekran za uunos stringa (npr "Unesite string (max 20)")
# Proveriti da li je korisnik uneo vise od 20 karaktera ili ne. 
# Ako jeste, vratiti ga na pocetak gde ponovo unosi string.
# Proveriti da li je string PALINDROM
# Ako string jeste Palindrom ispisati poruku "String JESTE palindrom", 
# u suprotnom, ispisati "String NIJE palindrom"

.section .data
    str_max = 20                   # Ukupan broj karaktera koji je dozvoljeno korisniku da unese 
	string: .fill str_max, 1, 42     # '*'

    msgIn: .ascii "Unesite string: "
	len1 = . - msgIn                 # '.' predstavlja brojac lokacija

    msgIs: .ascii "String je palindrom.\n"
    len2 = . - msgIs               # '.' predstavlja brojac lokacija

    msgNot: .ascii "String nije palindrom.\n"
    len3 = . - msgNot              # '.' predstavlja brojac lokacija

.section .text
.global main

main:                                ######## ISPIS msgIn ###########
	movl $4,     %eax                # Sistemski poziv za izlaz
	movl $1,     %ebx                # Identifikacioni broj za STANDARDNI IZLAZ
	leal msgIn,  %ecx                # ekvivalentno sa: movl $string, %ecx
	movl $len1,  %edx                # Koliko karaktera zelimo da ispisemo na ekran
	int $0x80
	                                 ######## SKENIRANJE SA TASTATURE ######
	movl $3,        %eax             # Sistemski poziv za ulaz.
	movl $0,        %ebx             # Identifikacioni broj za STANDARDNI ULAZ
	leal string,    %ecx             # Adresa promenljive u koju pisemo
	movl $str_max,  %edx             # Maksimalan broj karaktera koji korisnik moze da unese
	int $0x80

    addl $string-2, %eax             # indeksi 0 do n-1
    movl $string,   %ebx
    
provera:
    movb (%eax), %cl
    cmpb %cl, (%ebx)
    jne nijePalindrom

    decl %eax
    incl %ebx
    cmpl %ebx, %eax
    jg provera
									# ako su se pokazivači susreli, 
									# string jeste palindrom

palindrom:
	movl $4,    %eax                # Sistemski poziv za izlaz
	movl $1,    %ebx                # Identifikacioni broj za STANDARDNI IZLAZ
	leal msgIs, %ecx                # ekvivalentno sa: movl $string, %ecx
	movl $len2,  %edx               # Koliko karaktera zelimo da ispisemo na ekran
	int $0x80 
    movl $0,    %ebx
	jmp kraj

nijePalindrom:
	movl $4, %eax                   # Sistemski poziv za izlaz
	movl $1, %ebx                   # Identifikacioni broj za STANDARDNI IZLAZ
	leal msgNot, %ecx               # ekvivalentno sa: movl $string, %ecx
	movl $len3, %edx                # Koliko karaktera zelimo da ispisemo na ekran
	int $0x80 
	jmp krajNijePal

kraj:
	movl $1, %eax
	movl $0, %ebx
	int $0x80

krajNijePal:
	movl $1, %eax
	movl $1, %ebx
	int $0x80
