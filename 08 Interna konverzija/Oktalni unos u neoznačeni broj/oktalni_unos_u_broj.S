# 1. Zadatak: napisati asemblerski potprogram za konverziju iz znakovnog 
# oblika (ceo neoznačen oktalni broj) u interni oblik (direktorijum „oktalni“):
# unsigned int oct_str_to_inter(char* str, unsigned int* greska)
# Povratna vrednost potprograma je interni oblik broja. Dopuniti potprogram proverom grešaka:
# 1. Validnost pojedinačnih cifara, u skladu sa brojnom osnovom broja: cifra van dozvoljenog opsega
#  predstavlja grešku (greska = 1)
# 2. Kapacitet odredišta za interni format: prekoračenje kapaciteta je greška (greska = 2)
# 3. Za prazan string vratiti greska = 1

.section .text
.global oct_str_to_inter

oct_str_to_inter:
    pushl %ebp
    movl %esp, %ebp
    pushl %esi
    pushl %edi
    pushl %ebx

    movl 8(%ebp), %esi # string
    movl 12(%ebp), %edi # greška
		
    movl $0, %ebx

    movl $0, %eax
    movl $8, %ecx

cifra:
    movb (%esi), %bl
    
    andb %bl, %bl				#IZMENJENO: uslov za kraj mora da bude ovde, jer u suprotnom u slucaju kad je %bl 0 ode na uvecajGresku
    jz provKraj
    
    cmpb $'0', %bl 
    jb uvecajGresku

    cmpb $'7', %bl
    ja uvecajGresku

oktalno:

    subb $'0', %bl # pretvori u broj
    mull %ecx
    jc uvecajGresku2

    addl %ebx, %eax
    jc uvecajGresku2

    incl %esi
    jmp cifra

provKraj:
    cmpl 8(%ebp), %esi
    jne setZeroError

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
    #movl $0, %eax  			#IZMENJENO: ovde treba da bude povratna vrednost, ne treba da se anulira

kraj_pp:
    popl %ebx
    popl %edi
    popl %esi
    movl %ebp, %esp
    popl %ebp
    ret
