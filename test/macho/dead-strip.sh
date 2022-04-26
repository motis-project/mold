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
mold="$(pwd)/ld64.mold"
t=out/test/macho/$testname
mkdir -p $t

cat <<EOF | $CC -o $t/a.o -c -xc -
#include <stdio.h>

char msg1[] = "Hello world";
char msg2[] = "Howdy world";

void hello() {
  printf("%s\n", msg1);
}

void howdy() {
  printf("%s\n", msg2);
}

int main() {
  hello();
}
EOF

clang -fuse-ld="$mold" -o $t/exe $t/a.o -Wl,-dead_strip
$QEMU $t/exe | grep -q 'Hello world'
otool -tVj $t/exe > $t/log
grep -q 'hello:' $t/log
! grep -q 'howdy:' $t/log || false

echo OK
