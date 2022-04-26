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

if [ $MACHINE = x86_64 ]; then
  dialect=gnu
elif [ $MACHINE = aarch64 ]; then
  dialect=trad
else
  echo skipped
  exit
fi

cat <<EOF | $GCC -ftls-model=initial-exec -mtls-dialect=$dialect -fPIC -c -o $t/a.o -xc -
#include <stdio.h>

static _Thread_local int foo;
static _Thread_local int bar;

void set() {
  foo = 3;
  bar = 5;
}

void print() {
  printf("%d %d ", foo, bar);
}
EOF

$CC -B. -shared -o $t/b.so $t/a.o

cat <<EOF | $GCC -c -o $t/c.o -xc -
#include <stdio.h>

_Thread_local int baz;

void set();
void print();

int main() {
  baz = 7;
  print();
  set();
  print();
  printf("%d\n", baz);
}
EOF

$CC -B. -o $t/exe $t/b.so $t/c.o
$QEMU $t/exe | grep -q '^0 0 3 5 7$'

$CC -B. -o $t/exe $t/b.so $t/c.o -Wl,-no-relax
$QEMU $t/exe | grep -q '^0 0 3 5 7$'

echo OK
