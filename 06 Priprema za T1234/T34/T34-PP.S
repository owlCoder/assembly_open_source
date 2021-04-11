.section .data
.section .text
.global potprogram

# void potprogram(unsigned char *s1, unsigned char *s2, char *r);

potprogram:                # naziv potprograma
    pushl %ebp             # početak potprograma
    movl  %esp,     %ebp
    pushl %ebx

    movl -4(%esp),  %eax   # promenljiva rezultata
    movl -8(%esp),  %ebx   # char *s2
    movl -12(%esp), %ecx   # char *s1
    movl  $0,   -16(%esp)  # duzina s1
    movl  $0,   -20(%esp)  # duzina s2
    movl  $0,   -24(%ebp)  # i = 0

duzina_s1:
    movl %

# void potprogram(unsigned char *s1, unsigned char *s2, char *r) 
# {
#    unsigned duzina_S1 = strlen(s1), duzina_S2 = strlen(s2);
#
#    if(duzina_S1 != duzina_S2) {
#        *r = 'n';
#        return;
#    }
#    int i = 0;
#    while(s1[i] == s2[i] && s1[i] != '\0' && s2[i] != '\0') {
#        i++;
#    }
#        
#    if(i == duzina_S1)
#       *r = '0'; // stringovi su jednaki
#    
#    return;
# }