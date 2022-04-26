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

cat <<EOF | $CC -o $t/a.o -c -xc -
void foobar() {}
EOF

rm -f $t/b.a
ar rcs $t/b.a $t/a.o

cat <<EOF | $CC -o $t/c.o -c -xc -
int main() {}
EOF

$CC -B. -o $t/exe $t/c.o $t/b.a
! readelf --symbols $t/exe | grep -q foobar || false

$CC -B. -o $t/exe $t/c.o $t/b.a -Wl,-require-defined,foobar
readelf --symbols $t/exe | grep -q foobar

! $CC -B. -o $t/exe $t/c.o $t/b.a -Wl,-require-defined,xyz >& $t/log
grep -q 'undefined symbol: xyz' $t/log

echo OK
