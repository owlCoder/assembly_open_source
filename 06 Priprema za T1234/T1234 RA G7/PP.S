# PR55-2020 Jovanovic Danijel
.section .text
.global modifikuj

# unsigned int modifikuj(char *string, char *znakovi)
modifikuj:
	pushl %ebp
	movl  %esp, 	    %ebp

	pushl %esi
	pushl %edi
	pushl %ebx

	movl  8(%ebp),      %esi  # prvi string
	movl 12(%ebp), 	    %edi  # znakovi za izmenu
	movl $0,            %eax  # povratna vrednost potprograma
	movl $0, 	    %ebx  # maloSlovo = 0 (nije malo slovo), u suprotnom jeste malo slovo

krajStringa:
	cmpb $10,	   (%esi) # da li smo obradili sve znakove u stringu ?
	je kraj

malo_ili_veliko_slovo:
	movb (%edi),	    %dl    # trenutni znak iz drugog stringa cuvamo
	veliko_slovo:
		cmpb $'A',  %dl
		jl uvecajAdrese		  # ako je manji od 'A' verovatno nije ni slovo
		
		cmpb $'Z',  %dl
		jg malo_slovo		  # mozda je malo slovo

		movl $0,    %ebx   # slovo je veliko tj nije malo
        	jmp pretrazi_prvi_string_za_trazenim_znakom  # ako je veliko slovo odmah dodaj 32
	
	malo_slovo:
		cmpb $'z',  %dl
		jg uvecajAdrese		  # nije ni malo ni veliko slovo
		
		cmpb $'a',  %dl
		jl uvecajAdrese
		
		movl $1,    %ebx   # slovo je malo

pretrazi_prvi_string_za_trazenim_znakom:
	cmpb $10,          (%edi)  # da li smo pretrazili ceo drugi string
	je resetujAdresuPrvogPredjiNaSledeciZnak

	cmpb (%esi),	    %dl
	je promeniSlovo
	
	incl %edi
	jmp malo_ili_veliko_slovo

promeniSlovo:
	cmpl $1,            %ebx  # ako je malo slovo oduzmi 32, ako je veliko dodaj 32
	je oduzmi32
	jl dodaj32

oduzmi32:
	subb $32,          (%esi)
	incl 		    %eax	  # desila se izmena, uvecaj povratnu vrednost za 1
	jmp uvecajAdrese

dodaj32:
	addb $32, 	   (%esi)
	incl 		    %eax	  # desila se izmena, uvecaj povratnu vrednost za 1
	jmp uvecajAdrese
		
resetujAdresuPrvogPredjiNaSledeciZnak:
	movl  12(%ebp),      %edi   # prvi string postavi na pocetak
	incl    %esi			  # prelazimo na sledeci znak
	jmp krajStringa

uvecajAdrese:
	incl %esi
	jmp krajStringa

kraj:
	popl %ebx			# restauracija registara
	popl %edi
	popl %esi

	movl %ebp,		    %esp
	popl %ebp
	ret
