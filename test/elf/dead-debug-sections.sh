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

which dwarfdump >& /dev/null || { echo skipped; exit; }

cat <<EOF | $CXX -c -o $t/a.o -g -xc++ -
#include <iostream>
struct Foo {
  Foo() { std::cout << "Hello world\n"; }
};
Foo x;
EOF

cat <<EOF | $CXX -c -o $t/b.o -g -xc++ -
#include <iostream>
struct Foo {
  Foo() { std::cout << "Hello world\n"; }
};
Foo y;
EOF

cat <<EOF | $CXX -o $t/c.o -c -xc++ -g -
int main() {}
EOF

$CXX -B. -o $t/exe $t/a.o $t/b.o $t/c.o -g
$QEMU $t/exe | grep -q 'Hello world'

dwarfdump $t/exe > /dev/null

echo OK
