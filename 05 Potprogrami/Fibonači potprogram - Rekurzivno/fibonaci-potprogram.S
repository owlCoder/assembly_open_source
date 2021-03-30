#potprogram za racunjanje fibonacijevog broja
.section .data
    str: .ascii "AAAA\0"
.section .text
.global fibonaci

# int fibonaci(int n, unsigned int* rez)
fibonaci:                  # naziv potprograma
    pushl %ebp             # početak potprograma
    movl  %esp,  %ebp

    #subl  $4,    %esp      # promenljiva greške
    #movl  $0, -4(%ebp)     # greška = 0

    cmpl $2, 16(%ebp)       # f(1) = f(2) = 1
    jbe  start_fib

    movl 12(%ebp), %eax
    decl %eax

    pushl %eax
    #jc prekoracenje        # provera ima li prekoračenja
    call fibonaci

    addl $4, %esp
    pushl %eax             # izračunata vrednost se čuva na steku
    
    movl 12(%ebp), %eax     # f(n - 2)
    subl $2,      %eax
    pushl %eax
    #jc prekoracenje        # provera ima li prekoračenja
    call fibonaci

    addl $4, %esp
    popl %ecx
    addl %ecx, %eax
    jmp kraj

start_fib:
    movl $1,      %eax

#prekoracenje:
 #   incl -4(%ebp)

kraj:
    movl 8(%ebp),  %ecx    # rezultat (adresa)
    #movl    %eax, (%ecx)   # upis rezultata
    movl -4(%ebp), %eax    # povratna vrednost je greska

    # završetak potprograma
    movl %ebp, %esp       
    popl %ebp
    ret
