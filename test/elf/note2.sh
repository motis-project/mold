#!/bin/bash
export LC_ALL=C
set -e
CC="${CC:-cc}"
CXX="${CXX:-c++}"
GCC="${GCC:-gcc}"
GXX="${GXX:-g++}"
OBJDUMP="${OBJDUMP:-objdump}"
MACHINE="${MACHINE:-$(uname -m)}"
testname=$(basename "$0" .sh)
echo -n "Testing $testname ... "
cd "$(dirname "$0")"/../..
mold="$(pwd)/mold"
t=out/test/elf/$testname
mkdir -p $t

[ $MACHINE = x86_64 ] || { echo skipped; exit; }

cat <<EOF | $CC -o $t/a.o -c -x assembler -
.section .note.a, "a", @note
.p2align 3
.quad 42
EOF

cat <<EOF | $CC -o $t/b.o -c -x assembler -
.section .note.b, "a", @note
.p2align 2
.quad 42
EOF

cat <<EOF | $CC -o $t/c.o -c -x assembler -
.section .note.c, "a", @note
.p2align 3
.quad 42
EOF

cat <<EOF | $CC -o $t/d.o -c -xc -
int main() {}
EOF

"$mold" -static -o $t/exe $t/a.o $t/b.o $t/c.o $t/d.o

readelf --segments $t/exe > $t/log
fgrep -q '01     .note.b' $t/log
fgrep -q '02     .note.a .note.c' $t/log

echo OK
