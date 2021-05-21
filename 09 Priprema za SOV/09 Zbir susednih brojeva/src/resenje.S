.section .data

inMessage: .ascii "Ulazna sekvenca: "
inMessageLen = .-inMessage
outMessage: .ascii "Izlazna sekvenca: "
outMessageLen = .-outMessage
errMessage: .ascii "Greska!"
errMessageLen = .-errMessage

# Nizovi brojeva
inArr: .fill 50, 4, 0
outArr: .fill 50, 4, 0

# Ulazni i izlazni tekst
inTxt: .fill 100,1,0
outTxt: .fill 100,1,0
inTxtEnd: .long 0
maxLengthTxt = 100
maxLengthArray = 50
inArr_minLength = 2

# duzina ucitanog niza i kod greske
len: .long 0
err: .long 0

.section .text
.globl main
main:
	movl $4, %eax
	movl $1, %ebx
	movl $inMessage, %ecx
	movl $inMessageLen, %edx
	int $0x80

	movl $3, %eax
	movl $0, %ebx
	movl $inTxt, %ecx
	movl $maxLengthTxt, %edx
	int $0x80
	movl %eax, inTxtEnd 

	# provera da li su sve cifre i razmaci
	pushl $inTxt
	call checkDigits
	addl $4, %esp
	testl %eax, %eax
	jz allDigits
	movl $1, err
	jmp error

allDigits:
	movl $inTxt, %esi
	movl $0, %ecx

parseNextNumber:
	# pronadje se poetak broja
	pushl %esi
	call firstDigit
	addl $4, %esp
	cmpl $-1, %eax
	je parsingFinished
	addl %eax, %esi

	# pronadje se kraj broja
	pushl %esi
	call firstSpace
	addl $4, %esp
	movl %esi, %edi
	addl %eax, %edi
	
	# char2int za pocetak i kraj broja
	pushl %edi
	pushl %esi
	call char2int
	addl $8, %esp
	cmpl $-1, %eax
	jne newNum
	movl $2, err
	jmp error
newNum:
	# dodavanje novog broja u ulazni niz brojeva
	movl %eax, inArr(,%ecx,4)
	incl %ecx
	movl %edi, %esi
	jmp parseNextNumber
	

parsingFinished:
	# greska ako imamo manje cifara nego sto je neophodno
	cmpl $inArr_minLength, %ecx
	jae transformArrays
	movl $3, err
	jmp error

transformArrays:
	# pravljenje izlasnog niza od ulaznog
	pushl %ecx
	pushl $outArr
	pushl $inArr
	call f
	addl $12, %esp
	cmpl $-1, %eax
	jne transformationFinished
	movl $4, err
	jmp error

transformationFinished:
	# cuvanje duzine izlaznog niza
	movl %eax, len
	movl $0, %esi

	movl $4, %eax
	movl $1, %ebx
	movl $outMessage, %ecx
	movl $outMessageLen, %edx
	int $0x80
	
printEachNumber:
	# konverzija i-tog elem ulaznog niza u string
	pushl $outTxt
	movl outArr(,%esi,4), %eax
	pushl %eax
	call int2char
	addl $8, %esp

	# ispis stringa
	movl %eax, %edx
	movl $4, %eax
	movl $1, %ebx
	movl $outTxt, %ecx
	int $0x80

	# ako nije poslenji broj, sledi mu space
	incl %esi
	cmpl len, %esi
	jnb end

	movl $' ', outTxt
	movl $4, %eax
	movl $1, %ebx
	movl $outTxt, %ecx
	movl $1, %edx
	int $0x80
	jmp printEachNumber
	
end:
	movl $1, %eax
	movl $0, %ebx
	int $0x80
error:
	movl $4, %eax
	movl $1, %ebx
	movl $errMessage, %ecx
	movl $errMessageLen, %edx
	int $0x80
	movl $1, %eax
	movl err, %ebx
	int $0x80

# int firstSpace(char* c)	
# return value - potreban broj pozicija za pomeranje da se dodje do prve cifre
firstSpace:
	pushl %ebp
	movl %esp, %ebp
