#include <stdio.h>
#include <string.h>

unsigned int RUNPP_REG_ERR = 0;

unsigned int oct_str_to_inter(char* str, unsigned int* greska);
void konvertujBrojUString(unsigned int broj, char *izrazZaIspis); // dopuna programa

int main() {
    unsigned int r;
    char s[30]={0};
    char jedanVeci[30]={0};
    unsigned int g;
    printf("Unesite broj u oktalnoj osnovi: ");
    scanf("%30[^\n]s",s);
    r = oct_str_to_inter(s,&g);
    konvertujBrojUString(r, jedanVeci); // dopuna programa
    printf("\nGreska: %u\n",g);
    if (g == 0) {
        printf("Rezultat: %u\n",r);
        printf("Broj za jedan veci od %u je: %s\n", r, jedanVeci); // dopuna programa
    }
    else
        printf("Uneti broj nije oktalni!\n");
    #ifdef LEVEL42
    printf("\nRUNPP_REG_ERR:%d\n",RUNPP_REG_ERR);
    #endif
    return ((g<0)||(g>127))?127:g;
}

