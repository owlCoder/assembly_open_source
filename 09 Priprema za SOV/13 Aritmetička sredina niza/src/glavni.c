#include <stdio.h>

#define MAX_LEN 100

unsigned int RUNPP_REG_ERR = 0;

int oduzimaj(int* brojevi, unsigned int broj_elemenata, int oduzimac);
int srednjaVrednost(int* brojevi, unsigned int broj_elemenata, unsigned int* greska);
int konvertuj(char* znakovi, unsigned int duzina, int prviBroj, int drugiBroj);

int main() {
    int i;
    int nizBrojeva[MAX_LEN];
    char nizZnakova[MAX_LEN];

    int aritmetickaSredina;
    int brojZaOduzimanje;
    unsigned int nizDuzinaBrojeva;
    unsigned int nizDuzinaZnakova;
    unsigned int greska = 0;

    int unosPrviBroj;
    int unosDrugiBroj;

    unsigned int odabir;
    do {
        printf("Odaberite sta zelite da testirate:\n(0-oduzimaj, 1-srednjaVrednost, 2-konvertuj, 3-sve)\n");
        scanf("%d", &odabir);
    } while (odabir > 3);

    switch(odabir)
    {
        case 0:
            printf("Unesite broj elemenata niza brojeva:\n");
            scanf("%d", &nizDuzinaBrojeva);
            printf("Unesite redom sve clanove niza brojeva:\n");
            for(i = 0; i < nizDuzinaBrojeva; i++)
            {
                scanf("%d", &nizBrojeva[i]);
            }
            printf("Unesite oduzimac:\n");
            scanf("%d", &brojZaOduzimanje);
            oduzimaj(nizBrojeva, nizDuzinaBrojeva, brojZaOduzimanje);
            printf("Niz brojeva nakon funkcije oduzimaj:\n");
            for(i = 0; i < nizDuzinaBrojeva; i++)
            {
                printf("%d ", nizBrojeva[i]);
            }
            printf("\n");
            break;
        case 1:
            printf("Unesite broj elemenata niza brojeva:\n");
            scanf("%d", &nizDuzinaBrojeva);
            printf("Unesite redom sve clanove niza brojeva:\n");
            for(i = 0; i < nizDuzinaBrojeva; i++)
            {
                scanf("%d", &nizBrojeva[i]);
            }
            aritmetickaSredina = srednjaVrednost(nizBrojeva, nizDuzinaBrojeva, &greska);
            if (greska)
            {
                printf("Greska u srednjaVrednost!\n");
                break;
            }
            printf("Srednja vrednost:\n%d\n", aritmetickaSredina);
            break;
        case 2:
            printf("Unesite prviBroj:\n");
            scanf("%d", &unosPrviBroj);
            printf("Unesite drugiBroj:\n");
            scanf("%d", &unosDrugiBroj);
            printf("Unesite duzinu znakovnog niza:\n");
            scanf("%d", &nizDuzinaZnakova);
            greska = konvertuj(nizZnakova, nizDuzinaZnakova, unosPrviBroj, unosDrugiBroj);
            if (greska)
            {
                printf("Greska u konvertuj!\n");
                break;
            }
            printf("Nakon konverzije:\n%s\n", nizZnakova);
            break;
        case 3:
            printf("Unesite broj elemenata niza brojeva:\n");
            scanf("%d", &nizDuzinaBrojeva);
            printf("Unesite redom sve clanove niza brojeva:\n");
            for(i = 0; i < nizDuzinaBrojeva; i++)
            {
                scanf("%d", &nizBrojeva[i]);
            }
            printf("Unesite oduzimac:\n");
            scanf("%d", &brojZaOduzimanje);
            oduzimaj(nizBrojeva, nizDuzinaBrojeva, brojZaOduzimanje);
            printf("Niz brojeva nakon funkcije oduzimaj:\n");
            for(i = 0; i < nizDuzinaBrojeva; i++)
            {
                printf("%d ", nizBrojeva[i]);
            }
            printf("\n");
            aritmetickaSredina = srednjaVrednost(nizBrojeva, nizDuzinaBrojeva, &greska);
            if (greska)
            {
                printf("Greska u srednjaVrednost!\n");
                break;
            }
            printf("Srednja vrednost:\n%d\n", aritmetickaSredina);
            printf("Unesite duzinu znakovnog niza:\n");
            scanf("%d", &nizDuzinaZnakova);
            greska = konvertuj(nizZnakova, nizDuzinaZnakova, aritmetickaSredina, nizDuzinaBrojeva);
            if (greska)
            {
                printf("Greska u konvertuj!\n");
                break;
            }
            printf("Nakon konverzije:\n%s\n", nizZnakova);
            break;
    }

    #ifdef LEVEL42
    printf("\nRUNPP_REG_ERR:%d\n",RUNPP_REG_ERR);
    #endif
    return ((greska<0)||(greska>127))?127:greska;
}