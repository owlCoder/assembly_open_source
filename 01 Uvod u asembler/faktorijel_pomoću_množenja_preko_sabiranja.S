# Program za iterativno računanje faktorijela (uz korišćenje množenja pomoću sabiranja)
.section .data
.section .text
.globl main

main:
    movl $5, %esi   # n
    movl $1, %edi   # faktorijel

_start:
    cmpl $1, %esi   # da li smo stigli do kraja?
    jbe kraj        # kraj programa
    movl %esi, %eax # broj n postaje prvi broj za množenje
    movl %edi, %ebx # trenutni proizvod postaje drugi broj za množenje

                    # Množenje pomoću sabiranja - Ulaz: eax, ebx
resetovanje_vrednosti:
    movl $0, %ecx   # trenutni proizvod postavi na 0

pomnozi:
    cmpl $0, %eax   # da li smo izmnožili do kraja?
    je factorial    # pređi na faktorijel
    addl %ebx, %ecx # u suprotnom, trenutni proizvod uvećaj za drugim brojem za množenje
    decl %eax       # umanji prvi broj za množenje za 1
    jmp pomnozi     # nastavi množenje dok ne stigneš do kraja
                    # Množenje pomoću sabiranja - Izlaz: ecx

factorial:
    movl %ecx, %edi # trenutni proizvod postaje novi faktorijel
    decl %esi       # n umanji za 1
    jmp _start      # množi za sledeće n

kraj: 
    movl $1, %eax   # flush registrija %eax
    movl $0, %ebx   # flush registrija %ebx
    int $0x80       # sistemski poziv
