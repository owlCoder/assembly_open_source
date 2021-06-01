#potprogram za racunjanje fibonacijevog broja
.section .data
.section .text
.global fibonaci

# int fibonaci(int n, unsigned int* rez)
fibonaci:                  # naziv potprograma
    pushl %ebp             # početak potprograma
    movl  %esp,  %ebp
    subl  $4,    %esp      # promenljiva greške
    movl  $0, -4(%ebp)     # greška = 0

    movl  $1,    %eax      # f(1)
    movl  %eax,  %ecx      # f(2)
    
petlja:
    cmpl  $2,  8(%ebp)     # da li smo stigli do kraja?
    jbe kraj

    addl  %eax,  %ecx      # prvi broj + drugi broj
    jc prekoracenje

    xchgl %eax,  %ecx      # zameni vrednosti u registrima
    decl       8(%ebp)     # prelaz na sledeći korak

    jmp petlja

prekoracenje:
    incl -4(%ebp)

kraj:
    movl 12(%ebp), %ecx    # rezultat (adresa)
    movl    %eax, (%ecx)   # upis rezultata
    movl -4(%ebp), %eax    # povratna vrednost je greska

    # završetak potprograma
    movl %ebp, %esp       
    popl %ebp
    ret
