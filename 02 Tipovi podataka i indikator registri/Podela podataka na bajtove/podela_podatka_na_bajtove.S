# Rezervisati jednu 32-bitnu reč u memoriji, 
# a da onda pročitati njena 4 bajta redom u 
# ah, al, bh, bl, da se lepo vidi gde je viši, a gde niži deo
.section .data
    rec: .long 0x12345678
.section .text

.global main

main:
    movb rec,   %ah     # 0x78
    movb rec+1, %al     # 0x56
    movb rec+2, %bh     # 0x34
    movb rec+3, %bl     # 0x12

kraj:
    movl $0, %eax
    movl $1, %ebx
    int $0x80

# (gdb) info register ah al bh bl
# ah             0x78     120
# al             0x56     86
# bh             0x34     52
# bl             0x12     18
##################################
