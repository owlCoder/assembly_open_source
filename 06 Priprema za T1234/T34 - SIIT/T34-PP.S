# PR55-2020 Jovanovic Danijel
.section .data
.section .text

.global SaberiMnozi
					   # int SaberiMnozi(int n, unsigned short *a, unsigned short *b, unsigned short *resenje);
SaberiMnozi:
	pushl %ebp             		   # početak potprograma
    	movl  %esp,     %ebp               # sacuvaj %esp
	subl  $8,       %esp   		   # lokalna promenljiva nekorektni, parno
	movl  $0,     -4(%ebp)	           # nekorektni = 0
	movl  $1,     -8(%ebp) 		   # prvi indeks je uvek paran

	pushl %esi			   # registar potreban za rad
	pushl %edi			   # registar potreban za rad
	pushl %ebx			   # registar potreban za rad
	pushl %ecx			   # registar potreban za rad
	pushl %edx			   # registar potreban za rad
	
	movl 12(%ebp), %esi    		   # prvi niz
	movl 16(%ebp), %edi	  	   # drugi niz
	movl 20(%ebp), %edx	   	   # treci niz za resenja
    	movl $0,       %ecx	  	   # brojac
	movl $0,       %eax    		   # povratna vrednost f-je

provera:
	cmpl %ecx,     8(%ebp) 		   # da li smo stigli do kraja niza
	je kraj				   # ako je kraj niza, zavrsi potprogram
	jne sab_ili_mnozi	           # ako nije kraj niza, nastavi dalje sa radom

sab_ili_mnozi:
	cmpl $1,    -8(%ebp)               # da li paran indeks trenutni koji se uporedjuje ?
	je mnozi			   # ako jeste, elementi istog indeksa se mnoze
	jne saberi			   # ako nije, elementi istog indeksa se sabiraju

mnozi:					   # carry flag za neoznacene brojeve
	movl   %edx,    %ebx   		   # smesti adresu trenutnog elementa niza resenje
	movw  (%esi),    %ax  		   # sacuvaj prvu vrednost u 16-bitni registar
	imulw (%edi),    %ax 		   # pomnozi vrednost trenutnog elementa drugog niza u 16-bitni register %ax
	jc prekoracenje			   # kod neoznacenih brojeva, carry flag je 1 ako se desi prekoracenje
	movw   %ax,    (%ebx)		   # izracunatu vrednost smesti na odgovarajucu poziciju u nizu resenje 
	jmp uvecaj_adrese     		   # nema prekoracenja, prelazimo na sledeci element

saberi:					   # carry flag za neoznacene brojeve
	movl  %edx,    %ebx	  	   # smesti adresu trenutnog elementa niza resenje
	movw (%esi),    %ax	 	   # sacuvaj prvu vrednost u 16-bitni registar
	addw (%edi),    %ax	   	   # dodaj vrednost trenutnog elementa drugog niza u 16-bitni register %ax
	jc prekoracenje		 	   # kod neoznacenih brojeva, carry flag je 1 ako se desi prekoracenje
	movw  %ax,    (%ebx)  	           # izracunatu vrednost smesti na odgovarajucu poziciju u nizu resenje 
	jmp uvecaj_adrese	   	   # nema prekoracenja, prelazimo na sledeci element


prekoracenje:
	movl   %edx,    %ebx  		   # smesti adresu trenutnog elementa niza resenje
	movw $11111,    %ax    		   # vrednost koja se postavi ako je doslo do prekoracenja
	movw  %ax,    (%ebx)   		   # vrednost smesti na odgovarajucu poziciju u nizu resenje 
    incl       -4(%ebp)	   		   # vred. prekoracenja za 1 veca
	jmp uvecaj_adrese	  	   # svakako prelazimo na sledeci element niza

uvecaj_adrese:
	addl $2,      %esi	 	   # 2 jer su word nizovi
	addl $2, 	  %edi	 	   # 2 jer su word nizovi
	addl $2,      %edx    		   # 2 jer su word nizovi
	incl 		  %ecx	 	   # predji na sledeci element niza
	
	cmpl $1,   -8(%ebp)    		   # ako je paran indeks
	je paran_u_neparan    		   # paran indeks -> neparan indeks tj. paran = 0
	jb neparan_u_paran	  	   # neparan indeks -> paran indeks tj. paran = 1

paran_u_neparan:
	movl $0,   -8(%ebp)	  	   # sledeci indeks je neparan
	jmp provera			   # povratak na proveru niza

neparan_u_paran:
	movl $1,   -8(%ebp)	   	   # sledeci indeks je paran
	jmp provera			   # povratak na proveru niza

kraj:
	movl -4(%ebp), %eax    		   # broj prekoracenja je povr. vr. fje
	popl 	%edx		  	   # restauracija registra
	popl	%edx		  	   # restauracija registra
	popl 	%ebx          		   # restauracija registra
	popl 	%edi           		   # restauracija registra
	popl 	%esi           		   # restauracija registra
    movl 	%ebp,  %esp                # vrati stari %ebp u %esp
	popl 	%ebp           		   # restauracija registra
	ret				   # povratak u glavni program
