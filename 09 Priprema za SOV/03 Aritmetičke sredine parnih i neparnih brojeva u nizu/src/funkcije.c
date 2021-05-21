#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>

/////////////////
// binarni ispis
/////////////////

// binarni ispis 16-bitne vrednosti
void printbin16(unsigned short int x) {
    unsigned short int m=0x8000;
    int s=0;
    while(m) {
        printf("%s%s",m&x ? "1" : "0",++s%8 ? "" : " ");
        m >>= 1;
    }
}

// binarni ispis 32-bitne vrednosti
void printbin(unsigned int x) {
    unsigned int m=0x80000000;
    int s=0;
    while(m) {
        printf("%s%s",m&x ? "1" : "0",++s%8 ? "" : " ");
        m >>= 1;
    }
}

// binarni ispis 64-bitne vrednosti
void printbin64(unsigned long long x) {
    unsigned long long m=0x8000000000000000ULL;
    int s=0;
    while(m) {
        printf("%s%s",m&x ? "1" : "0",++s%8 ? "" : " ");
        m >>= 1;
    }
}

// binarni ispis 16-bitnog niza
void printbin16niz(unsigned short int *x, int n) {
    int i;
    for (i=0;i<n;i++) {
        printf("%02d:",i);
        printbin16(x[i]);
        printf("\n");
    }
}


/////////////////
// ispis u boji
/////////////////

//zamenjuje jedan podstring drugim
int string_replace(char** String, char* ReplaceWhat, char* ReplaceTo) {
    char *NewString, *c, *lastf;
    char *found = *String;
    int count = 0;
    int RepToLen = strlen(ReplaceTo);
    int RepWhatLen = strlen(ReplaceWhat);

    while (found) {
        if ((found = strstr(found, ReplaceWhat)) != 0) {
            found++;
            count++;
        }
    }
    if (count) {
        c = NewString = malloc(strlen(*String) + count*(RepToLen - RepWhatLen) + 1);
        lastf = *String;
        while ((found = strstr(lastf, ReplaceWhat)) != 0) {
            if (found != lastf) {
                strncpy(c, lastf, found-lastf);
                c += found-lastf;
            }
            strncpy(c, ReplaceTo, RepToLen);
            c += RepToLen;
            lastf = found+RepWhatLen;
        }
        strcpy(c, lastf);
        free(*String);
        *String = NewString;
    }
    return count;
}

//funkcija koja radi isto što i printf, samo što pre ispisa
//konvertuje konstante za boje u odgovarajuće escape sekvence
int cprintf(const char *format, ...) {
    size_t size;
    size_t sizem=1024;
    va_list ap,apc;
    char* buff;
    int ret;

    va_start(ap,format);
    do {
        buff = (char*)malloc(sizem);
        va_copy(apc, ap);
        size = vsnprintf(buff, sizem, format, apc);
        va_end(apc);
        if (size<sizem) break;
        else {
            free(buff);
            sizem = size+1;
        }
     } while (1);
    va_end(ap);

    string_replace(&buff,"{BLU}", "\033[1;34m");
    string_replace(&buff,"{GRN}", "\033[1;32m");
    string_replace(&buff,"{CYN}", "\033[1;36m");
    string_replace(&buff,"{RED}", "\033[1;31m");
    string_replace(&buff,"{MAG}", "\033[1;35m");
    string_replace(&buff,"[BLU]", "\033[1;44m");
    string_replace(&buff,"[GRN]", "\033[1;42m");
    string_replace(&buff,"[CYN]", "\033[1;46m");
    string_replace(&buff,"[RED]", "\033[1;41m");
    string_replace(&buff,"[MAG]", "\033[1;45m");
    string_replace(&buff,"{NRM}", "\033[0m");
    string_replace(&buff,"[NRM]", "\033[0m");

    ret=printf("%s",buff);
    free(buff);
    return ret;
}


/////////////////////////////////
// binarni ispis razlika, u boji
/////////////////////////////////

// binarni ispis razlika dve 16-bitne vrednosti
void printbin16diff(unsigned short int x, unsigned short int t) { // t - tačna vrednost
    unsigned short int m=0x8000;
    int s=0;
    while(m) {
        if ((m&x) == (m&t)) cprintf("{GRN}");
        else cprintf("{RED}");
        cprintf("%s%s",m&x ? "1" : "0",++s%8 ? "" : " ");
        m >>= 1;
    }
    cprintf("{NRM}");
}

// binarni ispis razlika dve 32-bitne vrednosti
void printbindiff(unsigned int x, unsigned int t) { // t - tačna vrednost
    unsigned int m=0x80000000;
    int s=0;
    while(m) {
        if ((m&x) == (m&t)) cprintf("{GRN}");
        else cprintf("{RED}");
        cprintf("%s%s",m&x ? "1" : "0",++s%8 ? "" : " ");
        m >>= 1;
    }
    cprintf("{NRM}");
}


// binarni ispis razlika dve 64-bitne vrednosti
void printbin64diff(unsigned long long x, unsigned long long t) { // t - tačna vrednost
    unsigned long long m=0x8000000000000000ULL;
    int s=0;
    while(m) {
        if ((m&x) == (m&t)) cprintf("{GRN}");
        else cprintf("{RED}");
        cprintf("%s%s",m&x ? "1" : "0",++s%8 ? "" : " ");
        m >>= 1;
    }
    cprintf("{NRM}");
}

// ispis razlike dva stringa
// neprintabilni znaci prvog stringa će biti ispisani kao hex kodovi u uglastim zagradama
printstrdiff(char *s, char *t) { // t - tačna vrednost
    int i, l=strlen(t),ct=0,cs=0,ci=0;
    for (i=0;i<l;i++) {
        if (t[i] == s[i]) cprintf("{GRN}");
        else cprintf("{RED}");
        if ((s[i]>=32) && (s[i]<=127)) cprintf("%c",s[i]);
        else cprintf("[%x]", (unsigned char)s[i]);
    }
    cprintf("{NRM}");
}

// binarni ispis razlika dva 16-bitna niza
void printbin16nizdiff(unsigned short int *x, unsigned short int *t, int n) {
    int i;
    for (i=0;i<n;i++) {
        printf("%02d:",i);
        printbin16diff(x[i],t[i]);
        printf("\n");
    }
}


///////////
// razno
///////////

// računanje bita pariteta za jedan znak
char paritet(char n) {
    int jed=0;
    while(n) {
        if (n&1) jed++;
        n>>=1;
    }
    if (jed&1) return 0x80; //bit pariteta je 1
    else return 0;  //bit pariteta je 0
}