localFirstSpace:
	# lokalne promenjive
pushFirstSpace:
	pushl %ebx
	pushl %ecx
	pushl %edx
	pushl %edi
	pushl %esi
doFirstSpace:
	# inicijalizacija brojaca na 0
	movl 8(%ebp), %ebx
	movl $0, %eax
isSpace:
	# provera jel ovo space, ako nije, proveri naredni
	cmpb $0, (%ebx)
	je popFirstSpace
	cmpb $' ', (%ebx)
	je popFirstSpace
	cmpb $10, (%ebx)
	je popFirstSpace
	incl %eax
	incl %ebx
	jmp isSpace
	
		
popFirstSpace:
	popl %esi
	popl %edi
	popl %edx
	popl %ecx
	popl %ebx
	movl %ebp, %esp
	popl %ebp
	ret


# int firstDigit(char* c)
# return value - potreban broj pozicija za pomeranje da se dodje do prvog praznog karaktera
firstDigit:
	pushl %ebp
	movl %esp, %ebp
localFirstDigit:
	# lokalne promenjive
pushFirstDigit:
	pushl %ebx
	pushl %ecx
	pushl %edx
	pushl %edi
	pushl %esi
doFirstDigit:
	movl 8(%ebp), %ebx
	movl $0, %eax
isDigit:
	# inicijalizacija
	cmpb $0, (%ebx)
	je noMoreDigits
	cmpb $10, (%ebx)
	je noMoreDigits

	cmpb $'0', (%ebx)
	jb nextCharDigit
	cmpb $'9', (%ebx)
	ja nextCharDigit
	jmp popFirstDigit
nextCharDigit:	
	# jel ovo cifra, ako nije, idi dalje
	incl %ebx
	incl %eax			
	jmp isDigit

noMoreDigits:
	movl $-1, %eax	
		
popFirstDigit:
	popl %esi
	popl %edi
	popl %edx
	popl %ecx
	popl %ebx
	movl %ebp, %esp
	popl %ebp
	ret



# int checkDigits(char* c)
# provera da su sve space-ovi i cifre
checkDigits:
	pushl %ebp
	movl %esp, %ebp
localCheckDigits:
	# lokalne promenjive
pushCheckDigits:
	pushl %ebx
	pushl %ecx
	pushl %edx
	pushl %edi
	pushl %esi
doCheckDigits:
	# pozicioniranje na pocetak stringa
	movl 8(%ebp), %ebx
	movl $0, %eax

currentCheckDigits:	
	# ako sam dosao do kraja, sve je ok
	cmpb $0, (%ebx)
	je popCheckDigits
	cmpb $10, (%ebx)
	je popCheckDigits
	
	# space -> proveri dalje
	cmpb $' ', (%ebx)
	je nextCheckDigits
	
	# nesto sto nije cifra, ni space ni kraj -> greska
	cmpb $'0', (%ebx)
	jb errorCheckDigits
	cmpb $'9', (%ebx)
	ja errorCheckDigits
nextCheckDigits:
	incl %ebx
	jmp currentCheckDigits

nextCheck:	
	incl %ebx
	jmp isDigit


errorCheckDigits:
	movl $1, %eax	
popCheckDigits:
	popl %esi
	popl %edi
	popl %edx
	popl %ecx
	popl %ebx
	movl %ebp, %esp
	popl %ebp
	ret


# int char2int(char* support, char* lead)
# konverzija u broj onog izmedju ova 2 pokazivaca
char2int:
	pushl %ebp
	movl %esp, %ebp
localChar2int:
	# lokalne promenjive
pushChar2int:
	pushl %ebx
	pushl %ecx
	pushl %edx
	pushl %edi
	pushl %esi
doChar2int:
	movl $10, %ebx # osnova brojnog sistema
	movl 8(%ebp), %esi # pocetak stringa
	movl 12(%ebp), %edi # kraj stringa
	decl %edi
	movl $0, %eax
	movl $0, %edx	
	movl $0, %ecx


