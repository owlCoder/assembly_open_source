#include <stdio.h>

unsigned int RUNPP_REG_ERR = 0;

int str_to_inter(char* str, unsigned int* greska, unsigned int baza);
void konvertujBrojUString(unsigned int broj, char *izrazZaIspis, unsigned int baza); // dopuna programa

int main() {
    unsigned int r;
    char s[30]={0};
    char broj[30]={0};
    unsigned int g, baza;
    printf("Unesite brojnu osnovu sistema: ");
    scanf("%u", &baza);
    while(baza < 1 || baza > 10) {
        printf("Unesite brojnu osnovu sistema: ");
        scanf("%u", &baza);
    }
    printf("Unesite broj u brojevnoj osnovi %u: ", baza);
    scanf(" %30[^\n]s",s);
    r = str_to_inter(s,&g, baza);
    konvertujBrojUString(r, broj, 10); // dopuna programa
    printf("\nGreska: %u\n",g);
    if (g == 0)
        printf("Rezultat (u decimalnoj osnovi): %s\n", broj);
	else if(g == 1)
		printf("Broj %s nije unet u brojevnoj bazi %u!\n", s, baza); 
    #ifdef LEVEL42
    printf("\nRUNPP_REG_ERR:%d\n",RUNPP_REG_ERR);
    #endif
    return ((g<0)||(g>127))?127:g;
}

