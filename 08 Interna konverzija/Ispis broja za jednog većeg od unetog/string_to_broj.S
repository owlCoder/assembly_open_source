# uvesti parametar baza u zadatak 2 i prepraviti potprogram da radi sa bilo kojom bazom 2-10:
# int str_to_inter(char* str, unsigned int* greska, unsigned int baza)

.section .text
.global str_to_inter

# int str_to_inter(char* str, unsigned int* greska, unsigned int baza)

str_to_inter:
    pushl %ebp
    movl %esp, %ebp

    subl $8, %esp

    pushl %esi
    pushl %edi
    pushl %ebx

    movl   8(%ebp), %esi   # string
    movl  12(%ebp), %edi   # greška
    movl $0,     -4(%ebp)  # da li je negativan broj?
		
    movl $0, %ebx
    movl $0, %eax
    movl  16(%ebp), %ecx   # baza
    
    movl    %ecx,      -8(%ebp) # baza
    decl -8(%ebp)				# baza - 1
    addb $'0',		   -8(%ebp) # baza u ascii formatu

proveriPredznak:
    movb (%esi), %bl

    cmpb $'-', %bl
    je negativan

    cmpb $'+', %bl
    je pozitivan
    # ako nema predznaka onda je pozitivan broj svakako

cifra:
    movb (%esi),     %bl
    
    andb %bl,        %bl   # uslov za kraj mora da bude ovde, jer u suprotnom u slucaju kad je %bl 0 ode na uvecajGresku
    jz provKraj
    
    cmpb $'0',       %bl 
    jb uvecajGresku

        
    cmpb -8(%ebp),   %bl   # da li je broj izvan baze brojnog sistema
    jg uvecajGresku

oktalno:
    subb $'0', %bl # pretvori u broj
    mull %ecx
    jo uvecajGresku2

    addl %ebx, %eax
    jo uvecajGresku2

    incl %esi
    jmp cifra

negativan:
    movl $1,   -4(%ebp) # broj je negativan
    incl %esi           # predji na sledecu cifru
    jmp cifra

pozitivan:
    incl %esi           # predji na sledecu cifru
    jmp cifra

provKraj:
    cmpl 8(%ebp), %esi
    je uvecajGresku

    cmpl $1,   -4(%ebp) # treba li promeniti predznak broja?
    je promeniPredznak

    # ako je broj na početku bio pozitivan, a pri proveri postao negativan
    # došlo je do prekoračenja
    andl %eax, %eax
    js uvecajGresku2

    jmp setZeroError

promeniPredznak:
    negl %eax
    jmp setZeroError

uvecajGresku:
    movl %edi, %ebx
    movl $1, (%ebx)
    movl $0, %eax  # nema broja u povratnoj vrednosti ako je doslo do greske
    jmp kraj_pp

uvecajGresku2:
    movl %edi, %ebx
    movl $2, (%ebx)
    movl $0, %eax  # nema broja u povratnoj vrednosti ako je doslo do greske
    jmp kraj_pp

setZeroError:
    movl %edi, %ebx
    movl $0, (%ebx)

kraj_pp:
    popl %ebx
    popl %edi
    popl %esi
    movl %ebp, %esp
    popl %ebp
    ret
