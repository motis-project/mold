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

cat <<EOF | $CC -fPIC -o $t/a.o -c -xc -
extern int foo;
int bar = 5;
int baz() { return foo; }
EOF

$CC -B. -o $t/b.so -shared $t/a.o

cat <<EOF | $CC -o $t/c.o -c -xc -
int foo = 3;
EOF

rm -f $t/d.a
ar rcs $t/d.a $t/c.o

cat <<EOF | $CC -o $t/e.o -c -xc -
extern int bar;
int main() {
  return bar - 5;
}
EOF

$CC -B. -o $t/exe $t/b.so $t/d.a $t/e.o
readelf --dyn-syms $t/exe | grep -q ' foo$'

echo OK
