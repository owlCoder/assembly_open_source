# PR55-2020 Jovanovic Danijel
.section .text
.global modifikuj

# unsigned int prebroj(char *s1, char *s2, short int *razlika)
modifikuj:
    pushl %ebp
    movl  %esp, 	   %ebp

    pushl %esi
    pushl %edi
    pushl %ebx

    movl  8(%ebp),      %esi     # prvi string
    movl 12(%ebp),   	%edi     # drugi string
    movl 16(%ebp),      %edx     # short int *razlika
    movl $0,            %eax     # povratna vrednost potprograma
    movl $0, 	        %ebx     # broj malih slova u prvom stringu
    movl $0,            %ecx     # broj malih slova u drugom stringu

krajStringa_s1:
    cmpb $10,	       (%esi)    # da li smo obradili sve znakove u stringu ?
    je krajStringa_s2

malo_slovo_s1:
    cmpb $'z',         (%esi)
    jg uvecajAdresu_s1
        
    cmpb $'a',         (%esi)
    jl uvecajAdresu_s1

    # malo je slovo -> prvi brojac uvecaj za 1
    incl                %ebx
        
uvecajAdresu_s1:
    incl     %esi	              # prelazimo na sledeci znak u prvom stringu, a drugi gledamo ponovo otpocetka
    jmp krajStringa_s1

# drugi string
krajStringa_s2:
    cmpb $10,	       (%edi)    # da li smo obradili sve znakove u stringu ?
    je racunajRazliku

malo_slovo_s2:
    cmpb $'z',         (%edi)
    jg uvecajAdresu_s2
        
    cmpb $'a',         (%edi)
    jl uvecajAdresu_s2

    # malo je slovo -> drugi brojac uvecaj za 1
    incl                %ecx
        
uvecajAdresu_s2:
    incl     %edi	              # prelazimo na sledeci znak u prvom stringu, a drugi gledamo ponovo otpocetka
    jmp krajStringa_s2

racunajRazliku:
    cmpl %ebx,         %ecx       # uporedi broj slova
    je istiBroj
    jl prviVise
    jg drugiVise

prviVise:
    movl $1,          (%edx)
    jmp razlikaMalihSlova

drugiVise:
    movl $2,          (%edx)
    jmp razlikaMalihSlova

istiBroj:
    movl $3,          (%edx)
    jmp razlikaMalihSlova

razlikaMalihSlova:
    cmpl %ebx,         %ecx
    jl zameniVrednosti

oduzmi:
    movl %ecx,         %eax
    subl %ebx,         %eax       # samo oduzmi
    jmp kraj

zameniVrednosti:
    xchgl %ebx,        %ecx
    jmp oduzmi

kraj:
    popl %ebx			          # restauracija registara
    popl %edi
    popl %esi

    movl %ebp,		%esp
    popl %ebp
    ret