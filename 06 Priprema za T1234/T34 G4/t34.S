.section .data
    maks = 20 + 1

    poruka1: .ascii "Unesite string: "
    por1duz = . - poruka1

    poruka2: .ascii "Unesite podstring: "
    por2duz = . - poruka2

    unos1: .fill maks, 1, 0
    unos2: .fill maks, 1, 0

    unetoS1: .long 0
.section .text
.global main

potprogram:
	pushl %ebp
	movl  %esp,     %ebp
	
	pushl %esi
	pushl %edi
	pushl %ebx

init:
    movl $unos1,    %esi
    movl $unos2,    %edi
    movl $0,        %ecx
    movl $0,        %eax

krajStringa:
    movb (%esi),    %dl
    cmpb $10,       %dl
    je nijePronadjen

poredi:
    cmpb %dl,      (%edi)
    je dalje

    incl %esi
    incl %ecx
	addl %eax, %ecx
    movl $unos2,   %edi
    jmp krajStringa

dalje:
    cmpb $10,    1(%edi)
    je pronadjenPodstring

    incl %esi
    incl %edi
	incl %eax
    jmp krajStringa

nijePronadjen: 
    movl $0,      %ecx
    jmp kraj_pp

pronadjenPodstring:
    incl %ecx

kraj_pp:
	movl %ecx,    %eax

	popl %ebx
	popl %edi
	popl %esi

	movl %ebp,	  %esp
	popl %ebp
	ret

main:
     # ispis poruke
    movl $4,        %eax
    movl $1,        %ebx
    leal poruka1,   %ecx
    movl $por1duz,  %edx
    int $0x80

    # unos
    movl $3,        %eax
    movl $0,        %ebx
    leal unos1,     %ecx
    movl $maks,     %edx
    int $0x80

    movl %eax, unetoS1

     # ispis poruke
    movl $4,        %eax
    movl $1,        %ebx
    leal poruka2,   %ecx
    movl $por2duz,  %edx
    int $0x80

    # unos
    movl $3,        %eax
    movl $0,        %ebx
    leal unos2,     %ecx
    movl $maks,     %edx
    int $0x80

    pushl $unos2
	pushl $unos1
	call potprogram
	addl  $8,       %esp

	movl %eax,      %ecx

kraj:
    movl $1,        %eax
    movl %ecx,      %ebx
    int $0x80
