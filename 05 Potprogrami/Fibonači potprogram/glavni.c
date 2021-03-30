#include <stdio.h>

unsigned int RUNPP_REG_ERR = 0;

int fibonaci(int n, unsigned int* rez);

int main()
{
    int n, g;
    unsigned int f;
    printf("Unesite N: ");
    scanf("%d",&n);
    g = fibonaci(n, &f);
    if (g)
        printf("Greska!\n");
    else
        printf("Fibonaci(%d)=%u\n", n, f);

    if (RUNPP_REG_ERR) return RUNPP_REG_ERR+128;
    else return g;

}
/*
int fibonaci(int n, unsigned int* rez) {
    int a = 1, b = 0, suma = 0;
    for(int i = 1; i <= n; i++) {
        suma = a + b;
        a = b;
        b = suma;
    }
    *rez = suma;
    return 0;
}*/