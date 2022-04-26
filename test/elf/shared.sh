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

cat <<'EOF' | $CC -fPIC -c -o $t/a.o -xc -
void fn2();
void fn1() { fn2(); }
void fn3() {}
EOF

$CC -B. -shared -o $t/b.so $t/a.o

readelf --dyn-syms $t/b.so > $t/log

grep -q '00000000     0 NOTYPE  GLOBAL DEFAULT  UND fn2' $t/log
grep -Eq 'FUNC    GLOBAL DEFAULT .* fn1' $t/log

cat <<EOF | $CC -fPIC -c -o $t/c.o -xc -
#include <stdio.h>

int fn1();

void fn2() {
  printf("hello\n");
}

int main() {
  fn1();
  return 0;
}
EOF

$CC -B. -o $t/exe $t/c.o $t/b.so
$QEMU $t/exe | grep -q hello
! readelf --symbols $t/exe | grep -q fn3 || false

echo OK
