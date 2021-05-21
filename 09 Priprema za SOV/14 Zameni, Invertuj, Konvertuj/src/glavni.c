#include <stdio.h>
#include <stdio_ext.h>

#define MAX_LEN 100

unsigned int RUNPP_REG_ERR = 0;

unsigned int zameni(char* znakovi, int* brojevi);
int mnoziSumiraj(int* brojevi, unsigned int broj_elemenata, int* greska);
int konvertuj(char* znakovi, unsigned int duzina, int broj);

int main() {
    int i;
    int nizBrojeva[MAX_LEN];
    char nizZnakova[MAX_LEN] = {0};

    int suma;
    unsigned int nizDuzinaBrojeva;
    unsigned int nizDuzinaZnakova;
    unsigned int greska = 0;

    int broj;

    unsigned int odabir;
    do {
        printf("Odaberite sta zelite da testirate:\n(0-zameni, 1-mnoziSumiraj, 2-konvertuj, 3-sve)\n");
        scanf("%d", &odabir);
    } while (odabir > 3);

    __fpurge(stdin);

    switch(odabir)
    {
        case 0:
            printf("Unesite niz karaktera: ");
            scanf("%100[^\n]s", nizZnakova);
            nizDuzinaBrojeva = zameni(nizZnakova, nizBrojeva);
            printf("Niz brojeva: ");
            for(i = 0; i < nizDuzinaBrojeva; i++)
            {
                printf("%d ", nizBrojeva[i]);
            }
            printf("\n");
            break;
        case 1:
            printf("Unesite broj elemenata niza brojeva: ");
            scanf("%d", &nizDuzinaBrojeva);
            printf("Unesite redom sve clanove niza brojeva:\n");
            for(i = 0; i < nizDuzinaBrojeva; i++)
            {
                scanf("%d", &nizBrojeva[i]);
            }
            suma = mnoziSumiraj(nizBrojeva, nizDuzinaBrojeva, &greska);
            if (greska)
            {
                printf("Greska u mnoziSumiraj!\n");
                break;
            }
            printf("Suma nakon mnozenja i deljenja niza brojeva: %d\n", suma);
            break;
        case 2:
            printf("Unesite broj: ");
            scanf("%d", &broj);
            printf("Unesite duzinu znakovnog niza: ");
            scanf("%d", &nizDuzinaZnakova);
            greska = konvertuj(nizZnakova, nizDuzinaZnakova, broj);
            if (greska)
            {
                printf("Greska u konvertuj!\n");
                break;
            }
            printf("Nakon konverzije:\n%s\n", nizZnakova);
            break;
        case 3:
            printf("Unesite niz karaktera: ");
            scanf("%100[^\n]s", nizZnakova);
            nizDuzinaBrojeva = zameni(nizZnakova, nizBrojeva);
            printf("Niz brojeva: ");
            for(i = 0; i < nizDuzinaBrojeva; i++)
            {
                printf("%d ", nizBrojeva[i]);
            }
            printf("\n");
            suma = mnoziSumiraj(nizBrojeva, nizDuzinaBrojeva, &greska);
            if (greska)
            {
                printf("Greska u mnoziSumiraj!\n");
                break;
            }
            printf("Suma nakon mnozenja i deljenja niza brojeva: %d\n", suma);
            printf("Unesite duzinu znakovnog niza: ");
            scanf("%d", &nizDuzinaZnakova);
            greska = konvertuj(nizZnakova, nizDuzinaZnakova, suma);
            if (greska)
            {
                printf("Greska u konvertuj!\n");
                break;
            }
            printf("Nakon konverzije: %s\n", nizZnakova);
            break;
    }

    #ifdef LEVEL42
    printf("\nRUNPP_REG_ERR:%d\n",RUNPP_REG_ERR);
    #endif
    return ((greska<0)||(greska>127))?127:greska;
}