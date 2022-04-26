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

cat <<EOF | $CC -c -o $t/a.o -xc -
#include <stdio.h>

void foo() {
  printf("foo\n");
}
EOF

cat <<EOF | $CC -c -o $t/b.o -xc -
#include <stdio.h>

void foo();

void __wrap_foo() {
  printf("wrap_foo\n");
}

int main() {
  foo();
}
EOF

cat <<EOF | $CC -c -o $t/c.o -xc -
#include <stdio.h>

void __real_foo();

int main() {
  __real_foo();
}
EOF

$CC -B. -o $t/exe $t/a.o $t/b.o
$QEMU $t/exe | grep -q '^foo$'

$CC -B. -o $t/exe $t/a.o $t/b.o -Wl,-wrap,foo
$QEMU $t/exe | grep -q '^wrap_foo$'

$CC -B. -o $t/exe $t/a.o $t/c.o -Wl,-wrap,foo
$QEMU $t/exe | grep -q '^foo$'

echo OK
