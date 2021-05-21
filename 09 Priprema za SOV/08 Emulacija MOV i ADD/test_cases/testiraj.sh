#!/bin/bash
# testiranje rešenja zadatka sa unapred definisanim ulazima

#   Copyright 2019 Žarko Živanov
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.

# exit 0 - stiglo se do testova
# exit 1 - greška u kompajliranju
# exit 2 - nije nađen fajl

# provera instaliranih programa
missing=0
for prg in "expect" "sed" "diff" "grep"; do
    which $prg >/dev/null
    if [ $? -ne 0 ]; then
        missing=1
    fi
done
if [ $missing -ne 0 ]; then
\e[01;31m\n\nGreška u kompajliranju!\e[00m\n
    echo -e "\e[01;31mNedostaju paketi za rad skripta.\e[01;32m Instalirajte ih sa:\e[00m"
    echo -e "\e[01;34msudo apt install expect diffutils grep sed\e[00m\n"
    exit 1
fi

TESTS=(01 02 03 04 05 06 07 08 09 10 11 12)
EXITS=(0 1 1 1 4 0 0 0 0 1 2 3)
EMPTY="#"
QUIET=0
KEEP=0
SIG=""
OUT1=$(mktemp /tmp/testiraj.XXXXXXXXX)

TEST01=$(cat <<EOL
04
MOV \$1,%R1
MOV \$2,%R2
ADD \$1234,%R1
ADD \$2345,%R2
EOL
)

OUTP01=$(cat <<EOL
Unesite broj naredbi: 04
Unesite naredbe (naredba po liniji):
MOV \$1,%R1
MOV \$2,%R2
ADD \$1234,%R1
ADD \$2345,%R2
Vrednost u registru R1 nakon operacija: 1235
Vrednost u registru R2 nakon operacija: 2347
EOL
)

TEST02=$(cat <<EOL
08
EOL
)

OUTP02=$(cat <<EOL
Unesite broj naredbi: 08
Doslo je do greske u izvrsavanju programa!
EOL
)

TEST03=$(cat <<EOL
5
EOL
)

OUTP03=$(cat <<EOL
Unesite broj naredbi: 5
Doslo je do greske u izvrsavanju programa!
EOL
)

TEST04=$(cat <<EOL
#
EOL
)

OUTP04=$(cat <<EOL
Unesite broj naredbi: 
Doslo je do greske u izvrsavanju programa!
EOL
)

TEST05=$(cat <<EOL
013
EOL
)

OUTP05=$(cat <<EOL
Unesite broj naredbi: 013
Doslo je do greske u izvrsavanju programa!
EOL
)

TEST06=$(cat <<EOL
01
MOV \$1,%R1
EOL
)

OUTP06=$(cat <<EOL
Unesite broj naredbi: 01
Unesite naredbe (naredba po liniji):
MOV \$1,%R1
Vrednost u registru R1 nakon operacija: 1
Vrednost u registru R2 nakon operacija: 0
EOL
)

TEST07=$(cat <<EOL
05
MOV \$1,%R2
ADD \$12,%R2
ADD \$123,%R2
ADD \$1234,%R2
ADD \$12345,%R2
EOL
)

OUTP07=$(cat <<EOL
Unesite broj naredbi: 05
Unesite naredbe (naredba po liniji):
MOV \$1,%R2
ADD \$12,%R2
ADD \$123,%R2
ADD \$1234,%R2
ADD \$12345,%R2
Vrednost u registru R1 nakon operacija: 0
Vrednost u registru R2 nakon operacija: 13715
EOL
)

TEST08=$(cat <<EOL
012
ADD \$100,%R2
ADD \$101,%R2
ADD \$102,%R2
ADD \$103,%R2
ADD \$104,%R2
ADD \$105,%R2
ADD \$106,%R2
ADD \$107,%R2
ADD \$108,%R2
ADD \$109,%R2
EOL
)

OUTP08=$(cat <<EOL
Unesite broj naredbi: 012
Unesite naredbe (naredba po liniji):
ADD \$100,%R2
ADD \$101,%R2
ADD \$102,%R2
ADD \$103,%R2
ADD \$104,%R2
ADD \$105,%R2
ADD \$106,%R2
ADD \$107,%R2
ADD \$108,%R2
ADD \$109,%R2
Vrednost u registru R1 nakon operacija: 0
Vrednost u registru R2 nakon operacija: 1045
EOL
)

TEST09=$(cat <<EOL
00
EOL
)

OUTP09=$(cat <<EOL
Unesite broj naredbi: 00
Unesite naredbe (naredba po liniji):
Vrednost u registru R1 nakon operacija: 0
Vrednost u registru R2 nakon operacija: 0
EOL
)

TEST10=$(cat <<EOL
04
MOV \$1f,%R1
EOL
)

OUTP10=$(cat <<EOL
Unesite broj naredbi: 04
Unesite naredbe (naredba po liniji):
MOV \$1f,%R1
Doslo je do greske u izvrsavanju programa!
EOL
)

TEST11=$(cat <<EOL
03
MOV \$0,%R1
MOV \$4294967296,%R1
EOL
)

OUTP11=$(cat <<EOL
Unesite broj naredbi: 03
Unesite naredbe (naredba po liniji):
MOV \$0,%R1
MOV \$4294967296,%R1
Doslo je do greske u izvrsavanju programa!
EOL
)

TEST12=$(cat <<EOL
02
MOV \$4294967295,%R1
ADD \$1,%R1
EOL
)

OUTP12=$(cat <<EOL
Unesite broj naredbi: 02
Unesite naredbe (naredba po liniji):
MOV \$4294967295,%R1
ADD \$1,%R1
Doslo je do greske u izvrsavanju programa!
EOL
)

function echoq {
    if [ $QUIET -eq 0 ]; then
        echo "$@"
    fi
}

if [ "$1" == "-q" ]; then
    QUIET=1
    shift
fi
if [ "$1" \> "00" ] && [ "$1" \< "99" ]; then
    TESTS=($1)
    KEEP=1
    shift
fi

if [ "$1" != "" ] && [ -f "$1" ]; then
    echoq -e "\n\e[01;32mKompajliranje...\e[00m"
    grep ".text" $1 1>/dev/null 2>/dev/null && (grep ".globl" $1 1>/dev/null 2>/dev/null || grep ".global" $1 1>/dev/null 2>/dev/null)
    if [ $? -ne 0 ]; then
        echoq -e "\e[01;31m\n\nNije asemblerski program!\e[00m\n"
        exit 1
    fi
    GLAVNI=""
    if [ $(grep -c "main:" $1) == "0" ]; then
        if [ -f glavni.c ]; then
            GLAVNI=glavni.c
        else
            echoq -e "\e[01;31m\n\nNije nađen glavni.c!\e[00m\n"
        fi
    fi
    #nalaženje fajlova od kojih se sastoji rešenje
    zfiles=$(grep -E "^[[:space:]]*#[[:space:]]*fajlovi[[:space:]]*:" $1)
    if [ "$zfiles" != "" ]; then
        zfiles=${zfiles#*:}
    else
        zfiles="$@"
    fi
    gcc -g -m32 -o zad $GLAVNI $zfiles 1>$OUT1 2>&1
    if [ $? -ne 0 ]; then
        echoq -e "\e[01;31m\n\nGreška u kompajliranju!\e[00m\n"
        if [ $QUIET -eq 0 ]; then
            cat $OUT1
        else
            echo "0"
        fi
        rm -f $OUT1
        exit 1
    fi
else
    if [ "$1" != "" ]; then
        echoq -e "\e[01;31mFajl \"$1\" nije nađen!\e[00m"
    fi
    lasttest=${TESTS[${#TESTS[@]}-1]}
    echoq -e "\n\e[01;32mUpotreba:\e[00m"
    echoq -e "\e[01;34m$0 [-q] [TT] \e[01;32mime_programa.S\e[00m"
    echoq -e "Opcija -q ispisuje samo procenat uspešnih testova"
    echoq -e "Opcija TT (01<=TT<=$lasttest) pokreće samo zadati test i ispisuje diff izlaz za njega\n"
    if [ $QUIET -ne 0 ]; then
        echo "0"
    fi
    exit 2
fi

cat >./run <<EOL
spawn -noecho [lindex \$argv 0]
for {set i 1} {\$i < [llength \$argv]} {incr i 1} {
    sleep 0.5
    send -- "[lindex \$argv \$i]"
    send "\r"
}
expect eof
catch wait reason
set sig [lindex \$reason 5]
if {\$sig == ""} {
    set code [lindex \$reason 3]
} elseif {\$sig == "SIGFPE"} {
    set code [expr 128+8]
} elseif {\$sig == "SIGSEGV"} {
    set code [expr 128+11]
} elseif {\$sig == "SIGINT"} {
    set code [expr 128+2]
} elseif {\$sig == "SIGILL"} {
    set code [expr 128+4]
} elseif {\$sig == "SIGKILL"} {
    set code [expr 128+9]
} else {
    set code [expr 128+1]
}
exit \$code
EOL

passed=0
total=0
nn=0
for n in "${TESTS[@]}"; do
    echoq -e "\n\n\e[01;34m-----------------------------------"
    echoq "TEST $n"
    echoq -e "-----------------------------------\e[00m"
    tcode=${EXITS[$nn]}
    cor="OUTP$n"
    eval cor="\$$cor"
    echo -e "$cor" > out2
    echoq -e "\e[01;32mTAČAN IZLAZ:\e[00m"
    if [ $QUIET -eq 0 ]; then
        cat out2
    fi
    echoq -e "\nIzlazni kod: \e[01;32m$tcode\e[00m"
    tst="TEST$n"
    eval tst=\$$tst
    oldIFS="$IFS"; IFS=$'\n'
    tst=($tst)
    IFS="$oldIFS"
    lin=${#tst[*]}
    for ((l=0; l<lin; l++ )); do
        if [ "${tst[$l]}" == "$EMPTY" ]; then
            eval tst[$l]=""
        fi
    done
    ok=1
    expect run ./zad "${tst[@]}" 1>$OUT1 2>&1
    code=$?
    sed -i -e '$a\' $OUT1
    sed -i 's/\x0//g' $OUT1
    sed -i 's/\xd//g' $OUT1
    #sed -i '/^$/d' $OUT1
    sed -i 's/\x0//g' $OUT1
    for ((i=1; i<32; i++)); do
        if [ $i -ne 9 ] && [ $i -ne 10 ] && [ $i -ne 13 ]; then
            hex=$(printf '%X' $i)
            sed -i "s/\x$hex/[0x$hex]/g" $OUT1
        fi
    done
    for ((i=128; i<256; i++)); do
        hex=$(printf '%X' $i)
        sed -i "s/\x$hex/[0x$hex]/g" $OUT1
    done
    echoq -e "\e[01;34m\nVAŠ IZLAZ:\e[00m"
    if [ $QUIET -eq 0 ]; then
        cat $OUT1
    fi
    diff -q -a -w -B $OUT1 out2 1>/dev/null 2>/dev/null
    if [ $? -eq 0 ]; then
        echoq -e "\e[01;32m\nIzlazi se poklapaju.\e[00m"
    else
        echoq -e "\e[01;31m\nIzlazi se NE poklapaju!\e[00m"
        ok=0
    fi
    if [ $code -gt 127 ]; then
        code=$((code-128))
        sig=""
        if [ $code -eq 8 ]; then sig=" (SIGFPE - Floating point exception)"; fi
        if [ $code -eq 11 ]; then sig=" (SIGSEGV - Invalid memory segment access)"; fi
        echoq -e "\n\e[01;31mProgram je vratio Fatal error signal $code$sig!\e[00m"
        ok=0
        SIG="(zbog \e[01;31mexception\e[00m-a) "
    elif [ $code -eq $tcode ]; then
        echoq -e "\nIzlazni kod: \e[01;32m$code\e[00m"
    else
        echoq -e "\n\e[01;31mPogrešan izlazni kod: $code\e[00m"
        ok=0
    fi
    total=$((total + 1))
    if [ $ok -eq 1 ]; then
        passed=$((passed + 1))
    fi
    nn=$((nn+1))
done
percent=$((passed * 100 / total))
if [ "$SIG" != "" ]; then
    percent=0
fi
echoq -e "\n\n\e[01;34m-----------------------------------"
echoq "Ukupan rezultat"
echoq -e "-----------------------------------\e[00m"
if [ $passed -eq $total ]; then
    col="\e[01;32m"
else
    col="\e[01;31m"
fi
echoq -e "Prošlo je ${col}${passed}\e[00m od \e[01;32m${total}\e[00m automatskih testova, odnosno ${SIG}${col}${percent}%.\e[00m\n"
if [ $KEEP -eq 0 ]; then
    rm -f zad run $OUT1 out2 1>/dev/null 2>/dev/null
else
    rm -f run 1>/dev/null 2>/dev/null
    #diff -u -a -w $OUT1 out2
fi
if [ $QUIET -ne 0 ]; then
    echo $percent
fi
if [ "$SIG" != "" ]; then
    exit 3
else
    exit 0
fi