mulChar_char2int:
	# pomnozi, ako moze
	mull %ebx
	testl %edx, %edx
	jnz errorChar2int
	testl %eax, %eax
	js errorChar2int

addChar_char2int:	
	# dodaj novu najnizu cifru
	movb (%esi), %cl
	subb $'0', %cl
	
	addl %ecx, %eax
	jo errorChar2int
	
nextChar_Char2int:
	# ako nisam na kraju, ubaciti dodatnu cifru
	cmpl %esi, %edi
	je popChar2int
		
	incl %esi
	jmp mulChar_char2int


errorChar2int:
	movl $-1, %eax	
popChar2int:
	popl %esi
	popl %edi
	popl %edx
	popl %ecx
	popl %ebx
	movl %ebp, %esp
	popl %ebp
	ret



# int int2char(int x, char* txt)
# konverzija broja u string, povratna vrednost je duzina broja karakterno prikazanog
int2char:
	pushl %ebp
	movl %esp, %ebp
localInt2char:
	# lokalne promenjive
pushInt2char:
	pushl %ebx
	pushl %ecx
	pushl %edx
	pushl %edi
	pushl %esi
doInt2char:
	movl $10, %ebx # osnova brojnog sistema
	movl $0, %edx		# edx:eax - sta delimo
	movl 8(%ebp), %eax

	movl 12(%ebp), %esi

nextChar_int2char:
	# izvlacenje najnize cifre
	divl %ebx
	addb $'0', %dl
	movb %dl, (%esi)
	incl %esi
	movl $0, %edx
	
	# ako nije kraj, nastavi ubacifati nize cifre
	testl %eax, %eax
	jz rotate_int2char
	jmp nextChar_int2char

rotate_int2char:
	# inicijalizacije
	movl %esi, %edi
	movl 12(%ebp), %esi
	movl %edi, %eax
	subl %esi, %eax # eax = broj karaktera
	decl %edi

rotateNextChar_int2char:
	# rotiranje cifara
	cmpl %edi, %esi
	jae popInt2char

	movb (%esi), %dh
	movb (%edi), %dl
	movb %dl, (%esi)
	movb %dh, (%edi)
	incl %esi
	decl %edi
	jmp rotateNextChar_int2char

popInt2char:
	popl %esi
	popl %edi
	popl %edx
	popl %ecx
	popl %ebx
	movl %ebp, %esp
	popl %ebp
	ret



# int f(int* inArr, int* outArr, int inLeng)
# dobijanje izlaznog niza od ulaznog
# zapis svaki put kada se naidje na element koji je >= svim prethodnim
f:
	pushl %ebp
	movl %esp, %ebp
localF:
	# lokalne promenjive
pushF:
	pushl %ebx
	pushl %ecx
	pushl %edx
	pushl %edi
	pushl %esi
doF:

	movl $0, %eax # iterator kroz outArr
	movl 8(%ebp), %esi # baza za inArr
	movl 12(%ebp), %edi # baza za outArr
	movl $1, %ecx # iterator kroz inArr

		
loop_F:
	# kada smo na kraju inArr
	cmpl 16(%ebp), %ecx
	jae popF

	# ako su razlicite parnosti, preskoci ih
	movl -4(%esi, %ecx,4), %ebx # prethodni elem
	movl (%esi, %ecx, 4), %edx # naredni elem
	xorl %ebx, %edx
	testl $1, %edx
	jz next_F

	# ako pri sumiranju bude overflow, preskoci ih
	movl -4(%esi, %ecx,4), %ebx # prethodni elem
	movl (%esi, %ecx, 4), %edx # naredni elem
	addl %ebx, %edx
	jo next_F
	
	# sume koje zadovoljavaju oba uslova ispisati
	movl %edx, (%edi, %eax, 4)
	incl %eax		
	
next_F:
	incl %ecx
	jmp loop_F			

errorF:
	movl $-1, %eax	
popF:
	cmpl $0, %eax
	jne finish_F
	movl $-1, %eax

finish_F:
	popl %esi
	popl %edi
	popl %edx
	popl %ecx
	popl %ebx
	movl %ebp, %esp
	popl %ebp
	ret

	
