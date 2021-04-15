#include <stdio.h>

unsigned int prebroji(char *str, char c);

void main(void)
{
    char s1[20] = "la++", s2[20] = "-lend-";
    int pl = prebroji(s1, '+');
    int mn = prebroji(s2, '-');

	printf("%d %d", pl, mn);

    if(pl > mn)
        printf("1");
    else if(pl < mn)
        printf("2");
    else
        printf("3");
}
