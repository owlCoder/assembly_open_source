## Assembly projects and codes done in "Computer architecture"


<h3> File structure </h3>

```
UVOD U ALGORITME
│  
└─── T1234
│     01 Uvod u asembler
│     02 Tipovi podataka i indikator registri
│     03 Nizovi
│     04 Sistemski pozivi
|     05 Potprogrami
│     06 Priprema za T1234
|
└─── SOV
      07 Bit maske
      08 Interna konverzija

```

<hr>
<h3> Installation and run </h3>

1. You need to have <b>gcc</b> installed.
2. Open terminal and run `$ sudo apt update && sudo apt install gcc gdb build-essential gcc-multilib g++-multilib -y`
3. Locate section/folder which you want to run
4. When inside corresponding directory
5. Compile it with `$ gcc -g -m32 program_name.S`
6. Run it with `$ ./a.out`
7. Run test script (if script available) `$ ./testiraj.sh program_name.S`
