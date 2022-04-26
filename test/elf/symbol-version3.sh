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
void foo() {}
void foo2() {}
void foo3() {}

__asm__(".symver foo2, foo@TEST2");
__asm__(".symver foo3, foo@TEST3");
EOF

cat <<EOF > $t/b.version
TEST1 { global: foo; };
TEST2 {};
TEST3 {};
EOF

$CC -B. -o $t/c.so -shared $t/a.o -Wl,--version-script=$t/b.version
readelf -W --dyn-syms $t/c.so > $t/log

grep -q ' foo@@TEST1$' $t/log
grep -q ' foo@TEST2$' $t/log
grep -q ' foo@TEST3$' $t/log
! grep -q ' foo$' $t/log || false

echo OK
