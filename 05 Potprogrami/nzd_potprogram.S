.section .data
.section .text
.global main				

NZD:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx  

    movl  8(%ebp), %eax  # ebp se pomerio za 4 lokacije, pa je drugi broj za 8 lokacija manji
    movl 12(%ebp), %ebx  # prvi broj za 12 lokacija

uporedi:
    cmpl %ebx,     %eax
    je stek_end
    ja veci_broj

    subl %eax,     %ebx
    jmp uporedi

veci_broj:
    subl %ebx,     %eax
    jmp uporedi

stek_end:
    popl %ebx
    movl %ebp,     %esp
    popl %ebp
    ret   

main:
    pushl $12       # dodaj na stek podatak
    pushl $8        # dodaj na stek podatak
    call NZD        # poziv potprograma
    addl $8, %esp   # pomeraj za 8 lokacija
  
kraj:
    movl $1, %eax
    movl $0, %ebx
    int $0x80


