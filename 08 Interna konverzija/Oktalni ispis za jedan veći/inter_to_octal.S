# 1. Zadatak: napisati asemblerski potprogram za konverziju iz znakovnog 
# oblika (ceo neoznačen oktalni broj) u interni oblik (direktorijum „oktalni“):
# unsigned int oct_str_to_inter(char* str, unsigned int* greska)
# Povratna vrednost potprograma je interni oblik broja. Dopuniti potprogram proverom grešaka:
# 1. Validnost pojedinačnih cifara, u skladu sa brojnom osnovom broja: cifra van dozvoljenog opsega
#  predstavlja grešku (greska = 1)
# 2. Kapacitet odredišta za interni format: prekoračenje kapaciteta je greška (greska = 2)
# 3. Za prazan string vratiti greska = 1

.section .data
    rezultat_ispis: .fill 30, 1, 0

.section .text
.global oct_str_to_inter


oct_str_to_inter:
    pushl %ebp
    movl %esp, %ebp

    subl $4, %esp

    pushl %esi
    pushl %edi
    pushl %ebx

    movl 8(%ebp), %esi   # string
    movl 12(%ebp), %edi  # greška
    movl $0,   -4(%ebp)  # da li je negativan broj?
		
    movl $0, %ebx

    movl $0, %eax
    movl $8, %ecx

proveriPredznak:
    movb (%esi), %bl

    cmpb $'-', %bl
    je negativan

    cmpb $'+', %bl
    je pozitivan
    # ako nema predznaka onda je pozitivan broj svakako

cifra:
    movb (%esi), %bl
    
    andb %bl, %bl		# uslov za kraj mora da bude ovde, jer u suprotnom u slucaju kad je %bl 0 ode na uvecajGresku
    jz provKraj
    
    cmpb $'0', %bl 
    jb uvecajGresku

    cmpb $'7', %bl
    ja uvecajGresku

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
    # movl $0,   -4(%ebp) # broj je pozitivan
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
