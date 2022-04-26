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

cat <<EOF | $CC -o $t/long-long-long-filename.o -c -xc -
int three() { return 3; }
EOF

cat <<EOF | $CC -o $t/b.o -c -xc -
int five() { return 5; }
EOF

cat <<EOF | $CC -o $t/c.o -c -xc -
#include <stdio.h>

int three();
int five();

int main() {
  printf("%d\n", three() + five());
}
EOF

rm -f $t/d.a
(cd $t; ar rcs d.a long-long-long-filename.o b.o)

$CC -B. -Wl,--trace -o $t/exe $t/c.o $t/d.a > $t/log

fgrep -q 'static-archive/d.a(long-long-long-filename.o)' $t/log
fgrep -q 'static-archive/d.a(b.o)' $t/log
fgrep -q static-archive/c.o $t/log

$QEMU $t/exe | grep -q '8'

echo OK
