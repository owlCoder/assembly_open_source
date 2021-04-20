#include <stdio.h>

int Rot13(unsigned char *s1) 
{
    unsigned izmena = 0;
    while(*s1 != '\0')
    {
        if(*s1 >= 'a' && *s1 <= 'm') {
            *s1 += 13;
            izmena++;
        }
        else if(*s1 >= 'n' && *s1 <= 'z') {
            *s1 -= 13;
            izmena++;
        }
        else if(*s1 >= 'A' && *s1 <= 'M') {
            *s1 += 13;
            izmena++;
        }
        else if(*s1 >= 'N' && *s1 <= 'Z') {
            *s1 -= 13;
            izmena++;
        }
            s1++;
    }
    return izmena;
}

int main(void)
{
    unsigned char str[51];

    printf("Unesite string: ");
    scanf("%50[^\n]s", str);

    int izmena = Rot13(str);
    printf("Enkodovan string: %s\n", str);

    return 0;
}